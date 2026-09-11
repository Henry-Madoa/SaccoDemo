tableextension 52203463 "User Setup" extends "User Setup"
{
    fields
    {
        field(52203423; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                IF Employee.GET("Employee No.") then begin
                    Employee.TestField("Company E-Mail");
                    Employee.TestField("Phone No.");
                    "E-Mail" := Employee."Company E-Mail";
                    "Phone No." := Employee."Phone No.";
                end;
            end;
        }
        field(52203424; "Signature Card"; BLOB)
        {
            Compressed = false;
            DataClassification = ToBeClassified;
            SubType = Bitmap;
        }
        field(52203425; "In Management"; Boolean)
        {
        }
        field(52203426; "Line Manager"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup"."User ID";

            trigger OnValidate()
            begin
                if "Line Manager" = "User ID" then Error('You need to select a diffrent line manager');
                if UserSetup.Get("Line Manager") then begin
                    Employee.Get("Employee No.");
                    Employee."Manager No." := UserSetup."Employee No.";
                    Employee.Modify(true);
                end
                else
                    Error(Text000);
            end;
        }
        field(52203427; "Procurement Admin"; Boolean)
        {
        }
        field(52203428; "Is System Admin"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203429; "Is Store Admin"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203430; "Head of Branch"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = CONST(false));
        }
        field(52203431; "Head of Department"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = CONST(false));
        }
        field(52203432; Signature; BLOB)
        {
            DataClassification = ToBeClassified;
            SubType = Bitmap;
        }
        field(52203433; "Apply Leave Later Dater"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203434; "Is HOD"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203435; "Finance Admin"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203436; CEO; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203437; "Payroll Admin"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203438; "Store Admin"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203439; "HR Admin"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203440; "Can Auto Reverse"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    var
        Employee: Record Employee;
        UserSetup: Record "User Setup";
        Text000: Label 'Supervisor must be have a mapping first.';
}
