table 52204202 "Loans Payable Advice"
{
    LookupPageId = "Loans Payable Advice";
    DrillDownPageId = "Loans Payable Advice";

    fields
    {
        field(1; "Loan No"; Code[20])
        {
            TableRelation = Loans;
        }
        field(2; "Vendor No."; Code[20])
        {
            TableRelation = Vendor where("Account Type" = const(Supplier), Blocked = const(" "));

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                Vendor.Get("Vendor No.");
                "Vendor Name" := Vendor.Name;
            end;
        }
        field(3; "Vendor Name"; Text[100])
        {
            Editable = false;
        }
        field(4; Amount; Decimal)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Loan No", "Vendor No.")
        {
            Clustered = true;
        }
    }
}
