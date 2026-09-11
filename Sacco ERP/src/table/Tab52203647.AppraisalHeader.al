table 52203647 "Appraisal Header"
{
    DataCaptionFields = "No.", "Employee No", "Employee Name";

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Employee No"; Code[20])
        {
            TableRelation = Employee where("Nature Of Employment"=filter(<>Board), "Employee Status"=filter(Active|OnLeave));

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then begin
                    "Job Title":=Employee."Job Title";
                    "Employee Name":=Employee.FullName;
                    "Level/Grade":=Employee."Job Scale";
                    Employee.TestField("Manager No.");
                    Employee.TestField("Overview Manager");
                    "Overview Manager":=Employee."Overview Manager";
                    "Supervisor No":=Employee."Manager No.";
                    "Appraisal Start Date":=Employee."Employment Date";
                    "Global Dimension 1 Code":=Employee."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=Employee."Global Dimension 2 Code";
                    "Global Dimension 3 Code":=Employee."Global Dimension 3 Code";
                    "Global Dimension 4 Code":=Employee."Global Dimension 4 Code";
                    "Global Dimension 5 Code":=Employee."Global Dimension 5 Code";
                    "Global Dimension 6 Code":=Employee."Global Dimension 6 Code";
                    if Employee.Get("Supervisor No")then UserSetup.Reset;
                    UserSetup.SetRange("Employee No.", "Supervisor No");
                    if UserSetup.FindFirst then "Supervisor User Id":=UserSetup."User ID";
                    if Employee.Get("Overview Manager")then UserSetup.Reset;
                    UserSetup.SetRange("Employee No.", "Overview Manager");
                    if UserSetup.FindFirst then "Overview Manager UserID":=UserSetup."User ID";
                    AppraisalCalender.Reset;
                    AppraisalCalender.SetRange("Current Calender", true);
                    if AppraisalCalender.FindFirst then begin
                        "Calendar Code":=AppraisalCalender.Description;
                        if Employee."Probation Status" in[Employee."Probation Status"::Confirmed]then begin
                            "Appraisal Start Date":=AppraisalCalender."Period Start Date";
                            "Appraisal End Date":=AppraisalCalender."Period End Date";
                        end;
                    end;
                end;
            end;
        }
        field(3; "Employee Name"; Text[70])
        {
        }
        field(4; "Level/Grade"; Text[50])
        {
        }
        field(5; "Job Title"; Text[100])
        {
        }
        field(6; "Function/Team"; Text[50])
        {
        }
        field(7; "Calendar Code"; Code[50])
        {
            TableRelation = "Appraisal Calender"."Calendar Code";
        }
        field(8; "Appraisee Agreed"; Boolean)
        {
        }
        field(13; Status;Enum "Appraisal Status")
        {
            Editable = false;
        }
        field(14; "No. Series"; Code[20])
        {
        }
        field(15; "Created On"; Date)
        {
        }
        field(16; "Created By"; Code[70])
        {
        }
        field(17; "Supervisor User Id"; Code[70])
        {
        }
        field(18; "Employee User Id"; Code[70])
        {
        }
        field(19; "Supervisor No"; Code[20])
        {
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Supervisor No")then "Supervisor Name":=Employee.FullName;
                UserSetup.Reset;
                UserSetup.SetRange("Employee No.", "Supervisor No");
                if UserSetup.FindFirst then begin
                    "Supervisor User Id":=UserSetup."User ID";
                end;
            end;
        }
        field(20; "Supervisor Name"; Text[70])
        {
        }
        field(21; "Supervisor Title"; Text[70])
        {
        }
        field(22; "Supervisor Function/Team"; Text[70])
        {
        }
        field(23; "Review Period"; Code[20])
        {
            TableRelation = "Appraisal Review Periods".Code;
            Editable = false;

            trigger OnValidate()
            var
                AppraisalKRAs: Record "Appraisal Objectives/KRAs";
                AppraisalKPIs: Record "Appraisal Activities";
                AppraisalCompetence: Record "Appraisal Competence";
                AppraisalBehaviour: Record "Appraisal Behaviour";
            begin
                AppraisalKRAs.Reset();
                AppraisalKRAs.SetRange("Appraisal No", "No.");
                if AppraisalKRAs.FindSet()then begin
                    repeat AppraisalKRAs."Review Period":="Review Period";
                        AppraisalKRAs.Modify(true);
                    until AppraisalKRAs.Next = 0;
                end;
                AppraisalKPIs.Reset();
                AppraisalKPIs.SetRange("Appraisal No", "No.");
                if AppraisalKPIs.FindSet()then begin
                    repeat AppraisalKPIs."Review Period":="Review Period";
                        AppraisalKPIs.Modify(true);
                    until AppraisalKPIs.Next = 0;
                end;
                AppraisalCompetence.Reset();
                AppraisalCompetence.SetRange("Appraisal No", "No.");
                if AppraisalCompetence.FindSet()then begin
                    repeat AppraisalCompetence."Review Period":="Review Period";
                        AppraisalCompetence.Modify(true);
                    until AppraisalCompetence.Next = 0;
                end;
                AppraisalBehaviour.Reset();
                AppraisalBehaviour.SetRange("Appraisal No", "No.");
                if AppraisalBehaviour.FindSet()then begin
                    repeat AppraisalBehaviour."Review Period":="Review Period";
                        AppraisalBehaviour.Modify(true);
                    until AppraisalBehaviour.Next = 0;
                end;
            end;
        }
        field(26; "Peer 1 Employee No"; Code[20])
        {
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if "Peer 1 Employee No" = '' then exit;
                Employee.Get("Peer 1 Employee No");
                "Peer 1 Employee Name":=Employee.FullName;
            end;
        }
        field(27; "Peer 1 Employee Name"; Text[70])
        {
        }
        field(28; "Peer 2 Employee No"; Code[20])
        {
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if "Peer 2 Employee No" = '' then exit;
                Employee.Get("Peer 2 Employee No");
                "Peer 2 Employee Name":=Employee.FullName;
            end;
        }
        field(29; "Peer 2 Employee Name"; Text[70])
        {
        }
        field(30; "Appraisal Start Date"; Date)
        {
        }
        field(31; "Appraisal End Date"; Date)
        {
        }
        field(32; Sequence; Integer)
        {
            DataClassification = ToBeClassified;
            MinValue = 0;
            MaxValue = 4;
            Editable = false;
        }
        field(33; "New Emp. App. Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Appraisee Level,Supervisor Level,HR Level,Closed';
            OptionMembers = " ", "Appraisee Level", "Supervisor Level", "HR Level", Closed;
        }
        field(34; "Hr UserId"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Action Taken"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Confirmed,Probation Extension,Terminated';
            OptionMembers = " ", Confirmed, "Probation Extension", Terminated;
        }
        field(37; "Overview Manager"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Overview Manager")then "Overview Manager Name":=Employee.FullName;
                UserSetup.Reset;
                UserSetup.SetRange("Employee No.", "Overview Manager");
                if UserSetup.FindFirst then begin
                    "Overview Manager UserID":=UserSetup."User ID";
                end;
            end;
        }
        field(38; "Action To Implement"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Extend Probation,Confirm Employeee,Terminate Employee';
            OptionMembers = " ", "Extend Probation", "Confirm Employee", "Terminate Employee";
        }
        field(39; "Overview Manager Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Overview Manager UserID"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(42; "Recomended Action"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Perfomance Improvement';
            OptionMembers = " ", "Perfomance Improvement";
        }
        field(44; "Probation Recomended Action"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Confirm,Extend Probation,Terminate';
            OptionMembers = " ", Confirm, "Extend Probation", Terminate;

            trigger OnValidate()
            begin
                if "Probation Extended" then if "Probation Recomended Action" in["Probation Recomended Action"::"Extend Probation"]then Error('You cannot extend probation twice');
            end;
        }
        field(45; "Probation Extended"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(46; "Global Dimension 1 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(47; "Global Dimension 2 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(48; "Global Dimension 3 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(49; "Global Dimension 4 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50; "Global Dimension 5 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(51; "Global Dimension 6 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Technical Objective Score"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(53; "Qualitative Objective Score"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(54; "OverView Manager Comments"; Text[140])
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Overall Rating"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(56; "Overall Score"; Decimal)
        {
            DataClassification = ToBeClassified;
            MinValue = 0;
            MaxValue = 100;
        }
        field(57; "Supervisor Overall Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(58; "Overview Rejection Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(59; "Supervisor Rejection Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(61; "One Point Done"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(62; "Eligible for one point"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(65; "CEO Comment"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnDelete()
    begin
        EmployeeAppraisalKRAs.Reset;
        EmployeeAppraisalKRAs.SetRange("Appraisal No", Rec."No.");
        EmployeeAppraisalKRAs.SetRange("Employee No", Rec."Employee No");
        if EmployeeAppraisalKRAs.FindSet then EmployeeAppraisalKRAs.DeleteAll;
        EmployeeAppraisalKPIs.Reset;
        EmployeeAppraisalKPIs.SetRange("Appraisal No", Rec."No.");
        EmployeeAppraisalKPIs.SetRange("Employee No", Rec."Employee No");
        if EmployeeAppraisalKPIs.FindSet then EmployeeAppraisalKPIs.DeleteAll;
        EmployeeAppraisalCompetence.Reset;
        EmployeeAppraisalCompetence.SetRange("Appraisal No", Rec."No.");
        EmployeeAppraisalCompetence.SetRange("Employee Code", Rec."Employee No");
        if EmployeeAppraisalCompetence.FindSet then EmployeeAppraisalCompetence.DeleteAll;
        EmployeeAppraisalBehaviour.Reset;
        EmployeeAppraisalBehaviour.SetRange("Appraisal No", Rec."No.");
        EmployeeAppraisalBehaviour.SetRange("Employee No", Rec."Employee No");
        if EmployeeAppraisalBehaviour.FindSet then EmployeeAppraisalBehaviour.DeleteAll;
    end;
    trigger OnInsert()
    begin
        if "No." = '' then begin
            HumanResourcesSetup.Get;
            HumanResourcesSetup.TestField("Appraisal Nos");
            "No.":=NoSeriesManagement.GetNextNo(HumanResourcesSetup."Appraisal Nos", 0D, true);
        end;
    end;
    var Departments: Record "Training Attended Prev. Year";
    Employee: Record Employee;
    UserSetup: Record "User Setup";
    AppraisalCalender: Record "Appraisal Calender";
    NoSeriesSetup: Record "Human Resource Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    HumanResourcesSetup: Record "Human Resources Setup";
    HrAppraisalManagement: Codeunit "Appraisal Management";
    EmployeeAppraisalKRAs: Record "Appraisal Objectives/KRAs";
    EmployeeAppraisalKPIs: Record "Appraisal Activities";
    EmployeeAppraisalCompetence: Record "Appraisal Competence";
    EmployeeAppraisalBehaviour: Record "Appraisal Behaviour";
    AppraisalReviewPeriod: Record "Appraisal Review Periods";
}
