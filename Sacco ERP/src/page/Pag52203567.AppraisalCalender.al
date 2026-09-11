page 52203567 "Appraisal Calender"
{
    CardPageID = "Appraisal Calendar Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Appraisal Calender";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Calendar Code"; Rec."Calendar Code")
                {
                    Editable = PageFieldEditable;
                    ApplicationArea = All;
                }
                field("Calendar Description"; Rec.Description)
                {
                    Editable = PageFieldEditable;
                    ApplicationArea = All;
                }
                field("Appraisal Period"; Rec."Appraisal Period")
                {
                    Editable = PageFieldEditable;
                    ApplicationArea = All;
                }
                field("Period Start Date"; Rec."Period Start Date")
                {
                    Editable = PageFieldEditable;
                    ApplicationArea = All;
                }
                field("Period End Date"; Rec."Period End Date")
                {
                    Editable = PageFieldEditable;
                    ApplicationArea = All;
                }
                field(Closed; Rec.Closed)
                {
                    Editable = PageFieldEditable;
                    ApplicationArea = All;
                }
                field("Current Calender"; Rec."Current Calender")
                {
                    Editable = PageFieldEditable;
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Review Periods")
            {
                ApplicationArea = BasicHR;
                Image = Period;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "Appraisal Review Periods";
                RunPageLink = "Calendar Code"=field("Calendar Code");
            }
            action("Initialize Appraisal")
            {
                ApplicationArea = BasicHR;
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = not Rec.Closed;

                trigger OnAction()
                begin
                    Rec.TestField("Calendar Code");
                    Rec.TestField(Description);
                    Rec.TestField("Period Start Date");
                    Rec.TestField("Period End Date");
                    if not Confirm('Are you sure you want to start appraisal for ' + Format(Rec.Description) + ' ?')then exit;
                    AppraisalReminders.InitialiseAppraisal(Rec);
                end;
            }
            action("Close Period")
            {
                ApplicationArea = BasicHR;
                Caption = 'Close Calendar';
                Image = ClosePeriod;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Closed, false);
                    if not Confirm('Are you sure you want to close appraisal period?')then HrAppraisalManagement.OnCloseAppraisalCalender(Rec);
                end;
            }
            action("Close Calendar")
            {
                ApplicationArea = BasicHR;
                Image = CloseYear;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = not Rec.Closed;

                trigger OnAction()
                begin
                    Rec.TestField("Calendar Code");
                    Rec.TestField(Description);
                    Rec.TestField("Period Start Date");
                    Rec.TestField("Period End Date");
                    if not Confirm(StrSubstNo('Are you sure you want to Close %1?', Rec.Description))then exit;
                    AppraisalReminders.CloseCalendar(Rec);
                end;
            }
        }
    }
    var PageFieldEditable: Boolean;
    AppraisalReminders: Codeunit "Appraisal Management";
    HrAppraisalManagement: Codeunit "Appraisal Management";
// local procedure SetControlAppearance()
// begin
//     if Rec.Closed then begin
//         PageFieldEditable := false;
//     end else
//         PageFieldEditable := true;
// end;
}
