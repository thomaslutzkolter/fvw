import { Link, useLocation } from 'react-router-dom'
import {
    LayoutDashboard,
    Users,
    Building2,
    Settings,
    Database,
    LogOut,
    Menu,
    X,
    FolderOpen
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { useState } from 'react'

const navItems = [
    { icon: LayoutDashboard, label: 'Dashboard', href: '/' },
    { icon: Users, label: 'Kontakte', href: '/contacts' },
    { icon: Building2, label: 'Firmen', href: '/companies' },
    { icon: FolderOpen, label: 'Gruppen', href: '/groups' },
    { icon: Database, label: 'Studio', href: '/studio' },
    { icon: Settings, label: 'Einstellungen', href: '/settings' },
]

export function Sidebar() {
    const location = useLocation()
    const [collapsed, setCollapsed] = useState(false)

    return (
        <aside className={cn(
            "fixed left-0 top-0 z-40 h-screen border-r bg-card/80 backdrop-blur-xl transition-all duration-300 ease-in-out border-border/50",
            collapsed ? "w-16" : "w-64"
        )}>
            {/* Logo Area */}
            <div className="flex h-16 items-center justify-between px-4 border-b border-border/50">
                {!collapsed && (
                    <Link to="/" className="flex items-center gap-2 font-bold text-xl text-primary">
                        <div className="h-8 w-8 rounded-lg bg-primary/10 flex items-center justify-center">
                            <span className="text-primary">F</span>
                        </div>
                        <span>FVW</span>
                    </Link>
                )}
                <button
                    onClick={() => setCollapsed(!collapsed)}
                    className="p-1.5 rounded-md hover:bg-muted text-muted-foreground transition-colors"
                >
                    {collapsed ? <Menu size={20} /> : <X size={20} />}
                </button>
            </div>

            {/* Navigation */}
            <div className="py-4 space-y-1 px-2">
                {navItems.map((item) => {
                    const isActive = location.pathname === item.href
                    return (
                        <Link
                            key={item.href}
                            to={item.href}
                            className={cn(
                                "flex items-center gap-3 px-3 py-2 rounded-md transition-all duration-200 group",
                                isActive
                                    ? "bg-primary/10 text-primary font-medium"
                                    : "text-muted-foreground hover:bg-muted hover:text-foreground",
                                collapsed && "justify-center px-2"
                            )}
                            title={collapsed ? item.label : undefined}
                        >
                            <item.icon size={20} className={cn(
                                "shrink-0 transition-colors",
                                isActive ? "text-primary" : "text-muted-foreground group-hover:text-foreground"
                            )} />
                            {!collapsed && <span>{item.label}</span>}
                        </Link>
                    )
                })}
            </div>

            {/* User Profile / Footer */}
            <div className="absolute bottom-0 w-full p-4 border-t border-border/50 bg-background/50 backdrop-blur-sm">
                <div className={cn("flex items-center gap-3", collapsed && "justify-center")}>
                    <div className="h-9 w-9 rounded-full bg-gradient-to-tr from-primary to-purple-500 shrink-0" />
                    {!collapsed && (
                        <div className="overflow-hidden">
                            <p className="text-sm font-medium truncate">Admin User</p>
                            <p className="text-xs text-muted-foreground truncate">admin@fvw.local</p>
                        </div>
                    )}
                </div>
            </div>
        </aside>
    )
}
