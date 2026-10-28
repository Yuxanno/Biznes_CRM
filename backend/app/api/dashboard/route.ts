import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { requireAuth } from '@/lib/auth'
import Transaction from '@/models/Transaction'
import Order from '@/models/Order'
import Debt from '@/models/Debt'
import BusinessPeriod from '@/models/BusinessPeriod'
import { successResponse, errorResponse } from '@/lib/response'
import mongoose from 'mongoose'

export async function GET(req: NextRequest) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)

    const { searchParams } = new URL(req.url)
    const periodIdParam = searchParams.get('periodId')

    let period
    if (periodIdParam) {
      period = await BusinessPeriod.findOne({ _id: periodIdParam, userId })
    } else {
      period = await BusinessPeriod.findOne({ userId, status: 'active' })
    }
    if (!period) return errorResponse('No active period found', 404)

    const periodId = period._id as mongoose.Types.ObjectId

    // Transaction stats for current period
    const transactionStats = await Transaction.aggregate([
      { $match: { userId, periodId, deletedAt: { $exists: false } } },
      { $group: { _id: '$type', total: { $sum: '$amount' }, count: { $sum: 1 } } },
    ])

    let totalIncome = 0
    let totalExpense = 0
    transactionStats.forEach((s) => {
      if (s._id === 'income') totalIncome = s.total
      if (s._id === 'expense') totalExpense = s.total
    })
    const netProfit = totalIncome - totalExpense

    // Active orders count
    const activeOrdersCount = await Order.countDocuments({
      userId,
      status: { $in: ['new', 'in_progress', 'waiting'] },
      deletedAt: { $exists: false },
    })

    // Debt stats (all periods, unpaid only)
    const debtStats = await Debt.aggregate([
      { $match: { userId, deletedAt: { $exists: false }, status: { $ne: 'paid' } } },
      {
        $group: {
          _id: '$type',
          total: { $sum: { $subtract: ['$amount', '$paidAmount'] } },
        },
      },
    ])

    let owedToMe = 0
    let iOwe = 0
    debtStats.forEach((s) => {
      if (s._id === 'owed') owedToMe = s.total
      if (s._id === 'owe') iOwe = s.total
    })

    // Recent transactions
    const recentTransactions = await Transaction.find({
      userId,
      periodId,
      deletedAt: { $exists: false },
    })
      .sort({ date: -1 })
      .limit(5)
      .lean()

    // Recent orders
    const recentOrders = await Order.find({ userId, deletedAt: { $exists: false } })
      .sort({ createdAt: -1 })
      .limit(5)
      .lean()

    // Chart data — last 6 months grouped by month
    const sixMonthsAgo = new Date()
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 5)
    sixMonthsAgo.setDate(1)
    sixMonthsAgo.setHours(0, 0, 0, 0)

    const chartData = await Transaction.aggregate([
      {
        $match: {
          userId,
          periodId,
          deletedAt: { $exists: false },
          date: { $gte: sixMonthsAgo },
        },
      },
      {
        $group: {
          _id: { year: { $year: '$date' }, month: { $month: '$date' }, type: '$type' },
          total: { $sum: '$amount' },
        },
      },
      { $sort: { '_id.year': 1, '_id.month': 1 } },
    ])

    // Upcoming deadlines (notifications)
    const now = new Date()
    const threeDaysFromNow = new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000)

    const upcomingOrders = await Order.find({
      userId,
      status: { $in: ['new', 'in_progress', 'waiting'] },
      deadline: { $lte: threeDaysFromNow },
      deletedAt: { $exists: false },
    })
      .sort({ deadline: 1 })
      .limit(5)
      .lean()

    return successResponse({
      period,
      balance: netProfit,
      totalIncome,
      totalExpense,
      netProfit,
      activeOrdersCount,
      owedToMe,
      iOwe,
      recentTransactions,
      recentOrders,
      chartData,
      upcomingOrders,
    })
  } catch (error) {
    console.error('Dashboard error:', error)
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to load dashboard', 500)
  }
}
