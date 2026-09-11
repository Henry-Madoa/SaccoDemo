table 52203520 "RFQ Vendors"
{
    fields
    {
        field(1; "RFQ No"; Code[20])
        {
        }
        field(2; "Vendor No"; Code[20])
        {
            TableRelation = Vendor where("Account Type"=const(Supplier));

            trigger OnValidate()
            begin
                if Suppliers.Get("Vendor No")then Name:=Suppliers.Name;
                if RFP.Get("RFQ No")then "Requisition No.":=RFP."Requisition No.";
            end;
        }
        field(3; Name; Text[50])
        {
        }
        field(4; "Quote No"; Code[20])
        {
        }
        field(5; Total; Decimal)
        {
            CalcFormula = Sum("Purchase Line".Amount WHERE("Document No."=FIELD("Quote No"), "Buy-from Vendor No."=FIELD("Vendor No")));
            FieldClass = FlowField;
        }
        field(6; "Requisition No."; Code[20])
        {
        }
        field(7; Competency; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; Capacity; Decimal)
        {
            DataClassification = CustomerContent;
            TableRelation = "Vendor Rating";
        }
        field(9; Commitment; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; Control; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Cash Resources"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(12; Cost; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; Consistency; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Quote Generated"; Boolean)
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "RFQ No", "Vendor No")
        {
        }
    }
    var Suppliers: Record Vendor;
    RFP: Record "RFQ Header";
}
