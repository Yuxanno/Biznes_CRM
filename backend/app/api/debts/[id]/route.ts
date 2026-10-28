import { NextRequest } from 'next/server';
import { connectDB } from '@/lib/mongodb';
import { requireAuth } from '@/lib/auth';
import Debt from '@/models/Debt';
import { successResponse, errorResponse } from '@/lib/response';
import { z } from 'zod';
import mongoose from 'mongoose';

const updateSchema = z.object({
  personName: z.string().min(1).optional(),
  phone: z.string().optional(),
  amount: z.number().positive().optional(),
  paidAmount: z.number().min(0).optional(),
  description: z.string().optional(),
  dueDate: z.string().optional(),
  status: z.enum(['unpaid', 'partial', 'paid']).optional(),
  comment: z.string().optional(),
});

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);
    const body = await req.json();
    const parsed = updateSchema.safeParse(body);
    if (!parsed.success) return errorResponse(parsed.error.errors[0].message);

    const updateData: Record<string, unknown> = { ...parsed.data };
    if (parsed.data.dueDate) updateData.dueDate = new Date(parsed.data.dueDate);

    // Auto-compute status
    if (parsed.data.paidAmount !== undefined && parsed.data.amount !== undefined) {
      if (parsed.data.paidAmount === 0) updateData.status = 'unpaid';
      else if (parsed.data.paidAmount >= parsed.data.amount) updateData.status = 'paid';
      else updateData.status = 'partial';
    }

    const debt = await Debt.findOneAndUpdate(
      { _id: params.id, userId, deletedAt: { $exists: false } },
      updateData,
      { new: true }
    );
    if (!debt) return errorResponse('Debt not found', 404);
    return successResponse(debt);
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to update debt', 500);
  }
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);
    const debt = await Debt.findOneAndUpdate(
      { _id: params.id, userId, deletedAt: { $exists: false } },
      { deletedAt: new Date() },
      { new: true }
    );
    if (!debt) return errorResponse('Debt not found', 404);
    return successResponse({ message: 'Debt deleted' });
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to delete debt', 500);
  }
}
