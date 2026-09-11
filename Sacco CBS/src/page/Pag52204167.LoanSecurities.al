page 52204167 "Loan Securities"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Securities";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Loan No"; Rec."Loan No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Security Type"; Rec."Security Type")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Security Code"; Rec."Security Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Security Value"; Rec."Security Value")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Outstanding Value"; Rec."Linked Loan Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Guarantee; Rec.Guarantee)
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
