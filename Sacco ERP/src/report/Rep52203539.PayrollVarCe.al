report 52203539 "Payroll VarCe"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll VarCe.rdlc';

    dataset
    {
        dataitem("Payroll Transaction Code"; "Payroll Transaction Code")
        {
            DataItemTableView = SORTING(Code)ORDER(Descending);
            RequestFilterFields = Type, Code;

            column(TransactionCode_PRTransactionCodes; Code)
            {
            }
            column(TransactionName_PRTransactionCodes; Name)
            {
            }
            column(TransactionType_PRTransactionCodes; Type)
            {
            }
            column(Amount; Amount)
            {
            }
            column(PeriodFilter; PeriodFilter)
            {
            }
            column(PreviousAmount; PreviousAmount)
            {
            }
            column(PreviousPeriod; "Previous Period")
            {
            }
            column(varCe; VarCe)
            {
            }
            column(PercentageVarCe; "Percentage VarCe")
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
            trigger OnAfterGetRecord()
            begin
                VarCe:=0;
                Amount:=0;
                PRPeriodTrans.Reset;
                PRPeriodTrans.SetCurrentKey("Employee Code", "Transaction Code", "Period Month", "Period Year", Membership, "Reference No");
                PRPeriodTrans.SetRange(PRPeriodTrans."Transaction Code", Code);
                PRPeriodTrans.SetRange(PRPeriodTrans."Payroll Period", PeriodFilter);
                if PRPeriodTrans.Find('-')then begin
                    PRPeriodTrans.CalcSums(PRPeriodTrans.Amount);
                    Amount:=PRPeriodTrans.Amount;
                end;
                PreviousAmount:=0;
                PRPeriodTrans.Reset;
                PRPeriodTrans.SetCurrentKey("Employee Code", "Transaction Code", "Period Month", "Period Year", Membership, "Reference No");
                PRPeriodTrans.SetRange(PRPeriodTrans."Transaction Code", Code);
                PRPeriodTrans.SetRange(PRPeriodTrans."Payroll Period", "Previous Period");
                if PRPeriodTrans.Find('-')then begin
                    PRPeriodTrans.CalcSums(PRPeriodTrans.Amount);
                    PreviousAmount:=PRPeriodTrans.Amount;
                    VarCe:=Amount - PreviousAmount;
                    if Amount <> 0 then begin
                        if PreviousAmount <> 0 then "Percentage VarCe":=VarCe / Amount * 100;
                    end;
                    if Amount = 0 then begin
                        if PreviousAmount <> 0 then "Percentage VarCe":=100;
                    end;
                    if Amount > 0 then begin
                        if PreviousAmount = 0 then "Percentage VarCe":=-100;
                    end;
                end;
                if Amount = 0 then begin
                    if PreviousAmount = 0 then CurrReport.Skip;
                end;
            end;
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
                field(PeriodFilter; PeriodFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Period Filter';
                    TableRelation = "Payroll Periods";
                }
                field("Previous Period"; "Previous Period")
                {
                    ApplicationArea = All;
                    Caption = 'Previous Period';
                    TableRelation = "Payroll Periods";
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        if PeriodFilter = 0D then Error('Please specify period filter');
    end;
    var PRPeriodTrans: Record "Payroll Period Transaction";
    PeriodFilter: Date;
    Amount: Decimal;
    "Previous Period": Date;
    PreviousAmount: Decimal;
    VarCe: Decimal;
    "Percentage VarCe": Decimal;
    CompanyInformation: Record "Company Information";
}
