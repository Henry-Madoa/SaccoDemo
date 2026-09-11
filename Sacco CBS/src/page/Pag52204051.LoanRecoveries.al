page 52204051 "Loan Recoveries"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Recoveries";

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
                field("Recovery Type"; Rec."Recovery Type")
                {
                    Visible = false;
                }
                field("Recovery Code"; Rec."Recovery Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recovery Description"; Rec."Recovery Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Balance"; Rec."Current Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Commission %"; Rec."Commission %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Commission Amount"; Rec."Commission Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Commission Account"; Rec."Commission Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Prorated Interest"; Rec."Prorated Interest")
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
