import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { requireAuth } from '@/lib/auth'
import BusinessPeriod from '@/models/BusinessPeriod'
import Transaction from '@/models/Transaction'
import { successResponse, errorResponse } from '@/lib/response'
import mongoose from 'mongoose'

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)

    const period = await BusinessPeriod.findOne({ _id: params.id, userId }).lean()
    if (!period) return errorResponse('Period not found', 404)

    const stats = await Transaction.aggregate([
      {
        $match: {
          userId,
          periodId: new mongoose.Types.ObjectId(params.id),
          deletedAt: { $exists: false },
        },
      },
      {
        $group: {
          _id: '$type',
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
    ])

    let income = 0
    let expense = 0
    let incomeCount = 0
    let expenseCount = 0

    stats.forEach((s) => {
      if (s._id === 'income') {
        income = s.total
        incomeCount = s.count
      }
      if (s._id === 'expense') {
        expense = s.total
        expenseCount = s.count
      }
    })

    // Category breakdown
    const categoryBreakdown = await Transaction.aggregate([
      {
        $match: {
          userId,
          periodId: new mongoose.Types.ObjectId(params.id),
          deletedAt: { $exists: false },
        },
      },
      {
        $group: {
          _id: { type: '$type', category: '$category' },
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { total: -1 } },
    ])

    return successResponse({
      ...period,
      income,
      expense,
      profit: income - expense,
      incomeCount,
      expenseCount,
      categoryBreakdown,
    })
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to fetch period', 500)
  }
}
