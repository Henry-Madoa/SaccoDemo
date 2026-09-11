table 52203466 "Employee Relative Change"
{
    Caption = 'Employee Relative';
    DataCaptionFields = "Employee No.";

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
        field(3; "Relative Code"; Code[10])
        {
            Caption = 'Relative Code';
            TableRelation = Relative;
        }
        field(4; "First Name"; Text[30])
        {
            Caption = 'First Name';
        }
        field(5; "Middle Name"; Text[30])
        {
            Caption = 'Middle Name';
        }
        field(6; "Last Name"; Text[30])
        {
            Caption = 'Last Name';
        }
        field(7; "Birth Date"; Date)
        {
            Caption = 'Birth Date';

            trigger OnValidate()
            begin
                if "Date of Birth" = 0D then exit;
                Age:=HRDates.DetermineDatesDiffrence("Birth Date", Today);
            end;
        }
        field(8; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(9; "Relative's Employee No."; Code[20])
        {
            Caption = 'Relative''s Employee No.';
            TableRelation = Employee;
        }
        field(10; Comment; Boolean)
        {
            CalcFormula = Exist("Human Resource Comment Line" WHERE("Table Name"=CONST("Employee Relative"), "No."=FIELD("Employee No."), "Table Line No."=FIELD("Line No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70000; "ID/Birth Certificate No."; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(70002; "Email Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(70003; Entitlement; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70004; Gender; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Male,Female,Unknown';
            OptionMembers = " ", Male, Female, Unknown;
        }
        field(70005; "Date of Birth"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(70006; Age; Text[40])
        {
            DataClassification = ToBeClassified;
        }
        field(90000; "Change No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(90001; "Action"; Option)
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
    var
        HRCommentLine: Record "Human Resource Comment Line";
    begin
        HRCommentLine.SetRange("Table Name", HRCommentLine."Table Name"::"Employee Relative");
        HRCommentLine.SetRange("No.", "Employee No.");
        HRCommentLine.DeleteAll;
    end;
    var HRDates: Codeunit "HR Dates";
}
