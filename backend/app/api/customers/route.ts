import { NextRequest } from 'next/server';
import { connectDB } from '@/lib/mongodb';
import { requireAuth } from '@/lib/auth';
import Customer from '@/models/Customer';
import { successResponse, errorResponse, paginatedResponse } from '@/lib/response';
import { z } from 'zod';
import mongoose from 'mongoose';

const customerSchema = z.object({
  name: z.string().min(1),
  phone: z.string().optional(),
  notes: z.string().optional(),
});

export async function GET(req: NextRequest) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);
    const { searchParams } = new URL(req.url);
    const search = searchParams.get('search');
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '20');

    const query: Record<string, unknown> = { userId, deletedAt: { $exists: false } };
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
      ];
    }

    const total = await Customer.countDocuments(query);
    const customers = await Customer.find(query)
      .sort({ name: 1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .lean();

    return paginatedResponse(customers, total, page, limit);
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to fetch customers', 500);
  }
}

export async function POST(req: NextRequest) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);
    const body = await req.json();
    const parsed = customerSchema.safeParse(body);
    if (!parsed.success) return errorResponse(parsed.error.errors[0].message);

    const customer = await Customer.create({ userId, ...parsed.data });
    return successResponse(customer, 201);
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to create customer', 500);
  }
}
