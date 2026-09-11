table 52203546 "Contract Commitment Lines"
{
    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Line No."; Integer)
        {
        }
        field(3; "Expense Code"; Code[50])
        {
            TableRelation = "Expense Codes" where("Account No"=filter(<>''));

            trigger OnValidate()
            begin
                if Expenses.Get("Expense Code")then begin
                    "Expense Description":=Expenses.Description;
                    Validate("GL Account No.", Expenses."Account No");
                end;
            end;
        }
        field(4; "Expense Description"; Text[250])
        {
        }
        field(5; "GL Account No."; Code[20])
        {
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                if GL.Get("GL Account No.")then "Account Name":=GL.Name;
            end;
        }
        field(6; "Account Name"; Text[50])
        {
        }
        field(7; Description; Text[250])
        {
        }
        field(8; Amount; Decimal)
        {
        }
        field(9; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(10; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(11; "Global Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(12; "Global Dimension 4 Code"; Code[20])
        {
            CaptionClass = '1,2,4';
            Caption = 'Global Dimension 4 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(4), Blocked=const(false));
        }
        field(13; "Global Dimension 5 Code"; Code[20])
        {
            CaptionClass = '1,2,5';
            Caption = 'Global Dimension 5 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(5), Blocked=const(false));
        }
        field(14; "Commitment Date"; Date)
        {
        }
    }
    keys
    {
        key(Key1; "No.", "Line No.")
        {
        }
    }
    var Expenses: Record "Expense Codes";
    GL: Record "G/L Account";
}
