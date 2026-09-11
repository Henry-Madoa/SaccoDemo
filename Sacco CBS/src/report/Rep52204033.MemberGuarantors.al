report 52204033 "Member Guarantors"
{
    UsageCategory = Administration;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Member Guarantors.rdl';

    dataset
    {
        dataitem(Members; Members)
        {
            RequestFilterFields = "No.";

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
            column(Member_No_; "No.")
            {
            }
            column(Full_Name; "Full Name")
            {
            }
            column(National_ID_No; "Identification No.")
            {
            }
            column(Payroll_No; "Payroll No.")
            {
            }
            dataitem("Loan Guarantees"; "Loan Guarantees")
            {
                DataItemLink = "Loan Owner" = field("No.");
                DataItemTableView = sorting("Member No.") where(Substituted = const(false));

                column(Loan_No; "Loan No")
                {
                }
                column(Member_No; "Member No.")
                {
                }
                column(Member_Name; "Member Name")
                {
                }
                column(Member_Deposits; "Member Deposits")
                {
                }
                column(Guaranteed_Amount; "Guaranteed Amount")
                {
                }
                column(Intial_Substitution; "Intial Substitution")
                {
                }
                column(Substituted; Substituted)
                {
                }
                column(Arrears; Arrears)
                {
                }
                column(LoanClassification; LoanClassification)
                {
                }
                column(Outstanding_Guarantees; OutstandingGrnt)
                {
                }
                column(OwnerNo; OwnerNo)
                {
                }
                column(OwnerName; OwnerName)
                {
                }
                column(LoanBalance; LoanBalance)
                {
                }
                column(ProductName; ProductName)
                {
                }
                column(ProductCode; ProductCode)
                {
                }
                column(LoanPrincipal; LoanPrincipal)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    OutstandingGrnt := 0;
                    LoanClassification := '';
                    Arrears := 0;
                    OwnerName := '';
                    OwnerNo := '';
                    ProductCode := '';
                    ProductName := '';
                    LoanPrincipal := 0;
                    LoanBalance := 0;
                    if Loans.Get("Loan Guarantees"."Loan No") then begin
                        Loans.CalcFields("Loan Balance");
                        ProductCode := Loans."Product Code";
                        ProductName := Loans."Product Description";
                        OwnerName := Loans."Member Name";
                        OwnerNo := Loans."Member No.";
                        LoanBalance := Loans."Loan Balance";
                        LoanPrincipal := Loans."Loan Amount";
                        LoanClassification := Format(Loans."Loan Classification");
                        Arrears := Loans."Total Arrears";
                        OutstandingGrnt := MemberMgt.GetOutstandingGuarantee(Loans."No.", "Loan Guarantees"."Member No.");
                    end
                    else
                        CurrReport.Skip();
                end;
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                PayrollNo := '';
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        PayrollNo: Code[20];
        MemberMgt: Codeunit "Member Management";
        Loans: Record Loans;
        OutstandingGrnt, Arrears, LoanPrincipal, LoanBalance : Decimal;
        LoanClassification, OwnerNo, OwnerName, ProductCode, ProductName : Text;
}
