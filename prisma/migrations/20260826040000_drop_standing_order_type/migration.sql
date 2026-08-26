-- Standing Order Type is redundant with Standing Order Class: the standing order itself already
-- carries every instruction (amount, destination, class, charge) a recovery needs, so matching
-- by class alone is sufficient. Drop the free-text type tag from both sides.
ALTER TABLE "standing_order" DROP COLUMN "sto_type";
ALTER TABLE "transaction_recovery" DROP COLUMN "sto_type";
