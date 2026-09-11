table 52203519 "RFQ Lines"
{
    fields
    {
        field(1; "RFQ No"; Code[20])
        {
        }
        field(2; "Line No"; Integer)
        {
        }
        field(3; Type;Enum "Purchase Line Type")
        {
        }
        field(4; No; Code[20])
        {
            TableRelation = IF(Type=CONST("G/L Account"))"G/L Account"
            ELSE IF(Type=CONST(Item))Item
            ELSE IF(Type=CONST("Fixed Asset"))"Fixed Asset";
        }
        field(5; Description; Text[250])
        {
        }
        field(6; "Unit of Measure"; Code[10])
        {
        }
        field(7; Quantity; Decimal)
        {
        }
        field(8; "Direct Unit Cost"; Decimal)
        {
        }
        field(9; Amount; Decimal)
        {
        }
        field(10; "Store of Delivery"; Code[10])
        {
            TableRelation = Location;
        }
        field(11; "Requisition No"; Code[20])
        {
        }
        field(12; "Req Line No"; Integer)
        {
        }
        field(13; "Responsibility Center"; Code[10])
        {
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3));
        }
        field(14; "Cost Center"; Code[10])
        {
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3));
        }
        field(15; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(16; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(22; MFR; Text[30])
        {
        }
        field(23; "Catalog No."; Code[20])
        {
        }
        field(24; "Currency Code"; Code[10])
        {
        }
    }
    keys
    {
        key(Key1; "RFQ No", "Line No")
        {
        }
        key(Key2; Type, No)
        {
        }
    }
    var RFQ: Record "RFQ Header";
    trigger OnInsert()
    begin
        if RFQ.Get("RFQ No")then begin
            if RFQ.Status = RFQ.Status::Open then RFQ.TestField("Created by", UserId)
            else
                Error('You cannot add more lines at this stage.');
        end;
    end;
    trigger OnDelete()
    begin
        if RFQ.Get("RFQ No")then if RFQ.Status = RFQ.Status::Open then RFQ.TestField("Created by", UserId)
            else
                Error('You cannot delete lines at this stage.');
    end;
}
