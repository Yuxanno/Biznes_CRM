import mongoose, { Document, Schema } from 'mongoose'

export interface ICategory extends Document {
  userId: mongoose.Types.ObjectId
  type: 'income' | 'expense'
  name: string
  createdAt: Date
}

const categorySchema = new Schema<ICategory>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    type: { type: String, enum: ['income', 'expense'], required: true },
    name: { type: String, required: true, trim: true },
  },
  { timestamps: true }
)

categorySchema.index({ userId: 1, type: 1 })

export default mongoose.models.Category ||
  mongoose.model<ICategory>('Category', categorySchema)
