table 52203601 "Training Application"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
        }
        field(2; "Date of Application"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Training Calender"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Training Calender";
        }
        field(7; "Training Need"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Training Need";

            trigger OnLookup()
            begin
                TrainingCalendar.Reset;
                TrainingCalendar.SetRange("Current Period", true);
                TrainingCalendar.SetRange(Closed, false);
                if TrainingCalendar.FindFirst then CurrentCalender:=TrainingCalendar."Calender Code";
                TrainingPlanLines.Reset;
                TrainingPlanLines.SetRange("Calender Code", CurrentCalender);
                TrainingPlanLines.SetFilter("Global Dimension 1 Code", '=%1|=%2', Rec."Global Dimension 1 Code", '');
                if PAGE.RunModal(PAGE::"Training Plan Lines", TrainingPlanLines) = ACTION::LookupOK then begin
                    "Training Plan Line No":=TrainingPlanLines."Line No.";
                    if TrainingPlanLines."Expected Trainees" <= TrainingPlanLines."No. of Applications" then "Exceeds Expected Trainees":=true
                    else
                        "Exceeds Expected Trainees":=false;
                    "Training Need":=TrainingPlanLines."Training Need";
                    Category:=TrainingPlanLines.Category;
                    "Training Calender":=CurrentCalender;
                    "Start Date":=TrainingCalendar."Start Date";
                    "Training Start Date":=TrainingPlanLines."Expected Start Date";
                    "End Date":=TrainingCalendar."End Date";
                    "Training Need Description":=TrainingPlanLines."Training Need Description";
                    Trainer:=TrainingPlanLines."Trainer Code";
                    "Expected Cost":=TrainingPlanLines."Estimated Cost";
                    Period:=TrainingPlanLines.Duration;
                end;
                HumanResourcesSetup.Get;
                TrainingApplication.Reset;
                TrainingApplication.SetRange("Training Calender", Rec."Training Calender");
                TrainingApplication.SetRange("Employee No", Rec."Employee No");
                TrainingApplication.SetFilter(Status, '=%1|=%2|=%3', TrainingApplication.Status::"Awaiting Attendance Confirmation", TrainingApplication.Status::"Awaiting Availability Confirmation", TrainingApplication.Status::Attended);
                if TrainingApplication.FindSet then begin
                    if TrainingApplication.Count >= HumanResourcesSetup."Maximum No. of Trainings" then Error('You cannot apply for more than %1 trainings', HumanResourcesSetup."Maximum No. of Trainings");
                end;
            end;
        }
        field(8; "Training Need Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Global Dimension 1 Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(10; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then begin
                    HumanResourcesSetup.Get;
                    if CalcDate(HumanResourcesSetup."Retirement Age", Employee."Birth Date") < Today then Error('You are beyond %1', HumanResourcesSetup."Retirement Age");
                    Employee.TestField("Global Dimension 1 Code");
                    "Employee Name":=Employee.FullName;
                    "Global Dimension 1 Code":=Employee."Global Dimension 1 Code";
                    "Job Group":=Employee."Job Scale";
                    "Job Title":=Employee."Job Title";
                end;
            end;
        }
        field(11; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(12; Status; Option)
        {
            Editable = false;
            DataClassification = ToBeClassified;
            OptionMembers = , "Awaiting Availability Confirmation", "Awaiting Attendance Confirmation", "Awaiting HR Confirmation", Attended;
        }
        field(13; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(15; Period; Duration)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Expected Cost"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; Trainer; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Training Plan Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Job Group"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Job Title"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Exceeds Expected Trainees"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Training Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "SS Created"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Training Feedback"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Notification Sent"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(26; Category; Code[20])
        {
            TableRelation = "Training Categories";
        }
        field(27; "Category Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Training Categories".Description where(Code=field(Category)));
            Editable = false;
        }
        field(28; "Plan No."; Code[20])
        {
            Editable = false;
            TableRelation = "Training Plan";
        }
        field(29; "Plan Line No."; Integer)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            HumanResourcesSetup.Get;
            HumanResourcesSetup.TestField("Training Application Nos");
            NoSeriesManagement.InitSeries(HumanResourcesSetup."Training Application Nos", "No. Series", 0D, "No.", "No. Series");
        end;
        if "SS Created" then begin
            if UserSetup.Get(UserId)then begin
                UserSetup.TestField("Employee No.");
                "Employee No":=UserSetup."Employee No.";
                Validate("Employee No");
            end;
        end;
        "Created By":=UserId;
        "Created On":=WorkDate;
        "Date of Application":=WorkDate;
    end;
    procedure AttachmentValidator(): Boolean begin
        DocumentAttachment.Reset();
        DocumentAttachment.SetRange("Table ID", 56002);
        DocumentAttachment.SetRange("No.", Rec."No.");
        DocumentAttachment.SetFilter("File Name", '<>%1', '');
        if DocumentAttachment.FindSet()then exit(true)
        else
            exit(false);
    end;
    procedure AttachmentValidatorResponse(): Text begin
        exit(Validator_Err);
    end;
    var HumanResourcesSetup: Record "Human Resources Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    Employee: Record Employee;
    TrainingCalendar: Record "Training Calender";
    UserSetup: Record "User Setup";
    TrainingPlanLines: Record "Training Plan Lines";
    PlanNo: Code[100];
    CurrentCalender: Code[50];
    TrainingApplication: Record "Training Application";
    DocumentAttachment: Record "Document Attachment";
    Validator_Err: Label 'You have not attached any document. Please attach document/s and continue.';
}
