report 52204080 "Dividend Slip"
{
    UsageCategory = Administration;
    Caption = 'Dividend Slip';
    ApplicationArea = Basic, Suite;
    RDLCLayout = '.\ssrs\DividendSlip.rdl';

    dataset
    {
        dataitem(Members; Members)
        {
            RequestFilterFields = "No.", "Product Code Filter", "Dividend Code Filter";

            column(Member_No_; "No.")
            {
            }
            column(Full_Name; "Full Name")
            {
            }
            column(Payroll_No; "Payroll No.")
            {
            }
            column(Payroll_No_; "Payroll No.")
            {
            }
            column(CalcRate; CalcRate)
            {
            }
            column(CompanyInfo; CompanyInfo.Picture)
            {
            }
            column(ProductName; ProductName)
            {
            }
            column(Year; Year)
            {
            }
            column(CloseDate; CloseDate)
            {
            }
            column(NetDividend; NetDividend)
            {
            }
            column(AmountOwed; AmountOwed)
            {
            }
            column(Defaulted; Defaulted)
            {
            }
            dataitem("Dividend Progression"; "Dividend Det. Entries")
            {
                DataItemLink = "Member No." = field("No.");
                DataItemTableView = sorting("Dividend Code", "Entry No");

                column(Closing_Date; "Month Code")
                {
                }
                column(Rate; Rate)
                {
                }
                column(Ratio; Ratio)
                {
                }
                column(Net_Change; "Net Change")
                {
                }
                column(Amount_Earned; Amount)
                {
                }
                column(WeightedDeposits; WeightedDeposits)
                {
                }
                column(WTax; WTax)
                {
                }
                trigger OnPreDataItem()
                begin
                    SetRange("Account Type", ProductCodeFilter);
                    SetFilter("Dividend Code", DividendCodeFilter);
                end;

                trigger OnAfterGetRecord()
                begin
                    WTax := 0;
                    WeightedDeposits := 0;
                    WeightedDeposits := "Dividend Progression"."Net Change" * "Dividend Progression".Ratio;
                    ChargeCode := '';
                    if DividendHeader.Get("Dividend Code") then ChargeCode := DividendHeader."Transaction Code";
                    //WTax := DivManagement.GetWTaxAmount(ChargeCode, "Dividend Progression".Amount, 'W/TAX')
                end;
            }
            dataitem("Dividend Det. Lines"; "Dividend Recoveries")
            {
                DataItemLink = "Member No" = field("No.");

                column(Transaction_Code; "Recovery Code")
                {
                }
                column(Transaction_Description; Description)
                {
                }
                column(Amount; Amount)
                {
                }
                trigger OnPreDataItem()
                begin
                    SetRange("Account No.", AccountNoFilter);
                    SetFilter("Dividend Code", DividendCodeFilter);
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInfo.get;
                CompanyInfo.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                AccountNoFilter := '';
                ProductCodeFilter := Members.GetFilter("Product Code Filter");
                if PFactory.Get("Product Code Filter") then ProductName := PFactory.Description;
                DividendCodeFilter := Members.GetFilter("Dividend Code Filter");
                Vendor.Reset();
                Vendor.SetFilter("Product Code", ProductCodeFilter);
                Vendor.SetRange("No.", "No.");
                if Vendor.FindFirst() then AccountNoFilter := Vendor."No.";
                if DividendHeader.Get(DividendCodeFilter) then CloseDate := DividendHeader."End Date";
                if CloseDate <> 0D then Year := Date2DMY(CloseDate, 3);
                CalcRate := 0;
                DivCalcParameters.Reset();
                DivCalcParameters.SetRange("Dividend Code", DividendCodeFilter);
                DivCalcParameters.SetRange(Type, ProductCodeFilter);
                if DivCalcParameters.FindFirst() then CalcRate := DivCalcParameters.Rate;
                NetDividend := 0;
                Defaulted := 0;
                AmountOwed := 0;
                DivManagement.GetNetDividend(DividendCodeFilter, "No.", ProductCodeFilter, Defaulted, NetDividend, AmountOwed, DefaultTransfer);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        ProductName: Text;
        DivManagement: Codeunit "Dividend Management";
        AccountNoFilter, ProductCodeFilter, DividendCodeFilter : Text;
        Vendor: Record Vendor;
        ChargeCode: Code[20];
        DividendHeader: Record "Dividend Header";
        DefaultTransfer, WTax, CalcRate, WeightedDeposits, NetDividend, Defaulted, AmountOwed : Decimal;
        Year: Integer;
        DivCalcParameters: Record "Dividend Calculation Params";
        PFactory: Record "Sacco Products";
        CloseDate: Date;
        CompanyInfo: Record "Company Information";
}
