table 52203578 "Security Company"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; No; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor."No.";
        }
        field(2; Description; text[120])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Starting Date"; date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "End Date"; date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Active"; boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; No)
        {
            Clustered = true;
        }
    }
    var myInt: Integer;
    trigger OnInsert()
    begin
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
