page 52203722 "Earning & Deductions Approval"
{
    Editable = false;
    PageType = List;
    SourceTable = "Payroll Employee Transaction";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction Code"; Rec."Transaction Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transaction Name"; Rec."Transaction Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Temporary Transaction"; Rec."Temporary Transaction")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Period Month"; Rec."Period Month")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Period Year"; Rec."Period Year")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Payroll Period"; Rec."Payroll Period")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Loan Number"; Rec."Loan Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Imprest No"; Rec."Imprest No")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
