-- =================================
-- INITIAL DATABASE SCHEMA
-- Kontaktverwaltung mit vollständigem Adressmanagement
-- =================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Für Fuzzy-Search

-- =================================
-- 1. CONTACTS - Haupttabelle
-- =================================
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Namen
    first_name VARCHAR(100),
    middle_name VARCHAR(100),
    last_name VARCHAR(100),
    nickname VARCHAR(100),
    
    -- Formelle Anrede
    title VARCHAR(50), -- z.B. "Dr.", "Prof."
    nobility_title VARCHAR(50), -- z.B. "von", "zu", "Freiherr"
    academic_title VARCHAR(100), -- z.B. "Dr. med.", "Prof. Dr."
    salutation VARCHAR(20), -- "Herr", "Frau", "Divers"
    gender VARCHAR(20), -- "male", "female", "diverse", "prefer_not_to_say"
    
    -- Geschäftlich
    company VARCHAR(200),
    department VARCHAR(100),
    position VARCHAR(100),
    job_title VARCHAR(100),
    
    -- Kategorisierung
    contact_type VARCHAR(20) DEFAULT 'personal' CHECK (contact_type IN ('personal', 'business', 'both')),
    category VARCHAR(50), -- z.B. "Kunde", "Lieferant", "Partner"
    tags TEXT[], -- Flexible Tags
    
    -- Persönliches
    birthday DATE,
    anniversary DATE,
    
    -- Online
    website VARCHAR(500),
    photo_url VARCHAR(500),
    
    -- Notizen
    notes TEXT,
    
    -- Metadaten
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE, -- Soft Delete
    
    -- Full-Text Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('german', coalesce(first_name, '')), 'A') ||
        setweight(to_tsvector('german', coalesce(last_name, '')), 'A') ||
        setweight(to_tsvector('german', coalesce(company, '')), 'B') ||
        setweight(to_tsvector('german', coalesce(notes, '')), 'C')
    ) STORED
);

-- Indizes für Performance
CREATE INDEX idx_contacts_user_id ON contacts(user_id);
CREATE INDEX idx_contacts_company ON contacts(company) WHERE company IS NOT NULL;
CREATE INDEX idx_contacts_last_name ON contacts(last_name) WHERE last_name IS NOT NULL;
CREATE INDEX idx_contacts_tags ON contacts USING GIN(tags);
CREATE INDEX idx_contacts_search ON contacts USING GIN(search_vector);
CREATE INDEX idx_contacts_updated_at ON contacts(user_id, updated_at DESC);
CREATE INDEX idx_contacts_deleted_at ON contacts(deleted_at) WHERE deleted_at IS NULL;

