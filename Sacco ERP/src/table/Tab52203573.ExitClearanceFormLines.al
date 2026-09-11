table 52203573 "Exit Clearance Form Lines"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Exit No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(4; "Clearance Item"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Returned; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Yes,No,N/A';
            OptionMembers = " ", Yes, No, "N/A";
        }
        field(6; Number; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Validate("Item Worth");
            end;
        }
        field(7; "Form No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "Clearance Section"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Clearance Sections";
        }
        field(10; "Clearance Section Name"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Clearance Sections".Name where(Code=field("Clearance Section")));
            Editable = false;
        }
        field(11; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Uncleared, Cleared;
        }
        field(12; "Item Worth"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if((Number <> 0) and ("Item Worth" <> 0))then Amount:=(Number * "Item Worth")
                else
                    Amount:=0;
            end;
        }
    }
    keys
    {
        key(Key1; "Employee No", "Line No", "Exit No")
        {
        }
    }
}
