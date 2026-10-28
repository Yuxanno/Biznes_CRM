import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { requireAuth } from '@/lib/auth'
import Order from '@/models/Order'
import BusinessPeriod from '@/models/BusinessPeriod'
import { successResponse, errorResponse, paginatedResponse } from '@/lib/response'
import { z } from 'zod'
import mongoose from 'mongoose'

const orderSchema = z.object({
  title: z.string().min(1, 'Title is required'),
  clientName: z.string().min(1, 'Client name is required'),
  clientPhone: z.string().optional(),
  description: z.string().optional(),
  amount: z.number().min(0, 'Amount must be non-negative'),
  status: z.enum(['new', 'in_progress', 'waiting', 'completed', 'cancelled']).optional(),
  createdDate: z.string().optional(),
  deadline: z.string().optional(),
  comment: z.string().optional(),
  customerId: z.string().optional(),
})

export async function GET(req: NextRequest) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)
    const { searchParams } = new URL(req.url)

    const page = Math.max(1, parseInt(searchParams.get('page') || '1'))
    const limit = Math.min(100, parseInt(searchParams.get('limit') || '20'))
    const status = searchParams.get('status')
    const search = searchParams.get('search')
    const periodId = searchParams.get('periodId')
    const startDate = searchParams.get('startDate')
    const endDate = searchParams.get('endDate')

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const query: any = { userId, deletedAt: { $exists: false } }
    if (status) query.status = status
    if (periodId) query.periodId = new mongoose.Types.ObjectId(periodId)
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { clientName: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ]
    }
    if (startDate || endDate) {
      query.createdDate = {}
      if (startDate) query.createdDate.$gte = new Date(startDate)
      if (endDate) query.createdDate.$lte = new Date(endDate)
    }

    const total = await Order.countDocuments(query)
    const orders = await Order.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .populate('customerId', 'name phone')
      .lean()

    return paginatedResponse(orders, total, page, limit)
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to fetch orders', 500)
  }
}

export async function POST(req: NextRequest) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)
    const body = await req.json()
    const parsed = orderSchema.safeParse(body)
    if (!parsed.success) return errorResponse(parsed.error.errors[0].message)

    const activePeriod = await BusinessPeriod.findOne({ userId, status: 'active' })
    if (!activePeriod) return errorResponse('No active period found', 404)

    const order = await Order.create({
      userId,
      periodId: activePeriod._id,
      title: parsed.data.title,
      clientName: parsed.data.clientName,
      clientPhone: parsed.data.clientPhone,
      description: parsed.data.description,
      amount: parsed.data.amount,
      status: parsed.data.status || 'new',
      createdDate: parsed.data.createdDate ? new Date(parsed.data.createdDate) : new Date(),
      deadline: parsed.data.deadline ? new Date(parsed.data.deadline) : undefined,
      comment: parsed.data.comment,
      customerId: parsed.data.customerId || undefined,
      photos: [],
    })

    return successResponse(order, 201)
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to create order', 500)
  }
}
