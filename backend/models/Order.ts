import mongoose, { Document, Schema } from 'mongoose'

export interface IOrder extends Document {
  userId: mongoose.Types.ObjectId
  periodId: mongoose.Types.ObjectId
  customerId?: mongoose.Types.ObjectId
  title: string
  clientName: string
  clientPhone?: string
  description?: string
  amount: number
  status: 'new' | 'in_progress' | 'waiting' | 'completed' | 'cancelled'
  createdDate: Date
  deadline?: Date
  comment?: string
  photos: string[]
  audioId?: string
  deletedAt?: Date
  createdAt: Date
  updatedAt: Date
}

const orderSchema = new Schema<IOrder>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    periodId: { type: Schema.Types.ObjectId, ref: 'BusinessPeriod', required: true },
    customerId: { type: Schema.Types.ObjectId, ref: 'Customer' },
    title: { type: String, required: true, trim: true },
    clientName: { type: String, required: true, trim: true },
    clientPhone: { type: String, trim: true },
    description: { type: String, trim: true },
    amount: { type: Number, required: true, min: 0 },
    status: {
      type: String,
      enum: ['new', 'in_progress', 'waiting', 'completed', 'cancelled'],
      default: 'new',
    },
    createdDate: { type: Date, default: Date.now },
    deadline: { type: Date },
    comment: { type: String, trim: true },
    photos: [{ type: String }],
    audioId: { type: String },
    deletedAt: { type: Date },
  },
  { timestamps: true }
)

orderSchema.index({ userId: 1, periodId: 1 })
orderSchema.index({ userId: 1, status: 1 })

export default mongoose.models.Order || mongoose.model<IOrder>('Order', orderSchema)
