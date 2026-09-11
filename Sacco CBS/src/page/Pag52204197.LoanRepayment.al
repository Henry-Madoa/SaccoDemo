page 52204197 "Loan Repayment"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Loan Repayment Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = not Rec.Posted;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Available Balance"; Rec."Available Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Amount"; Rec."Payment Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("Loans"; "Loan Repayment Lines")
            {
                Editable = not Rec.Posted;
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("No.");
            }
            group("Audit Trail")
            {
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Posted; Rec.Posted)
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
            action(Post)
            {
                ApplicationArea = Basic, Suite;
                Image = PostBatch;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = not Rec.Posted;

                trigger OnAction()
                var
                    LoansMgt: Codeunit "Loans Management";
                begin
                    Rec.CalcFields("Payment Amount");
                    Rec.Testfield("Payment Amount");
                    if Confirm('Do you want to Post Loan Repayment?') then
                        LoansMgt.PostLoanRepayment(Rec."No.");
                end;
            }
        }
    }
}
