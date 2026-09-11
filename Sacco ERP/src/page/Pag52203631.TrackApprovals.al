page 52203631 "Track Approvals"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Approval Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sender ID"; Rec."Sender ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approver ID"; Rec."Approver ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approval Date"; Rec."Last Date-Time Modified")
                {
                    Caption = 'Approval Date';
                }
            }
        }
    }
}
