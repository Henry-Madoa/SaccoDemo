page 52203519 "Appraisal Review Periods"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Appraisal Review Periods";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Editable = Rec.Status <> Rec.Status::Closed;

                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Review Type"; Rec."Review Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Quarterly Review"; Rec.Sequence)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Review Type" = Rec."Review Type"::Quarterly;
                }
                field("Period Length"; Rec."Period Length")
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
                field(Closed; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Re-Open Review Period")
            {
                ApplicationArea = Basic, Suite;
                Image = ReopenPeriod;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    Rec.TestField(Status, Rec.Status::Closed);
                    Rec.Validate(Status, Rec.Status::Open);
                    Rec.Modify(true);
                end;
            }
            action("Close/Update Review Period")
            {
                ApplicationArea = Basic, Suite;
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    If Rec.Status = Rec.Status::Open then begin
                        if not Confirm(StrSubstNo('Are you sure you want to Close %1', Rec.Description), false)then exit;
                        AppraisalMgmt.CloseAppraisalReviewPeriod(Rec, true);
                    end
                    else if Rec.Status = Rec.Status::Closed then begin
                            if not Confirm(StrSubstNo('Are you sure you want to Update Apraisals for %1', Rec.Description), false)then exit;
                            AppraisalMgmt.CloseAppraisalReviewPeriod(Rec, false);
                        end;
                end;
            }
        }
    }
    var AppraisalMgmt: Codeunit "Appraisal Management";
}
