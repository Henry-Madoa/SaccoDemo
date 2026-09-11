page 52203867 "Tender Committee Member"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    PageType = List;
    SourceTable = "Tender Committee Members";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tender No."; Rec."Tender No.")
                {
                    ApplicationArea = All;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                }
                field("Committee UserID"; Rec."Committee UserID")
                {
                    ApplicationArea = All;
                }
                field("Committee Member Name"; Rec."Committee Member Name")
                {
                    ApplicationArea = All;
                }
                field("Email Sent"; Rec."Email Sent")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
    trigger OnQueryClosePage(CloseAction: Action): Boolean begin
        if CloseAction in[ACTION::OK, ACTION::LookupOK]then begin
            EvaluationCommittee.Reset;
            EvaluationCommittee.SetRange("Reference No", Rec."Tender No.");
            if EvaluationCommittee.FindSet then begin
                EvaluationCommittee.DeleteAll;
            end;
            TenderCommitteeMembers.Reset;
            TenderCommitteeMembers.SetRange("Tender No.", Rec."Tender No.");
            if TenderCommitteeMembers.FindFirst then begin
                repeat EvaluationCommittee.Init;
                    case EvaluationCommittee.Stage of EvaluationCommittee.Stage::Mandatory: begin
                        EvaluationCommittee."Reference No":=TenderCommitteeMembers."Tender No.";
                        EvaluationCommittee."User Name":=TenderCommitteeMembers."Committee UserID";
                        EvaluationCommittee.Validate("User Name");
                        EvaluationCommittee.Stage:=EvaluationCommittee.Stage::Mandatory;
                    end;
                    EvaluationCommittee.Stage::Technical: begin
                        EvaluationCommittee."Reference No":=TenderCommitteeMembers."Tender No.";
                        EvaluationCommittee."User Name":=TenderCommitteeMembers."Committee UserID";
                        EvaluationCommittee.Validate("User Name");
                        EvaluationCommittee.Stage:=EvaluationCommittee.Stage::Technical;
                    end;
                    end;
                    EvaluationCommittee.Insert;
                until TenderCommitteeMembers.Next = 0;
            end;
        end;
    end;
    var EvaluationCommittee: Record "Evaluation Committee";
    TenderCommitteeMembers: Record "Tender Committee Members";
}
