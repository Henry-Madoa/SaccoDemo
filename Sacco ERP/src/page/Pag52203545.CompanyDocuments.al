page 52203545 "Company Documents"
{
    Caption = 'Company Documents';
    CardPageID = "Company Documents Card";
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
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Name"; Rec."Document Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Visible To"; Rec."Visible To")
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
}
