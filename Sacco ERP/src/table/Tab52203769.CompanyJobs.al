table 52203769 "Company Jobs"
{
    DrillDownPageID = "Company Jobs";
    LookupPageID = "Company Jobs";

    fields
    {
        field(1; "Job ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; Name; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "No of Posts"; Integer)
        {
            //CalcFormula = count(Employee where("Job ID" = field("Job ID")));
            //Caption = 'Specifies Ocuppied Positions';
            //FieldClass = FlowField;
            trigger OnValidate()
            begin
                //if "No of Posts" <> xRec."No of Posts" then
                "Vacant Posistions":="No of Posts" - "Occupied Position";
            end;
        }
        field(4; "Position Reporting to"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Company Jobs" where(Status=const(Approved));
        }
        field(5; "Occupied Position"; Integer)
        {
            CalcFormula = count(Employee where("Job Code"=field("Job ID"), Status=const(Active)));
            //CalcFormula = Count("Employee Master" WHERE(Position = FIELD("Job ID"),
            //                                            Status = CONST(Active)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Vacant Posistions"; Integer)
        {
            Caption = 'Vacant Positions';
            DataClassification = ToBeClassified;
        }
        field(7; "Score code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Company Jobs" where(Status=const(Approved));
        }
        field(8; "Dimension 1"; Code[20])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(9; "Dimension 2"; Code[20])
        {
            CaptionClass = '1,1,2';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(10; "Dimension 3"; Code[20])
        {
            CaptionClass = '1,2,3';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(11; "Dimension 4"; Code[20])
        {
            CaptionClass = '1,2,4';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(4));
        }
        field(12; "Dimension 5"; Code[20])
        {
            CaptionClass = '1,2,5';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(5));
        }
        field(13; "Dimension 6"; Code[20])
        {
            CaptionClass = '1,2,6';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(6));
        }
        field(19; Objective; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(23; Grade; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employee Payroll Scales";
        }
        field(24; "Primary Skills Category"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Auditors, Consultants, Training, Certification, Administration, Marketing, Management, "Business Development", Other;
        }
        field(25; "2nd Skills Category"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Auditors, Consultants, Training, Certification, Administration, Marketing, Management, "Business Development", Other;
        }
        field(26; "3nd Skills Category"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Auditors, Consultants, Training, Certification, Administration, Marketing, Management, "Business Development", Other;
        }
        field(27; Management; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(28; Profession; Code[20])
        {
            TableRelation = Professions;
            DataClassification = ToBeClassified;
        }
        field(29; Status;Enum "Document Status")
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Job ID")
        {
        }
        key(Key2; "Vacant Posistions")
        {
        }
        key(Key3; "Dimension 1")
        {
        }
        key(Key4; "Dimension 2")
        {
        }
    }
    fieldgroups
    {
    }
}
