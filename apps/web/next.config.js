/** @type {import('next').NextConfig} */
const nextConfig = {
    output: 'standalone',

    // Environment-Variablen
    env: {
        NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
        NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    },

    // Externals für Docker
    experimental: {
        serverComponentsExternalPackages: ['@supabase/supabase-js'],
    },
}

module.exports = nextConfig
