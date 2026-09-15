-- An Employee Editing request proposes a passport photo / specimen signature alongside the other
-- details: snapshotted from the employee when raised, replaceable on the request, applied with it.
ALTER TABLE "employee_edit_request" ADD COLUMN "photo_image" TEXT;
ALTER TABLE "employee_edit_request" ADD COLUMN "signature_image" TEXT;
