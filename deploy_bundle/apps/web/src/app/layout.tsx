export default function RootLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return (
        <html lang="de">
            <body className="font-sans antialiased">
                <nav className="bg-white dark:bg-gray-900 border-b">
                    <div className="container mx-auto px-4 py-4">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-6">
                                <a href="/" className="font-bold text-xl text-brand-600">
                                    FVW
                                </a>
                                <div className="hidden md:flex gap-4">
                                    <a href="/contacts" className="text-sm font-medium hover:text-brand-600">
                                        Kontakte
                                    </a>
                                    <a href="/studio" className="text-sm font-medium hover:text-brand-600">
                                        Studio
                                    </a>
                                    <a href="/api" className="text-sm font-medium hover:text-brand-600">
                                        API
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </nav>
                {children}
            </body>
        </html>
    )
}
