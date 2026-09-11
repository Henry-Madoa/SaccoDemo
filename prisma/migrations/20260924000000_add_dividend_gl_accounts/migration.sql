-- The two G/L accounts the Dividend module posts through, added inside the existing
-- Begin-Total/End-Total brackets so the chart's totals pick them up without any re-indenting:
--   2125 sits inside OTHER LIABILITIES  (2100..2199)
--   5095 sits inside EXPENDITURE        (5000..5099)
--
-- Both are ordinary Posting accounts at indentation 1, matching their siblings. 5010 "Interest on
-- Member Deposits" already exists and remains the natural expense account for a FOSA interest
-- declaration; 5095 is for the BOSA dividend on deposits and share capital, which SACCOs report
-- separately from deposit interest.

INSERT INTO "gl_account" ("code", "name", "type", "parent_code", "is_postable", "account_type", "indentation", "status")
SELECT * FROM (VALUES
  ('2125', 'Dividend Payable to Members', 'LIABILITY', '2100', 1, 'POSTING', 1, 'ACTIVE'),
  ('5095', 'Dividend on Member Deposits and Shares', 'EXPENSE', '5000', 1, 'POSTING', 1, 'ACTIVE')
) AS v(code, name, type, parent_code, is_postable, account_type, indentation, status)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;
