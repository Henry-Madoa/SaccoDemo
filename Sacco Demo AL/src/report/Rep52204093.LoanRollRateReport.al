report 52204093 "Loan Roll Rate Report"
{
    PreviewMode = Normal;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/LoanRollRateReport.rdl';

    dataset
    {
        dataitem(Loans; Loans)
        {
            CalcFields = "Sector Name";

            column(Application_No; "No.")
            {
            }
            column(Loan_Classification; "Loan Classification")
            {
            }
            column(Deposits; Deposits)
            {
            }
            column(Member_No_; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(EmployerName; EmployerName)
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Last_Pay_Date; "Last Pay Date")
            {
            }
            column(Repayment_End_Date; "Repayment End Date")
            {
            }
            column(SectorCode; "Sector Code")
            {
            }
            column(SectorName; "Sector Name")
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Loan_Balance; "Net Change-Principal")
            {
            }
            column(Net_Change_Principal; "Net Change-Principal")
            {
            }
            column(GroupSortingOrder; GroupSortingOrder)
            {
            }
            column(Product_Code; "Product Code")
            {
            }
            column(Product_Description; "Product Description")
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
            column(RemainingPeriod; RemainingPeriod)
            {
            }
            column(Principal_Balance; "Net Change-Principal")
            {
            }
            column(AgeingGroup; AgeingGroup)
            {
            }
            column(Staff_No; "Staff No")
            {
            }
            column(Filters; Filters)
            {
            }
            column(Interest_Rate; "Interest Rate")
            {
            }
            column(Rate_Type; "Interest Repayment Method")
            {
            }
            column(PersonalNo_; PersonalNo_)
            {
            }
            trigger OnPreDataItem()
            begin
                Filters := Loans.GetFilters;
                CompanyInformation.Get();
                CompanyInformation.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                Loans.CalcFields("Employer Code");
                EmployerCode := '';
                EmployerName := '';
                if Employers.Get("Employer Code") then EmployerName := Employers.Name;
                Deposits := 0;
                Deposits := LoansMgt.GetMemberDeposits("Member No.");
                AgeingGroup := '';
                ObjMembers.reset;
                ObjMembers.SetRange("No.", Loans."Member No.");
                if ObjMembers.findset then begin
                    PersonalNo_ := ObjMembers."Payroll No.";
                    if PersonalNo_ = '' then PersonalNo_ := ObjMembers."Payroll No.";
                end;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        EmployerName, AgeingGroup, Filters, EmployerCode : Text;
        GroupSortingOrder, RemainingPeriod : Integer;
        Employers: Record Employers;
        LoansMgt: Codeunit "Loans Management";
        ObjMembers: Record Members;
        PersonalNo_: Code[50];

    trigger OnInitReport()
    begin
    end;

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture)
    end;

    trigger OnPostReport()
    begin
    end;
}
