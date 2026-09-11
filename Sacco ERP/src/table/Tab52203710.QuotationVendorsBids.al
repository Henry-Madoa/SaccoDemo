table 52203710 "Quotation Vendors Bids"
{
    DrillDownPageID = "Vendor Quoted Amount Per Item";
    LookupPageID = "Vendor Quoted Amount Per Item";

    fields
    {
        field(1; "Quote No"; Code[30])
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(2; "Vendor No"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if Vendor.Get("Vendor No")then begin
                    "Vendor Name":=Vendor.Name;
                end;
            end;
        }
        field(3; "Vendor Name"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Item No"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if Item.Get("Item No")then begin
                    "Item Name":=Item.Description;
                end
                else if GLAccount.Get("Item No")then begin
                        "Item Name":=GLAccount.Name;
                    end
                    else if FixedAsset.Get("Item No")then begin
                            "Item Name":=FixedAsset.Description;
                        end;
            end;
        }
        field(6; "Item Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Quoted Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "VAT %"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Lead Time"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "VAT Inclusive"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Quantity; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                "Quoted Amount":="Unit Price" * Quantity;
            end;
        }
        field(13; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Quoted Amount":="Unit Price" * Quantity;
            end;
        }
        field(14; "Committee Selection Count"; Integer)
        {
            CalcFormula = Count("RFQ Committee Evaluation" WHERE("RFQ No."=FIELD("Quote No"), "Vendor No."=FIELD("Vendor No"), No=FIELD("Item No"), Award=CONST(true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "RFQ DeadLine Date"; Date)
        {
            CalcFormula = Lookup("Procurement Request"."RFQ Deadline Date" WHERE("No."=FIELD("Quote No")));
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(Key1; "Quote No", "Vendor No", "Line No")
        {
        }
        key(Key2; "Quoted Amount")
        {
        }
        key(Key3; "Item No")
        {
        }
    }
    var Vendor: Record Vendor;
    GLAccount: Record "G/L Account";
    Item: Record Item;
    FixedAsset: Record "Fixed Asset";
}
