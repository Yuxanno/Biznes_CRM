import mongoose from 'mongoose'
import { MongoClient, GridFSBucket } from 'mongodb'

const MONGODB_URI = process.env.MONGODB_URI!

if (!MONGODB_URI) {
  throw new Error('Please define the MONGODB_URI environment variable')
}

declare global {
  // eslint-disable-next-line no-var
  var _mongooseCache: { conn: typeof mongoose | null; promise: Promise<typeof mongoose> | null }
  // eslint-disable-next-line no-var
  var _mongoClient: MongoClient | null
  // eslint-disable-next-line no-var
  var _gridFSBucket: GridFSBucket | null
}

let cached = global._mongooseCache
if (!cached) {
  cached = global._mongooseCache = { conn: null, promise: null }
}

const MONGOOSE_OPTS: mongoose.ConnectOptions = {
  bufferCommands: false,
  // Connection pool — reuse connections instead of creating new ones
  maxPoolSize: 10,
  minPoolSize: 2,
  // Timeouts — fail fast instead of hanging
  serverSelectionTimeoutMS: 8000,
  socketTimeoutMS: 30000,
  connectTimeoutMS: 8000,
  // Heartbeat — detect dead connections quickly
  heartbeatFrequencyMS: 10000,
  // Keep alive
  family: 4, // Force IPv4 (faster on Windows)
}

export async function connectDB() {
  if (cached.conn) {
    // Verify connection is still alive
    if (mongoose.connection.readyState === 1) return cached.conn
    // Reset if disconnected
    cached.conn = null
    cached.promise = null
  }

  if (!cached.promise) {
    cached.promise = mongoose.connect(MONGODB_URI, MONGOOSE_OPTS)
      .catch((err) => {
        cached.promise = null
        throw err
      })
  }

  cached.conn = await cached.promise
  return cached.conn
}

export async function getMongoClient(): Promise<MongoClient> {
  if (global._mongoClient) {
    try {
      // Ping to check if still connected
      await global._mongoClient.db('admin').command({ ping: 1 })
      return global._mongoClient
    } catch {
      global._mongoClient = null
      global._gridFSBucket = null
    }
  }
  global._mongoClient = new MongoClient(MONGODB_URI, {
    maxPoolSize: 5,
    serverSelectionTimeoutMS: 8000,
    connectTimeoutMS: 8000,
    socketTimeoutMS: 30000,
    family: 4,
  })
  await global._mongoClient.connect()
  return global._mongoClient
}

export async function getGridFSBucket(): Promise<GridFSBucket> {
  if (global._gridFSBucket) return global._gridFSBucket
  const client = await getMongoClient()
  // Extract DB name from URI path
  const pathname = new URL(MONGODB_URI).pathname
  const dbName = pathname.replace(/^\//, '').split('?')[0]
  const db = client.db(dbName || undefined)
  global._gridFSBucket = new GridFSBucket(db, { bucketName: 'uploads' })
  return global._gridFSBucket
}
