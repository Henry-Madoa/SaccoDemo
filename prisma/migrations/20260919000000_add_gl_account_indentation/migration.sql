-- Business Central's "Indent Chart of Accounts" persists each account's depth on the account
-- itself (Table 15 "G/L Account"."Indentation") rather than deriving it at render time, so the
-- chart reads the same everywhere — the list, an export, a financial report.
ALTER TABLE "gl_account" ADD COLUMN "indentation" INTEGER NOT NULL DEFAULT 0;
