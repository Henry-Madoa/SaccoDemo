-- AlterTable
ALTER TABLE "workflow_task" ADD COLUMN "delegated_by_user_id" INTEGER;
ALTER TABLE "workflow_task" ADD COLUMN "delegated_to_user_id" INTEGER;
