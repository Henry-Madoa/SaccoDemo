-- CreateTable
CREATE TABLE "job_queue_entry" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "job_type" TEXT NOT NULL,
    "run_every_minutes" INTEGER NOT NULL DEFAULT 60,
    "earliest_start_date" TEXT,
    "status" TEXT NOT NULL DEFAULT 'ON HOLD',
    "next_run_at" TEXT,
    "last_run_at" TEXT,
    "last_run_status" TEXT,
    "last_run_message" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,
    "updated_at" TEXT,
    "updated_by" TEXT,

    CONSTRAINT "job_queue_entry_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "job_queue_entry_code_key" ON "job_queue_entry"("code");

-- CreateIndex
CREATE INDEX "ix_jqe_status" ON "job_queue_entry"("status");
