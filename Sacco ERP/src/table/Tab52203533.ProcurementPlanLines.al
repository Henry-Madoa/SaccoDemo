table 52203533 "Procurement Plan Lines"
{
    DataClassification = CustomerContent;
    DrillDownPageID = "Procurement Plan Lines";
    LookupPageID = "Procurement Plan Lines";

    fields
    {
        field(1; "Document No"; Code[10])
        {
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                if ProcureHeader.Get("Document No")then begin
                    "Global Dimension 1 Code":=ProcureHeader."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=ProcureHeader."Global Dimension 2 Code";
                    "Global Dimension 3 Code":=ProcureHeader."Global Dimension 3 Code";
                    "Item Budget Name":=ProcureHeader."Item Budget Name";
                end;
            end;
        }
        field(2; "Line No"; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(3; "Item Category"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Category";
        }
        field(4; "Plan Type";Enum "Plan Type")
        {
            DataClassification = ToBeClassified;
            InitValue = Item;
            Editable = false;
        }
        field(5; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = IF("Plan Type"=const("Fixed Asset"))"Fixed Asset"
            else if("Plan Type"=const("G/L Account"))"G/L Account" where("Account Category"=filter(Expense))
            else if("Plan Type"=const(item))Item;

            trigger OnValidate()
            begin
                if "Plan Type" = "Plan Type"::"Fixed Asset" then begin
                    if FixedAsset.Get("No.")then Description:=FixedAsset.Description;
                end;
                if "Plan Type" = "Plan Type"::Item then begin
                    if Item.Get("No.")then begin
                        Item.TestField("Purch. Unit of Measure");
                        Description:=Item.Description;
                        "Unit of Measure":=Item."Purch. Unit of Measure";
                        "Item Category":=Item."Item Category Code";
                    end;
                end;
                if "Plan Type" = "Plan Type"::"G/L Account" then begin
                    if GL_Accounts.Get("No.")then Description:=GL_Accounts.Name;
                end;
            end;
        }
        field(6; Description; Text[250])
        {
        }
        field(7; Quantity; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Unit Cost");
            end;
        }
        field(8; "Unit of Measure"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code where("Item No."=field("No."));

            trigger OnValidate()
            begin
                Validate("Unit Cost");
            end;
        }
        field(9; "Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Item.Get("No.")then begin
                    "Qty. per Unit of Measure":=UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure");
                    "Quantity (Base)":=UOMMgt.CalcBaseQty("No.", '', "Unit of Measure", Quantity, "Qty. per Unit of Measure");
                    if "Unit Cost" <> 0 then begin
                        if "Qty. per Unit of Measure" <> 0 then begin
                            "Unit Cost (Base)":=Round("Unit Cost" / "Qty. per Unit of Measure", 0.001);
                            Validate("Unit Cost (Base)");
                        end;
                    end;
                end;
                "Total Cost":=Quantity * "Unit Cost";
            end;
        }
        field(10; "Unit Cost (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Procurement Method"; Option)
        {
            DataClassification = ToBeClassified;
            InitValue = "Direct Procurement";
            OptionCaption = ' ,Tender,RFQ,Direct Procurement,RFP';
            OptionMembers = " ", Tender, RFQ, "Direct Procurement", RFP;
        }
        field(12; "Global Dimension 1 Code"; Code[10])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
            Editable = false;
        }
        field(13; "Global Dimension 2 Code"; Code[10])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(14; "Global Dimension 3 Code"; Code[10])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,3';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(15; Status;Enum "Document Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            Editable = false;
        }
        field(16; "Item Budget Name"; Code[10])
        {
            TableRelation = "Item Budget Name".Name where("Analysis Area"=const(Purchase));
            Editable = false;
        }
        field(17; "Location Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(18; "Quantity (Base)"; Decimal)
        {
            Editable = false;
        }
        field(19; "Total Cost"; Decimal)
        {
            Editable = false;
        }
        field(20; Date; Date)
        {
        }
        field(21; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0: 5;
            Editable = false;
            InitValue = 1;
        }
    }
    keys
    {
        key(Key1; "Document No", "Line No")
        {
            SumIndexFields = "Total Cost";
        }
    }
    var ProcureHeader: Record "Procurement Plans";
    UOMMgt: Codeunit "Unit of Measure Management";
    Item: Record Item;
    FixedAsset: record "Fixed Asset";
    GL_Accounts: Record "G/L Account";
    trigger OnDelete()
    begin
        if ProcureHeader.Get("Document No")then if ProcureHeader.Status = ProcureHeader.Status::Open then ProcureHeader.TestField("Raised By", UserId)
            else
                Error('You cannot delete lines at this stage.');
    end;
}
