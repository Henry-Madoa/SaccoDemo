-- Account Instructions — AL "Account Instructions" (Tab52204129), "Member Account Instructions"
-- (Tab52204009) and "Account Instruction Type" (Enum52204019). A member gives operating
-- instructions at registration (predefined from the admin list, or free text); they follow the
-- application onto the member and are editable via Member Editing.

CREATE TABLE "account_instruction" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "active" INTEGER NOT NULL DEFAULT 1,
    "sort" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "account_instruction_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "account_instruction_code_key" ON "account_instruction"("code");

CREATE TABLE "member_account_instruction" (
    "id" SERIAL NOT NULL,
    "member_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL DEFAULT 10000,
    "instruction_type" TEXT NOT NULL DEFAULT 'USER_DEFINED',
    "instruction" TEXT NOT NULL,

    CONSTRAINT "member_account_instruction_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_mai_member" ON "member_account_instruction"("member_id");
ALTER TABLE "member_account_instruction" ADD CONSTRAINT "member_account_instruction_member_id_fkey"
    FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "member_application_account_instruction" (
    "id" SERIAL NOT NULL,
    "application_no" TEXT NOT NULL,
    "line_no" INTEGER NOT NULL DEFAULT 10000,
    "instruction_type" TEXT NOT NULL DEFAULT 'USER_DEFINED',
    "instruction" TEXT NOT NULL,

    CONSTRAINT "member_application_account_instruction_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_aai_no" ON "member_application_account_instruction"("application_no");
ALTER TABLE "member_application_account_instruction" ADD CONSTRAINT "member_application_account_instruction_application_no_fkey"
    FOREIGN KEY ("application_no") REFERENCES "member_application"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "member_edit_account_instruction" (
    "id" SERIAL NOT NULL,
    "edit_no" TEXT NOT NULL,
    "line_no" INTEGER NOT NULL DEFAULT 10000,
    "instruction_type" TEXT NOT NULL DEFAULT 'USER_DEFINED',
    "instruction" TEXT NOT NULL,

    CONSTRAINT "member_edit_account_instruction_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_eai_no" ON "member_edit_account_instruction"("edit_no");
ALTER TABLE "member_edit_account_instruction" ADD CONSTRAINT "member_edit_account_instruction_edit_no_fkey"
    FOREIGN KEY ("edit_no") REFERENCES "member_edit_request"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- A starter set of predefined instructions the admin can extend or deactivate.
INSERT INTO "account_instruction" ("code", "description", "active", "sort") VALUES
  ('NO_THIRD_PARTY',   'No third-party withdrawals — the member must transact in person',        1, 10),
  ('CALL_BEFORE_WD',   'Call the member to confirm before paying any withdrawal',                1, 20),
  ('BOTH_SIGNATORIES', 'Withdrawals require both signatories',                                   1, 30),
  ('ID_ALWAYS',        'Always sight the original national ID / passport before transacting',     1, 40),
  ('SMS_ALL_TXN',      'Send an SMS alert to the member on every transaction',                    1, 50),
  ('NO_CHEQUE_BOOK',   'Cheque book facility not allowed on this account',                        1, 60),
  ('STMT_EMAIL_QTR',   'E-mail the account statement to the member every quarter',                1, 70),
  ('DECEASED_HOLD',    'Account frozen — refer any instruction to the Branch Manager',            0, 80)
ON CONFLICT ("code") DO NOTHING;

-- Permission page + grants for the Account Instructions setup screen (Setup Pool -> Membership),
-- following the ADMIN_POOL_CATEGORIES / ADMIN_POOL_SECTORS precedent (Branch Manager).
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, 'PAGE', 'ADMIN_ACCOUNT_INSTRUCTIONS', 0, 0, 0, 0, 1
FROM "role" r WHERE r.name = 'Branch Manager'
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");

INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, 'TABLE', 'account_instruction', 1, 1, 1, 1, 0
FROM "role" r WHERE r.name = 'Branch Manager'
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"   = GREATEST("permission_set_line"."read_perm",   EXCLUDED."read_perm"),
  "insert_perm" = GREATEST("permission_set_line"."insert_perm", EXCLUDED."insert_perm"),
  "modify_perm" = GREATEST("permission_set_line"."modify_perm", EXCLUDED."modify_perm"),
  "delete_perm" = GREATEST("permission_set_line"."delete_perm", EXCLUDED."delete_perm");

-- The instruction lines on applications / edits / members are managed by whoever manages those
-- documents, so grant the child tables wherever the parent's tables are already granted.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT psl.role_id, 'TABLE', t.name, psl.read_perm, psl.insert_perm, psl.modify_perm, psl.delete_perm, 0
FROM "permission_set_line" psl
JOIN (VALUES
  ('member_application_next_of_kin', 'member_application_account_instruction'),
  ('member_edit_next_of_kin',        'member_edit_account_instruction'),
  ('member_next_of_kin',             'member_account_instruction')
) AS t(src, name) ON t.src = psl.object_name
WHERE psl.object_type = 'TABLE'
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"   = GREATEST("permission_set_line"."read_perm",   EXCLUDED."read_perm"),
  "insert_perm" = GREATEST("permission_set_line"."insert_perm", EXCLUDED."insert_perm"),
  "modify_perm" = GREATEST("permission_set_line"."modify_perm", EXCLUDED."modify_perm"),
  "delete_perm" = GREATEST("permission_set_line"."delete_perm", EXCLUDED."delete_perm");
