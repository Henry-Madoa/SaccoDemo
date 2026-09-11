table 52203465 "Employee Proffesional Bodies"
{
    Caption = 'Employee Profesional bodies';
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
        //This property is currently not supported
        //TestTableRelation = false;
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
                if Prof.Get("Body Code")then Name:=Prof.Name;
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
        field(13; "Membership Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No.", "Line No.")
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
    Prof: Record "Professional Bodies";
    Employee: Record Employee;
}
