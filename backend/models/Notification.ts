import mongoose, { Document, Schema } from 'mongoose'

export interface INotification extends Document {
  userId: mongoose.Types.ObjectId
  type: 'order_deadline' | 'debt_due' | 'debt_overdue' | 'general'
  title: string
  message: string
  read: boolean
  relatedId?: string
  relatedType?: 'order' | 'debt'
  createdAt: Date
}

const notificationSchema = new Schema<INotification>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    type: {
      type: String,
      enum: ['order_deadline', 'debt_due', 'debt_overdue', 'general'],
      required: true,
    },
    title: { type: String, required: true },
    message: { type: String, required: true },
    read: { type: Boolean, default: false },
    relatedId: { type: String },
    relatedType: { type: String, enum: ['order', 'debt'] },
  },
  { timestamps: true }
)

notificationSchema.index({ userId: 1, read: 1 })

export default mongoose.models.Notification ||
  mongoose.model<INotification>('Notification', notificationSchema)
