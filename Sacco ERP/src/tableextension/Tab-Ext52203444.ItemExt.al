tableextension 52203444 "Item Ext" extends Item
{
    fields
    {
        // Add changes to table fields here
        field(50001; "Marked For Disposal"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50423; "Item Status";Enum "Item Status")
        {
            DataClassification = CustomerContent;
        }
    }
    trigger OnInsert()
    begin
        "Item Status":="Item Status"::Active;
    end;
}
