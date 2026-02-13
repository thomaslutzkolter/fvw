import { Search, Bell, Moon, Sun, Monitor } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useState, useEffect } from 'react'

export function Header() {
    const [theme, setTheme] = useState<'light' | 'dark' | 'system'>('system')

    // Theme handling effect (placeholder - would typically use a context)
    useEffect(() => {
        const root = window.document.documentElement
        root.classList.remove('light', 'dark')

        if (theme === 'system') {
            const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches
                ? 'dark'
                : 'light'
            root.classList.add(systemTheme)
            return
        }

        root.classList.add(theme)
    }, [theme])

    return (
        <header className="fixed top-0 right-0 left-0 md:left-64 z-30 h-16 border-b border-border/50 bg-background/80 backdrop-blur-xl transition-[left] duration-300">
            <div className="flex h-full items-center justify-between px-6">
                {/* Search Area */}
                <div className="flex-1 max-w-xl">
                    <div className="relative group">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground group-focus-within:text-primary transition-colors" size={18} />
                        <input
                            type="text"
                            placeholder="Suchen... (CMD+K)"
                            className="w-full h-10 pl-10 pr-4 rounded-full bg-muted/50 border-transparent focus:bg-background focus:border-primary/20 focus:ring-4 focus:ring-primary/10 transition-all outline-none text-sm"
                        />
                        <div className="absolute right-3 top-1/2 -translate-y-1/2 hidden md:flex gap-1">
                            <kbd className="pointer-events-none inline-flex h-5 select-none items-center gap-1 rounded border bg-muted px-1.5 font-mono text-[10px] font-medium text-muted-foreground opacity-100">
                                <span className="text-xs">⌘</span>K
                            </kbd>
                        </div>
                    </div>
                </div>

                {/* Actions */}
                <div className="flex items-center gap-4">
                    {/* Theme Toggle */}
                    <div className="flex items-center p-1 rounded-full bg-muted/50 border border-border/50">
                        <button
                            onClick={() => setTheme('light')}
                            className={cn("p-1.5 rounded-full transition-all", theme === 'light' && "bg-background shadow-sm")}
                        >
                            <Sun size={14} className={theme === 'light' ? "text-orange-500" : "text-muted-foreground"} />
                        </button>
                        <button
                            onClick={() => setTheme('system')}
                            className={cn("p-1.5 rounded-full transition-all", theme === 'system' && "bg-background shadow-sm")}
                        >
                            <Monitor size={14} className={theme === 'system' ? "text-primary" : "text-muted-foreground"} />
                        </button>
                        <button
                            onClick={() => setTheme('dark')}
                            className={cn("p-1.5 rounded-full transition-all", theme === 'dark' && "bg-background shadow-sm")}
                        >
                            <Moon size={14} className={theme === 'dark' ? "text-blue-400" : "text-muted-foreground"} />
                        </button>
                    </div>

                    <button className="relative p-2 rounded-full hover:bg-muted transition-colors text-muted-foreground hover:text-foreground">
                        <Bell size={20} />
                        <span className="absolute top-2 right-2 h-2 w-2 rounded-full bg-red-500 ring-2 ring-background" />
                    </button>
                </div>
            </div>
        </header>
    )
}
