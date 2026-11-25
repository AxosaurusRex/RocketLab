-- Run against an EMPTY throwaway database after 001_init.sql. Rolls itself back.
\set ON_ERROR_STOP on
BEGIN;
INSERT INTO users (id,email,password_hash,display_name) VALUES ('00000000-0000-4000-8000-000000000001','A@x.test','h','a');
INSERT INTO training_sessions VALUES ('00000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000002',now(),now(),'completed');
INSERT INTO drill_runs VALUES ('00000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000003','00000000-0000-4000-8000-000000000002','d',1,now(),1,'completed',1,2,NULL,NULL);
DO $$
BEGIN
  BEGIN
    INSERT INTO users (email,password_hash,display_name) VALUES ('a@X.test','h','b');
    RAISE EXCEPTION 'duplicate email accepted';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;
  DELETE FROM users;
  IF EXISTS (SELECT 1 FROM drill_runs) OR EXISTS (SELECT 1 FROM training_sessions) THEN
    RAISE EXCEPTION 'account deletion left data behind';
  END IF;
END $$;
ROLLBACK;
\echo PostgreSQL checks passed
