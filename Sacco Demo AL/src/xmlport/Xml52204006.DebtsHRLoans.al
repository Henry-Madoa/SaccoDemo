xmlport 52204006 "Debts & HR Loans"
{
    Direction = Import;
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
        textelement(LoansUpload)
        {
            tableelement(Loans; Loans)
            {
                fieldattribute(LoanNo; Loans."No.")
                {
                }
                fieldattribute(ApplicationDate; Loans."Application Date")
                {
                }
                fieldattribute(MemberNo; Loans."Member No.")
                {
                }
                fieldattribute(Category; Loans.Category)
                {
                }
                fieldattribute(ProductCode; Loans."Product Code")
                {
                }
                fieldattribute(RequestedAmount; Loans."Requested Amount")
                {
                }
                fieldattribute(ModeOfDisbursement; Loans."Mode of Disbursement")
                {
                }
                fieldattribute(DisbursementAccount; Loans."Disbursement Account")
                {
                }
                fieldattribute(Status; Loans."Disbursement Account")
                {
                }
                trigger OnBeforeInsertRecord()
                begin
                    Loans.Status := Loans.Status::Approved;
                end;
            }
        }
    }
}
