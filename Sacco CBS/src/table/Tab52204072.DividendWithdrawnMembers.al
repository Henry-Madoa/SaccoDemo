table 52204072 "Dividend Withdrawn Members"
{
    fields
    {
        field(1; "Dividend Header"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer;

            trigger OnValidate()
            begin
                if Customer.Get("Member No") then "Member Name" := Customer.Name;
            end;
        }
        field(3; "Member Name"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Dividend Header", "Member No")
        {
            Clustered = true;
        }
    }
    var
        Customer: Record Customer;
}
