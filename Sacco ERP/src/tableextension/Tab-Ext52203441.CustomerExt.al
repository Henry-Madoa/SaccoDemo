tableextension 52203441 "Customer Ext" extends Customer
{
    fields
    {
        // Add changes to table fields here
        field(50000; Rent; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Customer Charges".Amount where("Customer No."=field("No.")));
            Editable = false;
        }
        field(50001; "Tenant Booking No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
}
