report 52204054 "Overdrawn Accounts"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    RDLCLayout = './ssrs/OverdrawnAccounts.rdl';

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            RequestFilterFields = "Date Filter", "Member No.", "Vendor Posting Group", "Product Code";

            column(Member_No_; "Member No.")
            {
            }
            column(Name; Name)
            {
            }
            column(Search_Name; "Search Name")
            {
            }
            column(Net_Change; "Net Change")
            {
            }
            column(PayrollNo; PayrollNo)
            {
            }
            trigger OnAfterGetRecord()
            begin
                Vendor.CalcFields("Net Change");
                if "Net Change" >= 0 then CurrReport.Skip();
                PayrollNo := '';
                if Members.Get("Member No.") then begin
                    PayrollNo := Members."Payroll No.";
                    if PayrollNo = '' then PayrollNo := Members."Payroll No.";
                end;
            end;
        }
    }
    var
        PayrollNo: Code[20];
        Members: Record Members;
}
