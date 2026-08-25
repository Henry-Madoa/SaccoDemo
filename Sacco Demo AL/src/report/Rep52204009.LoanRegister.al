report 52204009 "Loan Register"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    PreviewMode = Normal;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Loan Register.rdl';

    dataset
    {
        dataitem(Loans; Loans)
        {
            DataItemTableView = where(Posted = const(true));
            RequestFilterFields = "Member Category", "Date Filter", "Member No.", "No.", "Application Date";

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
            column(Application_No; "No.")
            {
            }
            column(Application_Date; "Application Date")
            {
            }
            column(Member_No_; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Identification_No; Members."Identification No.")
            {
            }
            column(Total_Deposits; Members."Total Deposits")
            {
            }
            column(Category; "Member Category")
            {
            }
            column(Product_Code; "Product Code")
            {
            }
            column(EmployerCode; "Employer Code")
            {
            }
            column(EmployerName; EmployerName)
            {
            }
            column(Product_Description; "Product Description")
            {
            }
            column(Applied_Amount; "Loan Amount")
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Interest_Balance; "Interest Balance")
            {
            }
            column(Penalty_Balance; "Penalty Balance")
            {
            }
            column(Principal_Balance; "Principal Balance")
            {
            }
            column(Loan_Balance; "Loan Balance")
            {
            }
            column(Interest_Rate; "Interest Rate")
            {
            }
            column(Installments; Installments)
            {
            }
            column(Sales_Person; "Sales Representative")
            {
            }
            column(Sales_Person_Name; "Sales Representative Name")
            {
            }
            column(Interest_Repayment_Method; "Interest Repayment Method")
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Staff_No; "Staff No")
            {
            }
            column(Payment_Date; "Payment Date")
            {
            }
            column(Last_Pay_Date; "Last Pay Date")
            {
            }
            column(LastAmountPaid; LastAmountPaid)
            {
            }
            column(Debtor_Collector; "Debt Collector")
            {
            }
            column(DentorCollectorName; DentorCollectorName)
            {
            }
            column(PersonalNo_; PersonalNo_)
            {
            }
            column(Loan_Classification; "Loan Classification")
            {
            }
            column(Recovery_Mode; "Recovery Mode")
            {
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                DentorCollectorName := '';
                LastAmountPaid := 0;
                DateFilter := Loans.GetFilter("Date Filter");
                CalcFields("Last Pay Date");
                CompanyInformation.CalcFields(Picture);

                EmployerCode := '';
                EmployerName := '';
                if Members.Get("Member No.") then begin
                    EmployerCode := Members."Employer Code";
                    if Employers.Get(EmployerCode) then begin
                        EmployerCode := Employers.Code;
                        EmployerName := Employers.Name;
                    end;
                end;
                Members.Reset;
                Members.SetRange("No.", Loans."Member No.");
                Members.Setfilter("Date Filter", DateFilter);
                if Members.FindFirst then begin
                    Members.CalcFields("Total Deposits");
                    PersonalNo_ := Members."Payroll No.";
                end;

                If Employee.Get("Debt Collector") then
                    DentorCollectorName := Employee.FullName

                else if Vendor.Get("Debt Collector") then
                    DentorCollectorName := Vendor.Name;

                DetailedVendorLedgEntry.Reset();
                DetailedVendorLedgEntry.SetFilter("Posting Date", '=%1', "Last Pay Date");
                DetailedVendorLedgEntry.Setrange("Member No.", "Member No.");
                DetailedVendorLedgEntry.Setrange("Loan No.", "No.");
                DetailedVendorLedgEntry.SetFilter("Sacco Transaction Type", '%1|%2', DetailedVendorLedgEntry."Sacco Transaction Type"::"Interest Paid", DetailedVendorLedgEntry."Sacco Transaction Type"::"Principal Paid");
                if DetailedVendorLedgEntry.FindSet then begin
                    DetailedVendorLedgEntry.CalcSums(Amount);
                    LastAmountPaid := DetailedVendorLedgEntry.Amount;
                end;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        EmployerCode, EmployerName : Code[100];
        Members: Record Members;
        Vendor: Record Vendor;
        Employee: Record Employee;
        Employers: Record Employers;
        Products: Record "Sacco Products";
        PersonalNo_: code[50];
        LastAmountPaid: Decimal;
        DateFilter, DentorCollectorName : Text;
}
