page 52203546 "SS Company Documents"
{
    Caption = 'Company Documents';
    CardPageID = "SS Company Documents Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Company Documents";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Name"; Rec."Document Name")
                {
                    ApplicationArea = Basic, Suite;
                }
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
