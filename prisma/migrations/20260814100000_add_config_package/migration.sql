-- Configuration Packages (Admin Centre → Data Management): an admin-defined
-- table + column set that can be exported to CSV and re-imported to bulk
-- insert/update rows, for data migration.

CREATE TABLE "config_package" (
  "id" SERIAL PRIMARY KEY,
  "code" TEXT NOT NULL UNIQUE,
  "name" TEXT NOT NULL,
  "table_name" TEXT NOT NULL,
  "key_field" TEXT,
  "created_at" TEXT,
  "created_by" TEXT
);

CREATE TABLE "config_package_field" (
  "id" SERIAL PRIMARY KEY,
  "package_id" INTEGER NOT NULL REFERENCES "config_package"("id") ON DELETE CASCADE,
  "field_name" TEXT NOT NULL,
  "column_no" INTEGER NOT NULL,
  CONSTRAINT "ux_config_package_field" UNIQUE ("package_id", "field_name")
);
CREATE INDEX "config_package_field_package_id_idx" ON "config_package_field"("package_id");
