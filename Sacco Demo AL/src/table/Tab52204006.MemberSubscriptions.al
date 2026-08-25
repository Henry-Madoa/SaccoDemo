table 52204006 "Member Subscriptions"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Member Subscriptions";
    LookupPageId = "Member Subscriptions";

    fields
    {
        field(1; "Source Code"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Account Type"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false), "Product Posting Type" = filter(<> "Withdrawable Deposit" & <> "Fixed Deposit Account"));

            trigger OnValidate()
            begin
                if SaccoProduct.Get("Account Type") then begin
                    "Account Name" := SaccoProduct.Description;
                    "Minimum Contribution" := SaccoProduct."Minimum Contribution";
                end;
            end;
        }
        field(3; "Account Name"; Text[100])
        {
            Editable = false;
        }
        field(4; Amount; Decimal)
        {
            trigger OnValidate()
            begin
                if Rec.Amount < Rec."Minimum Contribution" then Error('You Cannot subscribe less than the minimum contribution of %1', "Minimum Contribution");
            end;
        }
        field(5; "Start Date"; date)
        {
        }
        field(6; "Minimum Contribution"; Decimal)
        {
            Editable = false;
        }
        field(7; Priority; Integer)
        {
        }
    }
    keys
    {
        key(PK; "Source Code", "Account Type")
        {
            Clustered = true;
        }
    }
    var
        SaccoProduct: Record "Sacco Products";
}
