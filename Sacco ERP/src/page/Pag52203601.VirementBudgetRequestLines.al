page 52203601 "Virement Budget Request Lines"
{
    PageType = ListPart;
    SourceTable = "Virement Budget Request Lines";
    MultipleNewLines = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transfer From"; Rec."Transfer From")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Unfavorable;
                }
                field("Transfer To"; Rec."Transfer To")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Favorable;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                }
            }
        }
    }
}
