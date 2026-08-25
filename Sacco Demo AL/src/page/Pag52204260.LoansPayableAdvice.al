page 52204260 "Loans Payable Advice"
{
    PageType = List;
    SourceTable = "Loans Payable Advice";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnModifyRecord(): Boolean
    begin
        if Loans.Get(Rec."Loan No") then
            Loans.TestField(Status, Loans.Status::Open);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if Loans.Get(Rec."Loan No") then
            Loans.TestField(Status, Loans.Status::Open);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Loans.Get(Rec."Loan No") then
            Loans.TestField(Status, Loans.Status::Open);
    end;

    var
        Loans: Record Loans;
}
