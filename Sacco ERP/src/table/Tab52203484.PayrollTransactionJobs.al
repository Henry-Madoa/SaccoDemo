table 52203484 "Payroll Transaction Jobs"
{
    DrillDownPageID = "Transaction For Jobs";
    LookupPageID = "Transaction For Jobs";

    fields
    {
        field(1; "Transaction Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Job Id"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Company Jobs";

            trigger OnValidate()
            begin
                if HRJobs.Get("Job Id")then "Job Description":=HRJobs.Name;
            end;
        }
        field(3; "Job Description"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Transaction Code", "Job Id")
        {
        }
    }
    var HRJobs: Record "Company Jobs";
}
