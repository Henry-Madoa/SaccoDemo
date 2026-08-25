page 52204121 "Checkoff Advice"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Checkoff Advice";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No"; Rec."Entry No")
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
                field("Payroll No."; Rec."Payroll No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employer Code"; Rec."Employer Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Name"; Rec."Product Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Advice Date"; Rec."Advice Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Advice Type"; Rec."Advice Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Off"; Rec."Amount Off")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount On"; Rec."Amount On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Balance"; Rec."Current Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan No"; Rec."Loan No")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loan Account.';
                }
                field("Recovery Mode"; Rec."Recovery Mode")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principal Repayment"; Rec."Principal Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Repayment"; Rec."Interest Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Monthly Repayment"; Rec."Monthly Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Principal Repayment"; Rec."Total Principal Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Interest Repayment"; Rec."Total Interest Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Repayment"; Rec."Total Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Balance"; Rec."Loan Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