-- =================================
-- 2. CONTACT_EMAILS - Mehrere E-Mail-Adressen
-- =================================
CREATE TABLE contact_emails (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    type VARCHAR(20) DEFAULT 'work' CHECK (type IN ('work', 'personal', 'other')),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_contact_emails_contact ON contact_emails(contact_id);
CREATE INDEX idx_contact_emails_email ON contact_emails(email);

-- =================================
-- 3. CONTACT_PHONES - Mehrere Telefonnummern
-- =================================
CREATE TABLE contact_phones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    number VARCHAR(50) NOT NULL,
    type VARCHAR(20) DEFAULT 'mobile' CHECK (type IN ('mobile', 'work', 'home', 'fax', 'other')),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_contact_phones_contact ON contact_phones(contact_id);

-- =================================
-- 4. CONTACT_ADDRESSES - Mehrere Adressen
-- =================================
CREATE TABLE contact_addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    
    type VARCHAR(20) DEFAULT 'home' CHECK (type IN ('home', 'work', 'billing', 'shipping', 'other')),
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Adressfelder
    street VARCHAR(200),
    street2 VARCHAR(200), -- Adresszusatz
    city VARCHAR(100),
    state VARCHAR(100), -- Bundesland
    postal_code VARCHAR(20),
    country VARCHAR(2) DEFAULT 'DE', -- ISO 3166-1 alpha-2
    
    -- Optional: Geocoding
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_contact_addresses_contact ON contact_addresses(contact_id);
CREATE INDEX idx_contact_addresses_city ON contact_addresses(city);
CREATE INDEX idx_contact_addresses_postal ON contact_addresses(postal_code);

-- =================================
-- 5. CONTACT_CUSTOM_FIELDS - Flexible Erweiterung
-- =================================
CREATE TABLE contact_custom_fields (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    field_name VARCHAR(100) NOT NULL,
    field_value TEXT,
    field_type VARCHAR(20) DEFAULT 'text' CHECK (field_type IN ('text', 'number', 'date', 'boolean', 'url')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_contact_custom_fields_contact ON contact_custom_fields(contact_id);

-- =================================
-- 6. CONTACT_VERSIONS - Audit Trail & Versionierung
-- =================================
CREATE TABLE contact_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    version_number INTEGER NOT NULL,
    
    -- Snapshot des kompletten Kontakts
    snapshot JSONB NOT NULL,
    
    -- Änderungsinfo
    changed_by UUID REFERENCES auth.users(id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    change_type VARCHAR(20) CHECK (change_type IN ('created', 'updated', 'merged', 'deleted')),
    change_description TEXT
);

CREATE INDEX idx_contact_versions_contact ON contact_versions(contact_id, version_number DESC);
CREATE INDEX idx_contact_versions_changed_at ON contact_versions(changed_at DESC);

-- =================================
-- 7. CONTACT_GROUPS - Gruppierung
-- =================================
CREATE TABLE contact_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(7), -- Hex-Color für UI
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_contact_groups_user ON contact_groups(user_id);
CREATE UNIQUE INDEX idx_contact_groups_user_name ON contact_groups(user_id, name);

-- =================================
-- 8. CONTACT_GROUP_MEMBERS - N:M Beziehung
-- =================================
CREATE TABLE contact_group_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES contact_groups(id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(contact_id, group_id)
);

CREATE INDEX idx_contact_group_members_contact ON contact_group_members(contact_id);
CREATE INDEX idx_contact_group_members_group ON contact_group_members(group_id);

-- =================================
-- 9. IMPORT_SESSIONS - Import-Tracking
-- =================================
CREATE TABLE import_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    source_file VARCHAR(500),
    source_type VARCHAR(20) CHECK (source_type IN ('csv', 'vcard', 'json', 'excel')),
    
    mapping_config JSONB, -- Feld-Mapping Konfiguration
    
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    
    imported_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    skipped_count INTEGER DEFAULT 0,
    
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_import_sessions_user ON import_sessions(user_id);
CREATE INDEX idx_import_sessions_status ON import_sessions(status);

-- =================================
-- 10. IMPORT_ERRORS - Fehlerprotokoll
-- =================================
CREATE TABLE import_errors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    import_session_id UUID NOT NULL REFERENCES import_sessions(id) ON DELETE CASCADE,
    
    row_number INTEGER,
    error_message TEXT NOT NULL,
    error_field VARCHAR(100),
    raw_data JSONB,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_import_errors_session ON import_errors(import_session_id);

-- =================================
-- TRIGGER: Auto-Update Timestamp
-- =================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_contacts_updated_at
    BEFORE UPDATE ON contacts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =================================
-- TRIGGER: Auto-Versionierung
-- =================================
CREATE OR REPLACE FUNCTION create_contact_version()
RETURNS TRIGGER AS $$
DECLARE
    v_number INTEGER;
    v_snapshot JSONB;
BEGIN
    -- Berechne nächste Version-Nummer
    SELECT COALESCE(MAX(version_number), 0) + 1
    INTO v_number
    FROM contact_versions
    WHERE contact_id = NEW.id;
    
    -- Erstelle Snapshot
    v_snapshot := to_jsonb(NEW);
    
    -- Insert Version
    INSERT INTO contact_versions (
        contact_id,
        version_number,
        snapshot,
        changed_by,
        change_type
    ) VALUES (
        NEW.id,
        v_number,
        v_snapshot,
        NEW.user_id,
        CASE
            WHEN TG_OP = 'INSERT' THEN 'created'
            WHEN TG_OP = 'UPDATE' THEN 'updated'
            ELSE 'unknown'
        END
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_contact_version_trigger
    AFTER INSERT OR UPDATE ON contacts
    FOR EACH ROW
    EXECUTE FUNCTION create_contact_version();

-- =================================
-- ROW LEVEL SECURITY (RLS)
-- =================================

-- Enable RLS auf allen Tabellen
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_emails ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_phones ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_custom_fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE import_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE import_errors ENABLE ROW LEVEL SECURITY;

-- Policies für contacts
CREATE POLICY "Users can view own contacts"
    ON contacts FOR SELECT
    USING (auth.uid() = user_id AND deleted_at IS NULL);

CREATE POLICY "Users can insert own contacts"
    ON contacts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own contacts"
    ON contacts FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can soft-delete own contacts"
    ON contacts FOR DELETE
    USING (auth.uid() = user_id);

-- Policies für contact_emails
CREATE POLICY "Users can view emails of own contacts"
    ON contact_emails FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM contacts
        WHERE contacts.id = contact_emails.contact_id
        AND contacts.user_id = auth.uid()
    ));

CREATE POLICY "Users can manage emails of own contacts"
    ON contact_emails FOR ALL
    USING (EXISTS (
        SELECT 1 FROM contacts
        WHERE contacts.id = contact_emails.contact_id
        AND contacts.user_id = auth.uid()
    ));

-- Analog für andere Tabellen (phones, addresses, etc.)
CREATE POLICY "Users can view phones of own contacts"
    ON contact_phones FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM contacts
        WHERE contacts.id = contact_phones.contact_id
        AND contacts.user_id = auth.uid()
    ));

