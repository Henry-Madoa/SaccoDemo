tableextension 52204013 "Payroll Emp Transaction" extends "Payroll Employee Transaction"
{
    fields
    {
        field(19; "Loan Product"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false));
        }
    }
}
