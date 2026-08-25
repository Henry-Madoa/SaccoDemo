report 52204042 "Savings And Loan Listing"
{
    Caption = 'Savings & Loan Listing';
    UsageCategory = Administration;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Savings And Loan Listing.rdl';

    dataset
    {
        dataitem(Members; Members)
        {
            RequestFilterFields = "No.", "Date of Registration";

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
            column(Member_No_; "No.")
            {
            }
            column(Full_Name; "Full Name")
            {
            }
            column(National_ID_No; "Identification No.")
            {
            }
            column(Gender; Gender)
            {
            }
            column(E_Mail; "E-Mail")
            {
            }
            column(Emplyoment_Type; "Emplyoment Type")
            {
            }
            column(Employer_Code; "Employer Code")
            {
            }
            column(EmployerName; EmployerName)
            {
            }
            column(Created_By; "Created By")
            {
            }
            column(Date_of_Registration; "Date of Registration")
            {
            }
            column(Recruited_By; "Recruited By")
            {
            }
            column(Recruiter_Code; "Recruiter Code")
            {
            }
            column(RecruiterName; RecruiterName)
            {
            }
            column(Occupation_Description; "Occupation Description")
            {
            }
            column(Nationality; Nationality)
            {
            }
            column(Domicile; "Country Name")
            {
            }

            dataitem(Vendor; Vendor)
            {
                DataItemLink = "Member No." = field("No.");
                DataItemTableView = sorting("Print Sequence");

                column(No_; "No.")
                {
                }
                column(Name; Name)
                {
                }
                column(Account_Class; "Product Posting Type")
                {
                }
                column(Net_Change; "Net Change")
                {
                }
                column(Print_Sequence; "Print Sequence")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if ((Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Loan Account") and not ShowLoans)
                    then
                        CurrReport.Skip;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);

                EmployerName := '';

                If "Recruited By" = "Recruited By"::Member then begin
                    If Member.Get("Recruiter Code") then
                        RecruiterName := Member.FullName;
                end;
                If "Recruited By" = "Recruited By"::"Sales Representative" then begin
                    If Employee.Get("Recruiter Code") then
                        RecruiterName := Employee.FullName;
                end;

                if Employer.Get("Employer Code") then
                    EmployerName := Employer.Name;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("Show Loans"; ShowLoans)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    var
        CompanyInformation: Record "Company Information";
        PayrollNo: Code[20];
        EmployerName, RecruiterName : Text;
        MemberMgt: Codeunit "Member Management";
        IssueDate: Date;
        SortingOrder: Integer;
        ShowLoans: Boolean;
        Member: Record Members;
        Employee: Record Employee;
        Employer: Record Employers;
}
