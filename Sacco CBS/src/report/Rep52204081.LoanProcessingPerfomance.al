report 52204081 "Loan Processing Perfomance"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    PreviewMode = Normal;
    DefaultLayout = RDLC;
    RDLCLayout = '.\ssrs\Loan Processing Perfomance.rdl';

    dataset
    {
        dataitem(Loans; Loans)
        {
            DataItemTableView = where("Mobile Loan" = const(false));
            RequestFilterFields = "Date Filter", "Member No.", "No.", "Posting Date";
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
            column(Application_No; Loans."No.")
            {
            }
            column(Application_Date; Loans."Application Date")
            {
            }
            column(Member_No_; Loans."Member No.")
            {
            }
            column(Member_Name; Members."Full Name")
            {
            }
            column(Product_Code; Loans."Product Code")
            {
            }
            column(EmployerCode; Loans."Employer Code")
            {
            }
            column(EmployerName; EmployerName)
            {
            }
            column(Product_Description; ProductName)
            {
            }
            column(Applied_Amount; Loans."Loan Amount")
            {
            }
            column(Approved_Amount; Loans."Approved Amount")
            {
            }
            column(Interest_Balance; Loans."Interest Balance")
            {
            }
            column(Penalty_Balance; Loans."Penalty Balance")
            {
            }
            column(Principal_Balance; Loans."Principal Balance")
            {
            }
            column(Loan_Balance; Loans."Loan Balance")
            {
            }
            column(Branch; Loans."Sales Representative")
            {
            }
            column(Interest_Rate; Loans."Interest Rate")
            {
            }
            column(Installments; Loans.Installments)
            {
            }
            column(Sales_Person; Loans."Sales Representative")
            {
            }
            column(Sales_Person_Name; Loans."Sales Representative Name")
            {
            }
            column(Interest_Repayment_Method; Loans."Interest Repayment Method")
            {
            }
            column(Posting_Date; Loans."Posting Date")
            {
            }
            column(Staff_No; Loans."Staff No")
            {
            }
            column(PersonalNo_; PersonalNo_)
            {
            }
            column(Created_On; "Created On")
            {
            }
            column(Created_By; "Created By")
            {
            }
            column(Appraised_On; "Appraised On")
            {
            }
            column(Appraised_By; "Appraised By")
            {
            }
            column(Posted_On; Loans."Posted On")
            {
            }
            column(Posted_By; Loans."Posted By")
            {
            }
            column(TOT; TOT)
            {
            }
            column(TAT_Hours; TAT_Hours)
            {
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                CalcFields("Appraised On", "Appraised By");
                ProductName := '';
                if Products.get("Product Code") then
                    ProductName := Products.Description;
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
                TOT := '';
                If (("Posted On" <> 0DT) and ("Created On" <> 0DT)) then begin
                    TAT_Hours := Round((("Posted On" - "Created On") / 3600000), 1, '=');

                    TAT_Minutes := Round((("Posted On" - "Created On") / 60000), 1, '>');
                    If ((TAT_Hours <> 0) and (TAT_Minutes <> 0)) then
                        TOT := StrSubstNo('%1H %2M', TAT_Hours, TAT_Minutes mod 24)
                    else If ((TAT_Hours <> 0) and (TAT_Minutes = 0)) then
                        TOT := StrSubstNo('%1H', TAT_Hours)
                    else If ((TAT_Hours = 0) and (TAT_Minutes <> 0)) then
                        TOT := StrSubstNo('%1M', TAT_Minutes);
                end;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        EmployerCode, EmployerName, ProductName : Code[100];
        Members: Record Members;
        Employers: Record Employers;
        Products: Record "Sacco Products";
        PersonalNo_: code[50];
        TOT: Text;
        TAT_Minutes: Decimal;
        TAT_Hours: Decimal;
}
