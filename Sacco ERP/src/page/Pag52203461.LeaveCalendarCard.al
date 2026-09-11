page 52203461 "Leave Calendar Card"
{
    InsertAllowed = true;
    ModifyAllowed = true;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Reports,Functions';
    SourceTable = "Leave Calendar";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

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
                field("Date Created"; Rec."Date Created")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Modified By"; Rec."Last Modified By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date Modified"; Rec."Date Modified")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control12; "HR Non Working Days & Dates")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control10; "HR Leave Calendar Lines")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = Code=FIELD("Calendar Code");
            }
            part(Control14; "Accrual Periods")
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
                SubPageLink = "Calender Code"=FIELD("Calendar Code");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Create Accrual Periods")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create Accrual Periods';
                Image = CalculateCalendar;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    Text8000: Text;
                    TEXT0025: Label 'Saturday';
                    TEXT0026: Label 'Sunday';
                begin
                    Rec.TestField("Calendar Code");
                    Rec.TestField("Start Date");
                    Evaluate(DateFormulaVariable, '1M');
                    CreateAccrualCalender.CreateCalender(Rec."Calendar Code", CalcDate('CM', Rec."Start Date"), DateFormulaVariable, 11);
                end;
            }
        }
    }
    var Day: Date;
    Date: Record Date;
    HRCalendarList: Record "Leave Calendar";
    CreateAccrualCalender: Codeunit "Create Accrual Calender";
    DateFormulaVariable: DateFormula;
    local procedure DetermineNonWorking(currDate: Date)isNonWorking: Boolean var
        HRNonWorkingDays: Record "Non Working Days & Dates";
    begin
    /*
            isNonWorking:=FALSE;
            HRCalendarList.Reason:='';

            HRNonWorkingDays.RESET;
            IF HRNonWorkingDays.GET(currDate) THEN
            BEGIN
                isNonWorking:=TRUE;
                HRCalendarList.Reason:=HRNonWorkingDays.Reason;
            end;
            */
    end;
}
