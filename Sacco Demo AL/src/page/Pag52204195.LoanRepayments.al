page 52204195 "Loan Repayments"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Repayment Header";
    CardPageId = "Loan Repayment";
    Editable = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
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
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
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
                    if Confirm('Do you want to Post Loan Repayment?') then LoansMgt.PostLoanRepayment(Rec."No.");
                end;
            }
        }
    }
}
