-- Who committed an approved application/edit request and when — the Audit Trail
-- tab's "Processed by / Processed on" fields, set once at the point of processing.
ALTER TABLE "member_application" ADD COLUMN "processed_at" TEXT;
ALTER TABLE "member_application" ADD COLUMN "processed_by" TEXT;

ALTER TABLE "member_edit_request" ADD COLUMN "processed_at" TEXT;
ALTER TABLE "member_edit_request" ADD COLUMN "processed_by" TEXT;
