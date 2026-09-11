table 52203580 "Security Daily Shift"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; No; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Date; date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Shift Code"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Security Shift";
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
