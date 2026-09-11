tableextension 52203443 "Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
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
