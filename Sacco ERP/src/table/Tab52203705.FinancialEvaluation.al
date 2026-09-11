table 52203705 "Financial Evaluation"
{
    fields
    {
        field(1; "Reference No."; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Vendor Name"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; "Quoted Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(4; Award; Boolean)
        {
            CalcFormula = Lookup("Tender Suppliers".Awarded WHERE("Reference No"=FIELD("Reference No."), "Vendor Name"=FIELD("Vendor Name")));
            FieldClass = FlowField;
        }
        field(5; "Technical Score"; Decimal)
        {
            CalcFormula = Sum("Tender Suppliers"."Technical Score" WHERE("Reference No"=FIELD("Reference No."), "Vendor Name"=FIELD("Vendor Name")));
            FieldClass = FlowField;
        }
        field(6; "Financial Score"; Decimal)
        {
            CalcFormula = Sum("Tender Suppliers"."Financial Score" WHERE("Reference No"=FIELD("Reference No."), "Vendor Name"=FIELD("Vendor Name")));
            FieldClass = FlowField;
        }
        field(7; "Total Score"; Decimal)
        {
            CalcFormula = Sum("Tender Suppliers"."Total Score" WHERE("Reference No"=FIELD("Reference No."), "Vendor Name"=FIELD("Vendor Name")));
            FieldClass = FlowField;
        }
        field(8; "Vendor No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "New Vendor No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Reference No.", "Vendor Name")
        {
        }
    }
}
