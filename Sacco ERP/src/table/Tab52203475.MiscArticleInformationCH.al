table 52203475 "Misc. Article Information CH"
{
    Caption = 'Misc. Article Information';
    DataCaptionFields = "Employee No.";
    DrillDownPageID = "Misc. Article Information";
    LookupPageID = "Misc. Article Information";

    fields
    {
        field(1; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            NotBlank = true;
            TableRelation = Employee;
        }
        field(2; "Asset Code"; Code[10])
        {
            NotBlank = true;
            TableRelation = "Fixed Asset";

            trigger OnValidate()
            begin
                FixedAssets.Get("Asset Code");
                Description:=FixedAssets.Description;
                "Asset Number":=FixedAssets."Asset Tag";
                "Serial No.":=FixedAssets."Serial No.";
            end;
        }
        field(3; "Line No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Line No.';
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "From Date"; Date)
        {
            Caption = 'From Date';

            trigger OnValidate()
            begin
                if "From Date" <> 0D then exit;
                if "To Date" <> 0D then if "To Date" < "From Date" then Error('from date cannot be higher than end date');
            end;
        }
        field(6; "To Date"; Date)
        {
            Caption = 'To Date';

            trigger OnValidate()
            begin
                if "To Date" <> 0D then exit;
                Rec.Testfield("From Date");
                if "To Date" < "From Date" then Error('from date cannot be higher than end date');
            end;
        }
        field(7; "In Use"; Boolean)
        {
            Caption = 'In Use';
        }
        field(8; Comment; Boolean)
        {
            CalcFormula = Exist("Human Resource Comment Line" WHERE("Table Name"=CONST("Misc. Article Information"), "No."=FIELD("Employee No."), "Table Line No."=FIELD("Line No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "Serial No."; Text[50])
        {
            Caption = 'Serial No.';
        }
        field(10; "Asset Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(15; Value; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70000; "Action"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Retain,Return,New Addition';
            OptionMembers = Retain, Return, "New Addition";
        }
        field(70001; "Change No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No.", "Asset Code", "Line No.", "Change No")
        {
        }
        key(Key2; "Line No.")
        {
        }
    }
    trigger OnDelete()
    begin
        if Comment then Error(Text000);
    end;
    trigger OnInsert()
    var
        MiscArticleInfo: Record "Misc. Article Information";
    begin
        MiscArticleInfo.SetCurrentKey("Line No.");
        if MiscArticleInfo.FindLast then "Line No.":=MiscArticleInfo."Line No." + 1
        else
            "Line No.":=1;
    end;
    var Text000: Label 'You cannot delete information if there are comments associated with it.';
    FixedAssets: Record "Fixed Asset";
}
