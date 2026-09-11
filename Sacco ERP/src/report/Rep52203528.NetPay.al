report 52203528 "Net Pay"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Net Pay.rdl';

    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = WHERE("Nature Of Employment"=FILTER(<>Board));
            PrintOnlyIfDetail = false;

            column(No_EmployeesHR; Employee."No.")
            {
            }
            column(FirstName_EmployeesHR; Employee."First Name")
            {
            }
            column(MiddleName_EmployeesHR; Employee."Middle Name")
            {
            }
            column(LastName_EmployeesHR; Employee."Last Name")
            {
            }
            column(CompanyName; CompanyInformation.Name)
            {
            }
            column(CompanyAddress; CompanyInformation.Address)
            {
            }
            column(CompanyCity; CompanyInformation.City)
            {
            }
            column(CompanyPhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(CompanyFaxNo; CompanyInformation."Fax No.")
            {
            }
            column(CompanyWedAddress; CompanyInformation."Home Page")
            {
            }
            column(CompanyPhoneNo2; CompanyInformation."Phone No. 2")
            {
            }
            column(CompanyCounty; CompanyInformation.County)
            {
            }
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            column(NetPay; NetPay)
            {
            }
            column(BankCode; "Bank/BranchCode")
            {
            }
            column(AccountNo; AccountNo)
            {
            }
            column(BranchName; BranchName)
            {
            }
            column(BankName; BankName)
            {
            }
            column(PayrollPeriod; PayrollPeriod)
            {
            }
            column(FOSAAccountNo_Employee; Employee."FOSA Account")
            {
            }
            column(BankAccountNo_Employee; Employee."Bank Account No.")
            {
            }
            column(BankBranchNo_Employee; Employee."Bank Branch No.")
            {
            }
            column(BankCode_Employee; Employee."Bank Code")
            {
            }
            column(BankName_Employee; Employee."Bank Name")
            {
            }
            column(BranchName_Employee; Employee."Branch Name")
            {
            }
            trigger OnAfterGetRecord()
            begin
                if not IncludeInactiveEmployees then Employee.SetFilter("Employee Status", '=%1|=%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
                NetPay:=0;
                PayrollPeriodTransaction.Reset;
                PayrollPeriodTransaction.SetRange("Employee Code", Employee."No.");
                PayrollPeriodTransaction.SetRange("Payroll Period", PayrollPeriod);
                PayrollPeriodTransaction.SetRange("Transaction Code", 'NPAY');
                if PayrollPeriodTransaction.FindFirst then NetPay:=PayrollPeriodTransaction.Amount;
                "Bank/BranchCode":='';
                AccountNo:='';
                BankName:='';
                BranchName:='';
                "Bank/BranchCode":=Employee."Bank Branch No.";
                AccountNo:=Employee."Bank Account No.";
                BankName:=Employee."Bank Name";
                if NetPay = 0 then CurrReport.Skip;
            end;
            trigger OnPreDataItem()
            begin
                if PayrollPeriod = 0D then Error('Payroll Period Must Have a value');
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
                field("Payroll Period"; PayrollPeriod)
                {
                    ApplicationArea = All;
                    TableRelation = "Payroll Periods"."Start Date";
                }
                field("Include Inactive Employees"; IncludeInactiveEmployees)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var CompanyInformation: Record "Company Information";
    EmployeesHR: Record Employee;
    EmpName: Text;
    PayrollPeriodTransaction: Record "Payroll Period Transaction";
    NetPay: Decimal;
    PayrollPeriod: Date;
    "Bank/BranchCode": Code[10];
    AccountNo: Code[50];
    BranchName: Text;
    BankName: Text;
    IncludeInactiveEmployees: Boolean;
}
