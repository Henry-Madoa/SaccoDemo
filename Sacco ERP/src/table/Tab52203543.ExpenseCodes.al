table 52203543 "Expense Codes"
{
    DrillDownPageID = "Expense Codes";
    LookupPageID = "Expense Codes";

    fields
    {
        field(1; "Code"; Code[50])
        {
        }
        field(2; Description; Text[50])
        {
        }
        field(3; "Account Type";Enum "Expense Types")
        {
        }
        field(4; "Account No"; Code[20])
        {
            TableRelation = IF("Account Type"=CONST("G/L Account"))"G/L Account" WHERE("Account Type"=CONST(Posting), Blocked=CONST(false), "Direct Posting"=const(true), "Account Category"=filter(Assets|Liabilities|Expense))
            ELSE IF("Account Type"=CONST(Item))Item
            ELSE IF("Account Type"=CONST("Fixed Asset"))"Fixed Asset"
            ELSE IF("Account Type"=CONST(Vendor))Vendor
            ELSE IF("Account Type"=CONST(Customer))Customer;

            trigger OnValidate()
            begin
                if "Account Type" = "Account Type"::"G/L Account" then if GLAcc.Get("Account No")then "Account Name":=GLAcc.Name;
                if "Account Type" = "Account Type"::Item then if Item.Get("Account No")then "Account Name":=Item.Description;
                if "Account Type" = "Account Type"::"Fixed Asset" then if FA.Get("Account No")then "Account Name":=FA.Description;
                if "Account Type" = "Account Type"::Vendor then if Ven.Get("Account No")then "Account Name":=Ven.Name;
                if "Account Type" = "Account Type"::Customer then if Cust.Get("Account No")then "Account Name":=Cust.Name;
            end;
        }
        field(5; "Account Name"; Text[50])
        {
        }
    }
    keys
    {
        key(Key1; "Code")
        {
        }
    }
    var GLAcc: Record "G/L Account";
    Ven: Record Vendor;
    Cust: Record Customer;
    Item: Record Item;
    FA: Record "Fixed Asset";
}
