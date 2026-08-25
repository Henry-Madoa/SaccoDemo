report 52204017 "Member List"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    PreviewMode = PrintLayout;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Member List.rdl';

    dataset
    {
        dataitem(Members; Members)
        {
            RequestFilterFields = "Date of Registration";
            column("CompanyAddress1"; CompanyInformation.Address)
            {
            }
            column("CompanyAddress2"; CompanyInformation."Address 2")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
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
            column(Alt__Phone_No; "Alt. Phone No")
            {
            }
            column(Date_of_Birth; "Date of Birth")
            {
            }
            column(Date_of_Registration; "Date of Registration")
            {
            }
            column(Total_Deposits; "Total Deposits")
            {
            }
            column(Full_Name; "Full Name")
            {
            }
            column(Gender; Gender)
            {
            }
            column(Member_No_; "No.")
            {
            }
            column(Mobile_Phone_No_; "Mobile Phone No.")
            {
            }
            column(National_ID_No; "Identification No.")
            {
            }
            column(Payroll_No; "Payroll No.")
            {
            }
            column(SerialNo; SerialNo)
            {
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                CalcFields("Total Deposits");
                if "Payroll No." = '' then "Payroll No." := Members."Payroll No.";
                SerialNo := 1;
                SerialNo := SerialNo + 1;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        SerialNo: Integer;
}
