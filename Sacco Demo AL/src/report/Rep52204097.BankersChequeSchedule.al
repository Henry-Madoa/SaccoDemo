report 52204097 "Bankers Cheque Schedule"
{
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Bankers Cheque Schedule.rdl';

    dataset
    {
        dataitem("Bankers Cheque"; "Bankers Cheque")
        {
            DataItemTableView = where(Posted = const(true));
            RequestFilterFields = "No.", "Posting Date";
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
            column(Posting_Date; "Posting Date")
            {
            }
            column(Account_Name; "Account Name")
            {
            }
            column(Payee_Details; "Payee Details")
            {
            }
            column(Amount; Amount)
            {
            }
            column(Charge_Amount; "Charge Amount")
            {
            }
            column(Net_Amount; "Net Amount")
            {
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
}
