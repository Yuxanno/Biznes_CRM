/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    serverComponentsExternalPackages: ['mongoose', 'sharp'],
  },

  webpack: (config, { isServer }) => {
    if (isServer) {
      config.externals = [...(config.externals || []), 'sharp', 'mongoose']
    }
    // Reduce bundle size in dev
    config.optimization = {
      ...config.optimization,
      moduleIds: 'named',
    }
    return config
  },

  // CORS for Flutter web
  async headers() {
    return [
      {
        source: '/api/:path*',
        headers: [
          { key: 'Access-Control-Allow-Origin', value: '*' },
          { key: 'Access-Control-Allow-Methods', value: 'GET,POST,PUT,PATCH,DELETE,OPTIONS' },
          { key: 'Access-Control-Allow-Headers', value: 'Content-Type, Authorization' },
          // Tell browser to cache preflight for 1 hour
          { key: 'Access-Control-Max-Age', value: '3600' },
        ],
      },
    ]
  },
}

module.exports = nextConfig
