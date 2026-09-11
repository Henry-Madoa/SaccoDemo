table 52204140 "Loan Charges"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Loan Charges";
    DrillDownPageId = "Loan Charges";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Charge Code"; Code[20])
        {
            Editable = false;

            trigger OnValidate()
            var
                Charges: Record Charges;
            begin
                if Charges.Get("Charge Code") then
                    "Charge Description" := Charges.Description;
            end;
        }
        field(3; "Charge Description"; Text[50])
        {
            Editable = false;
        }
        field(4; "Post to Account Type"; Option)
        {
            OptionMembers = " ","G/L Account","Liability Account";
        }
        field(5; "Post-to Account No."; Code[20])
        {
            TableRelation = if ("Post to Account Type" = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true), "Account Type" = const(Posting))
            else if ("Post to Account Type" = const("Liability Account")) Vendor where("Account Type" = filter(<> Sacco));
        }
        field(6; Editable; Boolean)
        {
            Editable = false;
        }
        field(7; Amount; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "No.", "Charge Code")
        {
            Clustered = true;
        }
    }
}
