-- AlterTable: group/corporate details for non-individual applicants and members
ALTER TABLE "member_application" ADD COLUMN "group_name" TEXT;
ALTER TABLE "member_application" ADD COLUMN "registration_no" TEXT;
ALTER TABLE "member_application" ADD COLUMN "registration_date" TEXT;
ALTER TABLE "member_application" ADD COLUMN "contact_person_name" TEXT;
ALTER TABLE "member_application" ADD COLUMN "contact_person_phone" TEXT;
ALTER TABLE "member_application" ADD COLUMN "contact_person_email" TEXT;
ALTER TABLE "member_application" ADD COLUMN "member_count" INTEGER;

ALTER TABLE "member" ADD COLUMN "group_name" TEXT;
ALTER TABLE "member" ADD COLUMN "registration_no" TEXT;
ALTER TABLE "member" ADD COLUMN "registration_date" TEXT;
ALTER TABLE "member" ADD COLUMN "contact_person_name" TEXT;
ALTER TABLE "member" ADD COLUMN "contact_person_phone" TEXT;
ALTER TABLE "member" ADD COLUMN "contact_person_email" TEXT;
ALTER TABLE "member" ADD COLUMN "member_count" INTEGER;
