import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Layout from './components/Layout'
import ContactsPage from './pages/ContactsPage'
import ContactDetailPage from './pages/ContactDetailPage'

function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<Layout />}>
                    <Route index element={<Navigate to="/contacts" replace />} />
                    <Route path="contacts" element={<ContactsPage />} />
                    <Route path="contacts/new" element={<ContactNewPage />} />
                    <Route path="contacts/:id" element={<ContactDetailPage />} />
                    <Route path="contacts/:id/edit" element={<ContactEditPage />} />
                    <Route path="studio" element={<div className="p-8">Studio Redirect...</div>} />
                    <Route path="api" element={<div className="p-8">API Redirect...</div>} />
                </Route>
            </Routes>
        </BrowserRouter>
    )
}

export default App
