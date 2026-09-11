report 52203557 "Grant Payroll Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Grant Payroll Report.rdlc';

    dataset
    {
        dataitem("Employee Donors"; "Employee Donors")
        {
            DataItemTableView = WHERE(Percentage=FILTER(>0));

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
            column(GratuityAmount; GratuityAmount)
            {
            }
            column(EmployeeNo_EmployeeDonors; "Employee Donors"."Employee No")
            {
            }
            column(DonorCode_EmployeeDonors; "Employee Donors"."Donor Code")
            {
            }
            column(DonorName_EmployeeDonors; "Employee Donors"."Donor Name")
            {
            }
            column(Percentage_EmployeeDonors; "Employee Donors".Percentage)
            {
            }
            column(GrossPay; GrossPay)
            {
            }
            column(NetPay; NetPay)
            {
            }
            column(Grade; Grade)
            {
            }
            column(PayrollType; PayrollType)
            {
            }
            column(EmployerName; EmployerName)
            {
            }
            column(EmployeeName; EmployeeName)
            {
            }
            column(SelectedPeriod; SelectedPeriod)
            {
            }
            column(GrantActivity_EmployeeDonors; "Employee Donors"."Grant Activity")
            {
            }
            trigger OnAfterGetRecord()
            begin
                GrossPay:=0;
                NetPay:=0;
                Grade:='';
                EmployeeName:='';
                PayrollType:='';
                IF Employee.GET("Employee Donors"."Employee No")THEN BEGIN
                    EmployeeName:=Employee.FullName;
                    Grade:=Employee."Job Scale";
                    PayrollType:=Employee."Global Dimension 6 Code";
                end;
                IF NOT(Employee."Employee Status" IN[Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave])THEN CurrReport.SKIP;
                IF(SelectedPeriod > "Employee Donors"."Grant Start Date") AND (SelectedPeriod < "Employee Donors"."Grant End Date")THEN BEGIN
                    PayrollPeriodTransaction.RESET;
                    PayrollPeriodTransaction.SETRANGE("Payroll Period", SelectedPeriod);
                    PayrollPeriodTransaction.SETRANGE("Employee Code", "Employee Donors"."Employee No");
                    IF PayrollPeriodTransaction.FINDSET THEN BEGIN
                        REPEAT IF PayrollPeriodTransaction."Transaction Code" = 'GPAY' THEN GrossPay:=(PayrollPeriodTransaction.Amount * ("Employee Donors".Percentage / 100));
                            IF PayrollPeriodTransaction."Transaction Code" = 'NPAY' THEN NetPay:=(PayrollPeriodTransaction.Amount * ("Employee Donors".Percentage / 100));
                        UNTIL PayrollPeriodTransaction.NEXT = 0;
                    end;
                END
                ELSE
                    CurrReport.SKIP;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
                IF SelectedPeriod = 0D THEN ERROR('Specify the period');
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("Payroll period"; SelectedPeriod)
                {
                    TableRelation = "Payroll Periods"."Start Date";
                }
            }
        }
    }
    var CompanyInformation: Record "Company Information";
    PeriodYear: Integer;
    GratuityAmount: Decimal;
    PayrollPeriods: Record "Payroll Periods";
    PayrollPeriodTransaction: Record "Payroll Period Transaction";
    IsBetweenDates: Boolean;
    Grade: Code[10];
    SelectedPeriod: Date;
    GrossPay: Decimal;
    NetPay: Decimal;
    PayrollType: Code[50];
    EmployerName: Text;
    EmployeeName: Text;
    Employee: Record Employee;
}
