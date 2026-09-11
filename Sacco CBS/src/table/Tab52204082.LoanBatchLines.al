table 52204082 "Loan Batch Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Loan No"; Code[20])
        {
        }
        field(3; "Product Description"; text[50])
        {
        }
        field(4; "Principal Amount"; Decimal)
        {
        }
        field(5; "Applied Amount"; Decimal)
        {
        }
        field(6; "Total Recoveries"; Decimal)
        {
        }
        field(7; "Net Amount"; Decimal)
        {
        }
        field(8; "Insurance Amount"; Decimal)
        {
        }
        field(9; Posted; Boolean)
        {
        }
        field(30; "Bank Code"; Code[50])
        {
        }
        field(40; "Bank Branch Code"; Code[50])
        {
        }
        field(50; "Bank Account No."; Code[50])
        {
        }
        field(60; "Bank Account Name"; Text[250])
        {
        }
    }
    keys
    {
        key(Key1; "No.", "Loan No")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    var
        Loans: Record Loans;
    begin
        if Loans.Get("Loan No") then begin
            Loans."Loan Batch No." := '';
            Loans.Modify();
        end;
    end;
}