CREATE POLICY "Users can manage phones of own contacts"
    ON contact_phones FOR ALL
    USING (EXISTS (
        SELECT 1 FROM contacts
        WHERE contacts.id = contact_phones.contact_id
        AND contacts.user_id = auth.uid()
    ));

CREATE POLICY "Users can view addresses of own contacts"
    ON contact_addresses FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM contacts
        WHERE contacts.id = contact_addresses.contact_id
        AND contacts.user_id = auth.uid()
    ));

CREATE POLICY "Users can manage addresses of own contacts"
    ON contact_addresses FOR ALL
    USING (EXISTS (
        SELECT 1 FROM contacts
        WHERE contacts.id = contact_addresses.contact_id
        AND contacts.user_id = auth.uid()
    ));

-- Custom Fields
CREATE POLICY "Users can view custom fields of own contacts"
    ON contact_custom_fields FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM contacts
        WHERE contacts.id = contact_custom_fields.contact_id
        AND contacts.user_id = auth.uid()
    ));

CREATE POLICY "Users can manage custom fields of own contacts"
    ON contact_custom_fields FOR ALL
    USING (EXISTS (
        SELECT 1 FROM contacts
        WHERE contacts.id = contact_custom_fields.contact_id
        AND contacts.user_id = auth.uid()
    ));

-- Versions
CREATE POLICY "Users can view versions of own contacts"
    ON contact_versions FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM contacts
        WHERE contacts.id = contact_versions.contact_id
        AND contacts.user_id = auth.uid()
    ));

-- Groups
CREATE POLICY "Users can manage own groups"
    ON contact_groups FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own group members"
    ON contact_group_members FOR ALL
    USING (EXISTS (
        SELECT 1 FROM contact_groups
        WHERE contact_groups.id = contact_group_members.group_id
        AND contact_groups.user_id = auth.uid()
    ));

-- Import Sessions
CREATE POLICY "Users can view own import sessions"
    ON import_sessions FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view own import errors"
    ON import_errors FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM import_sessions
        WHERE import_sessions.id = import_errors.import_session_id
        AND import_sessions.user_id = auth.uid()
    ));
