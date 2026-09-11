page 52203687 "Training Calender List"
{
    CardPageID = "Training Calendar Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Training Calender";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Calender Code"; Rec."Calender Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Period"; Rec."Current Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("CLose Calender")
            {
                ApplicationArea = Basic, Suite;
                Image = CloseYear;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to close the period')then exit;
                    HrTrainingManagement.OnCloseTrainingCalendar(Rec);
                end;
            }
        }
    }
    var HrTrainingManagement: Codeunit "Training Mgmt";
}
