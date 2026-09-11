page 52203825 "Mandatory Evaluation Window"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Supplier Mandatory Evaluation";
    SourceTableView = SORTING("Vendor Name")ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Requirement Code"; Rec."Requirement Code")
                {
                    ApplicationArea = All;
                }
                field("Requirement Description"; Rec."Requirement Description")
                {
                    ApplicationArea = All;
                }
                field("Evaluator Name"; Rec."Evaluator Name")
                {
                    ApplicationArea = All;
                }
                field("Max Score"; Rec."Max Score")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Score; Rec.Score)
                {
                    ApplicationArea = All;
                }
                field(Complied; Rec.Complied)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Comment; Rec.Comment)
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
                Image = Completed;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to submit your evaluations')then exit;
                    EvaluationCommittee.Reset;
                    EvaluationCommittee.SetRange("User Name", UserId);
                    EvaluationCommittee.SetRange("Reference No", Rec."Reference No");
                    EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Mandatory);
                    if EvaluationCommittee.FindFirst then ProcStoreManagement.IanSubmitMandatoryScore(EvaluationCommittee)
                    else
                    begin
                        EvaluationCommittee.Reset;
                        EvaluationCommittee.SetRange(Substitute, UserId);
                        EvaluationCommittee.SetRange("Reference No", Rec."Reference No");
                        EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Mandatory);
                        if EvaluationCommittee.FindFirst then ProcStoreManagement.IanSubmitMandatoryScore(EvaluationCommittee);
                    end;
                    CurrPage.Close();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        ProcurementSetup.Get;
        if not(ProcurementSetup."Procurement Officer User Id" = UserId)then Rec.SetRange("Evaluator ID", UserId);
    end;
    var ProcStoreManagement: Codeunit "Proc & Store Management";
    EvaluationCommittee: Record "Evaluation Committee";
    ProcurementSetup: Record "Purchases & Payables Setup";
}
