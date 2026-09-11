page 52204196 "Loan Repayment Lines"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Repayment Lines";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Loan No"; Rec."Loan No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Amount"; Rec."Payment Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Name"; Rec."Loan Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Penalty Balance"; Rec."Penalty Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Accrued Interest"; Rec."Accrued Interest")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Balance"; Rec."Interest Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principal Balance"; Rec."Principal Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Balance"; Rec."Loan Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Account"; Rec."Loan Account")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
