export default function HomePage() {
    return (
        <div className="min-h-screen bg-gradient-to-br from-brand-50 to-brand-100 dark:from-background dark:to-secondary">
            <div className="container mx-auto px-4 py-16">
                <div className="max-w-4xl mx-auto">
                    {/* Header */}
                    <header className="text-center mb-16 animate-in">
                        <div className="inline-flex items-center justify-center w-20 h-20 bg-brand-500 rounded-2xl mb-6 shadow-lg">
                            <svg className="w-12 h-12 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                            </svg>
                        </div>
                        <h1 className="text-5xl font-bold text-brand-900 dark:text-white mb-4">
                            FVW Kontaktverwaltung
                        </h1>
                        <p className="text-xl text-brand-700 dark:text-brand-200">
                            Enterprise Contact Management System
                        </p>
                    </header>

                    {/* Status Cards */}
                    <div className="grid md:grid-cols-3 gap-6 mb-16">
                        <div className="card-elevated p-6 animate-in">
                            <div className="flex items-center gap-4">
                                <div className="w-12 h-12 bg-green-100 dark:bg-green-900 rounded-lg flex items-center justify-center">
                                    <svg className="w-6 h-6 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                </div>
                                <div>
                                    <p className="text-sm text-muted-foreground">Backend</p>
                                    <p className="font-semibold">Supabase Ready</p>
                                </div>
                            </div>
                        </div>

                        <div className="card-elevated p-6 animate-in" style={{ animationDelay: '0.1s' }}>
                            <div className="flex items-center gap-4">
                                <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center">
                                    <svg className="w-6 h-6 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" />
                                    </svg>
                                </div>
                                <div>
                                    <p className="text-sm text-muted-foreground">Database</p>
                                    <p className="font-semibold">PostgreSQL 15</p>
                                </div>
                            </div>
                        </div>

                        <div className="card-elevated p-6 animate-in" style={{ animationDelay: '0.2s' }}>
                            <div className="flex items-center gap-4">
                                <div className="w-12 h-12 bg-purple-100 dark:bg-purple-900 rounded-lg flex items-center justify-center">
                                    <svg className="w-6 h-6 text-purple-600 dark:text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                                    </svg>
                                </div>
                                <div>
                                    <p className="text-sm text-muted-foreground">Realtime</p>
                                    <p className="font-semibold">Live Sync</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Features */}
                    <div className="card-elevated p-8 mb-8 animate-in" style={{ animationDelay: '0.3s' }}>
                        <h2 className="text-2xl font-bold mb-6 text-brand-900 dark:text-white">Features</h2>
                        <div className="grid md:grid-cols-2 gap-6">
                            <div className="flex gap-3">
                                <div className="w-5 h-5 text-brand-500 flex-shrink-0 mt-0.5">
                                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                    </svg>
                                </div>
                                <div>
                                    <p className="font-medium">50+ Kontaktfelder</p>
                                    <p className="text-sm text-muted-foreground">Titel, Adelstitel, Anreden, Kategorien</p>
                                </div>
                            </div>

                            <div className="flex gap-3">
                                <div className="w-5 h-5 text-brand-500 flex-shrink-0 mt-0.5">
                                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                    </svg>
                                </div>
                                <div>
                                    <p className="font-medium">Multi-Import</p>
                                    <p className="text-sm text-muted-foreground">CSV, vCard, JSON, Excel</p>
                                </div>
                            </div>

                            <div className="flex gap-3">
                                <div className="w-5 h-5 text-brand-500 flex-shrink-0 mt-0.5">
                                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                    </svg>
                                </div>
                                <div>
                                    <p className="font-medium">Versionierung</p>
                                    <p className="text-sm text-muted-foreground">Vollständiger Audit Trail</p>
                                </div>
                            </div>

                            <div className="flex gap-3">
                                <div className="w-5 h-5 text-brand-500 flex-shrink-0 mt-0.5">
                                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                    </svg>
                                </div>
                                <div>
                                    <p className="font-medium">Local-First Sync</p>
                                    <p className="text-sm text-muted-foreground">Offline-fähig mit Realtime-Sync</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Quick Links */}
                    <div className="grid md:grid-cols-2 gap-4 animate-in" style={{ animationDelay: '0.4s' }}>
                        <a
                            href="/studio"
                            className="card-flat p-6 hover:shadow-md transition-all group"
                        >
                            <div className="flex items-center justify-between">
                                <div>
                                    <h3 className="font-semibold text-lg mb-1 group-hover:text-brand-600">Supabase Studio</h3>
                                    <p className="text-sm text-muted-foreground">Datenbank-Management</p>
                                </div>
                                <svg className="w-5 h-5 text-muted-foreground group-hover:text-brand-600 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                                </svg>
                            </div>
                        </a>

                        <a
                            href="/api"
                            className="card-flat p-6 hover:shadow-md transition-all group"
                        >
                            <div className="flex items-center justify-between">
                                <div>
                                    <h3 className="font-semibold text-lg mb-1 group-hover:text-brand-600">REST API</h3>
                                    <p className="text-sm text-muted-foreground">Automatisch generierte API</p>
                                </div>
                                <svg className="w-5 h-5 text-muted-foreground group-hover:text-brand-600 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                                </svg>
                            </div>
                        </a>
                    </div>

                    {/* Footer */}
                    <footer className="text-center mt-16 text-sm text-muted-foreground">
                        <p>FVW Enterprise Contact Management • Built with Supabase & Next.js</p>
                    </footer>
                </div>
            </div>
        </div>
    )
}
