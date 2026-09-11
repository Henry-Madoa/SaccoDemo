table 52203723 "Procurement Committee Members"
{
    DrillDownPageID = "Procurement Commitee Members";
    LookupPageID = "Procurement Commitee Members";

    fields
    {
        field(1; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Employee No.")then begin
                    Employee.TestField("User ID");
                    "User ID":=Employee."User ID";
                    "Employee Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
                end;
            end;
        }
        field(2; "User ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup"."User ID";

            trigger OnValidate()
            begin
            // IF UserSetup.GET("User ID") THEN BEGIN
            //  UserSetup.TESTFIELD("Employee No.");
            //  "Employee No." := UserSetup."Employee No.";
            //  VALIDATE("Employee No.");
            //  END;
            end;
        }
        field(3; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Line No."; Integer)
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
    fieldgroups
    {
        fieldgroup(DropDown; "Employee No.", "User ID", "Employee Name")
        {
        }
    }
    var UserSetup: Record "User Setup";
    Employee: Record Employee;
}
