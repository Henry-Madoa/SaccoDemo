report 52204026 "Defaulters"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    PreviewMode = Normal;
    RDLCLayout = './ssrs/Defaulters.rdl';

    dataset
    {
        dataitem("Loan Application"; Loans)
        {
            RequestFilterFields = "Loan Classification", "No.", "Posting Date";

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
            column(Application_No; "No.")
            {
            }
            column(Member_No_; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Loan_Classification; "Loan Classification")
            {
            }
            column(Loan_Balance; "Loan Balance")
            {
            }
            column(Net_Change_Principal; "Net Change-Principal")
            {
            }
            column(Total_Arrears; "Total Arrears")
            {
            }
            column(Defaulted_Days; "Defaulted Days")
            {
            }
            column(Defaulted_Installments; "Defaulted Installments")
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Monthly_Inistallment; "Monthly Installment")
            {
            }
            column(Installments; Installments)
            {
            }
            column(Interest_Rate; "Interest Rate")
            {
            }
            column(PhoneNo; PhoneNo)
            {
            }
            column(StaffNo; StaffNo)
            {
            }
            trigger OnAfterGetRecord()
            begin
                StaffNo := '';
                PhoneNo := '';
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                if Member.Get("Loan Application"."Member No.") then begin
                    StaffNo := Member."Payroll No.";
                    PhoneNo := Member."Mobile Phone No.";
                end;
            end;
        }
    }
    var
        AsAt: Date;
        DateFilter, GroupText : Text;
        Provision, ProvisionAmount : decimal;
        PhoneNo, StaffNo : Code[20];
        Member: Record Members;
        GroupOrder1, GroupOrder2 : Integer;
        CompanyInformation: Record "Company Information";
}
