report 52204086 "Risk Categorization"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    PreviewMode = PrintLayout;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Risk Categorization.rdl';

    dataset
    {
        dataitem(Members; Members)
        {
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
            column(Member_No_; "No.")
            {
            }
            column(Full_Name; "Full Name")
            {
            }
            column(Status; Status)
            {
            }
            column(Running_Loans; "Running Loans")
            {
            }
            column(ClearedLoans; ClearedLoans)
            {
            }
            column(ActiveLoans; ActiveLoans)
            {
            }
            column(Restructured_Active_Loans; Restructured_Active_Loans)
            {
            }
            column(Restructured_Cleared_Loans; Restructured_Cleared_Loans)
            {
            }

            trigger OnAfterGetRecord()
            begin
                ActiveLoans := 0;
                ClearedLoans := 0;
                Restructured_Active_Loans := 0;
                Restructured_Cleared_Loans := 0;
                Loans.Reset();
                Loans.SetRange("Member No.", "No.");
                Loans.SetRange(Posted, true);
                Loans.SetFilter("Loan Balance", '=%1', 0);
                if Loans.FindSet then ClearedLoans := Loans.Count;
                Loans.Reset();
                Loans.SetRange("Member No.", "No.");
                Loans.SetRange(Posted, true);
                Loans.SetFilter("Loan Balance", '<>%1', 0);
                if Loans.FindSet then ActiveLoans := Loans.Count;
                Loans.Reset();
                Loans.SetRange("Member No.", "No.");
                Loans.SetRange(Posted, true);
                Loans.SetFilter("Loan Balance", '<>%1', 0);
                Loans.SetRange(Restructured);
                if Loans.FindSet then Restructured_Active_Loans := Loans.Count;
                Loans.Reset();
                Loans.SetRange("Member No.", "No.");
                Loans.SetRange(Posted, true);
                Loans.SetFilter("Loan Balance", '=%1', 0);
                Loans.SetRange(Restructured);
                if Loans.FindSet then Restructured_Cleared_Loans := Loans.Count;
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
        Loans: Record Loans;
        ActiveLoans, ClearedLoans, Restructured_Active_Loans, Restructured_Cleared_Loans : Integer;
}
