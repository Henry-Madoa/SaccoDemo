tableextension 52204022 "Payroll Vital Setup" extends "Payroll Vital Setup"
{
    fields
    {
        field(52204000; "Salary Charge"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
    }
}
