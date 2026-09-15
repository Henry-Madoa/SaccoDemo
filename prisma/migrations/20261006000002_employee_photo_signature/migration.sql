-- Employee Card identity strip: passport photo and specimen signature (Cloudinary public_ids),
-- the employee-side counterpart of member.photo / member.signature_image.
ALTER TABLE "employee" ADD COLUMN "photo_image" TEXT;
ALTER TABLE "employee" ADD COLUMN "signature_image" TEXT;
