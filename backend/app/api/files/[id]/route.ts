import { NextRequest, NextResponse } from 'next/server'
import { connectDB, getGridFSBucket } from '@/lib/mongodb'
import { requireAuth } from '@/lib/auth'
import { errorResponse } from '@/lib/response'
import mongoose from 'mongoose'

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    await connectDB()
    const authUser = requireAuth(req)

    const bucket = await getGridFSBucket()
    let fileId: mongoose.Types.ObjectId
    try {
      fileId = new mongoose.Types.ObjectId(params.id)
    } catch {
      return errorResponse('Invalid file ID', 400)
    }

    const files = await bucket.find({ _id: fileId }).toArray()
    if (!files.length) return errorResponse('File not found', 404)

    const file = files[0]

    // Verify ownership
    if (file.metadata?.userId !== authUser.userId) {
      return errorResponse('Access denied', 403)
    }

    const chunks: Buffer[] = []
    const downloadStream = bucket.openDownloadStream(fileId)

    const fileBuffer = await new Promise<Buffer>((resolve, reject) => {
      downloadStream.on('data', (chunk: Buffer) => chunks.push(chunk))
      downloadStream.on('end', () => resolve(Buffer.concat(chunks)))
      downloadStream.on('error', reject)
    })

    return new NextResponse(fileBuffer, {
      headers: {
        'Content-Type': file.metadata?.mimeType || 'application/octet-stream',
        'Content-Disposition': `inline; filename="${file.filename}"`,
        'Content-Length': fileBuffer.length.toString(),
        'Cache-Control': 'private, max-age=3600',
      },
    })
  } catch (error) {
    if ((error as Error).message === 'Unauthorized') return errorResponse('Unauthorized', 401)
    console.error('File serve error:', error)
    return errorResponse('Failed to retrieve file', 500)
  }
}
