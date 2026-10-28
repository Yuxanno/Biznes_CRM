import { NextRequest, NextResponse } from 'next/server';
import { connectDB } from '@/lib/mongodb';
import { requireAuth } from '@/lib/auth';
import Notification from '@/models/Notification';
import Order from '@/models/Order';
import Debt from '@/models/Debt';
import { successResponse, errorResponse } from '@/lib/response';
import mongoose from 'mongoose';

export async function GET(req: NextRequest) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);

    // Generate notifications dynamically
    const now = new Date();
    const twoDaysFromNow = new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000);

    // Check upcoming order deadlines
    const upcomingOrders = await Order.find({
      userId,
      status: { $in: ['new', 'in_progress', 'waiting'] },
      deadline: { $lte: twoDaysFromNow, $gte: now },
      deletedAt: { $exists: false },
    }).lean();

    // Check overdue orders
    const overdueOrders = await Order.find({
      userId,
      status: { $in: ['new', 'in_progress', 'waiting'] },
      deadline: { $lt: now },
      deletedAt: { $exists: false },
    }).lean();

    // Check upcoming debt dues
    const upcomingDebts = await Debt.find({
      userId,
      status: { $ne: 'paid' },
      dueDate: { $lte: twoDaysFromNow, $gte: now },
      deletedAt: { $exists: false },
    }).lean();

    // Check overdue debts
    const overdueDebts = await Debt.find({
      userId,
      status: { $ne: 'paid' },
      dueDate: { $lt: now },
      deletedAt: { $exists: false },
    }).lean();

    const notifications = [
      ...upcomingOrders.map(o => ({
        type: 'order_deadline' as const,
        title: 'Upcoming Deadline',
        message: `Order "${o.title}" is due soon`,
        relatedId: o._id?.toString(),
        relatedType: 'order' as const,
        read: false,
        createdAt: new Date(),
      })),
      ...overdueOrders.map(o => ({
        type: 'order_deadline' as const,
        title: 'Overdue Order',
        message: `Order "${o.title}" is overdue`,
        relatedId: o._id?.toString(),
        relatedType: 'order' as const,
        read: false,
        createdAt: new Date(),
      })),
      ...upcomingDebts.map(d => ({
        type: 'debt_due' as const,
        title: 'Debt Due Soon',
        message: `Payment to/from ${d.personName} is due soon`,
        relatedId: d._id?.toString(),
        relatedType: 'debt' as const,
        read: false,
        createdAt: new Date(),
      })),
      ...overdueDebts.map(d => ({
        type: 'debt_overdue' as const,
        title: 'Overdue Debt',
        message: `Payment to/from ${d.personName} is overdue`,
        relatedId: d._id?.toString(),
        relatedType: 'debt' as const,
        read: false,
        createdAt: new Date(),
      })),
    ];

    return successResponse({ notifications, count: notifications.length });
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to fetch notifications', 500);
  }
}

// PATCH /api/notifications — mark all as read
export async function PATCH(req: NextRequest) {
  try {
    await connectDB();
    const authUser = requireAuth(req);
    const userId = new mongoose.Types.ObjectId(authUser.userId);

    await Notification.updateMany({ userId, read: false }, { $set: { read: true } });
    return successResponse({ message: 'All notifications marked as read' });
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401);
    return errorResponse('Failed to update notifications', 500);
  }
}
