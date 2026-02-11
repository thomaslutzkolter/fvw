import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || ''
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ''

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Type Definitions
export type Contact = {
    id: string
    user_id: string
    first_name?: string
    middle_name?: string
    last_name?: string
    nickname?: string
    title?: string
    nobility_title?: string
    academic_title?: string
    salutation?: string
    gender?: string
    company?: string
    department?: string
    position?: string
    job_title?: string
    contact_type: 'personal' | 'business' | 'both'
    category?: string
    tags?: string[]
    birthday?: string
    anniversary?: string
    website?: string
    photo_url?: string
    notes?: string
    created_at: string
    updated_at: string
    deleted_at?: string
}

export type ContactEmail = {
    id: string
    contact_id: string
    email: string
    type: 'work' | 'personal' | 'other'
    is_primary: boolean
    created_at: string
}

export type ContactPhone = {
    id: string
    contact_id: string
    number: string
    type: 'mobile' | 'work' | 'home' | 'fax' | 'other'
    is_primary: boolean
    created_at: string
}

export type ContactAddress = {
    id: string
    contact_id: string
    type: 'home' | 'work' | 'billing' | 'shipping' | 'other'
    is_primary: boolean
    street?: string
    street2?: string
    city?: string
    state?: string
    postal_code?: string
    country: string
    latitude?: number
    longitude?: number
    created_at: string
}
