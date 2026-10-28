import { NextRequest } from 'next/server';
import { connectDB } from '@/lib/mongodb';
import { requireAuth } from '@/lib/auth';
import Category from '@/models/Category';
import { successResponse, errorResponse } from '@/lib/response';
import { z } from 'zod';
import mongoose from 'mongoose';

const categorySchema = z.object({
  type: z.enum(['income', 'expense']),
  name: z.string().min(1),
});

export async function GET(req: NextRequest) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);
    const { searchParams } = new URL(req.url);
    const type = searchParams.get('type');

    const query: Record<string, unknown> = { userId };
    if (type) query.type = type;

    const categories = await Category.find(query).sort({ name: 1 }).lean();
    return successResponse(categories);
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to fetch categories', 500);
  }
}

export async function POST(req: NextRequest) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);
    const body = await req.json();
    const parsed = categorySchema.safeParse(body);
    if (!parsed.success) return errorResponse(parsed.error.errors[0].message);

    const exists = await Category.findOne({ userId, type: parsed.data.type, name: parsed.data.name });
    if (exists) return errorResponse('Category already exists');

    const category = await Category.create({ userId, ...parsed.data });
    return successResponse(category, 201);
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to create category', 500);
  }
}
