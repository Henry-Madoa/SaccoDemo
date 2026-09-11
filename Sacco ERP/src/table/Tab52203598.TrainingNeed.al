table 52203598 "Training Need"
{
    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
            Editable = false;
        }
        field(2; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Global Dimension 1 Code"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(4; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Employee Specific"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Employee No"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then begin
                    "Global Dimension 1 Code":=Employee."Global Dimension 1 Code";
                    "Employee Name":=Employee.FullName;
                    "Employee Specific":=true;
                end;
            end;
        }
        field(8; "Employee Name"; Text[70])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "From Appraisal"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Calendar Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(11; "Appraisal Period"; Text[100])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Appraisal Calender".Description where("Calendar Code"=field("Calendar Code")));
        }
        field(12; Supervisor; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Training Source"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Training Objective"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "No. Series"; Code[20])
        {
        }
        field(16; Category; Code[20])
        {
            TableRelation = "Training Categories";
        }
        field(17; "Category Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Training Categories".Description where(Code=field(Category)));
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Code")
        {
        }
    }
    trigger OnInsert()
    begin
        "Created By":=UserId;
        "Created On":=WorkDate;
        HRSetup.Get;
        HRSetup.TestField("Training Need");
        if Code = '' then NoSeriesMgt.InitSeries(HRSetup."Training Need", xRec."No. Series", 0D, Code, "No. Series");
    end;
    var Employee: Record Employee;
    NoSeriesMgt: Codeunit NoSeriesManagement;
    HRSetup: Record "Human Resources Setup";
}
