table 52203745 "Service Proforma Line"
{
    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Item Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Item Name");
                TestField(Description);
                if Modify(true)then begin
                    if "Discount %" <> 0 then begin
                        "Total Amount":=(Quantity * "Unit Price") - ((Quantity * "Unit Price") * ("Discount %" / 100));
                    end
                    else
                    begin
                        "Total Amount":=Quantity * "Unit Price";
                    end;
                end;
            end;
        }
        field(5; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Item Name");
                TestField(Description);
                if Modify(true)then begin
                    if "Discount %" <> 0 then begin
                        "Total Amount":=(Quantity * "Unit Price") - ((Quantity * "Unit Price") * ("Discount %" / 100));
                    end
                    else
                    begin
                        "Total Amount":=Quantity * "Unit Price";
                    end;
                end;
            end;
        }
        field(6; Sundries; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Item Name");
                TestField(Description);
            end;
        }
        field(7; "Discount %"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Unit Price");
                TestField(Quantity);
                if Modify(true)then begin
                    "Total Amount":=(Quantity * "Unit Price") - ((Quantity * "Unit Price") * ("Discount %" / 100));
                end;
            end;
        }
        field(8; "VAT %"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Unit Price");
                TestField(Quantity);
            end;
        }
        field(9; "Total Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Total Amount + Sundries"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Item No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Service Items"."No.";

            trigger OnValidate()
            begin
                ServiceProformaLine.Reset;
                ServiceProformaLine.SetRange("Document No.", "Document No.");
                ServiceProformaLine.SetRange("Item No", "Item No");
                if ServiceProformaLine.FindFirst then begin
                    Error('The item %1 already exists in this document', "Item No");
                end;
                if ServiceItems.Get("Item No")then begin
                    "Item Name":=ServiceItems.Name;
                end;
            end;
        }
    }
    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
        }
    }
    trigger OnModify()
    begin
        if "Discount %" <> 0 then begin
            "Total Amount":=(Quantity * "Unit Price") - ((Quantity * "Unit Price") * ("Discount %" / 100));
        end
        else
        begin
            "Total Amount":=Quantity * "Unit Price";
        end;
        "Total Amount":=(Quantity * "Unit Price") - ((Quantity * "Unit Price") * ("Discount %" / 100));
    end;
    var ServiceProformaCard: Page "Service Proforma Card";
    ServiceItems: Record "Service Items";
    ServiceProformaLine: Record "Service Proforma Line";
    local procedure CalculateTotals()
    var
        ServiceProformaHeader: Record "Service Proforma Header";
        ServiceProformaLine: Record "Service Proforma Line";
        AmountTotal: Decimal;
        SundriesTotal: Decimal;
    begin
    end;
}
