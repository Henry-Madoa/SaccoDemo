report 52204062 "Loan Pro-rata Interest"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Loan Pro-rata Interest';
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = Normal;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Loan Pro_rata Interest.rdl';

    dataset
    {
        dataitem(LoanApplication; Loans)
        {
            DataItemTableView = where(posted = filter(true));
            RequestFilterFields = "Posting Date", "Member No.", "Employer Code", "Date Filter";

            column(LoanAccount; "Loan Account")
            {
            }
            column(ProductDescription; "Product Description")
            {
            }
            column(MemberName; "Member Name")
            {
            }
            column(ApprovedAmount; "Approved Amount")
            {
            }
            // column(Interest){}
            column(PostingDate; FORMAT("Posting Date"))
            {
            }
            column(ProratedDays; "Prorated Days")
            {
            }
            column(ProratedInterest; "Prorated Interest")
            {
            }
            column("CompanyLogo"; CompanyInfo.Picture)
            {
            }
            column("CompanyName"; CompanyInfo.Name)
            {
            }
            column("CompanyAddress1"; CompanyInfo.Address)
            {
            }
            column("CompanyAddress2"; CompanyInfo."Address 2")
            {
            }
            column("CompanyPhone"; CompanyInfo."Phone No.")
            {
            }
            column("CompanyEmail"; CompanyInfo."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInfo."Home Page")
            {
            }
            column(Interest; Interest)
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInfo.Get();
                CompanyInfo.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                Interest := 0;
                if LoanApplication.Get(LoanApplication."No.") then begin
                    Interest := LoanApplication."Approved Amount" * LoanApplication."Interest Rate" * 0.01 * (1 / 12) * (1 / 30) * LoanApplication."Prorated Days";
                    Interest := Round(Interest, 1, '=');
                end;
            end;

            trigger OnPostDataItem()
            begin
            end;
        }
    }
    var
        CompanyInfo: Record "Company Information";
        Interest: Decimal;
}
