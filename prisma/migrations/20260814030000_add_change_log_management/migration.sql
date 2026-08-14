-- CreateTable
CREATE TABLE "change_log_setup" (
    "table_name" TEXT NOT NULL,
    "table_caption" TEXT NOT NULL,
    "log_insertion" INTEGER NOT NULL DEFAULT 0,
    "log_modification" INTEGER NOT NULL DEFAULT 0,
    "log_deletion" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "change_log_setup_pkey" PRIMARY KEY ("table_name")
);

-- CreateTable
CREATE TABLE "change_log_entry" (
    "id" SERIAL NOT NULL,
    "table_name" TEXT NOT NULL,
    "table_caption" TEXT NOT NULL,
    "record_id" TEXT NOT NULL,
    "field_name" TEXT NOT NULL,
    "old_value" TEXT,
    "new_value" TEXT,
    "type" TEXT NOT NULL,
    "changed_at" TEXT NOT NULL,
    "user_id" INTEGER,
    "username" TEXT NOT NULL,

    CONSTRAINT "change_log_entry_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_change_log_entry_record" ON "change_log_entry"("table_name", "record_id");

-- CreateIndex
CREATE INDEX "ix_change_log_entry_at" ON "change_log_entry"("changed_at" DESC);

-- Business Central's Change Log Setup starts with every table's logging switched off
-- until an admin opts it in — these two rows are the only tables this feature governs.
INSERT INTO "change_log_setup" ("table_name", "table_caption") VALUES
  ('member_application', 'Member Application'),
  ('member_edit_request', 'Member Edit Request');
