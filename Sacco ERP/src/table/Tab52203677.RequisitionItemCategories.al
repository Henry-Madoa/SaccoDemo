table 52203677 "Requisition Item Categories"
{
    DrillDownPageID = "Requisition item categories";
    LookupPageID = "Requisition item categories";

    fields
    {
        field(1; Category; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Category Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Category)
        {
        }
    }
}
