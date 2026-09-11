page 52203711 "Employee Salary Card"
{
    PageType = ListPart;
    SourceTable = "Payroll Salary Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Basic Pay"; Rec."Basic Pay")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Payment Mode"; Rec."Payment Mode")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Pays NSSF"; Rec."Pays NSSF")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Pays SHIF"; Rec."Pays SHIF")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Pays PAYE"; Rec."Pays PAYE")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Certificate?"; Rec."Insurance Certificate?")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
