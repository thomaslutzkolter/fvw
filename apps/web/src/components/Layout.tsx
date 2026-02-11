import React from 'react'
import { Link, Outlet } from 'react-router-dom'

export default function Layout() {
    return (
        <div className="min-h-screen bg-background font-sans antialiased">
            <nav className="bg-white dark:bg-gray-900 border-b">
                <div className="container mx-auto px-4 py-4">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-6">
                            <Link to="/" className="font-bold text-xl text-brand-600">
                                FVW
                            </Link>
                            <div className="hidden md:flex gap-4">
                                <Link to="/contacts" className="text-sm font-medium hover:text-brand-600">
                                    Kontakte
                                </Link>
                                <Link to="/studio" className="text-sm font-medium hover:text-brand-600">
                                    Studio
                                </Link>
                                <Link to="/api" className="text-sm font-medium hover:text-brand-600">
                                    API
                                </Link>
                            </div>
                        </div>
                    </div>
                </div>
            </nav>
            <Outlet />
        </div>
    )
}
