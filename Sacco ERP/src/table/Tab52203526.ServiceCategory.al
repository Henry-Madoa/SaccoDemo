table 52203526 "Service Category"
{
    LookupPageId = "Service Category";
    DrillDownPageId = "Service Category";

    fields
    {
        field(1; Code; Code[10])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Code)
        {
        }
    }
}
