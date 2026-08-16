-- DropForeignKey
ALTER TABLE "permission_set_line" DROP CONSTRAINT "permission_set_line_role_id_fkey";

-- DropIndex
DROP INDEX "config_package_field_package_id_idx";

-- AlterTable
ALTER TABLE "approval_user_setup" ADD COLUMN     "can_reverse_journal" INTEGER NOT NULL DEFAULT 0;

-- AddForeignKey
ALTER TABLE "permission_set_line" ADD CONSTRAINT "permission_set_line_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "role"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- RenameIndex
ALTER INDEX "ux_permission_set_line" RENAME TO "permission_set_line_role_id_object_type_object_name_key";

-- RenameIndex
ALTER INDEX "ux_savings_account_junior_cert" RENAME TO "savings_account_junior_birth_cert_no_key";
