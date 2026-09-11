page 52203569 "Appraisal Calendar Card"
{
    PageType = Card;
    SourceTable = "Appraisal Calender";

    layout
    {
        area(content)
        {
            group("Calendar Details")
            {
                Editable = PageEditable;

                field("Calendar Code"; Rec."Calendar Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Calendar Description"; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Period Start Date"; Rec."Period Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Period End Date"; Rec."Period End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Calender"; Rec."Current Calender")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Long Term Objective End Date"; Rec."Long Term Objective End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
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
            action("Close Period")
            {
                ApplicationArea = BasicHR;
                Caption = 'Close Period & Open New';
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
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        ControlPageAppearance();
    end;
    trigger OnAfterGetRecord()
    begin
        ControlPageAppearance();
    end;
    trigger OnOpenPage()
    begin
        ControlPageAppearance();
    end;
    var PageEditable: Boolean;
    AppraisalPeriodEditable: Boolean;
    HrAppraisalManagement: Codeunit "Appraisal Management";
    local procedure ControlPageAppearance()
    begin
        if Rec.Closed then PageEditable:=false
        else
            PageEditable:=true;
        if Rec."Calendar Type" in[Rec."Calendar Type"::Predifined]then AppraisalPeriodEditable:=true
        else
            AppraisalPeriodEditable:=false end;
}
