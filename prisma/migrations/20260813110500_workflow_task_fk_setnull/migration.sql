-- Editing a workflow's steps (delete+reinsert on save) must not destroy the
-- history of tasks that already ran under the old steps — a task keeps its own
-- step_no even once its workflow_step_id points at nothing.
ALTER TABLE "workflow_task" DROP CONSTRAINT "workflow_task_workflow_id_fkey";
ALTER TABLE "workflow_task" ADD CONSTRAINT "workflow_task_workflow_id_fkey" FOREIGN KEY ("workflow_id") REFERENCES "workflow"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE "workflow_task" DROP CONSTRAINT "workflow_task_workflow_step_id_fkey";
ALTER TABLE "workflow_task" ADD CONSTRAINT "workflow_task_workflow_step_id_fkey" FOREIGN KEY ("workflow_step_id") REFERENCES "workflow_step"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
