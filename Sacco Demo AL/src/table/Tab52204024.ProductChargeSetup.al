table 52204024 "Product Charge Setup"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Product Charge Setup";
    LookupPageId = "Product Charge Setup";

    fields
    {
        field(1; "Source Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Charge Code"; Code[20])
        {
            TableRelation = Charges;

            trigger OnValidate()
            begin
                if Charges.Get("Charge Code") then "Charge Description" := Charges.Description;
            end;
        }
        field(3; "Charge Description"; Text[59])
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
        field(6; "Calculation Type"; Option)
        {
            OptionMembers = "Calculation Scheme","Percentage of Charge";
        }
        field(7; "Source Charge"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF ("Calculation Type" = CONST("Percentage of Charge")) "Product Charge Setup"."Charge Code" WHERE("Source Code" = FIELD("Source Code"));
        }
        field(8; Editable; Boolean)
        {
        }
    }
    keys
    {
        key(PK; "Source Code", "Charge Code")
        {
            Clustered = true;
        }
    }
    var
        Charges: Record Charges;
}
