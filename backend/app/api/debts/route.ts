import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { requireAuth } from '@/lib/auth'
import Debt from '@/models/Debt'
import { successResponse, errorResponse } from '@/lib/response'
import { z } from 'zod'
import mongoose from 'mongoose'

const debtSchema = z.object({
  type: z.enum(['owe', 'owed']),
  personName: z.string().min(1, 'Person name is required'),
  phone: z.string().optional(),
  amount: z.number().positive('Amount must be positive'),
  paidAmount: z.number().min(0).optional(),
  description: z.string().optional(),
  date: z.string().optional(),
  dueDate: z.string().optional(),
  comment: z.string().optional(),
  customerId: z.string().optional(),
})

export async function GET(req: NextRequest) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)
    const { searchParams } = new URL(req.url)

    const type = searchParams.get('type')
    const status = searchParams.get('status')
    const search = searchParams.get('search')

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const query: any = { userId, deletedAt: { $exists: false } }
    if (type) query.type = type
    if (status) query.status = status
    if (search) {
      query.$or = [
        { personName: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ]
    }

    const debts = await Debt.find(query)
      .sort({ createdAt: -1 })
      .populate('customerId', 'name phone')
      .lean()

    // Summary stats
    const summary = await Debt.aggregate([
      { $match: { userId, deletedAt: { $exists: false } } },
      {
        $group: {
          _id: '$type',
          totalAmount: { $sum: '$amount' },
          totalPaid: { $sum: '$paidAmount' },
          count: { $sum: 1 },
          unpaidCount: {
            $sum: { $cond: [{ $ne: ['$status', 'paid'] }, 1, 0] },
          },
        },
      },
    ])

    const owedSummary = summary.find((s) => s._id === 'owed') || {
      totalAmount: 0,
      totalPaid: 0,
      count: 0,
      unpaidCount: 0,
    }
    const oweSummary = summary.find((s) => s._id === 'owe') || {
      totalAmount: 0,
      totalPaid: 0,
      count: 0,
      unpaidCount: 0,
    }

    return successResponse({
      debts,
      summary: {
        owedToMe: {
          total: owedSummary.totalAmount,
          paid: owedSummary.totalPaid,
          remaining: owedSummary.totalAmount - owedSummary.totalPaid,
          count: owedSummary.count,
        },
        iOwe: {
          total: oweSummary.totalAmount,
          paid: oweSummary.totalPaid,
          remaining: oweSummary.totalAmount - oweSummary.totalPaid,
          count: oweSummary.count,
        },
      },
    })
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to fetch debts', 500)
  }
}

export async function POST(req: NextRequest) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)
    const body = await req.json()
    const parsed = debtSchema.safeParse(body)
    if (!parsed.success) return errorResponse(parsed.error.errors[0].message)

    const paidAmount = parsed.data.paidAmount || 0
    let status: 'unpaid' | 'partial' | 'paid' = 'unpaid'
    if (paidAmount >= parsed.data.amount) status = 'paid'
    else if (paidAmount > 0) status = 'partial'

    const debt = await Debt.create({
      userId,
      type: parsed.data.type,
      personName: parsed.data.personName,
      phone: parsed.data.phone,
      amount: parsed.data.amount,
      paidAmount,
      description: parsed.data.description,
      date: parsed.data.date ? new Date(parsed.data.date) : new Date(),
      dueDate: parsed.data.dueDate ? new Date(parsed.data.dueDate) : undefined,
      comment: parsed.data.comment,
      customerId: parsed.data.customerId || undefined,
      status,
    })

    return successResponse(debt, 201)
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to create debt', 500)
  }
}
