-- KRA P9 Tax Deduction Card (revised form, Tax Laws (Amendment) Act 2024): the run now keeps every
-- column the card prints — non-cash benefits (B), value of quarters (C), the defined-contribution
-- test E (lowest of 30% of basic, actual pension + NSSF, the fixed cap), owner-occupier interest (F),
-- and the post-2024 allowable deductions AHL (H), SHIF (I) and post-retirement medical fund (J).
-- Chargeable pay (K) = D - G - H - I - J stays in taxable_pay_cents.
ALTER TABLE "payroll_p9_line"
  ADD COLUMN "benefits_cents"                BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "quarters_cents"                BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "pension_cents"                 BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "defined_contribution_cents"    BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "owner_occupier_interest_cents" BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "prmf_cents"                    BIGINT NOT NULL DEFAULT 0;

-- Payroll Setup: the caps and switches behind columns E3, F, H, I and J. mortgage_relief_cents is
-- read as the owner-occupier interest cap (KES 30,000 a month from 27 Dec 2024).
ALTER TABLE "hr_payroll_setup"
  ADD COLUMN "pension_deduction_cap_cents" BIGINT  NOT NULL DEFAULT 3000000,
  ADD COLUMN "prmf_cap_cents"              BIGINT  NOT NULL DEFAULT 1500000,
  ADD COLUMN "shif_deductible"             BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN "housing_levy_deductible"     BOOLEAN NOT NULL DEFAULT true;
UPDATE "hr_payroll_setup" SET "mortgage_relief_cents" = 3000000 WHERE "mortgage_relief_cents" < 3000000;
