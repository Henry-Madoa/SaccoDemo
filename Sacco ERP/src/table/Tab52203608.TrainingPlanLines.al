table 52203608 "Training Plan Lines"
{
    fields
    {
        field(1; "Plan No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Training Need"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Training Need".Code;

            trigger OnValidate()
            begin
                if TrainingNeed.Get("Training Need")then begin
                    "Training Need Description":=TrainingNeed.Description;
                    "Global Dimension 1 Code":=TrainingNeed."Global Dimension 1 Code";
                    Category:=TrainingNeed.Category;
                end;
            end;
        }
        field(3; "Training Need Description"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Trainer Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor where("Account Type"=const(Supplier));

            trigger OnValidate()
            begin
                if HrTrainers.Get("Trainer Code")then "Trainer Name":=HrTrainers.Name;
            end;
        }
        field(5; "Trainer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "Expected Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Expected Start Date" = 0D then exit;
                if TrainingPlan.Get("Plan No.")then if "Expected Start Date" < TrainingPlan."Calender Start Date" then Error('Date has be greater than %1', TrainingPlan."Calender Start Date");
            end;
        }
        field(7; "Expected End Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Expected End Date" = 0D then exit;
                Rec.TestField("Expected Start Date"); // IF TrainingPlan.GET("Plan No.") THEN
            //  IF "Expected End Date">TrainingPlan."Calender End Date" THEN
            //    ERROR('Date has be less than %1',TrainingPlan."Calender End Date");            Duration := CreateDateTime("Expected End Date", 0T) - CreateDateTime("Expected Start Date", 0T);
            end;
        }
        field(8; "Estimated Cost"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Training Employee Costs".Cost where("Plan Line No."=field("Line No."), "Plan No."=field("Plan No.")));
            Editable = false;
        }
        field(9; Duration; Duration)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Employee Specific"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Global Dimension 1 Code"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Dimension Value"."Dimension Code" WHERE("Global Dimension No."=FILTER(1));
        }
        field(14; "Line No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(15; "Calender Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Training Calender"."Calender Code";
        }
        field(16; "Expected Trainees"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "No. of Applications"; Integer)
        {
            FieldClass = Normal;
        }
        field(18; "Training Venue"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Training Sponsor"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Target Group"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Sponsorship Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Sponsorship End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Actual Cost"; Decimal)
        {
        }
        field(24; "Training Type"; Option)
        {
            OptionMembers = Individual, Group;
        }
        field(25; Category; Code[20])
        {
            TableRelation = "Training Categories";
            Editable = false;
        }
        field(26; "Category Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Training Categories".Description where(Code=field(Category)));
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Line No.", "Plan No.", "Training Need")
        {
        }
    }
    trigger OnInsert()
    begin
        if TrainingPlan.Get("Plan No.")then "Calender Code":=TrainingPlan."Calender Code";
    end;
    var TrainingPlan: Record "Training Plan";
    TrainingNeed: Record "Training Need";
    HrTrainers: Record Vendor;
}
