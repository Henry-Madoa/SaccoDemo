page 52203548 "SS Company Documents Card"
{
    Caption = 'Company Documents';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "Company Documents";

    layout
    {
        area(content)
        {
            group(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Name"; Rec."Document Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(50636), "No."=FIELD("No.");
            }
        }
        area(factboxes)
        {
            systempart(Control7; Notes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    trigger OnOpenPage()
    begin
        if UserSetup.Get(UserId)then if not UserSetup."In Management" then Rec.SetRange("Visible To", Rec."Visible To"::"All Staff");
    end;
    var UserSetup: Record "User Setup";
}
