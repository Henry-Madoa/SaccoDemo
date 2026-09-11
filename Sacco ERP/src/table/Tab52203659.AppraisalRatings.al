table 52203659 "Appraisal Ratings"
{
    DrillDownPageID = "Appraisal Ratings";
    LookupPageID = "Appraisal Ratings";

    fields
    {
        field(2; Code; Code[20])
        {
        }
        field(3; Description; Text[50])
        {
        }
        field(4; Percentage; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Lower Limit"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Upper Limit"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
        key(Key2; Percentage)
        {
        }
    }
}
