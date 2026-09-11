report 52203424 "WHT Invoice Fee"
{
    DefaultLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    RDLCLayout = './ssrs/WHT Invoice Fee.rdl';

    dataset
    {
        dataitem(Payments; "Payment Voucher")
        {
            RequestFilterFields = "No.", Date;

            column(SupplierNo; PvLine."Account No")
            {
            }
            column(SupplierName; PvLine."Account Name")
            {
            }
            column(PVNo; Payments."No.")
            {
            }
            column(ContractDate; Payments.Date)
            {
            }
            column(PaymentNarration; PvLine.Description)
            {
            }
            column(Reference; Payments."Cheque Number")
            {
            }
            column(WHTCode; PvLine."WHT Code One")
            {
            }
            column(WHTAmount; PvLine."WHT Amount One")
            {
            }
            column(GrossAmount; PvLine.Amount)
            {
            }
            column(NetAmount; PvLine."Net Amount")
            {
            }
            column(TotalPayableAmount; Payments."Total Amount")
            {
            }
            column(VendorAcct; VendorAcct)
            {
            }
            column(PeriodCovered; Payments."Posted Date")
            {
            }
            column(VendorName; PvLine."Account Name")
            {
            }
            column(AccountNo; AcctNo)
            {
            }
            column(Description; Description)
            {
            }
            column(Amount; Amount)
            {
            }
            column(VendorAddress; VendorAddress)
            {
            }
            column(filterss; GetFilters)
            {
            }
            column(TIN; VendorTIN)
            {
            }
            trigger OnAfterGetRecord()
            begin
                PvLine.Reset;
                PvLine.SetRange("No.", Payments."No.");
                if PvLine.FindFirst then begin
                    Description:=PvLine.Description;
                    AcctNo:=PvLine."Account No";
                    WTA:=PvLine."WHT Code One";
                    Amount:=PvLine."Net Amount";
                    VendorAcct:=PvLine."Payee Account No.";
                end;
                if(Description = '') and (AcctNo = '')then Payments.Date:=0D;
                VendorAddress:='';
                VendorTIN:='';
                Vendor.Reset;
                if Vendor.Get(PvLine."Account No")then PayeeBankDetails.Reset;
                PayeeBankDetails.SetRange("Vendor No", PvLine."Account No");
                PayeeBankDetails.SetRange("Bank Account Number", PvLine."Payee Account No.");
                if PayeeBankDetails.FindFirst then VendorTIN:=PayeeBankDetails."Bank Telephone No";
            end;
        }
    }
    var PvLine: Record "Payment Voucher Lines";
    Description: Text;
    AcctNo: Code[30];
    PayReqLine: Record "Payment Voucher Lines";
    PayeeBankDetails: Record "Payee Bank Details";
    VendorAcct: Code[50];
    Amount: Decimal;
    WTA: Code[10];
    Vendor: Record Vendor;
    VendorAddress: Text;
    VendorTIN: Text;
}
