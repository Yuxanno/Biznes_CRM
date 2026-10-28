import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { requireAuth } from '@/lib/auth'
import BusinessPeriod from '@/models/BusinessPeriod'
import Transaction from '@/models/Transaction'
import { successResponse, errorResponse } from '@/lib/response'
import { z } from 'zod'
import mongoose from 'mongoose'

const periodSchema = z.object({
  name: z.string().min(1, 'Period name is required').max(100),
})

export async function GET(req: NextRequest) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)

    const periods = await BusinessPeriod.find({ userId }).sort({ createdAt: -1 }).lean()

    // Attach transaction stats to each period
    const periodsWithStats = await Promise.all(
      periods.map(async (period) => {
        const stats = await Transaction.aggregate([
          {
            $match: {
              userId,
              periodId: period._id,
              deletedAt: { $exists: false },
            },
          },
          { $group: { _id: '$type', total: { $sum: '$amount' }, count: { $sum: 1 } } },
        ])
        let income = 0
        let expense = 0
        stats.forEach((s) => {
          if (s._id === 'income') income = s.total
          if (s._id === 'expense') expense = s.total
        })
        return { ...period, income, expense, profit: income - expense }
      })
    )

    return successResponse(periodsWithStats)
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to fetch periods', 500)
  }
}

export async function POST(req: NextRequest) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)
    const body = await req.json()
    const parsed = periodSchema.safeParse(body)
    if (!parsed.success) return errorResponse(parsed.error.errors[0].message)

    // Close all currently active periods
    await BusinessPeriod.updateMany(
      { userId, status: 'active' },
      { status: 'closed', endDate: new Date() }
    )

    // Create new active period (balance starts at 0)
    const newPeriod = await BusinessPeriod.create({
      userId,
      name: parsed.data.name,
      startDate: new Date(),
      status: 'active',
    })

    return successResponse(newPeriod, 201)
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to create period', 500)
  }
}
