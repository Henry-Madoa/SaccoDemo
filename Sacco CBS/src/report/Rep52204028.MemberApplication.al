report 52204028 "Member Application"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Member Application.rdl';

    dataset
    {
        dataitem("Member Application"; "Member Application")
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
            column(Application_No_; "No.")
            {
            }
            column(Member_Category; Category)
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
            column(Full_Name; "Full Name")
            {
            }
            column(National_ID_No; "Identification No.")
            {
            }
            column(KRA_PIN; "KRA PIN")
            {
            }
            column(Date_of_Birth; "Date of Birth")
            {
            }
            column(Occupation; "Occupation Description")
            {
            }
            column(Gender; Gender)
            {
            }
            column(Employer_Code; "Employer Code")
            {
            }
            column(Station_Code; "Station Code")
            {
            }
            column(Payroll_No_; "Payroll No.")
            {
            }
            column(Designation; Designation)
            {
            }
            column(Address; Address)
            {
            }
            column(Alt__Phone_No; "Alt. Phone No")
            {
            }
            column(County; County)
            {
            }
            column(Sub_County; "Sub County")
            {
            }
            column(Town_of_Residence; "Town of Residence")
            {
            }
            column(Estate_of_Residence; "Estate of Residence")
            {
            }
            column(Member_Image; "Passport Size Photo")
            {
            }
            column(Front_ID_Image; "Front ID Photo")
            {
            }
            column(Back_ID_Image; "Back ID Photo")
            {
            }
            column(Member_Signature; Signature)
            {
            }
            column(ATM; ATM)
            {
            }
            column(Mobile; Mobile)
            {
            }
            column(Portal; Mobile)
            {
            }
            column(FOSA; true)
            {
            }
            column(Marketing_Texts; "Marketing Texts")
            {
            }
            dataitem("Nexts of Kin"; "Member Nominee/Kin")
            {
                DataItemLink = "Source Code" = field("No.");
                DataItemTableView = sorting("Source Code");

                column(KIN_ID; "Identification No.")
                {
                }
                column(Kin_Type; "Relative Code")
                {
                }
                column(Name; Name)
                {
                }
                column(Kin_Date_of_Birth; "Date of Birth")
                {
                }
                column(Phone_No_; "Phone No.")
                {
                }
                column(Allocation; Allocation)
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                "Member Application".CalcFields("Passport Size Photo", Signature, "Front ID Photo", "Back ID Photo");
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
}
