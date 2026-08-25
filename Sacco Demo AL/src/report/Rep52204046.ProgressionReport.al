report 52204046 "Progression Report"
{
    PreviewMode = Normal;
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/ProgressionReport.rdl';

    dataset
    {
        dataitem(Members; Members)
        {
            RequestFilterFields = "Account Type Filter", "No.";
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
            column(Member_No_; "No.")
            {
            }
            column(FullName; FullName)
            {
            }
            column(Run_Year; Year)
            {
            }
            dataitem(Vendor; Vendor)
            {
                DataItemLink = "Member No." = field("No."), "Product Code" = field("Account Type Filter");

                column(No_; "No.")
                {
                }
                column(Name; Name)
                {
                }
                column(OpeningBalance; OpeningBalance)
                {
                }
                dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
                {
                    DataItemLink = "Vendor No." = field("No.");
                    DataItemTableView = sorting("Entry No.");

                    column(Posting_Date; "Posting Date")
                    {
                    }
                    column(Amount; Amount)
                    {
                    }
                    trigger OnPreDataItem()
                    begin
                        SetFilter("Posting Date", DateFilter);
                    end;
                }
                trigger OnAfterGetRecord()
                begin
                    DateFilter := '..' + Format(DMY2Date(31, 12, Year - 1));
                    OpeningBalance := 0;

                    DetailedLedger.Reset();
                    DetailedLedger.SetFilter("Posting Date", DateFilter);
                    DetailedLedger.SetRange("Vendor No.", "No.");
                    if DetailedLedger.FindSet() then begin
                        DetailedLedger.CalcSums(Amount);
                        OpeningBalance := -1 * DetailedLedger.Amount;
                    end;

                    DateFilter := '';
                    DateFilter := Format(DMY2Date(1, 1, Year)) + '..' + Format(DMY2Date(31, 12, Year));
                end;
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Report Parameters")
                {
                    field(Year; Year)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
        }
    }
    var
        CompanyInformation: Record "Company Information";
        DateFilter: Text;
        DetailedLedger: Record "Detailed Vendor Ledg. Entry";
        DateRec: Record Date;
        OpeningBalance: Decimal;
        LowerLimit: Date;
        Year: Integer;
}
