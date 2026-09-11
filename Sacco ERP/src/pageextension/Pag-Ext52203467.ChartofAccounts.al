pageextension 52203467 "Chart of Accounts" extends "Chart of Accounts"
{
    trigger OnOpenPage()
    begin
        CashmgmtSetUp.Get();
        CashmgmtSetUp.TestField("Current Budget");
    end;

    trigger OnAfterGetRecord()
    begin
        if ((CashmgmtSetUp."Current Budget Start Date" <> 0D) and (CashmgmtSetUp."Current Budget End Date" <> 0D)) then begin
            Rec.SETFILTER("Budget Filter", CashmgmtSetUp."Current Budget");
            Rec.SETFILTER("Date Filter", '%1..%2', CashmgmtSetUp."Current Budget Start Date", CashmgmtSetUp."Current Budget End Date");
            Rec.CALCFIELDS("Net Change", Balance, "Balance at Date", "Budgeted Amount", "Commitment Amount");
            if ((Rec."Account Category" = Rec."Account Category"::Expense) AND (Rec."Budgeted Amount" <> 0)) then
                AvailableBudget := Rec."Budgeted Amount" - Rec."Commitment Amount" - Rec.Balance
            else
                AvailableBudget := 0;
            IF Rec."Budgeted Amount" <> 0 THEN
                BurnRate := ROUND((Rec.Balance + Rec."Commitment Amount") / Rec."Budgeted Amount", 0.01)
            ELSE
                BurnRate := 0;
        end;
    end;

    var
        AvailableBudget: Decimal;
        CashmgmtSetUp: Record "General Ledger Setup";
        BurnRate: Decimal;
}
