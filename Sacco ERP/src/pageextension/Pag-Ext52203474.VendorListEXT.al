pageextension 52203474 VendorListEXT extends "Vendor List"
{
    var myInt: Integer;
    trigger OnOpenPage()
    begin
        Rec.SetFilter("Account Type", 'Supplier');
    end;
}
