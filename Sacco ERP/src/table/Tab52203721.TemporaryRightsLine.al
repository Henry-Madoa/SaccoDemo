table 52203721 "Temporary Rights Line"
{
    fields
    {
        field(1; No; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Permission; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Aggregate Permission Set"."Role ID";
        }
        field(3; "User ID"; Code[70])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup"."User ID";
        }
        field(4; "Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Company Name"; Text[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Company.Name;
        }
    }
    keys
    {
        key(Key1; No, Permission)
        {
        }
    }
}
