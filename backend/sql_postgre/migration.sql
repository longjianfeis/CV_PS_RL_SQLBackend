ALTER TABLE document_versions
  DROP CONSTRAINT IF EXISTS document_versions_document_id_fkey;
ALTER TABLE document_versions
  ADD CONSTRAINT document_versions_document_id_fkey
    FOREIGN KEY (document_id) REFERENCES documents(id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


ALTER TABLE documents
  DROP CONSTRAINT IF EXISTS documents_current_version_id_fkey;
ALTER TABLE documents
  ADD CONSTRAINT documents_current_version_id_fkey
    FOREIGN KEY (current_version_id) REFERENCES document_versions(id)
    ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED;


ALTER TABLE document_versions
  ADD CONSTRAINT chk_content_len
    CHECK (char_length(content) <= 5000);


ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY documents_owner_policy
  ON documents FOR ALL
  USING (user_id = current_setting('app.current_user_id')::uuid);

ALTER TABLE document_versions ENABLE ROW LEVEL SECURITY;
CREATE POLICY doc_versions_owner_policy
  ON document_versions FOR ALL
  USING (
    document_id IN (SELECT id FROM documents WHERE user_id = current_setting('app.current_user_id')::uuid)
  );
