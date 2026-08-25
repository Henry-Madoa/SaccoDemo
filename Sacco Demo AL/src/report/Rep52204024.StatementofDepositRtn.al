report 52204024 "Statement of Deposit Rtn."
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    PreviewMode = Normal;
    RDLCLayout = './ssrs/StatementOfDepositReturn.rdl';

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = where("Product Posting Type" = filter(<> "Loan Account" & <> "Share Capital Account" & <> "Benevolent Account" & <> "Share Trading Account"));
            RequestFilterFields = "Date Filter";

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
            column(Member_No_; "Member No.")
            {
            }
            column(Account_Code; "Product Code")
            {
            }
            column(Net_Change; "Net Change")
            {
            }
            column(AccountClass; AccountClass)
            {
            }
            column(GroupCode; GroupCode)
            {
            }
            column(GroupOrder; GroupOrder)
            {
            }
            column(Position; Position)
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.get;
                //CompanyInformation.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            var
                ProductFactory: Record "Sacco Products";
            begin
                // if ProductFactory.Get(Vendor."Product Code") then begin
                //     if ProductFactory."Product Posting Type" = ProductFactory."Product Posting Type"::"Share Capital Account" then CurrReport.Skip();
                //     if ProductFactory."Product Posting Type" = ProductFactory."Product Posting Type"::"Loan Account" then CurrReport.Skip();
                // end
                // else
                //     CurrReport.Skip();
                if Vendor."Member No." = '' then CurrReport.Skip();
                Vendor.CALCFIELDS("Net Change");
                Position := 0;
                AccountClass := '';
                GroupCode := '';
                GroupOrder := 0;
                IF (Vendor."Net Change") > 1000000 THEN BEGIN
                    AccountClass := 'Over 1,000,000';
                    Position := 5;
                END
                ELSE IF (((Vendor."Net Change") >= 300000) AND (((Vendor."Net Change") <= 1000000))) THEN BEGIN
                    AccountClass := '300,000 to 1,000,000';
                    Position := 4;
                END
                ELSE IF (((Vendor."Net Change") >= 100000) AND (((Vendor."Net Change") < 300000))) THEN BEGIN
                    AccountClass := '100,000 to 300,000';
                    Position := 3;
                END
                ELSE IF (((Vendor."Net Change") >= 50000) AND (((Vendor."Net Change") < 100000))) THEN BEGIN
                    AccountClass := '50,000 to 100,000';
                    Position := 2;
                END
                ELSE IF (Vendor."Net Change") < 50000 THEN BEGIN
                    AccountClass := 'Less than 50,000';
                    Position := 1;
                end;
                if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Fixed Deposit Account" then begin
                    GroupCode := 'Term';
                    GroupOrder := 3;
                END
                ELSE if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Non Withdrawable Deposit" then BEGIN
                    GroupCode := 'Non-Withdrawable';
                    GroupOrder := 2;
                end
                ELSE BEGIN
                    GroupCode := 'Savings';
                    GroupOrder := 1;
                end;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        DateFilter: Text[100];
        Position, GroupOrder : Integer;
        AccountClass, GroupCode : Code[100];
}
