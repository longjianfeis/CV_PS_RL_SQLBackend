BEGIN;


ALTER TABLE documents DISABLE TRIGGER ALL;


CREATE TYPE doc_type_new AS ENUM (
  'resume',
  'personal_statement',
  'recommendation'
);


ALTER TABLE documents
  ALTER COLUMN type DROP DEFAULT,
  ALTER COLUMN type TYPE TEXT USING type::TEXT;


UPDATE documents
SET type = CASE type
  WHEN 'letter' THEN 'recommendation'
  WHEN 'sop'    THEN 'personal_statement'
  ELSE type
END;


ALTER TABLE documents
  ALTER COLUMN type TYPE doc_type_new
  USING type::doc_type_new;


ALTER TABLE documents
  ALTER COLUMN type SET DEFAULT 'resume'::doc_type_new;


DROP TYPE doc_type;
ALTER TYPE doc_type_new RENAME TO doc_type;


ALTER TABLE documents ENABLE TRIGGER ALL;

COMMIT;