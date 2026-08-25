report 52204065 "Membership Statistics"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/MembershipStatistics.rdl';

    dataset
    {
        dataitem(Employer_Codes; Employers)
        {
            RequestFilterFields = Code;
            DataItemTableView = where(Blocked = const(false));

            column(Code; "Code")
            {
            }
            column(Name; Name)
            {
            }
            column(NoOfActiveMembers; "Active Members")
            {
            }
            column(NoOfDormantMembers; "Dormant Members")
            {
            }
            column(NoOfWithdrawnMembers; "Withdrawn Members")
            {
            }
            column(NoOfDeceasedMembers; "Deceased Members")
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
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get();
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
}
