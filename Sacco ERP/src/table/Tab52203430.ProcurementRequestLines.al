table 52203430 "Procurement Request Lines"
{
    fields
    {
        field(1; "Procurement No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(3; Type;Enum "Purchase Line Type")
        {
            DataClassification = ToBeClassified;
        }
        field(4; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF(Type=CONST("G/L Account"))"G/L Account"."No." WHERE("Direct Posting"=CONST(true), "Account Category"=CONST(Expense))
            ELSE IF(Type=CONST(Item))Item WHERE(Blocked=CONST(false));

            trigger OnValidate()
            begin
                if RequisitionHeader.Get("Procurement No")then begin
                    if RequisitionHeader."Requisition Type" in[RequisitionHeader."Requisition Type"::"Purchase Requisition"]then begin
                        "Planned Quantity":=ProcurementManagement.GetPlannedQuantity("Global Dimension 1 Code", Type, "No.", "Plan No.");
                        "Planned Amount":=ProcurementManagement.GetPlannedAmount("Global Dimension 1 Code", Type, "No.", "Plan No.");
                        "Requisitioned Quantity":=ProcurementManagement.GetRequisitionedQuantity("Global Dimension 1 Code", "No.", "Plan No.");
                        "Used Amount":=ProcurementManagement.GetRequisitionedAmount("Global Dimension 1 Code", "Global Dimension 2 Code", "No.", "Plan No.");
                        "Available Quantity":="Planned Quantity" - "Requisitioned Quantity";
                        "Available Amount":="Planned Amount" - "Used Amount";
                    end;
                end;
                if Type = Type::"Fixed Asset" then begin
                    if FixedAsset.Get("No.")then Name:=FixedAsset.Description;
                end
                else if Type = Type::"G/L Account" then begin
                        if GLAccount.Get("No.")then Name:=GLAccount.Name;
                    end
                    else if Type = Type::Item then begin
                            if Item.Get("No.")then Name:=Item.Description;
                        end;
            end;
        }
        field(5; Name; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; Description; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; Quantity; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                "Total Amount":=Quantity * "Unit Price";
                Validate("Total Amount");
            end;
        }
        field(8; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                "Total Amount":=Quantity * "Unit Price";
                Validate("Total Amount");
            end;
        }
        field(9; "Total Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if "Total Amount" > "Available Amount" then UnPlanned:=true
                else
                    UnPlanned:=false;
            end;
        }
        field(10; "Unit of Measure"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Item Unit of Measure" where("Item No."=field("No."));
        }
        field(11; "Plan No."; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(12; "Planned Quantity"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Requisitioned Quantity"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Planned Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Used Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; UnPlanned; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Available Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Available Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Location Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
        }
        field(20; "Global Dimension 1 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Global Dimension 2 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Vendor To Award"; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Quotation Bidders"."Vendor No." WHERE("Reference No"=FIELD("Procurement No"));
        }
        field(23; "Tender Winner"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Order/Contract Created"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Procurement No", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Line No.", "Procurement No")
        {
        }
    }
    trigger OnInsert()
    begin
        if RequisitionHeader.Get("Procurement No")then begin
            "Global Dimension 1 Code":=RequisitionHeader."Global Dimension 3 Code";
            "Global Dimension 2 Code":=RequisitionHeader."Global Dimension 2 Code";
            "Plan No.":=RequisitionHeader."No.";
            Description:=RequisitionHeader.Description;
        end;
    end;
    var RequisitionHeader: Record "Requisition Header";
    ProcurementManagement: Codeunit "Procurement Management";
    GLAccount: Record "G/L Account";
    Item: Record Item;
    FixedAsset: Record "Fixed Asset";
}
