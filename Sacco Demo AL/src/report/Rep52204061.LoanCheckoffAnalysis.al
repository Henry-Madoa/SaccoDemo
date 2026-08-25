report 52204061 "Loan Checkoff Analysis"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    RDLCLayout = './ssrs/LoanCheckoffAnalysis.rdl';
    DefaultLayout = rdlc;

    dataset
    {
        dataitem("CheckoffAdvice"; "Checkoff Advice")
        {
            RequestFilterFields = "Advice Type", "Employer Code", "Member No";

            column(PayrollNo; PayrollNo)
            {
            }
            column(MemberName; MemberName)
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Amount_Off; "Amount Off")
            {
            }
            column(Amount_On; "Amount On")
            {
            }
            column("CompanyLogo"; CompanyInfo.Picture)
            {
            }
            column("CompanyName"; CompanyInfo.Name)
            {
            }
            column("CompanyAddress1"; CompanyInfo.Address)
            {
            }
            column("CompanyAddress2"; CompanyInfo."Address 2")
            {
            }
            column("CompanyPhone"; CompanyInfo."Phone No.")
            {
            }
            column("CompanyEmail"; CompanyInfo."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInfo."Home Page")
            {
            }
            column(Product_Name; "Product Name")
            {
            }
            column(Product_Type; "Product Code")
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInfo.Get();
                CompanyInfo.CalcFields(Picture);
                //CheckoffAdvice.CalcFields("Member Name");
            end;

            trigger OnAfterGetRecord()
            begin
                Member.reset;
                Member.SetRange(Member."No.", CheckoffAdvice."Member No");
                if Member.findset then begin
                    PayrollNo := Member."Payroll No.";
                    MemberName := Member."Full Name";
                    //Message('Member Number is %1', MemberName);
                end;
            end;

            trigger OnPostDataItem()
            begin
            end;
        }
    }
    var
        CompanyInfo: Record "Company Information";
        Member: Record Members;
        PayrollNo: Text[50];
        MemberName: Text[250];
}
