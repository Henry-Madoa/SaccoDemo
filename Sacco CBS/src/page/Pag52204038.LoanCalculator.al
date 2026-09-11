page 52204038 "Loan Calculator"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Loan Calculator";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No"; Rec."Member No")
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
                field("Installments (Months)"; Rec."Installments (Months)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Repayment Start Date"; Rec."Repayment Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Appraisal Parameters")
            {
                field("Current Deposits"; Rec."Current Deposits")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Deposit Multiplier"; Rec."Loan Deposit Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Ouststanding Loans"; Rec."Ouststanding Loans")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Deposit Appraisal"; Rec."Deposit Appraisal")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Payslip Details")
            {
                field(Earnings; Rec.Earnings)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Deductions; Rec.Deductions)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Net Income"; Rec."Net Income")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Available"; Rec."Amount Available")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("Calculator Lines"; "Loan Calculator Lines")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Calculator No" = field("No.");
            }
            group(Audit)
            {
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
    actions
    {
        area(Processing)
        {
            action("Calculate")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = CalculatePlanChange;

                trigger OnAction()
                var
                    LoansManagement: Codeunit "Loans Management";
                    LoaneeTransactions: Record "Loanees Payroll Transactions";
                    BasicPay: Decimal;
                begin
                    Rec.TestField(Earnings);
                    LoansManagement.GenerateCalculatorSchedule(Rec);
                    Commit();
                    LoaneeTransactions.Reset();
                    LoaneeTransactions.SetRange("Source No.", Rec."No.");
                    LoaneeTransactions.SetRange(Code, '001');
                    if LoaneeTransactions.findset then BasicPay := LoaneeTransactions.Amount;
                    Rec.CalcFields("Net Income");
                    Rec."Amount Available" := Rec."Net Income" - ((1 / 3) * BasicPay);
                    Rec.Modify;
                end;
            }
            action("Payroll Earnings")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Accounts;
                RunObject = page "Loanees Payroll Transactions";
                RunPageLink = "Source No." = field("No."), Type = const(Income);
            }
            action("Payroll Deductions")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = PayrollStatistics;
                RunObject = page "Loanees Payroll Transactions";
                RunPageLink = "Source No." = field("No."), Type = const(Deduction);
            }
        }
    }
}
