page 52203536 "Approval Status"
{
    PageType = Card;
    SourceTable = "User Setup";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Approver ID"; ApprovalSetup."Approver ID")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Substitute; ApprovalSetup.Substitute)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Signature Card"; Rec."Signature Card")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Rec.SetRange("User ID", UserId);
        if ApprovalSetup.Get(Rec."User ID") then;
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange("User ID", UserId);
        if ApprovalSetup.Get(Rec."User ID") then;
    end;

    var
        ApprovalSetup: Record "User Setup";
}
