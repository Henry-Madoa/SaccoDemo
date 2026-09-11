-- Business Central Begin-Total / End-Total bracketing for the chart of accounts, following the
-- convention already established by hand on CASH AND CASH EQUIVALENTS:
--
--   1000  CASH AND CASH EQUIVALENTS          Begin-Total   indent 0
--   1010    Cash in Hand — Tellers           Posting       indent 1
--   …
--   1099  CASH AND CASH EQUIVALENTS  TOTALS  End-Total     indent 0   Totaling 1000..1099
--
-- So: the End-Total takes the block-end code (xx99), repeats the group name with a "  TOTALS"
-- suffix, and carries the range. Every remaining group is bracketed the same way.
--
-- Two groups cannot use the plain block-end code:
--   * OTHER ASSETS closes at 1239 because TRADE AND OTHER RECEIVABLES opens at 1240 — they are
--     peers on the balance sheet, so they are bracketed as siblings rather than nested.
--   * INCOME closes at 4089 because SALES AND SERVICE INCOME opens at 4090, which then closes
--     at 4199 (4099 is already a posting account, Late Payment and Reminder Fees).
-- And one group must nest: TRADE AND OTHER PAYABLES (2145..2180) sits inside OTHER LIABILITIES
-- (2100..2199) because Withholding Tax/VAT Payable (2190, 2195) belong to OTHER LIABILITIES but
-- come after the payables codes. Nesting does not double-count — only Posting accounts
-- contribute to a range, and an End-Total holds no entries of its own.

-- 1. Group headings become Begin-Totals (1000 is already one and is left alone).
UPDATE "gl_account"
   SET "account_type" = 'BEGIN_TOTAL', "is_postable" = 0
 WHERE "code" IN ('1100','1200','1240','1400','2000','2100','2145','3000','4000','4090','5000')
   AND "account_type" = 'HEADING';

-- 2. The End-Total that closes each group.
INSERT INTO "gl_account" ("code","name","type","parent_code","is_postable","account_type","totaling","indentation")
VALUES
  ('1099','CASH AND CASH EQUIVALENTS  TOTALS','ASSET',NULL,0,'END_TOTAL','1000..1099',0),
  ('1199','LOANS AND ADVANCES TO MEMBERS  TOTALS','ASSET',NULL,0,'END_TOTAL','1100..1199',0),
  ('1239','OTHER ASSETS  TOTALS','ASSET',NULL,0,'END_TOTAL','1200..1239',0),
  ('1299','TRADE AND OTHER RECEIVABLES  TOTALS','ASSET',NULL,0,'END_TOTAL','1240..1299',0),
  ('1499','PROPERTY, PLANT AND EQUIPMENT  TOTALS','ASSET',NULL,0,'END_TOTAL','1400..1499',0),
  ('2099','MEMBER DEPOSITS  TOTALS','LIABILITY',NULL,0,'END_TOTAL','2000..2099',0),
  ('2180','TRADE AND OTHER PAYABLES  TOTALS','LIABILITY',NULL,0,'END_TOTAL','2145..2180',1),
  ('2199','OTHER LIABILITIES  TOTALS','LIABILITY',NULL,0,'END_TOTAL','2100..2199',0),
  ('3099','CAPITAL AND RESERVES  TOTALS','EQUITY',NULL,0,'END_TOTAL','3000..3099',0),
  ('4089','INCOME  TOTALS','INCOME',NULL,0,'END_TOTAL','4000..4089',0),
  ('4199','SALES AND SERVICE INCOME  TOTALS','INCOME',NULL,0,'END_TOTAL','4090..4199',0),
  ('5099','EXPENDITURE  TOTALS','EXPENSE',NULL,0,'END_TOTAL','5000..5099',0)
ON CONFLICT ("code") DO NOTHING;

-- 3. Indentation, as Indent Chart of Accounts would compute it — so the chart reads correctly
--    straight away and the action reports "already indented" on its first run.
UPDATE "gl_account" SET "indentation" = 1
 WHERE "parent_code" IN ('1000','1100','1200','1240','1400','2000','2100','2145','3000','4000','4090','5000');

UPDATE "gl_account" SET "indentation" = 2 WHERE "parent_code" = '2145';
