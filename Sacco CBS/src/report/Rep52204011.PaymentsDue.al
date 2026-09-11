report 52204011 "Payments Due"
{
    UsageCategory = Administration;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payments Due.rdl';
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem(Loans; Loans)
        {
            RequestFilterFields = "Date Filter";
            DataItemTableView = where("Recovery Mode" = filter(<> Checkoff & <> Salary), Posted = const(true), "Loan Balance" = filter(<> 0), "Payment Date" = filter(<> 0D));
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
            column(No_; "No.")
            {
            }
            column(Member_No_; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Staff_No; "Staff No")
            {
            }
            column(Phone_No; "Phone No")
            {
            }
            column(Recovery_Mode; "Recovery Mode")
            {
            }
            column(Loan_Classification; "Loan Classification")
            {
            }
            column(Payment_Date; PaymentDate)
            {
            }
            column(Monthly_Installment; "Monthly Installment")
            {
            }
            column(MemberPayment; MemberPayment)
            {
            }
            column(Variance; Variance)
            {
            }
            column(Principal_Balance; "Principal Balance")
            {
            }
            column(Interest_Balance; "Interest Balance")
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                Loans.CalcFields("Staff No", "Phone No", "Monthly Installment");
                Datefilter := '';
                Variance := 0;
                MemberPayment := 0;
                PaymentDate := 0D;
                PaymentDay := 0;

                Evaluate(FilterDate, DelChr(Loans.GetFilter("Date Filter"), '=', '..'));

                if Date2DMY("Payment Date", 1) > Date2DMY(CalcDate('CM', FilterDate), 1) then
                    PaymentDay := Date2DMY(CalcDate('CM', FilterDate), 1)
                else
                    PaymentDay := Date2DMY("Payment Date", 1);

                PaymentDate := DMY2Date(PaymentDay, Date2DMY(FilterDate, 2), Date2DMY(FilterDate, 3));

                Datefilter := StrSubstNo('%1..%2', CalcDate('-CM', FilterDate), CalcDate('CM', FilterDate));

                DetailedVendorLedgEntry.Reset();
                DetailedVendorLedgEntry.SetRange("Member No.", "Member No.");
                DetailedVendorLedgEntry.SetRange("Loan No.", "No.");
                DetailedVendorLedgEntry.Setfilter("Posting Date", Datefilter);
                DetailedVendorLedgEntry.Setfilter("Sacco Transaction Type", '%1|%2', DetailedVendorLedgEntry."Sacco Transaction Type"::"Interest Paid", DetailedVendorLedgEntry."Sacco Transaction Type"::"Principal Paid");
                DetailedVendorLedgEntry.Setfilter("Document No.", '<>OPENBAL');
                DetailedVendorLedgEntry.SetCurrentKey("Entry No.");
                DetailedVendorLedgEntry.SetAscending("Entry No.", false);
                if DetailedVendorLedgEntry.FindSet then begin
                    DetailedVendorLedgEntry.CalcSums("Credit Amount");
                    MemberPayment := DetailedVendorLedgEntry."Credit Amount";
                end;
                Variance := "Monthly Installment" - MemberPayment;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        Members: Record Members;
        PhoneNo: Code[20];
        PaymentDate, AsAtDate, FilterDate : Date;
        DateFilter: Text;
        PaymentDay: Integer;
        MemberPayment, Variance : Decimal;
}
