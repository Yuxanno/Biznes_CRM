import mongoose, { Document, Schema } from 'mongoose'

export interface IBusinessPeriod extends Document {
  userId: mongoose.Types.ObjectId
  name: string
  startDate: Date
  endDate?: Date
  status: 'active' | 'closed'
  createdAt: Date
  updatedAt: Date
}

const businessPeriodSchema = new Schema<IBusinessPeriod>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    name: { type: String, required: true, trim: true },
    startDate: { type: Date, required: true, default: Date.now },
    endDate: { type: Date },
    status: { type: String, enum: ['active', 'closed'], default: 'active' },
  },
  { timestamps: true }
)

businessPeriodSchema.index({ userId: 1, status: 1 })

export default mongoose.models.BusinessPeriod ||
  mongoose.model<IBusinessPeriod>('BusinessPeriod', businessPeriodSchema)
