-- A user can be pinned to one company by an administrator (User card → Company). Such a user
-- always works in that company and cannot switch; a user with no assignment picks their company
-- on My Settings. NULL = not assigned.
ALTER TABLE "app_user" ADD COLUMN "company_code" TEXT;
