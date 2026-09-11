table 52204009 "Member Account Instructions"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Source Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(3; Instruction; Text[250])
        {
            TableRelation = if (Type = const(Predifined)) "Account Instructions".Description;
        }
        field(4; Type; Enum "Account Instruction Type")
        {
        }
    }
    keys
    {
        key(Key1; "Source Code", "Line No")
        {
            Clustered = true;
        }
        key(Key2; "Line No", "Source Code")
        {
        }
    }
    trigger OnInsert()
    begin
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    begin
    end;
}
