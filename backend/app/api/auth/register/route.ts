import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import User from '@/models/User'
import BusinessPeriod from '@/models/BusinessPeriod'
import Category from '@/models/Category'
import { signToken } from '@/lib/auth'
import { successResponse, errorResponse } from '@/lib/response'
import { z } from 'zod'

const registerSchema = z.object({
  username: z
    .string()
    .min(3, 'Username must be at least 3 characters')
    .max(50)
    .regex(/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers, and underscores'),
  password: z.string().min(6, 'Password must be at least 6 characters').max(100),
  // confirmPassword is optional — validation is handled on the client side
  confirmPassword: z.string().optional(),
})

const DEFAULT_INCOME_CATEGORIES = ['Order', 'Sale', 'Service', 'Other']
const DEFAULT_EXPENSE_CATEGORIES = [
  'Materials',
  'Transport',
  'Tools',
  'Salary',
  'Advertising',
  'Other',
]

export async function POST(req: NextRequest) {
  try {
    await connectDB()
    const body = await req.json()
    const parsed = registerSchema.safeParse(body)
    if (!parsed.success) {
      return errorResponse(parsed.error.errors[0].message)
    }

    const { username, password } = parsed.data
    const existing = await User.findOne({ username: username.toLowerCase() })
    if (existing) {
      return errorResponse('Username already taken')
    }

    const user = await User.create({ username: username.toLowerCase(), password })

    const period = await BusinessPeriod.create({
      userId: user._id,
      name: 'Business Start',
      startDate: new Date(),
      status: 'active',
    })

    const categories = [
      ...DEFAULT_INCOME_CATEGORIES.map((name) => ({ userId: user._id, type: 'income', name })),
      ...DEFAULT_EXPENSE_CATEGORIES.map((name) => ({ userId: user._id, type: 'expense', name })),
    ]
    await Category.insertMany(categories)

    const token = signToken({ userId: user._id.toString(), username: user.username })

    return successResponse(
      {
        token,
        user: { _id: user._id, username: user.username },
        currentPeriod: period,
      },
      201
    )
  } catch (error) {
    console.error('Register error:', error)
    return errorResponse('Registration failed. Please try again.', 500)
  }
}
