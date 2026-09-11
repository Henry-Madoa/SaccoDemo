report 52204031 "Member KINS"
{
    UsageCategory = Administration;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Member KINS.rdl';

    dataset
    {
        dataitem(Members; Members)
        {
            RequestFilterFields = "No.";

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
            column("CompanyWebsite"; CompanyInformation."Home Page")
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
            column(Payroll_No; "Payroll No.")
            {
            }
            dataitem("Nexts of Kin"; "Member Nominee/Kin")
            {
                DataItemLink = "Source Code" = field("No.");
                DataItemTableView = sorting("Source Code");

                column(Kin_Type; "Relative Code")
                {
                }
                column(KIN_ID; "Identification No.")
                {
                }
                column(Name; Name)
                {
                }
                column(Phone_No_; "Phone No.")
                {
                }
                column(Allocation; Allocation)
                {
                }
                column(Date_of_Birth; "Date of Birth")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                PayrollNo := '';
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        PayrollNo: Code[20];
}
