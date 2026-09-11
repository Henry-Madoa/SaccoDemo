table 52203472 "Employee Proffesional Bodies C"
{
    Caption = 'Employee Qualification';
    DataCaptionFields = "Employee No.";
    DrillDownPageID = "Employee Proffessional Bodies";
    LookupPageID = "Employee Proffessional Bodies";

    fields
    {
        field(1; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            NotBlank = true;
            TableRelation = Employee;
        }
        field(2; "Line No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Line No.';
        }
        field(3; "Body Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Professional Bodies".Code;

            trigger OnValidate()
            begin
                if ProfessionalBodies.Get("Body Code")then Name:=ProfessionalBodies.Name;
            end;
        }
        field(4; "From Date"; Date)
        {
            Caption = 'From Date';
        }
        field(5; "To Date"; Date)
        {
            Caption = 'To Date';
        }
        field(8; Name; Text[100])
        {
            Caption = 'Institution/Company';
        }
        field(11; "Employee Status"; Option)
        {
            Caption = 'Employee Status';
            Editable = false;
            OptionCaption = 'Active,Inactive,Terminated';
            OptionMembers = Active, Inactive, Terminated;
        }
        field(12; Comment; Boolean)
        {
            CalcFormula = Exist("Human Resource Comment Line" WHERE("Table Name"=CONST("Employee Qualification"), "No."=FIELD("Employee No."), "Table Line No."=FIELD("Line No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Membership No"; Code[50])
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
        }
    }
    keys
    {
        key(Key1; "Employee No.", "Line No.", "Change No")
        {
        }
    }
    trigger OnDelete()
    begin
        if Comment then Error(Text000);
    end;
    trigger OnInsert()
    begin
        Employee.Get("Employee No.");
        "Employee Status":=Employee.Status;
    end;
    var Text000: Label 'You cannot delete employee qualification information if there are comments associated with it.';
    Qualification: Record Qualification;
    Employee: Record Employee;
    ProfessionalBodies: Record "Professional Bodies";
}
