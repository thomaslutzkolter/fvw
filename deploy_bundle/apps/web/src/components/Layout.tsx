import { Outlet } from 'react-router-dom'
import { Sidebar } from './Sidebar'
import { Header } from './Header'

export default function Layout() {
    return (
        <div className="min-h-screen bg-background font-sans antialiased flex">
            <Sidebar />
            <div className="flex-1 flex flex-col min-h-screen transition-all duration-300 md:pl-64">
                <Header />
                <main className="flex-1 pt-16 p-6">
                    <Outlet />
                </main>
            </div>
        </div>
    )
}
