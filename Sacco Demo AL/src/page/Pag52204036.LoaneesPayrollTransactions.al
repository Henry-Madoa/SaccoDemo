page 52204036 "Loanees Payroll Transactions"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loanees Payroll Transactions";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cleared Effect"; Rec."Cleared Effect")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = ((not Rec."Is Formula") or (Rec."Transaction Type" <> Rec."Transaction Type"::"1/3 Basic Salary"));
                }
                field(Type; Rec.Type)
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Source No."; Rec."Source No.")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnModifyRecord(): Boolean
    begin
        if Loans.Get(Rec."Source No.") then
            Loans.TestField(Status, Loans.Status::Open);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if Loans.Get(Rec."Source No.") then
            Loans.TestField(Status, Loans.Status::Open);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Loans.Get(Rec."Source No.") then
            Loans.TestField(Status, Loans.Status::Open);
    end;

    var
        Loans: Record Loans;
}
