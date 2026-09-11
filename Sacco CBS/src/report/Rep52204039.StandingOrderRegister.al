report 52204039 "Standing Order Register"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    RDLCLayout = './ssrs/Standing_Order_Register.rdl';
    DefaultLayout = RDLC;

    dataset
    {
        dataitem(DataItemName; "Standing Order")
        {
            DataItemTableView = where(Running = filter(true));
            RequestFilterFields = "Member No", "Run From Day", "Salary Based";

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
            column(Document_No; "No.")
            {
            }
            column(STO_Type; "STO Type")
            {
            }
            column(Member_No; "Member No")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Start_Date; "Start Date")
            {
            }
            column(Created_On; "Created On")
            {
            }
            column(Account_No; "Account No")
            {
            }
            column(AccountName; AccountName)
            {
            }
            column(Standing_Order_Class; "Standing Order Class")
            {
            }
            column(Destination_Account; "Destination Account")
            {
            }
            column(Destination_Name; "Destination Name")
            {
            }
            column(Period; Period)
            {
            }
            column(Run_From_Day; "Run From Day")
            {
            }
            column(Amount; Amount)
            {
            }
            column(PayrollNo; PayrollNo)
            {
            }
            column(AvailableBalance; AvailableBalance)
            {
            }
            column(Destination_Member_No; "Destination Member No")
            {
            }
            column(Next_Run_Date; "Next Run Date")
            {
            }
            trigger OnAfterGetRecord()
            begin
                if Members.Get("Member No") then PayrollNo := Members."Payroll No.";
                if Vendor.Get("Account No") then begin
                    AccountName := Vendor.Name;
                    Vendor.CalcFields(Balance, "Uncleared Funds");
                    AvailableBalance := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor."Member No.");
                    if AvailableBalance < 0 then AvailableBalance := 0;
                end;
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        AccountName: Text;
        Vendor: Record Vendor;
        PayrollNo: Code[20];
        AvailableBalance: Decimal;
        Members: Record Members;
        SaccoProduct: Record "Sacco Products";
        ChannelsIntegrations: Codeunit "Channels Integrations";
}
