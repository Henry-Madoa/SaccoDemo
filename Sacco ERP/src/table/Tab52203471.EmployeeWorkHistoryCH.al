table 52203471 "Employee Work History CH"
{
    Caption = 'Employee Qualification';
    DataCaptionFields = "Employee No.";
    DrillDownPageID = "Employee Work History";
    LookupPageID = "Employee Work History";

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
        field(4; "From Date"; Date)
        {
            Caption = 'From Date';
        }
        field(5; "To Date"; Date)
        {
            Caption = 'To Date';
        }
        field(7; "Work Done"; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Institution/Company"; Text[100])
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
        field(13; "Position Held"; Text[200])
        {
            DataClassification = ToBeClassified;
            Enabled = false;
        }
        field(14; "Key Experience"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Salary on Leaving"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Reason For Leaving"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(17; Comments; Text[200])
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
            OptionCaption = 'Existing,New Addition';
            OptionMembers = Existing, "New Addition";
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
}
