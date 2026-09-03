-- Remove the bespoke "Asset Type" flag (Fixed Asset | Motor Vehicle) and the Motor Vehicle
-- sub-card fields from the Fixed Asset card. Not part of Business Central Table 5600; a vehicle
-- is simply an asset in the "Motor Vehicles" FA Class / Subclass. Tangible / Intangible / etc.
-- classification rides on FA Class.

DROP INDEX IF EXISTS "ix_fa_asset_type";

ALTER TABLE "fixed_asset"
  DROP COLUMN IF EXISTS "asset_type",
  DROP COLUMN IF EXISTS "vehicle_registration_no",
  DROP COLUMN IF EXISTS "vehicle_make",
  DROP COLUMN IF EXISTS "vehicle_model",
  DROP COLUMN IF EXISTS "colour",
  DROP COLUMN IF EXISTS "frame_no",
  DROP COLUMN IF EXISTS "engine_no",
  DROP COLUMN IF EXISTS "log_book_no",
  DROP COLUMN IF EXISTS "year_of_manufacture",
  DROP COLUMN IF EXISTS "load_limit_kgs",
  DROP COLUMN IF EXISTS "passenger_capacity",
  DROP COLUMN IF EXISTS "fuel_capacity";
