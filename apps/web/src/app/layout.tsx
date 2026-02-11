import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
    title: 'FVW Kontaktverwaltung',
    description: 'Enterprise Contact Management System',
}

export default function RootLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return (
        <html lang="de" suppressHydrationWarning>
            <body className={inter.className}>{children}</body>
        </html>
    )
}
