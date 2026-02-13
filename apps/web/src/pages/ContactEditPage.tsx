import { useParams } from 'react-router-dom'
import { ContactForm } from '@/components/contacts/ContactForm'
import { useEffect, useState } from 'react'
import { getSupabase, type Contact } from '@/lib/supabase'

export default function ContactEditPage() {
    const { id } = useParams()
    const [contact, setContact] = useState<Contact | null>(null)
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        if (id) loadContact()
    }, [id])

    async function loadContact() {
        try {
            const supabase = getSupabase()
            const { data, error } = await supabase
                .from('contacts')
                .select('*')
                .eq('id', id)
                .single()

            if (error) throw error
            setContact(data)
        } catch (error) {
            console.error('Error loading contact:', error)
        } finally {
            setLoading(false)
        }
    }

    if (loading) return <div>Laden...</div>
    if (!contact) return <div>Kontakt nicht gefunden</div>

    return <ContactForm mode="edit" initialData={contact} />
}
