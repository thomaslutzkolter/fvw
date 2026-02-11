import { createClient } from '@supabase/supabase-js'

// IMPORTANT: Only use runtime config from window.__env__
// Do NOT use import.meta.env as it gets hardcoded at build time
const getEnv = () => {
    const env = (window as any).__env__ || {}
    return {
        url: env.VITE_SUPABASE_URL || 'http://localhost:54321',
        key: env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
    }
}

const env = getEnv()
export const supabase = createClient(env.url, env.key)

export type Contact = {
    id: string
    title?: string
    first_name?: string
    last_name?: string
    nickname?: string
    company?: string
    department?: string
    position?: string
    job_title?: string
    contact_type?: 'personal' | 'business' | 'both'
    category?: string
    notes?: string
    birthday?: string
    anniversary?: string
    tags?: string[]
    created_at: string
    updated_at: string
    deleted_at?: string | null
}
