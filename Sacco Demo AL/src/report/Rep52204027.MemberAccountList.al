report 52204027 "Member Account List"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    PreviewMode = Normal;
    RDLCLayout = './ssrs/Member Account List.rdl';

    dataset
    {
        dataitem(Members; Members)
        {
            column(Member_No_; "No.")
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
            column(Full_Name; "Full Name")
            {
            }
            column(National_ID_No; "Identification No.")
            {
            }
            column(Mobile_Phone_No_; "Mobile Phone No.")
            {
            }
            column(Alt__Phone_No; "Alt. Phone No")
            {
            }
            column(Gender; Gender)
            {
            }
            column(Date_of_Birth; "Date of Birth")
            {
            }
            column(Payroll_No; "Payroll No.")
            {
            }
            column(Date_of_Registration; "Date of Registration")
            {
            }
            dataitem(Vendor; Vendor)
            {
                DataItemLink = "Member No." = field("No.");
                DataItemTableView = sorting("No.");

                column(Net_Change; "Net Change")
                {
                }
                column(Name; Name)
                {
                }
                trigger OnPreDataItem()
                begin
                    SetFilter("Date Filter", DateFilter);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                DateFilter := Members.GetFilter("Date Filter");
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        DateFilter: Text;
}
