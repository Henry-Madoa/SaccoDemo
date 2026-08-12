-- Replace the single fingerprint slot with two (one per index finger scan).
ALTER TABLE member DROP COLUMN fingerprint_image;
ALTER TABLE member ADD COLUMN fingerprint1_image text;
ALTER TABLE member ADD COLUMN fingerprint2_image text;
