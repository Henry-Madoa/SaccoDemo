report 52204096 "Fixed Deposit Certificate"
{
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Fixed Deposit Certificate.rdl';

    dataset
    {
        dataitem("Member Fixed Deposits"; "Member Fixed Deposits")
        {
            RequestFilterFields = "No.", "Date Filter";
            CalcFields = "Total Interest Payable";
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
            column(Member_No_; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Control_Account; "Control Account")
            {
            }
            column(Start_Date; "Start Date")
            {
            }
            column(End_Date; "End Date")
            {
            }
            column(Amount; Amount)
            {
            }
            column(Period; Period)
            {
            }
            column(Rate; Rate)
            {
            }
            column(Total_Interest_Payable; "Total Interest Payable" - ("Total Interest Payable" * 0.15))
            {
            }
            column(AmountInWords; NumberText[1] + ' ' + NumberText[2])
            {
            }
            dataitem(Members; Members)
            {
                DataItemLink = "No." = field("Member No.");
                column(Identification_No_; "Identification No.")
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                GeneralLedgerSetup.GET;
                CurrencyCodeText := GeneralLedgerSetup."LCY Code";
                AmountToWords.FormatNoText(NumberText, "Total Interest Payable", CurrencyCodeText);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        NumberText: array[2] of Text[80];
        CurrencyCodeText: Code[10];
        AmountToWords: Codeunit "Amount To Words";
        GeneralLedgerSetup: Record "General Ledger Setup";
}
