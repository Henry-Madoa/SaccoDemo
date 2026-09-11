table 52203567 "Transaction Types"
{
    DrillDownPageID = "Transaction Type";
    LookupPageID = "Transaction Type";

    fields
    {
        field(1; "Code"; Code[20])
        {
        }
        field(2; "Transaction Name"; Text[70])
        {
        }
        field(3; "Account Type"; Option)
        {
            OptionCaption = 'G/L Account,Customer,Vendor,Bank Account,Fixed Asset';
            OptionMembers = "G/L Account", Customer, Vendor, "Bank Account", "Fixed Asset";
        }
        field(4; "Account No."; Code[20])
        {
            TableRelation = IF("Account Type"=CONST("G/L Account"))"G/L Account"
            ELSE IF("Account Type"=CONST(Customer))Customer
            ELSE IF("Account Type"=CONST(Vendor))Vendor
            ELSE IF("Account Type"=CONST("Fixed Asset"))"Fixed Asset"
            ELSE IF("Account Type"=CONST("Bank Account"))"Bank Account";
        }
    }
    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
