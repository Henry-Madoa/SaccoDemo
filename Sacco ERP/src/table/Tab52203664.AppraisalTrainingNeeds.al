table 52203664 "Appraisal Training Needs"
{
    fields
    {
        field(1; "Line No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Appraisal No."; Code[20])
        {
        }
        field(3; "Employee No."; Code[20])
        {
        }
        field(4; Category; Code[20])
        {
            TableRelation = "Training Categories";
        }
        field(5; "Category Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Training Categories".Description where(Code=field(Category)));
            Editable = false;
        }
        field(6; "Training Needs Line No."; Integer)
        {
        }
        field(7; Recommended; Boolean)
        {
            trigger OnValidate()
            begin
                AppraisalHeader.Get("Appraisal No.");
                if AppraisalHeader.Status <> AppraisalHeader.Status::"Appraiser Level" then Error('Its only Superviser who can Recommend');
            end;
        }
        field(8; "Proposed Trainer"; Text[250])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor where("Account Type"=const(Supplier));
        }
        field(9; "Training Need Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Recommendation Justification"; Text[250])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                AppraisalHeader.Get("Appraisal No.");
                if AppraisalHeader.Status <> AppraisalHeader.Status::"Appraiser Level" then Error('Its only Superviser who can Recommend');
            end;
        }
    }
    keys
    {
        key(Key1; "Line No.", "Appraisal No.", "Employee No.")
        {
        }
        key(Key2; "Training Needs Line No.")
        {
        }
    }
    var AppraisalHeader: Record "Appraisal Header";
}
