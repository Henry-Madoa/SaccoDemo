tableextension 52204012 "Payroll Transaction Code" extends "Payroll Transaction Code"
{
    fields
    {
        field(52204000; "Posting Type"; Enum "Product Posting Type")
        {
        }
        field(52204001; "Loan Product"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false));
        }
    }
}
