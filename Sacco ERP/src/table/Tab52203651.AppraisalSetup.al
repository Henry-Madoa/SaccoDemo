table 52203651 "Appraisal Setup"
{
    fields
    {
        field(1; "Appraisal Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Appraisal Description"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; Status; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = 'New,Running,Terminated';
            OptionMembers = New, Running, Terminated;
        }
        field(6; "Running Period"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "End Date":=CalcDate("Running Period", "Start Date");
            end;
        }
        field(8; "Max KRA Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Total Appraisals"; Integer)
        {
            CalcFormula = Count("Appraisal Header" WHERE("No."=FIELD("Appraisal Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Approved Appraisals"; Integer)
        {
            CalcFormula = Count("Appraisal Header" WHERE("No."=FIELD("Appraisal Code"), "Employee User Id"=CONST('2')));
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Department Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Responsibility Center";
        }
        field(12; "Created By"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup";
        }
        field(13; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14; "Last Updated By"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup";
        }
        field(15; "Last Updated On"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Appraisal Code")
        {
        }
    }
    trigger OnInsert()
    begin
        GeneralSetup.Get();
        GeneralSetup.TestField("Appraisal Nos");
        if "Appraisal Code" = '' then "Appraisal Code":=NoSeriesManagement.GetNextNo(GeneralSetup."Appraisal Nos", Today, true);
        "Created By":=UserId;
        "Created On":=WorkDate;
        "Last Updated By":=UserId;
        "Last Updated On":=WorkDate;
    end;
    trigger OnModify()
    begin
        "Last Updated By":=UserId;
        "Last Updated On":=WorkDate;
    end;
    var GeneralSetup: Record "Human Resources Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
}
