tableextension 52203465 "Approval Comment Line" extends "Approval Comment Line"
{
    fields
    {
    }
    trigger OnBeforeInsert()
    var
        LoginMgmt: Codeunit "User Management Ext";
    begin
        if not LoginMgmt.IsWebServiceUser then begin
            Evaluate("Record ID to Approve", GetFilter("Record ID to Approve"));
            Evaluate("Document No.", GetFilter("Document No."));
        end;
        "User ID" := UserId;
        "Date and Time" := CreateDateTime(Today, Time);
        if "Entry No." = 0 then "Entry No." := GetNextEntryNo;
    end;

    local procedure GetNextEntryNo(): Integer
    var
        ApprovalCommentLine: Record "Approval Comment Line";
    begin
        ApprovalCommentLine.SetCurrentKey("Entry No.");
        if ApprovalCommentLine.FindLast then exit(ApprovalCommentLine."Entry No." + 1);
        exit(1);
    end;
}
