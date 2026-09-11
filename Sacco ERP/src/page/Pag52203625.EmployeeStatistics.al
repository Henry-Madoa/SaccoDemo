page 52203625 "Employee Statistics"
{
    PageType = CardPart;
    SourceTable = Employee;

    layout
    {
        area(content)
        {
            field(Balance; Rec.Balance)
            {
                // DrillDownPageID = "Detailed Empl. Ledger View";
                ApplicationArea = Basic, Suite;
            }
            field("Balance (LCY)"; Rec."Balance (LCY)")
            {
                ApplicationArea = Basic, Suite;
            //DrillDownPageID = "Detailed Empl. Ledger View";
            }
            field("Unserended Imprest"; Rec."Unserended Imprest")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Surrendered Imprest"; Rec."Surrendered Imprest")
            {
                ApplicationArea = Basic, Suite;
            }
            field(Village; Rec.Village)
            {
                ApplicationArea = Basic, Suite;
            }
            field("Sub-Location"; Rec."Sub-Location")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
