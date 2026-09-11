table 52203534 "Supplier Service Categories"
{
    DataClassification = CustomerContent;
    DrillDownPageID = "Supplier Service Categories";
    LookupPageID = "Supplier Service Categories";

    fields
    {
        field(1; "Vendor No"; Code[20])
        {
        }
        field(2; "Line No"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Service Catagory"; code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Service Category";
        }
        field(4; "Description"; Text[250])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Service Category".Description where(Code=field("Service Catagory")));
        }
    }
    keys
    {
        key("PK"; "Vendor No", "Line No")
        {
        }
    }
}
