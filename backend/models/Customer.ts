import mongoose, { Document, Schema } from 'mongoose'

export interface ICustomer extends Document {
  userId: mongoose.Types.ObjectId
  name: string
  phone?: string
  notes?: string
  deletedAt?: Date
  createdAt: Date
  updatedAt: Date
}

const customerSchema = new Schema<ICustomer>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    name: { type: String, required: true, trim: true },
    phone: { type: String, trim: true },
    notes: { type: String, trim: true },
    deletedAt: { type: Date },
  },
  { timestamps: true }
)

customerSchema.index({ userId: 1 })

export default mongoose.models.Customer ||
  mongoose.model<ICustomer>('Customer', customerSchema)
