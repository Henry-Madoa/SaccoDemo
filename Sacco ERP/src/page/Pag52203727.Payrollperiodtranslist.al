page 52203727 "Payroll period trans list"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Payroll Period Transaction";

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
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Period Month"; Rec."Period Month")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Period Year"; Rec."Period Year")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payroll Period"; Rec."Payroll Period")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
