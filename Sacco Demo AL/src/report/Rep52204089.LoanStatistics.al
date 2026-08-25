report 52204089 "Loan Statistics"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/LoanStatistics.rdl';

    dataset
    {
        dataitem("Loan Application"; Loans)
        {
            DataItemTableView = where("Loan Balance" = filter(<> 0), Posted = filter(true));
            RequestFilterFields = "Date Filter", "Member No.", "No.", "Application Date", "Employer Code";

            column(Application_No; "No.")
            {
            }
            column(Installments; Installments)
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
            column(Posting_Date; FORMAT("Posting Date"))
            {
            }
            column(Last_Pay_Date; FORMAT("Last Pay Date"))
            {
            }
            column(Repayment_End_Date; FORMAT("Repayment End Date"))
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Loan_Balance; "Loan Balance")
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
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column(Principal_Balance; "Principal Balance - At Date")
            {
            }
            column(EmployerCode; EmployerCode)
            {
            }
            column(Principal_Paid; "Principal Paid")
            {
            }
            column(Interest_Arrears; "Interest Arrears")
            {
            }
            column(Employer_Code; "Employer Code")
            {
            }
            column(Monthly_Principal; "Monthly Principal")
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
            column(PrincipalDue; PrincipalDue)
            {
            }
            column(Sector_Code; "Sector Code")
            {
            }
            trigger OnPreDataItem()
            begin
                Filters := "Loan Application".GetFilters;
                CompanyInformation.Get();
                CompanyInformation.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                "Loan Application".CalcFields("Employer Code");
                EmployerCode := '';
                EmployerName := '';
                if Employers.Get("Employer Code") then EmployerName := Employers.Name;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Deposits, DefPrincipal, PrincipalPaid, MonthlyPrincipal, PrincipalDue : Decimal;
        MemberMgt: Codeunit "Member Management";
        LoansMgt: Codeunit "Loans Management";
        EmployerCode, EmployerName : Code[100];
        Members: Record Members;
        Employers: Record Employers;
        Filters: Text;
        AgeingGroup: Text[100];
        RemainingPeriod, GroupSortingOrder : Integer;
        AsAtDate: Date;
        LoanAge: Integer;
}
