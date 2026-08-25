report 52204066 "Collateral Register"
{
    PreviewMode = Normal;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Collateral Register.rdl';

    dataset
    {
        dataitem("Collateral Register"; "Collateral Register")
        {
            RequestFilterFields = "No.", "Member No.", Status;

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
            column(Filters; Filters)
            {
            }
            column(No_; "No.")
            {
            }
            column(Member_No; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Category; Category)
            {
            }
            column(Owner_Phone_No_; "Owner Phone No.")
            {
            }
            column(Owner_ID_No; "Owner ID No")
            {
            }
            column(Owner_Name; "Owner Name")
            {
            }
            column(Collateral_Type; "Collateral Type")
            {
            }
            column(Collateral_Description; "Collateral Description")
            {
            }
            column(County_Name; "County Name")
            {
            }
            column(Serial_No; "Serial/Reg No.")
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Car_Track_Due_Date; "Car Track Due Date")
            {
            }
            column(Insurance_Expiry_Date; "Insurance Expiry Date")
            {
            }
            column(Caollateral_Value; "Collateral Value")
            {
            }
            column(Guarantee; Guarantee)
            {
            }
            column(Linked_Loan_Balance; "Linked Loan Balance")
            {
            }
            column(CollateralBalance; Guarantee - "Linked Loan Balance")
            {
            }
            column(Status; Status)
            {
            }
            trigger OnPreDataItem()
            begin
                Filters := "Collateral Register".GetFilters;
                CompanyInformation.Get();
                CompanyInformation.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                CalcFields("County Name");
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Filters: Text;
}
