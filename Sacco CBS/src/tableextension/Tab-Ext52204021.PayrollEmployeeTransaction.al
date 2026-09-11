tableextension 52204021 "Payroll Employee Transaction" extends "Payroll Employee Transaction"
{
    fields
    {
        modify("Employee Code")
        {
            trigger OnAfterValidate()
            var
                Emp: Record Employee;
            begin
                If Emp.Get("Employee Code") then "Member No." := Emp."Member No.";
            end;
        }
        modify("Loan Number")
        {
            TableRelation = Loans where("Member No." = field("Member No."));

            trigger OnAfterValidate()
            var
                Loans: Record Loans;
            begin
                If Loans.Get("Loan Number") then begin
                    Loans.CalcFields("Monthly Installment");
                    Amount := Loans."Monthly Installment";
                end;
            end;
        }
        field(52204000; "Member No."; Code[20])
        {
        }
    }
}
