page 52204226 "Loan Charges"
{
    PageType = List;
    SourceTable = "Loan Charges";
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Charge Code"; Rec."Charge Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Charge Description"; Rec."Charge Description")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec.Editable;
                }
            }
        }
    }
}
