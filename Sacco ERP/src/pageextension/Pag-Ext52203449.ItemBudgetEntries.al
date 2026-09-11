pageextension 52203449 "Item Budget Entries" extends "Item Budget Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter(Quantity)
        {
            field("Items Requested"; Rec."Items Requested")
            {
                ApplicationArea = Basic, Suite;
                Style = Attention;
            }
            field(BudgetBalance; BudgetBalance)
            {
                ApplicationArea = Basic, Suite;
                Style = Attention;
                Caption = 'Balance';
            }
            field(BurnRate; BurnRate)
            {
                ApplicationArea = Basic, Suite;
                Style = Attention;
                Caption = 'Burn Rate';
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Items Requested");
        if Rec.Quantity <> 0 then begin
            BudgetBalance := Rec.Quantity - Rec."Items Requested";
            IF BudgetBalance <> 0 THEN
                BurnRate := ROUND(Rec."Items Requested" / Rec.Quantity, 0.01)
            ELSE
                BurnRate := 0;
        end;
    end;

    var
        BudgetBalance: Decimal;
        BurnRate: Decimal;
}
