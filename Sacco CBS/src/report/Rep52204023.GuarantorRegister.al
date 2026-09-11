report 52204023 "Guarantor Register"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    PreviewMode = Normal;
    RDLCLayout = './ssrs/Loan Guarantors.rdl';

    dataset
    {
        dataitem("Loan Guarantees"; "Loan Guarantees")
        {
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
            column(Substituted; Substituted)
            {
            }
            column(Arrears; Arrears)
            {
            }
            column(LoanClassification; LoanClassification)
            {
            }
            column(Outstanding_Guarantees; "Outstanding Guarantees")
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
            column(ProductCode; ProductCode)
            {
            }
            column(ProductName; ProductName)
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
    }
    var
        MemberMgt: Codeunit "Member Management";
        Loans: Record Loans;
        OutstandingGrnt, Arrears, LoanPrincipal, LoanBalance : Decimal;
        LoanClassification, OwnerNo, OwnerName, ProductCode, ProductName : Text;
}
