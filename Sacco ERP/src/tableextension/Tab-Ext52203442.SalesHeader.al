tableextension 52203442 "Sales Header" extends "Sales Header"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Payment Period"; Date)
        {
            Editable = false;
        }
        field(50001; Rent; Boolean)
        {
            Editable = false;
        }
    }
}
