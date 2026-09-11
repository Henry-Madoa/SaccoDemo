page 52203439 "HR Leave Calendar List"
{
    CardPageID = "Leave Calendar Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Leave Calendar";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Calendar Code"; Rec."Calendar Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
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
                field("Current Leave Calendar"; Rec."Current Leave Calendar")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Closed On"; Rec."Closed On")
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
            action("Close & Open Period")
            {
                ApplicationArea = Basic, Suite;
                Image = Period;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Closed, false);
                    Rec.TestField("Current Leave Calendar", true);
                    if not Confirm('Are you sure you want to close Leave Period ' + Format(Rec."Calendar Code") + ' And Open ' + Format(Date2DMY(CalcDate('+1D', Rec."End Date"), 3)))then exit;
                    CloseLeavePeriod.CloseLeaveCalendar(Rec);
                end;
            }
        }
    }
    var CloseLeavePeriod: Codeunit "Close Leave Period";
}
