table 52203579 "Security Guards"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; No; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Names; text[120])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "ID Number"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; Gender; option)
        {
            OptionMembers = , Male, Female;
            DataClassification = ToBeClassified;
        }
        field(5; "Security Company"; code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; No, "Security Company")
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
