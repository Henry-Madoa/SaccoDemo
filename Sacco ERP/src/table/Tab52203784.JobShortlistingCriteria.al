table 52203784 "Job Shortlisting Criteria"
{
    Caption = 'Shortlisting Criteria';
    LookupPageId = "Job Shortlisting Criteria";
    DrillDownPageId = "Job Shortlisting Criteria";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Requisition No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Job ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Company Jobs" where(Status=const(Approved));
        }
        field(4; "Qualification Type";Enum "Qualification Types")
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Qualification Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Qualification.Code WHERE("Qualification Type"=FIELD("Qualification Type"));
        }
        field(6; Score; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.", "Qualification Type", "Qualification Code")
        {
        }
    }
}
