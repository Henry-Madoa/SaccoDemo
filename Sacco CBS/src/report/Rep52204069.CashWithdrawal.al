report 52204069 "Cash Withdrawal"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Cash Withdrawal.rdl';

    dataset
    {
        dataitem("Teller Transactions"; "Teller Transactions")
        {
            column(Document_No; "No.")
            {
            }
            column("CompanyLogo"; CompanyInformation.Picture)
            {
            }
            column("CompanyName"; CompanyInformation.Name)
            {
            }
            column("CompanyAddress1"; CompanyInformation.Address)
            {
            }
            column("CompanyAddress2"; CompanyInformation."Address 2")
            {
            }
            column("CompanyPhone"; CompanyInformation."Phone No.")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
            {
            }
            column(Transaction_Type; "Transaction Type")
            {
            }
            column(Member_No; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Account_No; "Account No")
            {
            }
            column(Account_Name; "Account Name")
            {
            }
            column(Amount; Amount)
            {
            }
            column(Teller; Teller)
            {
            }
            column(Till; Till)
            {
            }
            column(Created_On; "Created On")
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Created_By; "Created By")
            {
            }
            column(Global_Dimension_1_Code; "Global Dimension 1 Code")
            {
            }
            column(AmountInWords; AmountInWords[1])
            {
            }
            column(Charge_Code; "Charge Code")
            {
            }
            column(ChargeAmount; ChargeAmount)
            {
            }
            column(BookBalBefore; "Book Balance")
            {
            }
            column(BookBalAfter; BookBalance - ChargeAmount - Amount)
            {
            }
            column(BookBalance; BookBalance)
            {
            }
            column(AvailableBal; "Available Balance" - Amount)
            {
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                SaccoSetup.Get();
                CompanyInformation.CalcFields(Picture);
                AmountToWords.FormatNoText(AmountInWords, Amount, SaccoSetup."LCY Code");
                ChargeAmount := 0;
                DetailedVendorLedgEntry.Reset();
                DetailedVendorLedgEntry.SetRange("Member No.", "Teller Transactions"."Member No.");
                DetailedVendorLedgEntry.SetRange("Document No.", "Teller Transactions"."No.");
                DetailedVendorLedgEntry.SetRange("Sacco Transaction Type", DetailedVendorLedgEntry."Sacco Transaction Type"::Charge);
                if DetailedVendorLedgEntry.FindSet then begin
                    DetailedVendorLedgEntry.CalcSums(Amount);
                    ChargeAmount := DetailedVendorLedgEntry.Amount;
                end;
                Vendor.RESET;
                Vendor.SETRANGE("Member No.", "Teller Transactions"."Member No.");
                Vendor.SetRange("Product Posting Type", Vendor."Product Posting Type"::"Withdrawable Deposit");
                Vendor.SetRange(Blocked, Vendor.Blocked::" ");
                if Vendor.FindFirst() then begin
                    SaccoProduct.Get(Vendor."Product Code");
                    Vendor.CalcFields(Balance);
                    BookBalance := Vendor.Balance;
                    AvailableBalance := BookBalance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelsIntegration.GetPendingChannelsTransactions(Vendor."Member No.");
                    if AvailableBalance < 0 then AvailableBalance := 0;
                end;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        DateFilter: Text;
        AmountInWords: array[2] of Text[80];
        Vendor: Record Vendor;
        AmountToWords: Codeunit "Amount To Words";
        AvailableBalance, BookBalance, ChargeAmount : Decimal;
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        SaccoSetup: Record "General Ledger Setup";
        SaccoProduct: Record "Sacco Products";
        ChannelsIntegration: Codeunit "Channels Integrations";
}
