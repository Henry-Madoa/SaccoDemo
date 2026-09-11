table 52203558 "Budget Plan Schedule Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No"; Code[20])
        {
            Editable = false;
        }
        field(2; "Plan Line No"; Integer)
        {
            Editable = false;
        }
        field(3; Date; Date)
        {
        }
        field(4; Budget; Code[10])
        {
            TableRelation = "G/L Budget Name" where(Status=const(Open));
            NotBlank = true;
            Editable = false;
        }
        field(5; "Budget Line Account"; Code[20])
        {
        }
        field(6; Amount; Decimal)
        {
        }
        field(7; "Global Dimension 1 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(8; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(9; "Global Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(10; Posted; Boolean)
        {
            Editable = false;
        }
        field(11; Description; Text[100])
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Document No", Date, "Budget Line Account", "Global Dimension 1 Code")
        {
            Clustered = true;
        }
    }
}
