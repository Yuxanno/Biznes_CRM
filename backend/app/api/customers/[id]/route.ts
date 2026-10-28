import { NextRequest } from 'next/server';
import { connectDB } from '@/lib/mongodb';
import { requireAuth } from '@/lib/auth';
import Customer from '@/models/Customer';
import Order from '@/models/Order';
import Debt from '@/models/Debt';
import { successResponse, errorResponse } from '@/lib/response';
import { z } from 'zod';
import mongoose from 'mongoose';

const updateSchema = z.object({
  name: z.string().min(1).optional(),
  phone: z.string().optional(),
  notes: z.string().optional(),
});

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);
    const customer = await Customer.findOne({ _id: params.id, userId, deletedAt: { $exists: false } });
    if (!customer) return errorResponse('Customer not found', 404);

    const orders = await Order.find({ userId, customerId: params.id, deletedAt: { $exists: false } })
      .sort({ createdAt: -1 }).limit(10).lean();
    const debts = await Debt.find({ userId, customerId: params.id, deletedAt: { $exists: false } })
      .sort({ createdAt: -1 }).limit(10).lean();

    return successResponse({ customer, orders, debts });
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to fetch customer', 500);
  }
}

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);
    const body = await req.json();
    const parsed = updateSchema.safeParse(body);
    if (!parsed.success) return errorResponse(parsed.error.errors[0].message);

    const customer = await Customer.findOneAndUpdate(
      { _id: params.id, userId, deletedAt: { $exists: false } },
      parsed.data,
      { new: true }
    );
    if (!customer) return errorResponse('Customer not found', 404);
    return successResponse(customer);
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to update customer', 500);
  }
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);
    const customer = await Customer.findOneAndUpdate(
      { _id: params.id, userId, deletedAt: { $exists: false } },
      { deletedAt: new Date() },
      { new: true }
    );
    if (!customer) return errorResponse('Customer not found', 404);
    return successResponse({ message: 'Customer deleted' });
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to delete customer', 500);
  }
}
