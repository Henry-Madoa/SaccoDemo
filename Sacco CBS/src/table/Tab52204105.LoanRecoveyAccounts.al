table 52204105 "Loan Recovey Accounts"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Loan Recovery Accounts";
    DrillDownPageId = "Loan Recovery Accounts";

    fields
    {
        field(1; "Document No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Account No"; Code[20])
        {
            Editable = false;
        }
        field(3; "Account Name"; Text[100])
        {
            Editable = false;
        }
        field(4; "Current Balance"; Decimal)
        {
            Editable = false;
        }
        field(5; "Recovery Amount"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Document No", "Account No")
        {
            Clustered = true;
        }
    }
    var
        LoanRecovery: Record "Loan Recovery Header";

    trigger OnInsert()
    begin
        if LoanRecovery.Get("Document No") then begin
            LoanRecovery.CalcFields("Guarantor Deposit Recovery", "Guarantor Liability Recovery");
            if LoanRecovery."Guarantor Deposit Recovery" + LoanRecovery."Guarantor Liability Recovery" > 0 then Error('You Cannot combine Member Recovery and Guarantor Recovery');
        end;
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    begin
    end;

    trigger OnRename()
    begin
    end;
}
