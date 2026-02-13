import * as React from "react"
import { cn } from "@/lib/utils"

// Simplified Dropdown for now
export const DropdownMenu = ({ children }: { children: React.ReactNode }) => <div className="relative inline-block text-left group">{children}</div>
export const DropdownMenuTrigger = ({ asChild, children }: any) => <>{children}</>
export const DropdownMenuContent = ({ children, className }: any) => (
    <div className={cn("hidden group-hover:block absolute right-0 mt-2 w-56 origin-top-right rounded-md bg-white dark:bg-slate-900 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none z-50", className)}>
        <div className="py-1">{children}</div>
    </div>
)
export const DropdownMenuItem = ({ children, className }: any) => (
    <div className={cn("block px-4 py-2 text-sm text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-slate-800 cursor-pointer", className)}>
        {children}
    </div>
)
