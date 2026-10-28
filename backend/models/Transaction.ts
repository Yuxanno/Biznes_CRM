import mongoose, { Document, Schema } from 'mongoose'

export interface ITransaction extends Document {
  userId: mongoose.Types.ObjectId
  periodId: mongoose.Types.ObjectId
  type: 'income' | 'expense'
  amount: number
  category: string
  description: string
  date: Date
  comment?: string
  deletedAt?: Date
  createdAt: Date
  updatedAt: Date
}

const transactionSchema = new Schema<ITransaction>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    periodId: { type: Schema.Types.ObjectId, ref: 'BusinessPeriod', required: true },
    type: { type: String, enum: ['income', 'expense'], required: true },
    amount: { type: Number, required: true, min: 0 },
    category: { type: String, required: true, trim: true },
    description: { type: String, required: true, trim: true },
    date: { type: Date, required: true, default: Date.now },
    comment: { type: String, trim: true },
    deletedAt: { type: Date },
  },
  { timestamps: true }
)

transactionSchema.index({ userId: 1, periodId: 1 })
transactionSchema.index({ userId: 1, type: 1 })
transactionSchema.index({ userId: 1, date: -1 })

export default mongoose.models.Transaction ||
  mongoose.model<ITransaction>('Transaction', transactionSchema)
