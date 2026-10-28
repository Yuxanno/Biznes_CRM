import mongoose, { Document, Schema } from 'mongoose'

export interface IDebt extends Document {
  userId: mongoose.Types.ObjectId
  type: 'owe' | 'owed'
  personName: string
  phone?: string
  amount: number
  paidAmount: number
  description?: string
  date: Date
  dueDate?: Date
  status: 'unpaid' | 'partial' | 'paid'
  comment?: string
  customerId?: mongoose.Types.ObjectId
  deletedAt?: Date
  createdAt: Date
  updatedAt: Date
}

const debtSchema = new Schema<IDebt>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    type: { type: String, enum: ['owe', 'owed'], required: true },
    personName: { type: String, required: true, trim: true },
    phone: { type: String, trim: true },
    amount: { type: Number, required: true, min: 0 },
    paidAmount: { type: Number, default: 0, min: 0 },
    description: { type: String, trim: true },
    date: { type: Date, default: Date.now },
    dueDate: { type: Date },
    status: { type: String, enum: ['unpaid', 'partial', 'paid'], default: 'unpaid' },
    comment: { type: String, trim: true },
    customerId: { type: Schema.Types.ObjectId, ref: 'Customer' },
    deletedAt: { type: Date },
  },
  { timestamps: true }
)

debtSchema.index({ userId: 1, type: 1 })
debtSchema.index({ userId: 1, status: 1 })

export default mongoose.models.Debt || mongoose.model<IDebt>('Debt', debtSchema)
