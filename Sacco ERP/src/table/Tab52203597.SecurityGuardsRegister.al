table 52203597 "Security Guards Register"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Guard No"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Security Guards".No;

            trigger OnValidate()
            var
                Guards: Record "Security Guards";
            begin
                if Guards.get("Guard No")then "Guard Name":=Guards.Names;
            end;
        }
        field(3; "Guard Name"; text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Date"; date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Allocated Section"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Security Sections".Code;
        }
        field(6; "Shift Code"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Security Shift".code;
        }
    }
    keys
    {
        key(PK; "Line No", Date, "Shift Code")
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
