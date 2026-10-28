import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import User from '@/models/User'
import BusinessPeriod from '@/models/BusinessPeriod'
import { signToken } from '@/lib/auth'
import { successResponse, errorResponse } from '@/lib/response'
import { z } from 'zod'

const loginSchema = z.object({
  username: z.string().min(1, 'Username is required'),
  password: z.string().min(1, 'Password is required'),
})

export async function POST(req: NextRequest) {
  try {
    await connectDB()
    const body = await req.json()
    const parsed = loginSchema.safeParse(body)
    if (!parsed.success) {
      return errorResponse('Username and password are required')
    }

    const { username, password } = parsed.data
    const user = await User.findOne({ username: username.toLowerCase() })
    if (!user || !(await user.comparePassword(password))) {
      return errorResponse('Invalid username or password', 401)
    }

    const currentPeriod = await BusinessPeriod.findOne({ userId: user._id, status: 'active' })
    const token = signToken({ userId: user._id.toString(), username: user.username })

    return successResponse({
      token,
      user: { _id: user._id, username: user.username },
      currentPeriod,
    })
  } catch (error) {
    console.error('Login error:', error)
    return errorResponse('Login failed. Please try again.', 500)
  }
}
