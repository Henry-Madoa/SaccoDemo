table 52204045 "Transaction Denomination"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "FOSA Transaction Types")
        {
            Editable = false;
        }
        field(2; "No."; code[20])
        {
            Editable = false;
        }
        field(3; Code; code[20])
        {
            Editable = false;
        }
        field(4; Description; Text[150])
        {
            Editable = false;
        }
        Field(5; Quantity; Integer)
        {
            trigger OnValidate()
            begin
                Validate("Total Value");
            end;
        }
        field(6; Value; Decimal)
        {
            Editable = false;
        }
        field(7; "Total Value"; Decimal)
        {
            Editable = false;

            trigger OnValidate()
            begin
                "Total Value" := Quantity * Value;
            end;
        }
    }
    keys
    {
        key(Key1; "Document Type", "No.", Code)
        {
            Clustered = true;
        }
        key(Key2; Value)
        {
        }
    }
}
