page 52203694 "Training Plan List"
{
    CardPageID = "Training Plan Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Training Plan";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Plan No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Calender Code"; Rec."Calender Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Calender Start Date"; Rec."Calender Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Calender End Date"; Rec."Calender End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Period"; Rec."Training Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
