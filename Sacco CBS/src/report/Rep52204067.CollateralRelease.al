report 52204067 "Collateral Release"
{
    PreviewMode = Normal;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Collateral Release.rdl';

    dataset
    {
        dataitem("Collateral Register"; "Collateral Register")
        {
            DataItemTableView = where(Status = const(Collected));
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
            column(Filters; Filters)
            {
            }
            column(No_; "No.")
            {
            }
            column(Owner_Phone_No_; "Owner Phone No.")
            {
            }
            column(Member_No; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Collateral_Description; "Collateral Description")
            {
            }
            column(Serial_No; "Serial/Reg No.")
            {
            }
            dataitem("Collateral Release"; "Collateral Release")
            {
                DataItemLink = "Collateral Code" = field("No.");
                DataItemTableView = sorting("No.") where(Posted = const(true));

                column(Collected_By; "Collected By")
                {
                }
                column(Collected_By_ID_No; "Collected By ID No")
                {
                }
                column(Phone_No; "Phone No")
                {
                }
                column(Collection_Date; "Collection Date")
                {
                }
            }
            trigger OnPreDataItem()
            begin
                Filters := "Collateral Release".GetFilters;
                CompanyInformation.Get();
                CompanyInformation.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Filters: Text;
}
