-- Names are collected on the application view page after creation, not at creation time.
ALTER TABLE "member_application" ALTER COLUMN "first_name" DROP NOT NULL;
ALTER TABLE "member_application" ALTER COLUMN "last_name" DROP NOT NULL;
