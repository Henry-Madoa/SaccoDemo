report 52204029 "Checkoff Advise"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    PreviewMode = Normal;
    RDLCLayout = './ssrs/Checkoff Advise.rdl';

    dataset
    {
        dataitem("Checkoff Advice"; "Checkoff Advice")
        {
            RequestFilterFields = "Advice Date", "Advice Type", "Employer Code";

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
            column(PayrollNo; PayrollNo)
            {
            }
            column(Member_No; "Member No")
            {
            }
            column(MemberName; "Member Name")
            {
            }
            column(Amount_Off; "Amount Off")
            {
            }
            column(Amount_On; "Amount On")
            {
            }
            column(Current_Balance; "Current Balance")
            {
            }
            column(Installments; Installments)
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Interest_Repayment; "Total Interest Repayment")
            {
            }
            column(Total_Repayment; "Total Repayment")
            {
            }
            column(Loan_Balance; "Loan Balance")
            {
            }
            column(Advice_Date; "Advice Date")
            {
            }
            column(Advice_Type; "Advice Type")
            {
            }
            column(AccountNo; AccountNo)
            {
            }
            column(ProductName; "Product Name")
            {
            }
            column(Loan_No; "Loan No")
            {
            }
            column(EmployerCode; "Employer Code")
            {
            }
            column(EmployerName; EmployerName)
            {
            }
            column(Current_Balance_V2; "Current Balance")
            {
            }
            column(Payroll_No_; Payroll_No_)
            {
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                if "Amount On" = 0 then CurrReport.Skip();
                SaccoProducts.Get("Product Code");
                If SaccoProducts."Salary Based" or SaccoProducts."Charge UpFront Interest" then CurrReport.Skip();
                PayrollNo := '';
                if Members.Get("Member No") then PayrollNo := Members."Payroll No.";
                if PayrollNo = '' then PayrollNo := Members."Payroll No.";
                AccountNo := '';
                if "Advice Type" in ["Advice Type"::Adjustment, "Advice Type"::"New Member", "Advice Type"::RMF] then begin
                    Vendor.Reset();
                    Vendor.SetRange("Member No.", "Member No");
                    Vendor.SetRange("Product Code", "Product Code");
                    if Vendor.FindFirst() then AccountNo := Vendor."No.";
                end
                else begin
                    Loans.Reset();
                    Loans.SetRange("Member No.", "Member No");
                    Loans.SetRange("Product Code", "Product Code");
                    Loans.SetFilter("Loan Balance", '>0');
                    if Loans.FindFirst() then begin
                        AccountNo := Loans."No.";
                        "Loan No" := AccountNo;
                    end;
                end;
                Members.reset;
                members.SetRange("No.", "Checkoff Advice"."Member No");
                if members.FindFirst then begin
                    Payroll_No_ := Members."Payroll No.";
                    if Payroll_No_ = '' then Payroll_No_ := Members."Payroll No.";
                    if Employers.Get(Members."Employer Code") then EmployerName := Employers.Name;
                end;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Members: Record Members;
        PayrollNo, AccountNo, EmployerCode : Code[20];
        MemberName, ProductName, EmployerName : Text[80];
        Vendor: Record Vendor;
        Loans: Record Loans;
        Payroll_No_: Code[50];
        Employers: Record Employers;
        SaccoProducts: Record "Sacco Products";
}
