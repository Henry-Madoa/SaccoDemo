-- Adds an Identification No. to every Next of Kin / Nominee row, across all three families
-- (live member, member application, member edit request) — lets the officer record who this
-- person is precisely enough to look them up (lib/members.ts's findMemberByIdentificationNo())
-- and auto-populate the row if they're already a SACCO member themselves. Nullable and
-- additive; uniqueness ("cannot be repeated for the same member") is enforced in the service
-- layer per submitted list (see each lib/*Nominees.ts's assertNoDuplicateId()), not as a DB
-- constraint, matching this codebase's existing nominee-percentage validation pattern.
ALTER TABLE "member_next_of_kin" ADD COLUMN "identification_no" TEXT;
ALTER TABLE "member_nominee" ADD COLUMN "identification_no" TEXT;
ALTER TABLE "member_application_next_of_kin" ADD COLUMN "identification_no" TEXT;
ALTER TABLE "member_application_nominee" ADD COLUMN "identification_no" TEXT;
ALTER TABLE "member_edit_next_of_kin" ADD COLUMN "identification_no" TEXT;
ALTER TABLE "member_edit_nominee" ADD COLUMN "identification_no" TEXT;
