page 52203568 "Appraisal Calender Lines"
{
    PageType = ListPart;
    SourceTable = "Appraisal Calender Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Period Name"; Rec."Period Name")
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
            group(Functions)
            {
                action("Close Period")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Close Period & Open New';
                    Image = ClosePeriod;

                    trigger OnAction()
                    var
                        AppraisalCalendarLines: Record "Appraisal Calender Lines";
                    begin
                        if not Confirm('Are you sure you want to close appraisal period?')then AppraisalCalendarLines.Reset;
                        AppraisalCalendarLines.SetCurrentKey("Start Date");
                        AppraisalCalendarLines.SetRange("Calender Code", Rec."Calender Code");
                        AppraisalCalendarLines.SetRange(Closed, false);
                        if AppraisalCalendarLines.FindFirst then HrAppraisalManagement.OnCloseAppraisalCalenderPeriod(AppraisalCalendarLines)
                        else
                            Message('No Open Period was found');
                    end;
                }
                action("Initialize Appraisal")
                {
                    ApplicationArea = BasicHR;
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                    // IF NOT CONFIRM('Are you sure you want to start appraisal for '+FORMAT(Rec."Period Name")+' ?') THEN
                    //  EXIT;
                    //
                    // AppraisalCalendarLines.RESET;
                    // AppraisalCalendarLines.SETCURRENTKEY("Start Date");
                    // AppraisalCalendarLines.SETRANGE("Calender Code",Rec."Calender Code");
                    // AppraisalCalendarLines.SETRANGE(Closed,FALSE);
                    // IF AppraisalCalendarLines.FINDFIRST THEN
                    //  HrAppraisalManagement.OnInitializeAppraisal(AppraisalCalendarLines."Calender Code",AppraisalCalendarLines."Period Name")
                    // ELSE
                    //  MESSAGE('No Open Period was found');
                    end;
                }
            }
        }
    }
    var HrAppraisalManagement: Codeunit "Appraisal Management";
    AppraisalCalender: Record "Appraisal Calender";
    PageColumnEditable: Boolean;
    AppraisalCalendarLines: Record "Appraisal Calender Lines";
}
