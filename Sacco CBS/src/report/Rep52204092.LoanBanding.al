report 52204092 "Loan Banding"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    PreviewMode = PrintLayout;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Loan Banding.rdl';
    dataset
    {
        dataitem(Members; Members)
        {
            RequestFilterFields = "Date Filter";
            column("CompanyAddress1"; CompanyInformation.Address)
            {
            }
            column("CompanyAddress2"; CompanyInformation."Address 2")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column("CompanyLogo"; CompanyInformation.Picture)
            {
            }
            column("CompanyName"; CompanyInformation.Name)
            {
            }
            column("CompanyPhone"; CompanyInformation."Phone No.")
            {
            }
            column(Member_No_; "No.")
            {
            }
            column(Full_Name; "Full Name")
            {
            }
            column(Employer_Code; "Employer Code")
            {
            }
            column(Total_Deposits; "Total Deposits")
            {
            }
            column(Outstanding_Loans; "Outstanding Loans")
            {
            }
            column(LoanBanding; LoanBanding)
            {
            }
            column(MemberContribution; MemberContribution)
            {
            }
            column(Variance; Variance)
            {
            }
            column(SerialNo; SerialNo)
            {
            }

            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                CalcFields("Total Deposits", "Outstanding Loans");

                SerialNo := 1;
                SerialNo := SerialNo + 1;

                LoanBanding := 0;
                MemberContribution := 0;
                Variance := 0;
                Datefilter := '';
                Evaluate(FilterDate, DelChr(Members.GetFilter("Date Filter"), '=', '..'));
                Datefilter := StrSubstNo('%1..%2', CalcDate('-CM', FilterDate), CalcDate('CM', FilterDate));

                If "Outstanding Loans" < 500000 then
                    LoanBanding := 2000
                else if (("Outstanding Loans" > 500000) and ("Outstanding Loans" <= 1000000)) then
                    LoanBanding := 4000
                else if (("Outstanding Loans" > 1000000) and ("Outstanding Loans" <= 2000000)) then
                    LoanBanding := 6000
                else if (("Outstanding Loans" > 2000000) and ("Outstanding Loans" <= 4000000)) then
                    LoanBanding := 8000
                else if (("Outstanding Loans" > 4000000) and ("Outstanding Loans" <= 5000000)) then
                    LoanBanding := 10000
                else if (("Outstanding Loans" > 5000000) and ("Outstanding Loans" <= 7000000)) then
                    LoanBanding := 12000
                else if (("Outstanding Loans" > 7000000) and ("Outstanding Loans" <= 10000000)) then
                    LoanBanding := 15000
                else if "Outstanding Loans" > 10000000 then
                    LoanBanding := 20000;


                DetailedVendorLedgEntry.Reset();
                DetailedVendorLedgEntry.SetRange("Product Posting Type", DetailedVendorLedgEntry."Product Posting Type"::"Non Withdrawable Deposit");
                DetailedVendorLedgEntry.SetRange("Member No.", "No.");
                DetailedVendorLedgEntry.Setfilter("Posting Date", Datefilter);
                DetailedVendorLedgEntry.Setfilter(Amount, '<0');
                DetailedVendorLedgEntry.Setfilter("Document No.", '<>OPENBAL');
                DetailedVendorLedgEntry.SetCurrentKey("Entry No.");
                DetailedVendorLedgEntry.SetAscending("Entry No.", false);
                if DetailedVendorLedgEntry.FindSet then begin
                    DetailedVendorLedgEntry.CalcSums("Credit Amount");
                    MemberContribution := DetailedVendorLedgEntry."Credit Amount";
                end;
                Variance := MemberContribution - LoanBanding;
            end;
        }
    }

    var
        CompanyInformation: Record "Company Information";
        SerialNo: Integer;
        LoanBanding, MemberContribution, Variance : Decimal;
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        Datefilter: Text;
        FilterDate: Date;
}
