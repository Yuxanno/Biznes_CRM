import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { requireAuth } from '@/lib/auth'
import Transaction from '@/models/Transaction'
import { successResponse, errorResponse } from '@/lib/response'
import { z } from 'zod'
import mongoose from 'mongoose'

const updateSchema = z.object({
  type: z.enum(['income', 'expense']).optional(),
  amount: z.number().positive().optional(),
  category: z.string().min(1).optional(),
  description: z.string().min(1).optional(),
  date: z.string().optional(),
  comment: z.string().optional(),
})

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)

    const transaction = await Transaction.findOne({
      _id: params.id,
      userId,
      deletedAt: { $exists: false },
    }).populate('periodId', 'name status')

    if (!transaction) return errorResponse('Transaction not found', 404)
    return successResponse(transaction)
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to fetch transaction', 500)
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
    if (parsed.data.date) updateData.date = new Date(parsed.data.date)

    const transaction = await Transaction.findOneAndUpdate(
      { _id: params.id, userId, deletedAt: { $exists: false } },
      updateData,
      { new: true }
    )
    if (!transaction) return errorResponse('Transaction not found', 404)
    return successResponse(transaction)
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to update transaction', 500)
  }
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)

    const transaction = await Transaction.findOneAndUpdate(
      { _id: params.id, userId, deletedAt: { $exists: false } },
      { deletedAt: new Date() },
      { new: true }
    )
    if (!transaction) return errorResponse('Transaction not found', 404)
    return successResponse({ message: 'Transaction deleted successfully' })
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to delete transaction', 500)
  }
}
