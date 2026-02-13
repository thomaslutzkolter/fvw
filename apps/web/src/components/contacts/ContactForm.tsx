import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { getSupabase, type Contact } from '@/lib/supabase'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Save, ArrowLeft } from 'lucide-react'

interface ContactFormProps {
    initialData?: Partial<Contact>
    mode: 'create' | 'edit'
}

export function ContactForm({ initialData, mode }: ContactFormProps) {
    const navigate = useNavigate()
    const [loading, setLoading] = useState(false)
    const [formData, setFormData] = useState<Partial<Contact>>(initialData || {
        first_name: '',
        last_name: '',
        company: '',
        position: '',
        contact_type: 'business'
    })

    const handleChange = (field: keyof Contact, value: string) => {
        setFormData(prev => ({ ...prev, [field]: value }))
    }

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()
        setLoading(true)
        const supabase = getSupabase()

        try {
            if (mode === 'create') {
                const { error } = await supabase
                    .from('contacts')
                    .insert([formData])

                if (error) throw error
                navigate('/contacts')
            } else {
                // Edit logic would go here
                if (!initialData?.id) return
                const { error } = await supabase
                    .from('contacts')
                    .update(formData)
                    .eq('id', initialData.id)

                if (error) throw error
                navigate(`/contacts/${initialData.id}`)
            }
        } catch (error) {
            console.error('Error saving contact:', error)
            alert('Fehler beim Speichern')
        } finally {
            setLoading(false)
        }
    }

    return (
        <form onSubmit={handleSubmit} className="space-y-8 max-w-2xl mx-auto p-6 bg-card rounded-lg border shadow-sm">
            <div className="flex items-center justify-between">
                <Button type="button" variant="ghost" onClick={() => navigate(-1)}>
                    <ArrowLeft className="mr-2 h-4 w-4" /> Zurück
                </Button>
                <h2 className="text-2xl font-bold">
                    {mode === 'create' ? 'Neuer Kontakt' : 'Kontakt bearbeiten'}
                </h2>
                <Button type="submit" disabled={loading}>
                    <Save className="mr-2 h-4 w-4" />
                    {loading ? 'Speichere...' : 'Speichern'}
                </Button>
            </div>

            <div className="grid gap-4">
                <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                        <label className="text-sm font-medium">Vorname</label>
                        <Input
                            value={formData.first_name || ''}
                            onChange={e => handleChange('first_name', e.target.value)}
                            required
                        />
                    </div>
                    <div className="space-y-2">
                        <label className="text-sm font-medium">Nachname</label>
                        <Input
                            value={formData.last_name || ''}
                            onChange={e => handleChange('last_name', e.target.value)}
                            required
                        />
                    </div>
                </div>

                <div className="space-y-2">
                    <label className="text-sm font-medium">Firma</label>
                    <Input
                        value={formData.company || ''}
                        onChange={e => handleChange('company', e.target.value)}
                    />
                </div>

                <div className="space-y-2">
                    <label className="text-sm font-medium">Position</label>
                    <Input
                        value={formData.position || ''}
                        onChange={e => handleChange('position', e.target.value)}
                    />
                </div>

                <div className="space-y-2">
                    <label className="text-sm font-medium">Typ</label>
                    <select
                        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                        value={formData.contact_type}
                        onChange={e => handleChange('contact_type', e.target.value)}
                    >
                        <option value="business">Geschäftlich</option>
                        <option value="personal">Privat</option>
                    </select>
                </div>
            </div>
        </form>
    )
}
