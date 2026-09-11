report 52203527 "Payroll Paye Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll Paye Report.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = WHERE("Nature Of Employment"=FILTER(<>Board));
            RequestFilterFields = "No.";

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
            column(KRANumber_Employee; Employee."KRA Number")
            {
            }
            column(NationalID_Employee; Employee."National ID")
            {
            }
            column(EmpName; EmpName)
            {
            }
            column(SNo; SNo)
            {
            }
            column(Pension; Pension)
            {
            }
            column(Paye; Paye)
            {
            }
            column(TotalAllowances; TotalAllowances)
            {
            }
            column(BasicPay; BasicPay)
            {
            }
            column(PayrollPeriod; PayrollPeriod)
            {
            }
            column(TaxablePay; TaxablePay)
            {
            }
            column(No_EmployeesHR; Employee."No.")
            {
            }
            column(PeriodName; PeriodName)
            {
            }
            column(NetPay; NetPay)
            {
            }
            column(House_Allowance; HouseAllowance)
            {
            }
            column(Other_Allowance; OtherAll)
            {
            }
            column(Leave; Leave)
            {
            }
            column(Relief; Relief)
            {
            }
            column(No_Employee; Employee."No.")
            {
            }
            trigger OnAfterGetRecord()
            begin
                if not IncludeInactiveEmployees then Employee.SetFilter("Employee Status", '=%1|=%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
                SNo+=1;
                EmpName:="First Name" + ' ' + "Middle Name" + ' ' + "Last Name";
                BasicPay:=0;
                TotalAllowances:=0;
                Paye:=0;
                Pension:=0;
                TaxablePay:=0;
                LeaveAll:=0;
                Leavepay:=0;
                Leave:=0;
                NetPay:=0;
                Relief:=0;
                PayrollVitalSetup.Get;
                Relief:=PayrollVitalSetup."Tax Relief";
                PrPeriodTrans.Reset;
                PrPeriodTrans.SetRange("Employee Code", Employee."No.");
                PrPeriodTrans.SetRange("Payroll Period", PayrollPeriod);
                if PrPeriodTrans.FindSet then repeat if PrPeriodTrans."Transaction Code" = 'BPAY' then BasicPay:=PrPeriodTrans.Amount;
                        if PrPeriodTrans."Transaction Code" = 'LEAVE ALLOW' then LeaveAll:=PrPeriodTrans.Amount;
                        if PrPeriodTrans."Transaction Code" = 'LEAVE P' then Leavepay:=PrPeriodTrans.Amount;
                        if PrPeriodTrans."Transaction Code" = 'TXBP' then TaxablePay:=PrPeriodTrans.Amount;
                        if PrPeriodTrans."Transaction Code" = 'PENS' then Pension:=PrPeriodTrans.Amount;
                        if PrPeriodTrans."Transaction Code" = 'GPAY' then HouseAllowance:=PrPeriodTrans.Amount;
                        if PrPeriodTrans."Transaction Code" = 'PAYE' then Paye:=PrPeriodTrans.Amount;
                        Leave:=LeaveAll + Leavepay;
                    until PrPeriodTrans.Next = 0;
                if BasicPay = 0 then CurrReport.Skip;
                if PrintOnExcel then MakeExcelDataBody;
            end;
            trigger OnPreDataItem()
            begin
                MakeExcelDataHeader;
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                if PayrollPeriod = 0D then Error('You must specify the payroll period');
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field(PayrollPeriod; PayrollPeriod)
                {
                    ApplicationArea = All;
                    Caption = 'Payroll Period';
                    TableRelation = "Payroll Periods";
                }
                field("Include Inactive Employees"; IncludeInactiveEmployees)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Print On Excel"; PrintOnExcel)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnInitReport()
    begin
        PrintOnExcel:=true;
    end;
    trigger OnPreReport()
    begin
        ExcelBuffer.DeleteAll;
        CompanyInfo.Get;
        if PayrollPeriod = 0D then Error('Please Specify the payroll period');
    end;
    var CompanyInfo: Record "Company Information";
    EmpName: Text;
    HrEmp: Record Employee;
    SNo: Integer;
    BasicPay: Decimal;
    TotalAllowances: Decimal;
    Paye: Decimal;
    PayrollPeriod: Date;
    Pension: Decimal;
    PrPeriodTrans: Record "Payroll Period Transaction";
    TaxablePay: Decimal;
    CompanyInformation: Record "Company Information";
    PeriodName: Text;
    PayrollPeriods: Record "Payroll Periods";
    NetPay: Decimal;
    IncludeInactiveEmployees: Boolean;
    HouseAllowance: Decimal;
    OtherAll: Decimal;
    LeaveAll: Decimal;
    Leavepay: Decimal;
    Relief: Decimal;
    PayrollVitalSetup: Record "Payroll Vital Setup";
    Leave: Decimal;
    PrintOnExcel: Boolean;
    ExcelBuffer: Record "Excel Buffer";
    procedure MakeExcelDataHeader()
    begin
        ExcelBuffer.AddColumn('PIN', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NAMES', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('RESIDENTIAL STATUS', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('TYPE OF EMPLOYEE', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('BASIC SALARY', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('HOUSE ALLOWANCE', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('TRANSPORT ALLOWANCE', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('LEAVE PAY', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('OVERTIME ALLOWANCE', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('DIRECTORS FEE', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('LUMPSUM IF ANY', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('OTHER ALLOWANCE', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('TOTAL CASH', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VALUE OF CAR BENEFIT', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('OTHER NON CASH BENEFIT', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('TOTAL NON CASH', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('GLOBAL INCOME', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('TYPE OF HOUSING', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('RENT OF HOUSE', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('COMPUTED HOUSE', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('RENT RECOVERED FROM EMPLOYEE', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NET VALUE OF HOUSING', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('TOTAL GROSS PAY', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('30% OF CASHPAY', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('ACTUAL CONTRIBUTION', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('PERMISSIBLE LIMIT', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('MORTGAGE INTEREST', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('DEPOSIT ON HOME OWNERSHIP', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('AMOUNT OF BENEFIT', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('TAXABLE PAY', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('TAX PAYABLE', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('MONTHLY PERSONAL RELIEF', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('AMOUNT OF INSURANCE RELIEF', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('PAYE TAX', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('SELF ASSESED PAYE', false, '', true, false, true, '', ExcelBuffer."Cell Type"::Text);
    end;
    procedure MakeExcelDataBody()
    begin
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Employee."KRA Number", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
    end;
}
