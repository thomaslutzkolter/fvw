import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase, type Contact } from '@/lib/supabase'
import { Plus, Search, Filter } from 'lucide-react'

export default function ContactsPage() {
    const navigate = useNavigate()
    const [contacts, setContacts] = useState<Contact[]>([])
    const [loading, setLoading] = useState(true)
    const [searchTerm, setSearchTerm] = useState('')

    useEffect(() => {
        loadContacts()
    }, [])

    async function loadContacts() {
        try {
            const { data, error } = await supabase
                .from('contacts')
                .select('*')
                .is('deleted_at', null)
                .order('updated_at', { ascending: false })

            if (error) throw error
            setContacts(data || [])
        } catch (error) {
            console.error('Error loading contacts:', error)
        } finally {
            setLoading(false)
        }
    }

    const filteredContacts = contacts.filter(contact => {
        const search = searchTerm.toLowerCase()
        return (
            contact.first_name?.toLowerCase().includes(search) ||
            contact.last_name?.toLowerCase().includes(search) ||
            contact.company?.toLowerCase().includes(search) ||
            contact.department?.toLowerCase().includes(search)
        )
    })

    return (
        <div className="min-h-screen bg-gradient-to-br from-brand-50 to-brand-100 dark:from-background dark:to-secondary">
            <div className="container mx-auto px-4 py-8">
                {/* Header */}
                <div className="mb-8">
                    <h1 className="text-4xl font-bold text-brand-900 dark:text-white mb-2">
                        Kontaktverwaltung
                    </h1>
                    <p className="text-brand-700 dark:text-brand-200">
                        {contacts.length} Kontakte gesamt
                    </p>
                </div>

                {/* Actions Bar */}
                <div className="card-elevated p-4 mb-6 flex flex-col sm:flex-row gap-4 items-center justify-between">
                    <div className="flex-1 w-full sm:max-w-md relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                        <input
                            type="text"
                            placeholder="Kontakte durchsuchen..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="input-field pl-10 w-full"
                        />
                    </div>

                    <div className="flex gap-2">
                        <button className="btn-ghost flex items-center gap-2">
                            <Filter className="h-4 w-4" />
                            Filter
                        </button>
                        <button className="btn-primary flex items-center gap-2">
                            <Plus className="h-4 w-4" />
                            Neuer Kontakt
                        </button>
                    </div>
                </div>

                {/* Contacts Table */}
                <div className="card-elevated overflow-hidden">
                    {loading ? (
                        <div className="p-12 text-center text-muted-foreground">
                            Lädt Kontakte...
                        </div>
                    ) : filteredContacts.length === 0 ? (
                        <div className="p-12 text-center">
                            <p className="text-muted-foreground mb-4">
                                {searchTerm ? 'Keine Kontakte gefunden' : 'Noch keine Kontakte vorhanden'}
                            </p>
                            <button className="btn-primary">
                                Ersten Kontakt erstellen
                            </button>
                        </div>
                    ) : (
                        <div className="overflow-x-auto">
                            <table className="data-table">
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th>Firma</th>
                                        <th>Position</th>
                                        <th>Typ</th>
                                        <th>Kategorie</th>
                                        <th>Aktualisiert</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {filteredContacts.map((contact) => (
                                        <tr
                                            key={contact.id}
                                            onClick={() => navigate(`/contacts/${contact.id}`)}
                                            className="cursor-pointer hover:bg-brand-50 dark:hover:bg-brand-900/10"
                                        >
                                            <td>
                                                <div className="font-medium">
                                                    {[contact.title, contact.first_name, contact.last_name]
                                                        .filter(Boolean)
                                                        .join(' ')}
                                                </div>
                                                {contact.nickname && (
                                                    <div className="text-xs text-muted-foreground">
                                                        &quot;{contact.nickname}&quot;
                                                    </div>
                                                )}
                                            </td>
                                            <td>
                                                <div>{contact.company || '-'}</div>
                                                {contact.department && (
                                                    <div className="text-xs text-muted-foreground">
                                                        {contact.department}
                                                    </div>
                                                )}
                                            </td>
                                            <td>{contact.position || contact.job_title || '-'}</td>
                                            <td>
                                                <span className={`badge ${contact.contact_type === 'business'
                                                    ? 'badge-primary'
                                                    : 'badge-secondary'
                                                    }`}>
                                                    {contact.contact_type === 'business' ? 'Geschäftlich' :
                                                        contact.contact_type === 'personal' ? 'Privat' : 'Beide'}
                                                </span>
                                            </td>
                                            <td>{contact.category || '-'}</td>
                                            <td className="text-sm text-muted-foreground">
                                                {new Date(contact.updated_at).toLocaleDateString('de-DE')}
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                </div>
            </div>
        </div>
    )
}
