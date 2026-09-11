table 52203427 "Employee Depandants"
{
    Caption = 'Employee Dependants';

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
        //This property is currently not supported
        //TestTableRelation = false;
        }
        field(3; "Full Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "ID/Birth Certificate No."; Code[25])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Employee.Reset;
                Employee.SetRange("National ID", "ID/Birth Certificate No.");
                Employee.SetRange(Status, Employee.Status::Active);
                if Employee.FindFirst then Error('This is an employee in the organization');
                EmployeeDepandants.Reset;
                EmployeeDepandants.SetRange("ID/Birth Certificate No.", Rec."ID/Birth Certificate No.");
                if EmployeeDepandants.FindFirst then Error('This certificate has been used by emp no. %1', EmployeeDepandants."Employee No.");
            end;
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
                if "Date of Birth" > Today then Age:=HRDates.DetermineDatesDiffrence("Date of Birth", Today);
                Rec.Testfield(Relationship);
                Relative.Get(Relationship);
                if("Is Student") or (Relative."Exempt Age Limit")then exit;
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
            TableRelation = Relative WHERE("For Dependant"=CONST(true));
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
        field(7000; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Active,Inactive';
            OptionMembers = Active, Inactive;
        }
        field(7001; "Employment Date"; Date)
        {
            CalcFormula = Lookup(Employee."Employment Date" WHERE("No."=FIELD("Employee No.")));
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(Key1; "Line No.", "Employee No.")
        {
        }
    }
    // trigger OnInsert()
    // begin
    //     EmployeeDepandants.Reset;
    //     EmployeeDepandants.SetRange("Employee No.", Rec."Employee No.");
    //     if EmployeeDepandants.FindSet then
    //         if EmployeeDepandants.Count > 5 then
    //             Error('You cannot insert more than 5 Lines');
    // end;
    var HRDates: Codeunit "HR Dates";
    HumanResourcesSetup: Record "Human Resources Setup";
    Relative: Record Relative;
    Employee: Record Employee;
    EmployeeDepandants: Record "Employee Depandants";
}
