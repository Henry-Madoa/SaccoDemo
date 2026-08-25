table 52204086 "Loan Recovery Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Member No"; code[20])
        {
        }
        field(3; "Member Name"; Text[100])
        {
            Editable = false;
        }
        field(4; "Member Deposits"; Decimal)
        {
            Editable = false;
        }
        field(5; "Outstanding Guarantee"; Decimal)
        {
            Editable = false;
        }
        field(6; "Recovery Amount"; Decimal)
        {
            Editable = false;
        }
        field(7; "Recovery Type"; Option)
        {
            OptionMembers = " ",Deposits,"Guarantor Liability Loan";

            trigger OnValidate()
            var
                SaccoSetup: Record "General Ledger Setup";
            begin
                SaccoSetup.Get;
                // If "Recovery Type" <> "Recovery Type"::"Guarantor Liability Loan" then "Product Code":=''
                // else If "Recovery Type" <> "Recovery Type"::"Guarantor Liability Loan" then "Product Code":=SaccoSetup."Defaulter Loan Product";
                If "Recovery Type" <> "Recovery Type"::"Guarantor Liability Loan" then
                    "Product Code" := ''
                else
                    "Product Code" := SaccoSetup."Defaulter Loan Product";
            end;
        }
        field(8; "Product Code"; code[20])
        {
            Editable = false;
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false), "Product Posting Type" = const("Loan Account"));
        }
    }
    keys
    {
        key(Key1; "No.", "Member No")
        {
            Clustered = true;
        }
    }
}
