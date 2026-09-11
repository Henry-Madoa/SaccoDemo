pageextension 52204030 "Payroll Vital Setup" extends "Payroll Vital Setup"
{
    layout
    {
        addbefore("Tax Relief")
        {
            field("Salary Charge"; Rec."Salary Charge")
            {
                ApplicationArea = All;
            }
        }
    }
}
