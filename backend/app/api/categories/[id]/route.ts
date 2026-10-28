import { NextRequest } from 'next/server';
import { connectDB } from '@/lib/mongodb';
import { requireAuth } from '@/lib/auth';
import Category from '@/models/Category';
import { successResponse, errorResponse } from '@/lib/response';
import mongoose from 'mongoose';
import { z } from 'zod';

const updateSchema = z.object({
  name: z.string().min(1, 'Name is required').optional(),
  type: z.enum(['income', 'expense']).optional(),
});

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);

    const body = await req.json();
    const parsed = updateSchema.safeParse(body);
    if (!parsed.success) return errorResponse(parsed.error.errors[0].message);

    // Check for duplicate name+type
    if (parsed.data.name || parsed.data.type) {
      const existing = await Category.findOne({
        userId,
        _id: { $ne: params.id },
        name: parsed.data.name,
        type: parsed.data.type,
      });
      if (existing) return errorResponse('Category with this name already exists', 409);
    }

    const category = await Category.findOneAndUpdate(
      { _id: params.id, userId },
      { $set: parsed.data },
      { new: true }
    );
    if (!category) return errorResponse('Category not found', 404);
    return successResponse(category);
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to update category', 500);
  }
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);
    const category = await Category.findOneAndDelete({ _id: params.id, userId });
    if (!category) return errorResponse('Category not found', 404);
    return successResponse({ message: 'Category deleted' });
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to delete category', 500);
  }
}
