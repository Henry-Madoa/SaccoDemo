page 52204183 "Account Statistics"
{
    PageType = CardPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = Vendor;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

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
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Uncleared Funds"; Rec."Uncleared Funds")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Available Balance"; BookBalance)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    var
        BookBalance: Decimal;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("Uncleared Funds", Balance);
        BookBalance := 0;
        BookBalance := Rec.Balance - Rec."Uncleared Funds";
    end;
}
