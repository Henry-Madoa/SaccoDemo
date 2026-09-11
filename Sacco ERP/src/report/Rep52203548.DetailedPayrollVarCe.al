report 52203548 "Detailed Payroll VarCe"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Detailed Payroll VarCe.rdlc';

    dataset
    {
        dataitem("Detailed Payroll VarCe"; "Detailed Payroll Variance")
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
            column(TransactionCode_DetailedPayrollVarCe; "Detailed Payroll VarCe"."Entry No")
            {
            }
            column(TransactionName_DetailedPayrollVarCe; "Detailed Payroll VarCe"."Transaction Code")
            {
            }
            column(EmployeeNo_DetailedPayrollVarCe; "Detailed Payroll VarCe"."Transaction Name")
            {
            }
            column(EmployeeName_DetailedPayrollVarCe; "Detailed Payroll VarCe"."Employee No.")
            {
            }
            column(PreviousPeriod_DetailedPayrollVarCe; "Detailed Payroll VarCe"."Employee Name")
            {
            }
            column(PreviousAmount_DetailedPayrollVarCe; "Detailed Payroll VarCe"."Current Period")
            {
            }
            column(EntryNo_DetailedPayrollVarCe; "Detailed Payroll VarCe"."Previous Period")
            {
            }
            column(CurrentPeriod_DetailedPayrollVarCe; "Detailed Payroll VarCe"."Previous Amount")
            {
            }
            column(CurrentAmount_DetailedPayrollVarCe; "Detailed Payroll VarCe"."Current Amount")
            {
            }
            column(VarCe_DetailedPayrollVarCe; "Detailed Payroll VarCe".VarCe)
            {
            }
            column(PercentageVarCe_DetailedPayrollVarCe; "Detailed Payroll VarCe".Percentage)
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("Previous Period"; PreviousPeriod)
                {
                    TableRelation = "Payroll Periods"."Start Date";
                }
                field("Current Period"; CurrentPeriod)
                {
                    TableRelation = "Payroll Periods"."Start Date";
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        CalculateVarCe.CalculateVarCe(PreviousPeriod, CurrentPeriod);
    end;
    var CompanyInformation: Record "Company Information";
    PeriodYear: Integer;
    GratuityAmount: Decimal;
    PayrollPeriods: Record "Payroll Periods";
    PayrollPeriodTransaction: Record "Payroll Period Transaction";
    PreviousAmount: Decimal;
    CurrentAmount: Decimal;
    PreviousPeriod: Date;
    CalculateVarCe: Codeunit "Calculate Variance";
    CurrentPeriod: Date;
}
