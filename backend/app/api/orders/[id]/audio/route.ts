import { NextRequest } from 'next/server'
import { connectDB, getGridFSBucket } from '@/lib/mongodb'
import { requireAuth } from '@/lib/auth'
import Order from '@/models/Order'
import { successResponse, errorResponse } from '@/lib/response'
import mongoose from 'mongoose'
import { Readable } from 'stream'

const MAX_AUDIO_SIZE = 10 * 1024 * 1024 // 10MB

export async function POST(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)

    const order = await Order.findOne({ _id: params.id, userId, deletedAt: { $exists: false } })
    if (!order) return errorResponse('Order not found', 404)

    const formData = await req.formData()
    const file = formData.get('audio') as File | null
    if (!file) return errorResponse('No audio file provided')

    const allowedTypes = [
      'audio/aac',
      'audio/mp4',
      'audio/mpeg',
      'audio/wav',
      'audio/x-m4a',
      'audio/m4a',
      'audio/webm',
    ]
    if (!allowedTypes.includes(file.type)) {
      return errorResponse('Invalid audio format. Supported: AAC, M4A, MP3, WAV, WebM')
    }

    const buffer = Buffer.from(await file.arrayBuffer())

    if (buffer.length > MAX_AUDIO_SIZE) {
      return errorResponse(
        `Audio file is too large (${(buffer.length / 1024 / 1024).toFixed(1)}MB). Maximum allowed size is ${MAX_AUDIO_SIZE / 1024 / 1024}MB.`
      )
    }

    // Delete old audio if exists
    if (order.audioId) {
      try {
        const bucket = await getGridFSBucket()
        await bucket.delete(new mongoose.Types.ObjectId(order.audioId))
      } catch {
        // ignore if already deleted
      }
    }

    const bucket = await getGridFSBucket()
    const filename = `audio_${Date.now()}_${file.name.replace(/[^a-zA-Z0-9._-]/g, '_')}`

    let audioId = ''

    await new Promise<void>((resolve, reject) => {
      const uploadStream = bucket.openUploadStream(filename, {
        metadata: {
          userId: authUser.userId,
          orderId: params.id,
          originalName: file.name,
          mimeType: file.type,
          size: buffer.length,
        },
      })
      audioId = uploadStream.id.toString()
      const readable = Readable.from(buffer)
      readable.pipe(uploadStream)
      uploadStream.on('finish', resolve)
      uploadStream.on('error', reject)
    })

    order.audioId = audioId
    await order.save()

    return successResponse(
      {
        audioId,
        size: buffer.length,
        message: 'Audio uploaded successfully',
      },
      201
    )
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    console.error('Audio upload error:', error)
    return errorResponse('Failed to upload audio', 500)
  }
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB()
    const authUser = requireAuth(req)
    const userId = new mongoose.Types.ObjectId(authUser.userId)

    const order = await Order.findOne({ _id: params.id, userId, deletedAt: { $exists: false } })
    if (!order) return errorResponse('Order not found', 404)
    if (!order.audioId) return errorResponse('No audio found for this order', 404)

    try {
      const bucket = await getGridFSBucket()
      await bucket.delete(new mongoose.Types.ObjectId(order.audioId))
    } catch {
      // ignore
    }

    order.audioId = undefined
    await order.save()

    return successResponse({ message: 'Audio deleted successfully' })
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    return errorResponse('Failed to delete audio', 500)
  }
}
