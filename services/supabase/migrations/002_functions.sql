-- =================================
-- STORED FUNCTIONS & PROCEDURES
-- =================================

-- =================================
-- 1. SEARCH CONTACTS (Full-Text + Fuzzy)
-- =================================
CREATE OR REPLACE FUNCTION search_contacts(
    p_user_id UUID,
    p_query TEXT,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    first_name VARCHAR,
    last_name VARCHAR,
    company VARCHAR,
    primary_email VARCHAR,
    primary_phone VARCHAR,
    rank REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (c.id)
        c.id,
        c.first_name,
        c.last_name,
        c.company,
        (SELECT email FROM contact_emails WHERE contact_id = c.id AND is_primary = TRUE LIMIT 1) as primary_email,
        (SELECT number FROM contact_phones WHERE contact_id = c.id AND is_primary = TRUE LIMIT 1) as primary_phone,
        ts_rank(c.search_vector, websearch_to_tsquery('german', p_query)) as rank
    FROM contacts c
    WHERE c.user_id = p_user_id
        AND c.deleted_at IS NULL
        AND (
            c.search_vector @@ websearch_to_tsquery('german', p_query)
            OR similarity(c.first_name || ' ' || c.last_name, p_query) > 0.3
            OR similarity(c.company, p_query) > 0.3
        )
    ORDER BY c.id, rank DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;

-- =================================
-- 2. GET CONTACT WITH ALL RELATIONS
-- =================================
CREATE OR REPLACE FUNCTION get_contact_full(p_contact_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'contact', to_jsonb(c.*),
        'emails', COALESCE(
            (SELECT jsonb_agg(to_jsonb(e.*))
             FROM contact_emails e
             WHERE e.contact_id = c.id
             ORDER BY e.is_primary DESC, e.created_at),
            '[]'::jsonb
        ),
        'phones', COALESCE(
            (SELECT jsonb_agg(to_jsonb(p.*))
             FROM contact_phones p
             WHERE p.contact_id = c.id
             ORDER BY p.is_primary DESC, p.created_at),
            '[]'::jsonb
        ),
        'addresses', COALESCE(
            (SELECT jsonb_agg(to_jsonb(a.*))
             FROM contact_addresses a
             WHERE a.contact_id = c.id
             ORDER BY a.is_primary DESC, a.created_at),
            '[]'::jsonb
        ),
        'custom_fields', COALESCE(
            (SELECT jsonb_agg(to_jsonb(cf.*))
             FROM contact_custom_fields cf
             WHERE cf.contact_id = c.id
             ORDER BY cf.field_name),
            '[]'::jsonb
        ),
        'groups', COALESCE(
            (SELECT jsonb_agg(jsonb_build_object(
                'id', g.id,
                'name', g.name,
                'color', g.color
            ))
             FROM contact_group_members cgm
             JOIN contact_groups g ON g.id = cgm.group_id
             WHERE cgm.contact_id = c.id),
            '[]'::jsonb
        )
    )
    INTO v_result
    FROM contacts c
    WHERE c.id = p_contact_id;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql STABLE;

-- =================================
-- 3. SYNC CONTACTS (für Offline-Sync)
-- =================================
CREATE OR REPLACE FUNCTION sync_contacts_since(
    p_user_id UUID,
    p_since TIMESTAMP WITH TIME ZONE
)
RETURNS TABLE (
    id UUID,
    data JSONB,
    updated_at TIMESTAMP WITH TIME ZONE,
    deleted BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        get_contact_full(c.id) as data,
        c.updated_at,
        (c.deleted_at IS NOT NULL) as deleted
    FROM contacts c
    WHERE c.user_id = p_user_id
        AND c.updated_at > p_since
    ORDER BY c.updated_at ASC;
END;
$$ LANGUAGE plpgsql STABLE;

-- =================================
-- 4. MERGE CONTACTS (Duplikat-Zusammenführung)
-- =================================
CREATE OR REPLACE FUNCTION merge_contacts(
    p_target_id UUID,
    p_source_id UUID,
    p_user_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- Prüfe Berechtigung
    IF NOT EXISTS (
        SELECT 1 FROM contacts
        WHERE id IN (p_target_id, p_source_id)
        AND user_id = p_user_id
    ) THEN
        RAISE EXCEPTION 'Unauthorized or contacts not found';
    END IF;
    
    -- Merge E-Mails (ohne Duplikate)
    INSERT INTO contact_emails (contact_id, email, type, is_primary)
    SELECT p_target_id, email, type, FALSE
    FROM contact_emails
    WHERE contact_id = p_source_id
    ON CONFLICT DO NOTHING;
    
    -- Merge Telefonnummern
    INSERT INTO contact_phones (contact_id, number, type, is_primary)
    SELECT p_target_id, number, type, FALSE
    FROM contact_phones
    WHERE contact_id = p_source_id
    ON CONFLICT DO NOTHING;
    
    -- Merge Adressen
    INSERT INTO contact_addresses (
        contact_id, type, street, street2, city, state, postal_code, country, is_primary
    )
    SELECT p_target_id, type, street, street2, city, state, postal_code, country, FALSE
    FROM contact_addresses
    WHERE contact_id = p_source_id;
    
    -- Merge Custom Fields
    INSERT INTO contact_custom_fields (contact_id, field_name, field_value, field_type)
    SELECT p_target_id, field_name, field_value, field_type
    FROM contact_custom_fields
    WHERE contact_id = p_source_id
    ON CONFLICT DO NOTHING;
    
    -- Merge Groups
    INSERT INTO contact_group_members (contact_id, group_id)
    SELECT p_target_id, group_id
    FROM contact_group_members
    WHERE contact_id = p_source_id
    ON CONFLICT DO NOTHING;
    
    -- Erstelle Version-Snapshot vom Merge
    INSERT INTO contact_versions (
        contact_id,
        version_number,
        snapshot,
        changed_by,
        change_type,
        change_description
    ) VALUES (
        p_target_id,
        (SELECT COALESCE(MAX(version_number), 0) + 1 FROM contact_versions WHERE contact_id = p_target_id),
        get_contact_full(p_target_id),
        p_user_id,
        'merged',
        'Merged contact ' || p_source_id::TEXT || ' into this contact'
    );
    
    -- Soft-Delete Source-Kontakt
    UPDATE contacts
    SET deleted_at = NOW(),
        updated_at = NOW()
    WHERE id = p_source_id;
    
    -- Rückgabe
    v_result := jsonb_build_object(
        'success', TRUE,
        'target_id', p_target_id,
        'source_id', p_source_id,
        'merged_contact', get_contact_full(p_target_id)
    );
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- =================================
-- 5. FIND DUPLICATE CONTACTS
-- =================================
CREATE OR REPLACE FUNCTION find_duplicate_contacts(p_user_id UUID)
RETURNS TABLE (
    contact1_id UUID,
    contact2_id UUID,
    similarity_score REAL,
    match_reason TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH contact_data AS (
        SELECT
            c.id,
            c.first_name,
            c.last_name,
            c.company,
            ARRAY_AGG(DISTINCT e.email) FILTER (WHERE e.email IS NOT NULL) as emails
        FROM contacts c
        LEFT JOIN contact_emails e ON e.contact_id = c.id
        WHERE c.user_id = p_user_id
            AND c.deleted_at IS NULL
        GROUP BY c.id, c.first_name, c.last_name, c.company
    )
    SELECT DISTINCT
        c1.id as contact1_id,
        c2.id as contact2_id,
        GREATEST(
            similarity(c1.first_name || ' ' || c1.last_name, c2.first_name || ' ' || c2.last_name),
            similarity(COALESCE(c1.company, ''), COALESCE(c2.company, ''))
        ) as similarity_score,
        CASE
            WHEN c1.emails && c2.emails THEN 'Gleiche E-Mail-Adresse'
            WHEN similarity(c1.first_name || ' ' || c1.last_name, c2.first_name || ' ' || c2.last_name) > 0.7 THEN 'Ähnlicher Name'
            WHEN similarity(COALESCE(c1.company, ''), COALESCE(c2.company, '')) > 0.8 THEN 'Gleiche Firma'
            ELSE 'Andere Ähnlichkeit'
        END as match_reason
    FROM contact_data c1
    CROSS JOIN contact_data c2
    WHERE c1.id < c2.id
        AND (
            -- Gleiche E-Mail
            c1.emails && c2.emails
            -- Sehr ähnlicher Name
            OR similarity(c1.first_name || ' ' || c1.last_name, c2.first_name || ' ' || c2.last_name) > 0.7
            -- Gleiche Firma + ähnlicher Name
            OR (
                COALESCE(c1.company, '') = COALESCE(c2.company, '')
                AND c1.company IS NOT NULL
                AND similarity(c1.first_name || ' ' || c1.last_name, c2.first_name || ' ' || c2.last_name) > 0.5
            )
        )
    ORDER BY similarity_score DESC;
END;
$$ LANGUAGE plpgsql STABLE;

-- =================================
-- 6. BULK IMPORT HELPER
-- =================================
CREATE OR REPLACE FUNCTION bulk_import_contacts(
    p_user_id UUID,
    p_import_session_id UUID,
    p_contacts JSONB
)
RETURNS JSONB AS $$
DECLARE
    v_imported INTEGER := 0;
    v_errors INTEGER := 0;
    v_contact JSONB;
    v_contact_id UUID;
BEGIN
    FOR v_contact IN SELECT * FROM jsonb_array_elements(p_contacts)
    LOOP
        BEGIN
            -- Insert Kontakt
            INSERT INTO contacts (
                user_id,
                first_name,
                last_name,
                company,
                contact_type,
                notes
            ) VALUES (
                p_user_id,
                v_contact->>'first_name',
                v_contact->>'last_name',
                v_contact->>'company',
                COALESCE(v_contact->>'contact_type', 'personal'),
                v_contact->>'notes'
            ) RETURNING id INTO v_contact_id;
            
            -- Insert E-Mails
            IF v_contact->'emails' IS NOT NULL THEN
                INSERT INTO contact_emails (contact_id, email, type)
                SELECT v_contact_id, value->>'email', value->>'type'
                FROM jsonb_array_elements(v_contact->'emails');
            END IF;
            
            -- Insert Telefone
            IF v_contact->'phones' IS NOT NULL THEN
                INSERT INTO contact_phones (contact_id, number, type)
                SELECT v_contact_id, value->>'number', value->>'type'
                FROM jsonb_array_elements(v_contact->'phones');
            END IF;
            
            v_imported := v_imported + 1;
            
        EXCEPTION WHEN OTHERS THEN
            -- Log Fehler
            INSERT INTO import_errors (
                import_session_id,
                error_message,
                raw_data
            ) VALUES (
                p_import_session_id,
                SQLERRM,
                v_contact
            );
            
            v_errors := v_errors + 1;
        END;
    END LOOP;
    
    -- Update Import Session
    UPDATE import_sessions
    SET imported_count = v_imported,
        error_count = v_errors,
        status = 'completed',
        completed_at = NOW()
    WHERE id = p_import_session_id;
    
    RETURN jsonb_build_object(
        'imported', v_imported,
        'errors', v_errors
    );
END;
$$ LANGUAGE plpgsql;

-- =================================
-- 7. GET STATISTICS
-- =================================
CREATE OR REPLACE FUNCTION get_contact_statistics(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_stats JSONB;
BEGIN
    SELECT jsonb_build_object(
        'total_contacts', COUNT(*),
        'business_contacts', COUNT(*) FILTER (WHERE contact_type IN ('business', 'both')),
        'personal_contacts', COUNT(*) FILTER (WHERE contact_type IN ('personal', 'both')),
        'with_email', COUNT(*) FILTER (WHERE id IN (SELECT contact_id FROM contact_emails)),
        'with_phone', COUNT(*) FILTER (WHERE id IN (SELECT contact_id FROM contact_phones)),
        'with_address', COUNT(*) FILTER (WHERE id IN (SELECT contact_id FROM contact_addresses)),
        'in_groups', COUNT(DISTINCT id) FILTER (WHERE id IN (SELECT contact_id FROM contact_group_members)),
        'created_this_month', COUNT(*) FILTER (WHERE created_at >= date_trunc('month', NOW())),
        'updated_this_week', COUNT(*) FILTER (WHERE updated_at >= date_trunc('week', NOW()))
    )
    INTO v_stats
    FROM contacts
    WHERE user_id = p_user_id
        AND deleted_at IS NULL;
    
    RETURN v_stats;
END;
$$ LANGUAGE plpgsql STABLE;
