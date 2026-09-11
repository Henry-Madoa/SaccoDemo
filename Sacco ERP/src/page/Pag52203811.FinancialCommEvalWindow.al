page 52203811 "Financial  Comm. Eval. Window"
{
    ApplicationArea = All;
    Caption = 'Financial Committee Evaluation Window';
    PageType = List;
    SourceTable = "Financial Commitee Evaluation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Commitee Member ID"; Rec."Commitee Member ID")
                {
                    ApplicationArea = All;
                }
                field("Comittee Member Name"; Rec."Comittee Member Name")
                {
                    ApplicationArea = All;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Quoted Amount"; Rec."Quoted Amount")
                {
                    ApplicationArea = All;
                }
                field("Technical Score"; Rec."Technical Score")
                {
                    ApplicationArea = All;
                }
                field("Financial Score"; Rec."Financial Score")
                {
                    ApplicationArea = All;
                }
                field("Total Score"; Rec."Total Score")
                {
                    ApplicationArea = All;
                }
                field("Award Bidder"; Rec."Award Bidder")
                {
                    ApplicationArea = All;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Submit Evaluation")
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.TestField("Commitee Member ID", UserId);
                    FinancialCommiteeEvaluation.Reset;
                    FinancialCommiteeEvaluation.SetRange("Reference No.", Rec."Reference No.");
                    FinancialCommiteeEvaluation.SetRange("Commitee Member ID", UserId);
                    FinancialCommiteeEvaluation.SetRange("Award Bidder", true);
                    if FinancialCommiteeEvaluation.FindFirst then begin
                        EvaluationCommittee.Reset;
                        EvaluationCommittee.SetRange("Reference No", FinancialCommiteeEvaluation."Reference No.");
                        EvaluationCommittee.SetRange("User Name", FinancialCommiteeEvaluation."Commitee Member ID");
                        EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Financial);
                        if EvaluationCommittee.FindFirst then begin
                            EvaluationCommittee."Submitted Financial Evaluation":=true;
                            if EvaluationCommittee.Modify(true)then Message('Evaluation submitted successfully');
                        end;
                    end
                    else
                    begin
                        Error('You have not picked a bidder to award');
                    end;
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        ProcurementSetup.Get;
        if ProcurementSetup."Procurement Officer User Id" <> UserId then Rec.SetRange("Commitee Member ID", UserId);
    end;
    var EvaluationCommittee: Record "Evaluation Committee";
    FinancialCommiteeEvaluation: Record "Financial Commitee Evaluation";
    ProcurementSetup: Record "Purchases & Payables Setup";
}
