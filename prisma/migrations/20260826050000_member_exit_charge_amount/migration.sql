-- The exit charge actually posted at processing time — shown on the Member Exit card and used
-- to net the displayed "Net amount" figure, same as loan.fees_charged's own precedent.
ALTER TABLE "member_exit" ADD COLUMN "charge_amount" BIGINT NOT NULL DEFAULT 0;
