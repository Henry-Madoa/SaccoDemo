table 52204199 "Storage Types"
{
    DrillDownPageID = "Storage Types";
    LookupPageID = "Storage Types";

    fields
    {
        field(1; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Safe,Safety Deposit Box';
            OptionMembers = Safe,"Safety Deposit Box";
        }
        field(2; Description; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Created On"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Created By"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup";
        }
    }
    keys
    {
        key(Key1; Type)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Type, Description)
        {
        }
    }
    trigger OnInsert()
    begin
        "Created By" := UserId;
        "Created On" := CreateDateTime(Today, Time);
    end;
}
