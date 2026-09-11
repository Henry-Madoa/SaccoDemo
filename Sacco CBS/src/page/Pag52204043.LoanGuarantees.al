page 52204043 "Loan Guarantees"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Guarantees";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Member No"; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Guaranteed Amount"; Rec."Guaranteed Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Deposits"; Rec."Member Deposits")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Self; Rec.Self)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Multiplied Deposits"; Rec."Multiplied Deposits")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Outstanding Guarantees"; Rec."Outstanding Guarantees")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Substituted; Rec.Substituted)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Substituted By"; Rec."Substituted By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Owner"; Rec."Loan Owner")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(Factboxes)
        {
            part("Loan Statistics"; "Loan Statistics")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Loan No");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Open Document")
            {
                ApplicationArea = Basic, Suite;
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    LoanCard: Page Loan;
                    Loans: Record Loans;
                begin
                    Clear(LoanCard);
                    Loans.Reset();
                    Loans.SetRange("No.", Rec."Loan No");
                    if Loans.FindSet() then begin
                        LoanCard.SetTableView(Loans);
                        LoanCard.RunModal();
                    end;
                end;
            }
        }
    }
}
