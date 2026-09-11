page 52203641 "Clearance Forms"
{
    CardPageID = "Clearance Form Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Exit Clearance Form";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Form No"; Rec."Form No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Exit No"; Rec."Exit No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 4 Code"; Rec."Global Dimension 4 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Responsible Employee"; Rec."Responsible Employee")
                {
                    ApplicationArea = BasicHR;
                }
            }
        }
    }
}
