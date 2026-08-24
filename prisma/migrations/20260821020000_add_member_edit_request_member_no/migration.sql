-- Lets a Member Edit request change the member's Member No. itself, not just the fields it
-- already snapshotted (name, contact details, etc.) — editable while the request is still Open,
-- applied onto the live member when the (approved) request is processed. Nullable and additive:
-- an in-flight request created before this column existed simply falls back to the live
-- member's own number until read/write code (lib/memberEdits.ts) starts populating it.
ALTER TABLE "member_edit_request" ADD COLUMN "member_no" TEXT;
