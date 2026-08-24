-- Reverts 20260821020000_add_member_edit_request_member_no: Member No. editing turned out to
-- mean "re-target this request onto a different member" (lib/memberEdits.ts's
-- changeMemberEditRequestMember(), which re-derives member_no from a live join), not "rename
-- this member's own number" — so the request never needed its own copy of it. No row ever had
-- this column populated (every attempt at the old free-text field failed its own uniqueness
-- check before the write), so this drop loses nothing.
ALTER TABLE "member_edit_request" DROP COLUMN "member_no";
