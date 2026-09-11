table 52203521 "Procurement Inspection"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Created By"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(3; "LPO No"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Supplier No."; Code[20])
        {
            TableRelation = Vendor where("Account Type"=const(Supplier));
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                IF Supplier.GET("Supplier No.")THEN "Supplier Name":=Supplier.Name;
            end;
        }
        field(5; "Supplier Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(6; Date; Date)
        {
            DataClassification = CustomerContent;
        }
        field(7; "RFQ No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(8; "RFQ Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(9; "LPO Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Total Value"; Decimal)
        {
            CalcFormula = Sum("Inspection Lines"."Total Cost" WHERE("No."=FIELD("No.")));
            FieldClass = FlowField;
        }
        field(11; "Invoice No."; Code[20])
        {
        }
        field(12; "D Note No."; Code[20])
        {
        }
        field(13; "Completion/Delivery Date"; Date)
        {
        }
        field(15; "Reviewed By"; Text[50])
        {
        }
        field(16; Status;Enum "Document Status")
        {
        }
        field(17; Processed; Boolean)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnInsert();
    begin
        IF("No." = '')THEN BEGIN
            PurchaseSetup.GET;
            PurchaseSetup.TESTFIELD("Inspection Nos.");
            "No.":=NoSeriesMgt.GetNextNo(PurchaseSetup."Inspection Nos.", 0D, true);
        END;
        Date:=TODAY;
        "Created By":=USERID;
        "Completion/Delivery Date":=TODAY;
        "Reviewed By":=PurchaseSetup."Inspection Reviewer";
    end;
    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;
    var PurchaseSetup: Record "Purchases & Payables Setup";
    NoSeriesMgt: Codeunit 396;
    Supplier: Record Vendor;
}
