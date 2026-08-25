report 52204091 "Loan Streaming"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    PreviewMode = Normal;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Loan Streaming.rdl';

    dataset
    {
        dataitem(Loans; Loans)
        {
            RequestFilterFields = "Date Filter", "Member No.";

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
            column(Member_Name; Members."Full Name")
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
            column(Loan_Classification; "Loan Classification")
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
            dataitem("Detailed Vendor Ledg. Entry"; "Detailed Vendor Ledg. Entry")
            {
                DataItemTableView = sorting("Entry No.") where("Sacco Transaction Type" = filter("Principal Paid" | "Interest Paid"));
                DataItemLink = "Loan No." = field("No."), "Vendor No." = field("Loan Account"), "Posting Date" = field("Date Filter");
                column(Document_No_; "Document No.")
                {
                }
                column(Payment_Posting_Date; "Posting Date")
                {
                }
                column(Amount; -Amount)
                {
                }
                column(RepaymentMode; RepaymentMode)
                {
                }
                column(Sacco_Transaction_Type; "Sacco Transaction Type")
                {
                }
                trigger OnAfterGetRecord()
                var
                    //MPESA
                    ArchivedChannelTransactions: Record "Archived Channel Transactions";
                    //OffSet
                    LoanRecoveryHeader: Record "Loan Recovery Header";
                    //FOSA
                    LoanRepaymentHeader: Record "Loan Repayment Header";
                    //Payment Mode
                    ReceiptHeader: Record "Receipt Header";
                    //Standing Order
                    StandingOrder: Record "Standing Order";
                    //Standing Order
                    CheckoffHeader: Record "Checkoff Header";
                begin
                    ArchivedChannelTransactions.Reset();
                    ArchivedChannelTransactions.SetRange("Document No", "Detailed Vendor Ledg. Entry"."Document No.");
                    if ArchivedChannelTransactions.FindFirst then
                        RepaymentMode := 'MPESA';

                    if LoanRecoveryHeader.Get("Detailed Vendor Ledg. Entry"."Document No.") then
                        RepaymentMode := 'OFFSET';
                    If LoanRepaymentHeader.Get("Detailed Vendor Ledg. Entry"."Document No.") then
                        RepaymentMode := 'FOSA';

                    If StandingOrder.Get("Detailed Vendor Ledg. Entry"."Document No.") then
                        RepaymentMode := 'STO';
                    If ReceiptHeader.Get("Detailed Vendor Ledg. Entry"."Document No.") then
                        RepaymentMode := ReceiptHeader."Pay Mode";

                    If CheckoffHeader.Get("Detailed Vendor Ledg. Entry"."Document No.") then begin
                        if CheckoffHeader."Upload Type" = CheckoffHeader."Upload Type"::Checkoff then
                            RepaymentMode := 'CHECKOFF'
                        else if CheckoffHeader."Upload Type" = CheckoffHeader."Upload Type"::Salary then
                            RepaymentMode := 'SALARY';
                    end;

                    if "Posting Date" = 0D then
                        CurrReport.Skip;
                    if RepaymentMode = '' then
                        CurrReport.Skip;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                LastAmountPaid := 0;
                DentorCollectorName := '';
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
                Members.reset;
                Members.SetRange("No.", Loans."Member No.");
                if Members.findset then begin
                    PersonalNo_ := members."Payroll No.";
                    if PersonalNo_ = '' then PersonalNo_ := members."Payroll No."
                end;
                CalcFields("Last Pay Date");

                If Employee.Get("Debt Collector") then
                    DentorCollectorName := Employee.FullName

                else if Vendor.Get("Debt Collector") then
                    DentorCollectorName := Vendor.Name;

                DetailedVendorLedgEntry.Reset();
                DetailedVendorLedgEntry.SetRange("Posting Date", "Last Pay Date");
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
        DentorCollectorName: Text;
        RepaymentMode: Code[20];
}
