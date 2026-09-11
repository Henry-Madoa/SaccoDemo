report 52203545 "P9 Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/P9 Report.rdl';

    dataset
    {
        dataitem("Payroll Employee P9 Tax Info"; "Payroll Employee P9 Tax Info")
        {
            DataItemTableView = SORTING("Employee Code", "Payroll Period")ORDER(Ascending);
            PrintOnlyIfDetail = false;
            RequestFilterFields = "Employee Code", "Period Year";

            column(EmployeeCode_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Employee Code")
            {
            }
            column(BasicPay_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Basic Pay")
            {
            }
            column(Allowances_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info".Allowances)
            {
            }
            column(Benefits_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info".Benefits)
            {
            }
            column(ValueOfQuarters_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Value Of Quarters")
            {
            }
            column(DefinedContribution_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Defined Contribution")
            {
            }
            column(OwnerOccupierInterest_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Owner Occupier Interest")
            {
            }
            column(GrossPay_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Gross Pay")
            {
            }
            column(TaxablePay_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Taxable Pay")
            {
            }
            column(TaxCharged_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Tax Charged")
            {
            }
            column(InsuranceRelief_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Insurance Relief")
            {
            }
            column(TaxRelief_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Tax Relief")
            {
            }
            column(PAYE_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info".PAYE)
            {
            }
            column(NSSF_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info".NSSF)
            {
            }
            column(SHIF_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info".SHIF)
            {
            }
            column(Deductions_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info".Deductions)
            {
            }
            column(NetPay_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Net Pay")
            {
            }
            column(PeriodMonth_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Period Month")
            {
            }
            column(PeriodYear_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Period Year")
            {
            }
            column(PayrollPeriod_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Payroll Period")
            {
            }
            column(PeriodFilter_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Period Filter")
            {
            }
            column(Pension_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info".Pension)
            {
            }
            column(HELB_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info".HELB)
            {
            }
            column(PayrollCode_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info"."Payroll Code")
            {
            }
            column(Source_PayrollEmployeeP9TaxInfo; "Payroll Employee P9 Tax Info".Source)
            {
            }
            column(MonthName; MonthName)
            {
            }
            column(SelectedYearText; Format("Period Year"))
            {
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            column(Retirement_OwnerOccupier; "Retirement+OwnerOccupier")
            {
            }
            column(EmployeeName; EmployeeName)
            {
            }
            column(EmployeePinNo; EmployeePINNo)
            {
            }
            column(EmployerPinNo; EmployerPinNo)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if(0.3 * "Payroll Employee P9 Tax Info"."Basic Pay" < ("Payroll Employee P9 Tax Info".NSSF + "Payroll Employee P9 Tax Info".Pension))then "Retirement+OwnerOccupier":=0.3 * "Payroll Employee P9 Tax Info"."Basic Pay" + "Payroll Employee P9 Tax Info"."Owner Occupier Interest"
                else
                    "Retirement+OwnerOccupier":=("Payroll Employee P9 Tax Info".NSSF + "Payroll Employee P9 Tax Info".Pension) + "Payroll Employee P9 Tax Info"."Owner Occupier Interest";
                EmployeePINNo:='';
                EmployeeName:='';
                if Employee.Get("Payroll Employee P9 Tax Info"."Employee Code")then begin
                    EmployeePINNo:=Employee."KRA Number";
                    EmployeeName:=Employee.FullName;
                end;
                MonthName:='';
                Date.Reset;
                Date.SetRange("Period Type", Date."Period Type"::Month);
                Date.SetRange("Period No.", "Payroll Employee P9 Tax Info"."Period Month");
                if Date.FindFirst then MonthName:=Date."Period Name";
            end;
        }
    }
    trigger OnPreReport()
    begin
        ReportFilters:="Payroll Employee P9 Tax Info".GETFILTERS;
        CompanyInfo.Reset;
        if CompanyInfo.Get then begin
            CompanyInfo.CalcFields(CompanyInfo.Picture);
            CompanyInfo.TestField(CompanyInfo.Name);
            EmployerPinNo:=CompanyInfo."VAT Registration No.";
        end;
    end;
    var ReportFilters: Text;
    CompanyInfo: Record "Company Information";
    PRPeriodTrans: Record "Payroll Period Transaction";
    "Retirement+OwnerOccupier": Decimal;
    EmployeeName: Text;
    EmployeePINNo: Code[50];
    EmployerPinNo: Code[50];
    Employee: Record Employee;
    Date: Record Date;
    MonthName: Text;
}
