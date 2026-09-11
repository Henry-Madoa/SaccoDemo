table 52203772 "Job Requirements"
{
    DrillDownPageID = "Job Requirements";
    LookupPageID = "Job Requirements";

    fields
    {
        field(1; "Job Id"; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; Description; Text[1000])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
    }
    keys
    {
        key(Key1; "Job Id", Description)
        {
            Clustered = true;
        }
    }
}
