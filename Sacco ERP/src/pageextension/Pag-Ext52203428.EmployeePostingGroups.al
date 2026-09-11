pageextension 52203428 "Employee Posting Groups" extends "Employee Posting Groups"
{
    layout
    {
        // Add changes to page layout here
        addafter("Payables Account")
        {
            field("Salary Expense Account"; Rec."Salary Expense Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("PAYE Payable Account"; Rec."PAYE Payable Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Net Payable Account"; Rec."Net Payable Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("NSSF Employee"; Rec."NSSF Employee")
            {
                ApplicationArea = Basic, Suite;
            }
            field("NSSF Employer Account"; Rec."NSSF Employer Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Pension Employer Acc"; Rec."Pension Employer Acc")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Gratuity Account"; Rec."Gratuity Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("National Housing Fund"; Rec."National Housing Fund")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Employer National Housing Fund"; Rec."Employer National Housing Fund")
            {
                ApplicationArea = Basic, Suite;
            }
            field("SHIF Account"; Rec."SHIF Account")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
