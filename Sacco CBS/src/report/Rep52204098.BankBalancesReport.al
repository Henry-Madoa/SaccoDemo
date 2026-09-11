report 52204098 "Bank Balances Report"
{
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Bank Balances Report.rdl';

    dataset
    {
        dataitem("Bank Account"; "Bank Account")
        {
            RequestFilterFields = "Bank Acc. Posting Group", "Date Filter";
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
            column(No_; "No.")
            {
            }
            column(Name; Name)
            {
            }
            column(Balance; Balance)
            {
            }
            column(Filters; Filters)
            {
            }
            trigger OnPreDataItem()
            begin
                Filters := "Bank Account".GetFilters;
            end;

            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                CalcFields(Balance);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Filters: Text;
}
