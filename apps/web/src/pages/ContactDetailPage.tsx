import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { supabase, type Contact } from '@/lib/supabase'
import { ArrowLeft, Mail, Phone, MapPin, Building2, Calendar, Tag, Save, Trash2, Plus } from 'lucide-react'

interface ContactEmail {
    id: string
    email: string
    type: string
    is_primary: boolean
}

interface ContactPhone {
    id: string
    number: string
    type: string
    is_primary: boolean
}

interface ContactAddress {
    id: string
    type: string
    street: string
    street2?: string
    city: string
    state?: string
    postal_code: string
    country: string
    is_primary: boolean
}

export default function ContactDetailPage() {
    const { id } = useParams()
    const navigate = useNavigate()
    const [contact, setContact] = useState<Contact | null>(null)
    const [emails, setEmails] = useState<ContactEmail[]>([])
    const [phones, setPhones] = useState<ContactPhone[]>([])
    const [addresses, setAddresses] = useState<ContactAddress[]>([])
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        if (id) loadContact()
    }, [id])

    async function loadContact() {
        try {
            const { data: contactData, error: contactError } = await supabase
                .from('contacts')
                .select('*')
                .eq('id', id)
                .single()

            if (contactError) throw contactError
            setContact(contactData)

            const { data: emailsData } = await supabase
                .from('contact_emails')
                .select('*')
                .eq('contact_id', id)
            setEmails(emailsData || [])

            const { data: phonesData } = await supabase
                .from('contact_phones')
                .select('*')
                .eq('contact_id', id)
            setPhones(phonesData || [])

            const { data: addressesData } = await supabase
                .from('contact_addresses')
                .select('*')
                .eq('contact_id', id)
            setAddresses(addressesData || [])

        } catch (error) {
            console.error('Error loading contact:', error)
        } finally {
            setLoading(false)
        }
    }

    if (loading) {
        return <div className="p-8 text-center">Lädt Kontakt...</div>
    }

    if (!contact) {
        return <div className="p-8 text-center">Kontakt nicht gefunden</div>
    }

    return (
        <div className="min-h-screen bg-gradient-to-br from-brand-50 to-brand-100 dark:from-background dark:to-secondary">
            <div className="container mx-auto px-4 py-8">
                <button
                    onClick={() => navigate('/contacts')}
                    className="btn-ghost mb-6 flex items-center gap-2"
                >
                    <ArrowLeft className="h-4 w-4" />
                    Zurück zur Übersicht
                </button>

                <div className="grid gap-6">
                    {/* Header Card */}
                    <div className="card-elevated p-6">
                        <div className="flex items-start justify-between">
                            <div>
                                <h1 className="text-3xl font-bold text-brand-900 dark:text-white">
                                    {[contact.title, contact.first_name, contact.last_name].filter(Boolean).join(' ')}
                                </h1>
                                {contact.nickname && (
                                    <p className="text-muted-foreground mt-1">&quot;{contact.nickname}&quot;</p>
                                )}
                                {contact.company && (
                                    <div className="flex items-center gap-2 mt-3">
                                        <Building2 className="h-4 w-4 text-brand-600" />
                                        <span className="font-medium">{contact.company}</span>
                                        {contact.department && <span className="text-muted-foreground">• {contact.department}</span>}
                                    </div>
                                )}
                                {contact.position && (
                                    <p className="text-sm text-muted-foreground mt-1">{contact.position}</p>
                                )}
                            </div>
                            <div className="flex gap-2">
                                <button className="btn-primary flex items-center gap-2">
                                    <Save className="h-4 w-4" />
                                    Speichern
                                </button>
                                <button className="btn-ghost text-red-600 flex items-center gap-2">
                                    <Trash2 className="h-4 w-4" />
                                </button>
                            </div>
                        </div>

                        {contact.tags && contact.tags.length > 0 && (
                            <div className="flex gap-2 mt-4">
                                {contact.tags.map((tag, i) => (
                                    <span key={i} className="badge badge-primary">
                                        <Tag className="h-3 w-3 mr-1" />
                                        {tag}
                                    </span>
                                ))}
                            </div>
                        )}
                    </div>

                    <div className="grid md:grid-cols-2 gap-6">
                        {/* E-Mails */}
                        <div className="card-elevated p-6">
                            <div className="flex items-center justify-between mb-4">
                                <h2 className="text-xl font-bold flex items-center gap-2">
                                    <Mail className="h-5 w-5 text-brand-600" />
                                    E-Mail-Adressen
                                </h2>
                                <button className="btn-ghost text-sm flex items-center gap-1">
                                    <Plus className="h-4 w-4" />
                                    Hinzufügen
                                </button>
                            </div>
                            <div className="space-y-3">
                                {emails.length === 0 ? (
                                    <p className="text-sm text-muted-foreground">Keine E-Mail-Adressen</p>
                                ) : (
                                    emails.map((email) => (
                                        <div key={email.id} className="flex items-center justify-between">
                                            <div>
                                                <a href={`mailto:${email.email}`} className="text-brand-600 hover:underline">
                                                    {email.email}
                                                </a>
                                                <div className="flex gap-2 mt-1">
                                                    <span className="text-xs badge badge-secondary">{email.type}</span>
                                                    {email.is_primary && <span className="text-xs badge badge-primary">Primär</span>}
                                                </div>
                                            </div>
                                        </div>
                                    ))
                                )}
                            </div>
                        </div>

                        {/* Telefonnummern */}
                        <div className="card-elevated p-6">
                            <div className="flex items-center justify-between mb-4">
                                <h2 className="text-xl font-bold flex items-center gap-2">
                                    <Phone className="h-5 w-5 text-brand-600" />
                                    Telefonnummern
                                </h2>
                                <button className="btn-ghost text-sm flex items-center gap-1">
                                    <Plus className="h-4 w-4" />
                                    Hinzufügen
                                </button>
                            </div>
                            <div className="space-y-3">
                                {phones.length === 0 ? (
                                    <p className="text-sm text-muted-foreground">Keine Telefonnummern</p>
                                ) : (
                                    phones.map((phone) => (
                                        <div key={phone.id} className="flex items-center justify-between">
                                            <div>
                                                <a href={`tel:${phone.number}`} className="text-brand-600 hover:underline">
                                                    {phone.number}
                                                </a>
                                                <div className="flex gap-2 mt-1">
                                                    <span className="text-xs badge badge-secondary">{phone.type}</span>
                                                    {phone.is_primary && <span className="text-xs badge badge-primary">Primär</span>}
                                                </div>
                                            </div>
                                        </div>
                                    ))
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Adressen */}
                    <div className="card-elevated p-6">
                        <div className="flex items-center justify-between mb-4">
                            <h2 className="text-xl font-bold flex items-center gap-2">
                                <MapPin className="h-5 w-5 text-brand-600" />
                                Adressen
                            </h2>
                            <button className="btn-ghost text-sm flex items-center gap-1">
                                <Plus className="h-4 w-4" />
                                Hinzufügen
                            </button>
                        </div>
                        <div className="grid md:grid-cols-2 gap-4">
                            {addresses.length === 0 ? (
                                <p className="text-sm text-muted-foreground">Keine Adressen</p>
                            ) : (
                                addresses.map((address) => (
                                    <div key={address.id} className="border rounded-lg p-4">
                                        <div className="flex justify-between items-start mb-2">
                                            <span className="badge badge-secondary">{address.type}</span>
                                            {address.is_primary && <span className="badge badge-primary">Primär</span>}
                                        </div>
                                        <div className="text-sm space-y-1">
                                            <p>{address.street}</p>
                                            {address.street2 && <p>{address.street2}</p>}
                                            <p>{address.postal_code} {address.city}</p>
                                            {address.state && <p>{address.state}</p>}
                                            <p>{address.country}</p>
                                        </div>
                                    </div>
                                ))
                            )}
                        </div>
                    </div>

                    {/* Notizen */}
                    {contact.notes && (
                        <div className="card-elevated p-6">
                            <h2 className="text-xl font-bold mb-4">Notizen</h2>
                            <p className="text-sm whitespace-pre-wrap">{contact.notes}</p>
                        </div>
                    )}

                    {/* Persönliche Daten */}
                    {(contact.birthday || contact.anniversary) && (
                        <div className="card-elevated p-6">
                            <h2 className="text-xl font-bold flex items-center gap-2 mb-4">
                                <Calendar className="h-5 w-5 text-brand-600" />
                                Persönliche Daten
                            </h2>
                            <div className="grid md:grid-cols-2 gap-4">
                                {contact.birthday && (
                                    <div>
                                        <span className="text-sm font-medium">Geburtstag</span>
                                        <p className="text-sm text-muted-foreground">
                                            {new Date(contact.birthday).toLocaleDateString('de-DE')}
                                        </p>
                                    </div>
                                )}
                                {contact.anniversary && (
                                    <div>
                                        <span className="text-sm font-medium">Jahrestag</span>
                                        <p className="text-sm text-muted-foreground">
                                            {new Date(contact.anniversary).toLocaleDateString('de-DE')}
                                        </p>
                                    </div>
                                )}
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </div>
    )
}
