import { createClient, SupabaseClient } from '@supabase/supabase-js'

// Lazy initialization to ensure window.__env__ is available at runtime
let supabaseInstance: SupabaseClient | null = null

export const getSupabase = () => {
    if (!supabaseInstance) {
        // @ts-ignore - runtime config injected by start.sh
        const env = (window as any).__env__ || {}

        // Prioritize runtime config, fallback to build-time env, then defaults
        const url = env.VITE_SUPABASE_URL || import.meta.env.VITE_SUPABASE_URL || 'http://localhost:54321'
        const key = env.VITE_SUPABASE_ANON_KEY || import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'

        console.log('[Supabase] Initializing with URL:', url)
        supabaseInstance = createClient(url, key)
    }
    return supabaseInstance
}

// For backwards compatibility
export const supabase = new Proxy({} as SupabaseClient, {
    get(_target, prop) {
        return (getSupabase() as any)[prop]
    }
})

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
