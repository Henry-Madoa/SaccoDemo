report 52204038 "Membership Form"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    RDLCLayout = './ssrs/Membership Form.rdl';

    dataset
    {
        dataitem(DataItemName; "Member Application")
        {
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
            column(Application_No_; "No.")
            {
            }
            column(First_Name; "First Name")
            {
            }
            column(Middle_Name; "Middle Name")
            {
            }
            column(Last_Name; "Last Name")
            {
            }
            column(Nationality; Nationality)
            {
            }
            column(National_ID_No; "Identification No.")
            {
            }
            column(KRA_PIN; "KRA PIN")
            {
            }
            column(Employer_Code; "Employer Code")
            {
            }
            column(Designation; Designation)
            {
            }
            column(Payroll_No_; "Payroll No.")
            {
            }
            column(Mobile_Phone_No_; "Mobile Phone No.")
            {
            }
            column(E_Mail_Address; "E-Mail")
            {
            }
            column(Address; Address)
            {
            }
            column(Town_of_Residence; "Town of Residence")
            {
            }
            column(FOSA; true)
            {
            }
            column(Mobile; Mobile)
            {
            }
            column(ATM; ATM)
            {
            }
            column(Member_Image; "Passport Size Photo")
            {
            }
            column(Member_Signature; Signature)
            {
            }
            column(Recruited_By; "Recruited By")
            {
            }
            column(Recruiter_Name; "Recruiter Name")
            {
            }
            column(Other_Recruitment_Details; "Other Recruitment Details")
            {
            }
            dataitem("Nexts of Kin"; "Member Nominee/Kin")
            {
                DataItemLink = "Source Code" = field("No.");

                column(Name; Name)
                {
                }
                column(Kin_Type; "Relative Code")
                {
                }
                column(Allocation; Allocation)
                {
                }
                column(KIN_ID; "Identification No.")
                {
                }
                column(Phone_No_; "Phone No.")
                {
                }
            }
            dataitem("Member Subscriptions"; "Member Subscriptions")
            {
                DataItemLink = "Source Code" = field("No.");

                column(Account_Type; "Account Type")
                {
                }
                column(Account_Name; "Account Name")
                {
                }
                column(Start_Date; "Start Date")
                {
                }
                column(Amount; Amount)
                {
                }
                column(Minimum_Contribution; "Minimum Contribution")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if "Account Type" = '' then CurrReport.Skip();
                end;
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                CalcFields("Passport Size Photo");
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
}
