-- AlterTable
ALTER TABLE "workflow_user_group_member" ADD COLUMN "sequence" INTEGER NOT NULL DEFAULT 1;

-- AlterTable
ALTER TABLE "workflow_task" ADD COLUMN "current_sequence" INTEGER;
