-- Biometric capture: ID scans, signature and fingerprint image, stored the
-- same way as the existing member photo (Cloudinary public_id, nullable).
ALTER TABLE member ADD COLUMN front_id_image    text;
ALTER TABLE member ADD COLUMN back_id_image     text;
ALTER TABLE member ADD COLUMN signature_image   text;
ALTER TABLE member ADD COLUMN fingerprint_image text;
