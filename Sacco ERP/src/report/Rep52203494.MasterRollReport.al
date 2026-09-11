report 52203494 "Master Roll Report"
{
    DefaultLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    RDLCLayout = './ssrs/Master Roll Report.rdl';

    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "Period Filter", "No.", Status, "Global Dimension 1 Code", "Global Dimension 2 Code";

            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; CompInfo.Name)
            {
            }
            column(CompanyPicture; CompInfo.Picture)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(USERID; UserId)
            {
            }
            column(UPPERCASE_FORMAT_DateSpecified_0___month_text___year4____; UpperCase(Format(DateSpecified, 0, '<month text> <year4>')))
            {
            }
            column(TIME; Time)
            {
            }
            column(No_; "No.")
            {
            }
            column(FullName; FullName)
            {
            }
            column(BasicSalary; BasicSalary)
            {
            }
            column(GrossPay; GrossPay)
            {
            }
            column(TaxableAmount; TaxableAmount)
            {
            }
            column(StatutoryDeductions; StatutoryDeductions)
            {
            }
            column(SaccoDeductions; SaccoDeductions)
            {
            }
            column(OtherDeductions; OtherDeductions)
            {
            }
            column(NetPay; NetPay)
            {
            }
            column(EarnDesc_1_; EarnDesc[1])
            {
            }
            column(EarnDesc_2_; EarnDesc[2])
            {
            }
            column(EarnDesc_3_; EarnDesc[3])
            {
            }
            column(EarnDesc_4_; EarnDesc[4])
            {
            }
            column(EarnDesc_5_; EarnDesc[5])
            {
            }
            column(EarnDesc_6_; EarnDesc[6])
            {
            }
            column(EarnDesc_7_; EarnDesc[7])
            {
            }
            column(EarnDesc_8_; EarnDesc[8])
            {
            }
            column(EarnDesc_9_; EarnDesc[9])
            {
            }
            column(EarnDesc_10_; EarnDesc[10])
            {
            }
            column(Allowances_1_; Allowances[1])
            {
            }
            column(Allowances_2_; Allowances[2])
            {
            }
            column(Allowances_3_; Allowances[3])
            {
            }
            column(Allowances_4_; Allowances[4])
            {
            }
            column(Allowances_5_; Allowances[5])
            {
            }
            column(Allowances_6_; Allowances[6])
            {
            }
            column(Allowances_7_; Allowances[7])
            {
            }
            column(Allowances_8_; Allowances[8])
            {
            }
            column(Allowances_9_; Allowances[9])
            {
            }
            column(Allowances_10_; Allowances[10])
            {
            }
            column(TotalAllowances; Allowances[1] + Allowances[2] + Allowances[3] + Allowances[4] + Allowances[5] + Allowances[6] + Allowances[7] + Allowances[8] + Allowances[9] + Allowances[10])
            {
            }
            column(STRSUBSTNO__Employees__1__counter_; StrSubstNo('Employees=%1', counter))
            {
            }
            column(Prepared_By_;'Prepared By.............................................Sign.............................................Date.............................................')
            {
            }
            column(Verified_By_;'Verified By.............................................Sign.............................................Date.............................................')
            {
            }
            column(Audited_By_;'Audited By...............................................Sign.............................................Date.............................................')
            {
            }
            column(Approved_By_;'Approved By.............................................Sign.............................................Date.............................................')
            {
            }
            column(MASTER_ROLLCaption; MASTER_ROLLCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Other_AllowancesCaption; Other_AllowancesCaptionLbl)
            {
            }
            column(Total_AllowancesCaption; Total_AllowancesCaptionLbl)
            {
            }
            column(TOTALSCaption; TOTALSCaptionLbl)
            {
            }
            trigger OnAfterGetRecord()
            begin
                OtherDeductions:=0;
                SaccoDeductions:=0;
                StatutoryDeductions:=0;
                TotalDeductions:=0;
                TaxableAmount:=0;
                PayrollPeriodTransaction[1].Reset;
                PayrollPeriodTransaction[1].SetRange("Employee Code", Employee."No.");
                PayrollPeriodTransaction[1].SetRange("Payroll Period", DateSpecified);
                PayrollPeriodTransaction[2].SetFilter("Group Text", '%1|%2|%3', 'NET PAY', 'GROSS PAY', 'BASIC SALARY');
                if not PayrollPeriodTransaction[1].FindSet then CurrReport.Skip
                else
                begin
                    repeat counter:=counter + 1;
                        if PayrollPeriodTransaction[1]."Group Text" = 'NET PAY' then NetPay:=Round(PayrollPeriodTransaction[1].Amount, 1);
                        if PayrollPeriodTransaction[1]."Group Text" = 'GROSS PAY' then GrossPay:=Round(PayrollPeriodTransaction[1].Amount, 1);
                        if PayrollPeriodTransaction[1]."Group Text" = 'BASIC SALARY' then BasicSalary:=Round(PayrollPeriodTransaction[1].Amount, 1);
                    until PayrollPeriodTransaction[1].Next = 0;
                end;
                for i:=1 to 10 do begin
                    Clear(Allowances[i]);
                end;
                PayrollPeriodTransaction[2].Reset;
                PayrollPeriodTransaction[2].SetRange("Employee Code", Employee."No.");
                PayrollPeriodTransaction[2].SetRange("Group Text", 'STATUTORIES');
                PayrollPeriodTransaction[2].SetRange("Payroll Period", DateSpecified);
                if PayrollPeriodTransaction[2].FindSet then begin
                    PayrollPeriodTransaction[2].CalcSums(Amount);
                    StatutoryDeductions:=Round(PayrollPeriodTransaction[2].Amount, 1);
                end;
                PayrollEmployeeP9TaxInfo.Reset();
                PayrollEmployeeP9TaxInfo.SetRange("Employee Code", Employee."No.");
                PayrollEmployeeP9TaxInfo.SetRange("Payroll Period", DateSpecified);
                if PayrollEmployeeP9TaxInfo.FindFirst()then TaxableAmount:=Round(PayrollEmployeeP9TaxInfo."Taxable Pay", 1);
                PayrollPeriodTransaction[3].Reset;
                PayrollPeriodTransaction[3].SetRange("Employee Code", Employee."No.");
                PayrollPeriodTransaction[3].SetRange("Transaction Code", 'TOT-DED');
                PayrollPeriodTransaction[3].SetRange("Payroll Period", DateSpecified);
                if PayrollPeriodTransaction[3].FindSet then begin
                    PayrollPeriodTransaction[3].CalcSums(Amount);
                    TotalDeductions:=Round(PayrollPeriodTransaction[3].Amount, 1);
                end;
                PayrollPeriodTransaction[4].Reset;
                PayrollPeriodTransaction[4].SetRange("Employee Code", Employee."No.");
                PayrollPeriodTransaction[4].SetRange("Payroll Period", DateSpecified);
                if PayrollPeriodTransaction[4].FindSet then begin
                    repeat if PayrollTransactionCode.Get(PayrollPeriodTransaction[4]."Transaction Code")then begin
                            if PayrollTransactionCode."Coop Parameter" in[PayrollTransactionCode."Coop Parameter"::Shares, PayrollTransactionCode."Coop Parameter"::loan, PayrollTransactionCode."Coop Parameter"::"loan Interest"]then begin
                                SaccoDeductions+=Round(PayrollPeriodTransaction[4].Amount, 1);
                            end;
                        end;
                    until PayrollPeriodTransaction[4].Next = 0;
                end;
                OtherDeductions:=Abs(Round((TotalDeductions - SaccoDeductions), 1));
                Totallowances:=0;
                for i:=1 to 20 do begin
                    PayrollPeriodTransaction[5].Reset;
                    PayrollPeriodTransaction[5].SetRange("Employee Code", Employee."No.");
                    PayrollPeriodTransaction[5].SetRange("Group Text", 'ALLOWANCE');
                    PayrollPeriodTransaction[5].SetRange("Transaction Code", Earncode[i]);
                    PayrollPeriodTransaction[5].SetRange("Payroll Period", DateSpecified);
                    if PayrollPeriodTransaction[5].Find('-')then Allowances[i]:=Round(PayrollPeriodTransaction[5].Amount, 1);
                    Totallowances:=Round(Totallowances + Allowances[i], 1);
                end;
            end;
            trigger OnPreDataItem()
            begin
                CurrReport.CreateTotals(TotallowancesCash, NetPay);
                HRSetup.Get;
                GLSetup.Get;
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompInfo.GET;
        CompInfo.CALCFIELDS(CompInfo.Picture);
        CompInfo.CALCFIELDS(CompInfo.Picture2);
        DateSpecified:=Employee.GetRangeMin(Employee."Period Filter");
        TransactionCodes.Reset;
        TransactionCodes.SetRange("Show on Master Roll", true);
        TransactionCodes.SetRange(Type, TransactionCodes.Type::Income);
        if TransactionCodes.Find('-')then repeat i:=i + 1;
                Earncode[i]:=TransactionCodes.Code;
                EarnDesc[i]:=TransactionCodes.Name;
            until TransactionCodes.Next = 0;
    end;
    procedure GetDateSpecified(var PayrollPeriod: Date)
    begin
        if PayrollPeriod <> 0D then begin
            DateSpecified:=PayrollPeriod;
            Employee."Period Filter":=PayrollPeriod;
        end;
    end;
    var Allowances: array[20]of Decimal;
    TransactionCodes: Record "Payroll Transaction Code";
    Earncode: array[20]of Code[10];
    EarnDesc: array[20]of Text[50];
    i: Integer;
    PayrollPeriodTransaction: array[6]of Record "Payroll Period Transaction";
    PayrollTransactionCode: Record "Payroll Transaction Code";
    PayrollEmployeeP9TaxInfo: Record "Payroll Employee P9 Tax Info";
    DateSpecified: Date;
    counter: Integer;
    HRSetup: Record "Human Resources Setup";
    BasicSalary: Decimal;
    NetPay: Decimal;
    GrossPay: Decimal;
    Totallowances: Decimal;
    TotalDeductions: Decimal;
    TaxableAmount: Decimal;
    StatutoryDeductions: Decimal;
    SaccoDeductions: Decimal;
    OtherDeductions: Decimal;
    MASTER_ROLLCaptionLbl: Label 'MASTER ROLL';
    CurrReport_PAGENOCaptionLbl: Label 'Page';
    Other_AllowancesCaptionLbl: Label 'Other Allowances';
    Total_AllowancesCaptionLbl: Label 'Total Allowances';
    TOTALSCaptionLbl: Label 'TOTALS';
    CashAllowances: array[20]of Decimal;
    TotallowancesCash: Decimal;
    GLSetup: Record "General Ledger Setup";
    CompInfo: Record "Company Information";
}
