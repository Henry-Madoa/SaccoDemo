table 52203790 "Applicant Languages"
{
    DrillDownPageID = "Applicant Languages";
    LookupPageID = "Applicant Languages";

    fields
    {
        field(1; "Applicant No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; Code; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "&Languages";

            trigger OnValidate()
            begin
                if LanguageRec.Get(Code)then Language:=LanguageRec.Name;
            end;
        }
        field(3; Language; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Applicant No.", Code)
        {
            Clustered = true;
        }
        key(Key2; Code, "Applicant No.")
        {
        }
    }
    var LanguageRec: Record "&Languages";
}
