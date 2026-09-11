table 52203781 "Job Responsibilities Specs"
{
    Caption = 'Responsibilities Specifications';
    DrillDownPageID = "Job Responsibilities Specs";
    LookupPageID = "Job Responsibilities Specs";

    fields
    {
        field(1; "Job Id"; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(3; "Specification"; Text[1000])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
    }
    keys
    {
        key(Key1; "Job Id", "Line No")
        {
            Clustered = true;
        }
        key(Key2; "Line No", "Job Id")
        {
        }
    }
}
