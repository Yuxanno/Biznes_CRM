import { NextRequest } from 'next/server'
import { connectDB, getGridFSBucket } from '@/lib/mongodb'
import { requireAuth } from '@/lib/auth'
import Order from '@/models/Order'
import { successResponse, errorResponse } from '@/lib/response'
import mongoose from 'mongoose'
import sharp from 'sharp'
import { Readable } from 'stream'

const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB
const TARGET_MAX_SIZE = 7 * 1024 * 1024 // 7MB after compression

export async function POST(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)

    const order = await Order.findOne({ _id: params.id, userId, deletedAt: { $exists: false } })
    if (!order) return errorResponse('Order not found', 404)

    const formData = await req.formData()
    const file = formData.get('photo') as File | null
    if (!file) return errorResponse('No photo file provided')

    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
    if (!allowedTypes.includes(file.type)) {
      return errorResponse('Invalid file type. Allowed formats: JPG, JPEG, PNG, WebP')
    }

    let buffer = Buffer.from(await file.arrayBuffer())
    const originalSize = buffer.length

    // Auto-compress if over 10MB
    if (buffer.length > MAX_FILE_SIZE) {
      let quality = 85
      let compressed = buffer
      while (compressed.length > TARGET_MAX_SIZE && quality >= 20) {
        compressed = await sharp(buffer)
          .resize({ width: 1920, height: 1920, fit: 'inside', withoutEnlargement: true })
          .jpeg({ quality })
          .toBuffer()
        quality -= 10
      }
      buffer = compressed
    }

    const bucket = await getGridFSBucket()
    const filename = `photo_${Date.now()}_${file.name.replace(/[^a-zA-Z0-9._-]/g, '_')}`

    let uploadedFileId = ''

    await new Promise<void>((resolve, reject) => {
      const uploadStream = bucket.openUploadStream(filename, {
        metadata: {
          userId: authUser.userId,
          orderId: params.id,
          originalName: file.name,
          mimeType: 'image/jpeg',
          originalSize,
          compressedSize: buffer.length,
        },
      })
      uploadedFileId = uploadStream.id.toString()
      const readable = Readable.from(buffer)
      readable.pipe(uploadStream)
      uploadStream.on('finish', resolve)
      uploadStream.on('error', reject)
    })

    order.photos.push(uploadedFileId)
    await order.save()

    return successResponse(
      {
        fileId: uploadedFileId,
        originalSize,
        compressedSize: buffer.length,
        wasCompressed: originalSize > MAX_FILE_SIZE,
        message: 'Photo uploaded successfully',
      },
      201
    )
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    console.error('Photo upload error:', error)
    return errorResponse('Failed to upload photo', 500)
  }
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)

    const { searchParams } = new URL(req.url)
    const fileId = searchParams.get('fileId')
    if (!fileId) return errorResponse('fileId query parameter is required')

    const order = await Order.findOne({ _id: params.id, userId, deletedAt: { $exists: false } })
    if (!order) return errorResponse('Order not found', 404)

    if (!order.photos.includes(fileId)) {
      return errorResponse('Photo not found in this order', 404)
    }

    try {
      const bucket = await getGridFSBucket()
      await bucket.delete(new mongoose.Types.ObjectId(fileId))
    } catch {
      // File may already be deleted from GridFS
    }

    order.photos = order.photos.filter((p) => p !== fileId)
    await order.save()

    return successResponse({ message: 'Photo deleted successfully' })
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to delete photo', 500)
  }
}
