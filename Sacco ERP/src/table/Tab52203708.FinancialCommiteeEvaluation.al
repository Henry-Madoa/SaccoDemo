table 52203708 "Financial Commitee Evaluation"
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
            Editable = false;
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
        field(10; "Commitee Member ID"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup"."User ID";
        }
        field(11; "Comittee Member Name"; Text[150])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(12; "Committee Emp. No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Award Bidder"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(14; Remarks; Text[250])
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
