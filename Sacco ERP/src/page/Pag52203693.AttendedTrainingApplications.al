page 52203693 "Attended Training Applications"
{
    CardPageID = "Training Application";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Training Application";
    SourceTableView = WHERE(Status=CONST(Attended));

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
                field("Date of Application"; Rec."Date of Application")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Calender"; Rec."Training Calender")
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
                field(Period; Rec.Period)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Trainer; Rec.Trainer)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
