table 52204074 "Dividend Earned Entries"
{
    fields
    {
        field(1; "Dividend Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members;
        }
        field(3; "Account Type"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sacco Products" where(Indentation = const(1));
            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                Vendor.Reset();
                Vendor.SetRange("Member No.", "Member No.");
                Vendor.SetRange("Product Code", "Account Type");
                if Vendor.FindFirst then begin
                    "Destination Account" := Vendor."No.";
                end;
            end;
        }
        field(4; "Destination Account"; Code[20])
        {
            TableRelation = Vendor;
            DataClassification = ToBeClassified;
        }
        field(5; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Dividend Code", "Member No.", "Account Type")
        {
            Clustered = true;
        }
    }
}
