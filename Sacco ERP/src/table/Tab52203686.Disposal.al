table 52203686 "Disposal"
{
    fields
    {
        field(1; "Disposal No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Fixed Asset,Item';
            OptionMembers = "Fixed Asset", Item;
        }
        field(3; No; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF(Type=CONST(Item))Item."No."
            ELSE IF(Type=CONST("Fixed Asset"))"Fixed Asset"."No.";

            trigger OnValidate()
            begin
                if Item.Get(No)then Description:=Item.Description;
                if FixedAsset.Get(No)then Description:=FixedAsset.Description;
            end;
        }
        field(4; Description; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; Reason; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Total Amount":=Quantity * "Unit Price";
            end;
        }
        field(7; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Total Amount":=Quantity * "Unit Price";
            end;
        }
        field(8; "Total Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70000; "Customer No"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer."No.";

            trigger OnValidate()
            begin
                if Customer.Get("Customer No")then "Customer Name":=Customer.Name
                else
                    "Customer Name":='';
            end;
        }
        field(70001; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(70002; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(70003; "Order Created"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(70004; "Customer Category"; Code[70])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Customer Category"."Category Code";
        }
        field(70005; "Customer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(70006; "Reason For Customer Selection"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(70007; "Global Dimension 1"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1));
        }
        field(70008; "Global Dimension 2"; Code[50])
        {
            CaptionClass = '1,1,2';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1));
        }
    }
    keys
    {
        key(Key1; "Disposal No")
        {
        }
    }
    var FixedAsset: Record "Fixed Asset";
    Item: Record Item;
    Customer: Record Customer;
}
