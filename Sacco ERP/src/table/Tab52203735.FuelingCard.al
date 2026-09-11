table 52203735 "Fueling Card"
{
    DrillDownPageID = "Fueling Card List";
    LookupPageID = "Fueling Card List";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ',Credit Card,Debit Card';
            OptionMembers = , "Credit Card", "Debit Card";
        }
        field(4; "Vehicle REG. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Motor Vehicle Asset"."No.";
        }
        field(5; Amount; Decimal)
        {
            CalcFormula = Sum("Fuel Card Top-Up"."Top-Up Amount" WHERE("Card No."=FIELD("No."), Submitted=CONST(true)));
            FieldClass = FlowField;
        }
        field(6; "Amount Usage"; Decimal)
        {
            CalcFormula = Sum("Fuel Requisition"."Total Fuel Cost" WHERE("Card No."=FIELD("No."), Posted=CONST(true)));
            FieldClass = FlowField;
        }
        field(7; "Amount Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Reminder If Low"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnInsert()
    begin
        PurchPayableSetup.get;
        if "No." = '' then "No.":=NoSeries.GetNextNo(PurchPayableSetup."Fuel No.", Today, true);
        "Created On":=Today;
        "Created By":=UserId;
    end;
    var NoSeries: Codeunit NoSeriesManagement;
    PurchPayableSetup: Record "Purchases & Payables Setup";
}
