report 52204095 "GL Balance vs Listing"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    PreviewMode = PrintLayout;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/GL Balance vs Listing.rdl';
    dataset
    {
        dataitem(SaccoProducts; "Sacco Products")
        {
            RequestFilterFields = Code, "Date Filter";
            column("CompanyAddress1"; CompanyInformation.Address)
            {
            }
            column("CompanyAddress2"; CompanyInformation."Address 2")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column("CompanyLogo"; CompanyInformation.Picture)
            {
            }
            column("CompanyName"; CompanyInformation.Name)
            {
            }
            column("CompanyPhone"; CompanyInformation."Phone No.")
            {
            }
            column(Code; Code)
            {
            }
            column(Description; Description)
            {
            }
            column(AccountBalance; AccountBalance)
            {
            }
            column(AccountListing; AccountListing)
            {
            }
            column(AccountVariance; AccountVariance)
            {
            }
            column(InterestBalance; InterestBalance)
            {
            }
            column(InterestListing; InterestListing)
            {
            }
            column(InterestVariance; InterestVariance)
            {
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                Datefilter := '';
                AccountBalance := 0;
                InterestBalance := 0;
                AccountListing := 0;
                InterestListing := 0;
                AccountVariance := 0;
                InterestVariance := 0;

                Datefilter := SaccoProducts.GetFilter("Date Filter");

                if VendorPostingGroup.Get("Posting Group") then begin
                    GLAccount[1].Reset();
                    GLAccount[1].SetFilter("No.", VendorPostingGroup."Payables Account");
                    GLAccount[1].SetFilter("Date Filter", Datefilter);
                    if GLAccount[1].FindFirst() then begin
                        GLAccount[1].CalcFields("Net Change");
                        AccountBalance := GLAccount[1]."Net Change";
                    end;

                    GLAccount[1].Reset();
                    GLAccount[1].SetFilter("No.", VendorPostingGroup."Interest Accrual Account");
                    GLAccount[1].SetFilter("Date Filter", Datefilter);
                    if GLAccount[1].FindFirst() then begin
                        GLAccount[1].CalcFields("Net Change");
                        InterestBalance := GLAccount[1]."Net Change";
                    end;

                end;
                if "Product Posting Type" <> "Product Posting Type"::"Loan Account" then begin
                    VendorLedgerEntry[1].Reset();
                    VendorLedgerEntry[1].SetFilter("Posting Date", Datefilter);
                    VendorLedgerEntry[1].SetFilter("Product Posting Type", '=%1', "Product Posting Type");
                    VendorLedgerEntry[1].Setrange("Vendor Posting Group", "Posting Group");
                    if VendorLedgerEntry[1].FindSet then begin
                        repeat
                            VendorLedgerEntry[1].CalcFields(Amount);
                            AccountListing += VendorLedgerEntry[1].Amount;
                        until VendorLedgerEntry[1].Next = 0;
                    end;
                end else begin
                    VendorLedgerEntry[2].Reset();
                    VendorLedgerEntry[2].SetFilter("Posting Date", Datefilter);
                    VendorLedgerEntry[2].SetFilter("Product Posting Type", '=%1', "Product Posting Type");
                    VendorLedgerEntry[2].SetFilter("Sacco Transaction Type", '=%1|%2', VendorLedgerEntry[2]."Sacco Transaction Type"::"Loan Disbursal", VendorLedgerEntry[2]."Sacco Transaction Type"::"Principal Paid");
                    VendorLedgerEntry[2].Setrange("Vendor Posting Group", "Posting Group");
                    if VendorLedgerEntry[2].FindSet then begin
                        repeat
                            VendorLedgerEntry[2].CalcFields(Amount);
                            AccountListing += VendorLedgerEntry[2].Amount;
                        until VendorLedgerEntry[2].Next = 0;
                    end;

                    VendorLedgerEntry[3].Reset();
                    VendorLedgerEntry[3].SetFilter("Posting Date", Datefilter);
                    VendorLedgerEntry[3].SetFilter("Product Posting Type", '=%1', "Product Posting Type");
                    VendorLedgerEntry[3].SetFilter("Sacco Transaction Type", '=%1|%2', VendorLedgerEntry[3]."Sacco Transaction Type"::"Interest Due", VendorLedgerEntry[3]."Sacco Transaction Type"::"Interest Paid");
                    VendorLedgerEntry[3].Setrange("Vendor Posting Group", "Posting Group");
                    if VendorLedgerEntry[3].FindSet then begin
                        repeat
                            VendorLedgerEntry[3].CalcFields(Amount);
                            InterestListing += VendorLedgerEntry[3].Amount;
                        until VendorLedgerEntry[3].Next = 0;
                    end;

                end;
                AccountVariance := AccountBalance - AccountListing;
                InterestVariance := InterestBalance - InterestListing;
            end;
        }
    }

    var
        CompanyInformation: Record "Company Information";
        Datefilter: Text;
        AccountBalance, InterestBalance, AccountListing, InterestListing, AccountVariance, InterestVariance : Decimal;
        VendorPostingGroup: Record "Vendor Posting Group";
        GLAccount: array[2] of Record "G/L Account";
        VendorLedgerEntry: array[3] of Record "Vendor Ledger Entry";
}
