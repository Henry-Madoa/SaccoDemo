page 52204035 "Loanees Payroll Codes"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loanees Payroll Codes";

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
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Is Cash"; Rec."Is Cash")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec.Type = Rec.Type::Income;
                }
                field("Cleared Effect"; Rec."Cleared Effect")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Taxable; Rec.Taxable)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec.Type = Rec.Type::Income;
                }
                field("Is Formula"; Rec."Is Formula")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Formula; Rec.Formula)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
