report 52204043 "Loan Ageing Analysis"
{
    PreviewMode = Normal;
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/LoanAgeingAnalysis.rdl';

    dataset
    {
        dataitem("Loan Application"; Loans)
        {
            column("CompanyAddress1"; CompanyInformation.Address)
            {
            }
            column("CompanyAddress2"; CompanyInformation."Address 2")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
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
            column(AgeingGroup; AgeingGroup)
            {
            }
            column(Application_No; "No.")
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Filters; Filters)
            {
            }
            column(GroupSortingOrder; GroupSortingOrder)
            {
            }
            column(Installments; Installments)
            {
            }
            column(Last_Pay_Date; "Last Pay Date")
            {
            }
            column(Loan_Balance; "Loan Balance")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Member_No_; "Member No.")
            {
            }
            // column(Loan_Balance;
            // "Net Change-Principal")
            // {
            // }
            column(Net_Change_Principal; "Net Change-Principal")
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Product_Code; "Product Code")
            {
            }
            column(Product_Description; "Product Description")
            {
            }
            column(RemainingPeriod; RemainingPeriod)
            {
            }
            column(Repayment_End_Date; "Repayment End Date")
            {
            }
            column(Staff_No; "Staff No")
            {
            }
            trigger OnPreDataItem()
            begin
                Filters := "Loan Application".GetFilters;
                CompanyInformation.Get();
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Deposits: Decimal;
        MemberMgt: Codeunit "Member Management";
        LoansMgt: Codeunit "Loans Management";
        EmployerCode, EmployerName : Code[100];
        Members: Record Members;
        Employers: Record Employers;
        Filters: Text;
        AgeingGroup: Text[100];
        RemainingPeriod, GroupSortingOrder : Integer;
        AsAtDate: Date;
}
