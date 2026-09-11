table 52203717 "Contract Milestone"
{
    fields
    {
        field(1; "Contract No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Milestone Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Milestone Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Period; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Format(Period) <> '' then begin
                    Rec.Testfield("Start Date");
                    "End Date":=CalcDate(Period, "Start Date");
                end;
            end;
        }
        field(6; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Is Percentage"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Percentage; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Fixed Amount"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Order Created"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Contract Lines"."Line No." WHERE("Contract No."=FIELD("Contract No"));

            trigger OnValidate()
            var
                ContractLines: Record "Contract Lines";
            begin
                ContractLines.Reset;
                ContractLines.SetRange("Contract No.", Rec."Contract No");
                ContractLines.SetRange("Line No.", Rec."Line No");
                if ContractLines.FindFirst then begin
                    "Item No.":=ContractLines.No;
                    "Item Name":=ContractLines.Name;
                    if "Is Percentage" then Amount:=Percentage / 100 * ContractLines."Total Amount";
                end;
            end;
        }
        field(13; "Item No."; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14; "Item Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(15; "Tender Amount"; Decimal)
        {
            CalcFormula = Sum("Contract Lines"."Total Amount" WHERE("Contract No."=FIELD("Contract No"), "Line No."=FIELD("Line No")));
            FieldClass = FlowField;
        }
        field(70000; "Milestone Extended"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(70001; "New End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(70002; Invoiced; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Contract No", "Milestone Code")
        {
        }
    }
    fieldgroups
    {
    }
}
