import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { requireAuth } from '@/lib/auth'
import Transaction from '@/models/Transaction'
import BusinessPeriod from '@/models/BusinessPeriod'
import { successResponse, errorResponse, paginatedResponse } from '@/lib/response'
import { z } from 'zod'
import mongoose from 'mongoose'

const transactionSchema = z.object({
  type: z.enum(['income', 'expense']),
  amount: z.number().positive('Amount must be positive'),
  category: z.string().min(1, 'Category is required'),
  description: z.string().min(1, 'Description is required'),
  date: z.string(),
  comment: z.string().optional(),
  periodId: z.string().optional(),
})

export async function GET(req: NextRequest) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)
    const { searchParams } = new URL(req.url)

    const page = Math.max(1, parseInt(searchParams.get('page') || '1'))
    const limit = Math.min(100, parseInt(searchParams.get('limit') || '20'))
    const type = searchParams.get('type')
    const category = searchParams.get('category')
    const periodId = searchParams.get('periodId')
    const search = searchParams.get('search')
    const startDate = searchParams.get('startDate')
    const endDate = searchParams.get('endDate')

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const query: any = { userId, deletedAt: { $exists: false } }
    if (type) query.type = type
    if (category) query.category = category
    if (periodId) query.periodId = new mongoose.Types.ObjectId(periodId)
    if (search) query.description = { $regex: search, $options: 'i' }
    if (startDate || endDate) {
      query.date = {}
      if (startDate) query.date.$gte = new Date(startDate)
      if (endDate) query.date.$lte = new Date(endDate)
    }

    const total = await Transaction.countDocuments(query)
    const transactions = await Transaction.find(query)
      .sort({ date: -1, createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .populate('periodId', 'name status')
      .lean()

    return paginatedResponse(transactions, total, page, limit)
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to fetch transactions', 500)
  }
}

export async function POST(req: NextRequest) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)
    const body = await req.json()
    const parsed = transactionSchema.safeParse(body)
    if (!parsed.success) return errorResponse(parsed.error.errors[0].message)

    let periodId: mongoose.Types.ObjectId
    if (parsed.data.periodId) {
      const period = await BusinessPeriod.findOne({ _id: parsed.data.periodId, userId })
      if (!period) return errorResponse('Period not found', 404)
      periodId = period._id as mongoose.Types.ObjectId
    } else {
      const activePeriod = await BusinessPeriod.findOne({ userId, status: 'active' })
      if (!activePeriod) return errorResponse('No active period found', 404)
      periodId = activePeriod._id as mongoose.Types.ObjectId
    }

    const transaction = await Transaction.create({
      userId,
      periodId,
      type: parsed.data.type,
      amount: parsed.data.amount,
      category: parsed.data.category,
      description: parsed.data.description,
      date: new Date(parsed.data.date),
      comment: parsed.data.comment,
    })

    return successResponse(transaction, 201)
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to create transaction', 500)
  }
}
