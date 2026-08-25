table 52204071 "Dividend Member List"
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

            trigger OnValidate()
            begin
                if Customer.Get("Member No.") then "Member Name" := Customer."Full Name";
            end;
        }
        field(3; "Member Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Dividend Code", "Member No.")
        {
            Clustered = true;
        }
    }
    var
        Customer: Record Members;
}
