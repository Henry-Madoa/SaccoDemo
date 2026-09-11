report 52203559 "Leave Utilization Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Leave Utilization Report.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
            column(CompanyName; CompanyInformation.Name)
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyAddress; CompanyInformation.Address)
            {
            }
            column(CompanyPhone; CompanyInformation."Phone No.")
            {
            }
            column(CompanyLocation; CompanyInformation.Location)
            {
            }
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(No_Employee; Employee."No.")
            {
            }
            column(FullName_Employee; Employee.FullName)
            {
            }
            column(GlobalDimension2Code_Employee; Employee."Global Dimension 2 Code")
            {
            }
            column(AnnualLeaveBalance_Employee; Employee."Annual Leave Balance")
            {
            }
            column(LeaveDaysWorth; LeaveDaysWorth)
            {
            }
            column(AllocatedLeaveDays_Employee; Employee."Allocated Leave Days")
            {
            }
            column(TotalLeaveDaysTaken_Employee; Employee."Total Leave Days Taken")
            {
            }
            column(ReimbursedLeaveDays_Employee; Employee."Reimbursed Leave Days")
            {
            }
            trigger OnAfterGetRecord()
            begin
                Employee.CALCFIELDS(Employee."Annual Leave Balance");
                LeaveDaysWorth:=0;
                HumanResourcesSetup.GET;
                PayrollVitalSetup.GET;
                IF PayrollSalaryCard.GET(Employee."No.")THEN BEGIN
                    LeaveDaysWorth:=(PayrollSalaryCard."Basic Pay" / PayrollVitalSetup."Monthly Working Days") * Employee."Annual Leave Balance";
                end;
                IF LeaveDaysWorth = 0 THEN CurrReport.SKIP;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    LeaveDaysToAccrueMatrix: Record "Leave Days To Accrue Matrix";
    LeaveDaysWorth: Decimal;
    PayrollSalaryCard: Record "Payroll Salary Card";
    HumanResourcesSetup: Record "Human Resources Setup";
    PayrollVitalSetup: Record "Payroll Vital Setup";
}
