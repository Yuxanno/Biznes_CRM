import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { requireAuth } from '@/lib/auth'
import Order from '@/models/Order'
import { successResponse, errorResponse } from '@/lib/response'
import { z } from 'zod'
import mongoose from 'mongoose'

const updateSchema = z.object({
  title: z.string().min(1).optional(),
  clientName: z.string().min(1).optional(),
  clientPhone: z.string().optional(),
  description: z.string().optional(),
  amount: z.number().min(0).optional(),
  status: z.enum(['new', 'in_progress', 'waiting', 'completed', 'cancelled']).optional(),
  deadline: z.string().optional(),
  comment: z.string().optional(),
  customerId: z.string().optional(),
})

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)

    const order = await Order.findOne({
      _id: params.id,
      userId,
      deletedAt: { $exists: false },
    }).populate('customerId', 'name phone')

    if (!order) return errorResponse('Order not found', 404)
    return successResponse(order)
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to fetch order', 500)
  }
}

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)
    const body = await req.json()
    const parsed = updateSchema.safeParse(body)
    if (!parsed.success) return errorResponse(parsed.error.errors[0].message)

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const updateData: any = { ...parsed.data }
    if (parsed.data.deadline) updateData.deadline = new Date(parsed.data.deadline)

    const order = await Order.findOneAndUpdate(
      { _id: params.id, userId, deletedAt: { $exists: false } },
      updateData,
      { new: true }
    )
    if (!order) return errorResponse('Order not found', 404)
    return successResponse(order)
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to update order', 500)
  }
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)

    const order = await Order.findOneAndUpdate(
      { _id: params.id, userId, deletedAt: { $exists: false } },
      { deletedAt: new Date() },
      { new: true }
    )
    if (!order) return errorResponse('Order not found', 404)
    return successResponse({ message: 'Order deleted successfully' })
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to delete order', 500)
  }
}
