page 52204037 "Loan Calculators"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Calculator";
    CardPageId = "Loan Calculator";

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
                field("Loan Product"; Rec."Loan Product")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Description"; Rec."Product Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principal Amount"; Rec."Principal Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Installments (Months)"; Rec."Installments (Months)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Repayment Start Date"; Rec."Repayment Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
