table 52204088 "Document Uploads"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Parent Type"; Option)
        {
            OptionMembers = "Member Application","Loan Application";
        }
        field(3; "Parent No"; Code[20])
        {
        }
        field(4; "Document Type"; Code[100])
        {
        }
        field(5; "Document No"; Code[100])
        {
        }
        field(6; "URL"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(7; "Added On"; DateTime)
        {
        }
        field(8; "Added By"; code[100])
        {
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        "Added By" := UserId;
        "Added On" := CurrentDateTime;
    end;
}
