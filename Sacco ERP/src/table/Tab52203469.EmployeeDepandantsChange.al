table 52203469 "Employee Depandants Change"
{
    fields
    {
        field(1; "Line No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;
        }
        field(3; "Full Name"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "ID/Birth Certificate No."; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Date of Birth"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Date of Birth" = 0D then begin
                    Age:='';
                    exit;
                end;
                Age:=HRDates.DetermineDatesDiffrence("Date of Birth", Today);
                if "Is Student" then exit;
                HumanResourcesSetup.Get;
                HumanResourcesSetup.TestField("Dependant Age Limit");
                if CalcDate(HumanResourcesSetup."Dependant Age Limit", "Date of Birth") < Today then Error('This individual is past the dependant age limit');
            end;
        }
        field(7; Age; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Relationship; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        field(9; Gender; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Male,Female,Unknown';
            OptionMembers = " ", Male, Female, Unknown;
        }
        field(10; "Is Student"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(70000; "Change No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(70001; "Action"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Retain,Remove,New Addition';
            OptionMembers = Retain, Remove, "New Addition";

            trigger OnValidate()
            begin
                if(xRec.Action in[xRec.Action::Retain]) and (not(Rec.Action in[Rec.Action::Remove]))then Error('This change is not permited');
            end;
        }
    }
    keys
    {
        key(Key1; "Line No.", "Employee No.", "Change No")
        {
        }
    }
    var HRDates: Codeunit "HR Dates";
    HumanResourcesSetup: Record "Human Resources Setup";
}
