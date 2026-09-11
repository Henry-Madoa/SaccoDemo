tableextension 52203447 "Item Budget Entry" extends "Item Budget Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50200; "Items Requested"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Requisition Lines".Quantity where(Type = const(Item), Status = const(Approved), "Global Dimension 1 Code" = field("Global Dimension 1 Code"), "Procurement Plan" = field("Budget Name"), "Global Dimension 2 Code" = field("Global Dimension 2 Code")));
        }
    }
}
