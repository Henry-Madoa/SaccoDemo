table 52203652 "Appraisal Training Rec."
{
    fields
    {
        field(1; "Appraisal Code"; Code[20])
        {
            Editable = false;
            TableRelation = "Appraisal Header"."No.";
        }
        field(2; "Employee No."; Code[20])
        {
            Editable = false;
            TableRelation = "Appraisal Header"."Employee No";
        }
        field(3; "Training Area"; Code[20])
        {
            trigger OnValidate()
            begin
                if TrainingNeeds.Get("Training Area")then "Training Description":=TrainingNeeds.Description;
            end;
        }
        field(4; "Training Description"; Text[250])
        {
        }
        field(5; Reason; Text[250])
        {
        }
    }
    keys
    {
        key(Key1; "Appraisal Code", "Employee No.", "Training Area")
        {
        }
    }
    var TrainingNeeds: Record "Training Needs";
}
