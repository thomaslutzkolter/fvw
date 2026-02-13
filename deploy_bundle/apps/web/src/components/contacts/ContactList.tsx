import { useState, useEffect } from 'react'
import { getSupabase, type Contact } from '@/lib/supabase'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow
} from '@/components/ui/table'
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'
import { MoreHorizontal, Plus, Search, Filter } from 'lucide-react'
import { Link } from 'react-router-dom'
import { format } from 'date-fns'
import { de } from 'date-fns/locale'

export function ContactList() {
    const [contacts, setContacts] = useState<Contact[]>([])
    const [loading, setLoading] = useState(true)
    const [search, setSearch] = useState('')

    useEffect(() => {
        fetchContacts()
    }, [])

    async function fetchContacts() {
        try {
            setLoading(true)
            const supabase = getSupabase()
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
        const searchLower = search.toLowerCase()
        const fullName = `${contact.first_name || ''} ${contact.last_name || ''}`.toLowerCase()
        return fullName.includes(searchLower) ||
            (contact.company && contact.company.toLowerCase().includes(searchLower)) ||
            (contact.city && contact.city.toLowerCase().includes(searchLower))
    })

    return (
        <div className="space-y-4">
            {/* Toolbar */}
            <div className="flex items-center justify-between gap-4">
                <div className="flex items-center gap-2 flex-1 max-w-sm">
                    <div className="relative w-full">
                        <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                        <Input
                            placeholder="Suche nach Namen, Firmen, Orten..."
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            className="pl-9"
                        />
                    </div>
                    <Button variant="outline" size="icon">
                        <Filter className="h-4 w-4" />
                    </Button>
                </div>
                <Link to="/contacts/new">
                    <Button>
                        <Plus className="mr-2 h-4 w-4" /> Kontakt erstellen
                    </Button>
                </Link>
            </div>

            {/* Table */}
            <div className="rounded-md border bg-card">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Namens</TableHead>
                            <TableHead>Firma</TableHead>
                            <TableHead>Kontakt</TableHead>
                            <TableHead>Aktualisiert</TableHead>
                            <TableHead className="w-[50px]"></TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {loading ? (
                            <TableRow>
                                <TableCell colSpan={5} className="h-24 text-center">
                                    Laden...
                                </TableCell>
                            </TableRow>
                        ) : filteredContacts.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={5} className="h-24 text-center text-muted-foreground">
                                    Keine Kontakte gefunden.
                                </TableCell>
                            </TableRow>
                        ) : (
                            filteredContacts.map((contact) => (
                                <TableRow key={contact.id}>
                                    <TableCell>
                                        <div className="flex flex-col">
                                            <span className="font-medium">
                                                {contact.first_name} {contact.last_name}
                                            </span>
                                            {contact.position && (
                                                <span className="text-xs text-muted-foreground">{contact.position}</span>
                                            )}
                                        </div>
                                    </TableCell>
                                    <TableCell>
                                        {contact.company || '-'}
                                    </TableCell>
                                    <TableCell>
                                        <div className="flex flex-col text-sm">
                                            {/* Email/Phone would need join or separate query if not flattened, 
                                                assuming basic fields for now or joined view */}
                                            <span>{/* TODO: Email */}</span>
                                        </div>
                                    </TableCell>
                                    <TableCell className="text-muted-foreground text-sm">
                                        {contact.updated_at && format(new Date(contact.updated_at), 'dd. MMM yyyy', { locale: de })}
                                    </TableCell>
                                    <TableCell>
                                        <DropdownMenu>
                                            <DropdownMenuTrigger asChild>
                                                <Button variant="ghost" size="icon" className="h-8 w-8">
                                                    <MoreHorizontal className="h-4 w-4" />
                                                </Button>
                                            </DropdownMenuTrigger>
                                            <DropdownMenuContent align="end">
                                                <Link to={`/contacts/${contact.id}`}>
                                                    <DropdownMenuItem>Öffnen</DropdownMenuItem>
                                                </Link>
                                                <DropdownMenuItem>Bearbeiten</DropdownMenuItem>
                                                <DropdownMenuItem className="text-destructive">Löschen</DropdownMenuItem>
                                            </DropdownMenuContent>
                                        </DropdownMenu>
                                    </TableCell>
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </Table>
            </div>
        </div>
    )
}
