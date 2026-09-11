xmlport 52203425 "Supplier Invoices"
{
    Direction = Import;
    Format = VariableText;

    schema
    {
    textelement(Root)
    {
    tableelement("Supplier Invoices";
    "Supplier Invoices")
    {
    XmlName = 'Invoices';

    fieldattribute(LineNo;
    "Supplier Invoices"."Line No.")
    {
    }
    fieldattribute(AccType;
    "Supplier Invoices"."Account Type")
    {
    }
    fieldattribute(AccNo;
    "Supplier Invoices"."Account No.")
    {
    }
    fieldattribute(Date;
    "Supplier Invoices"."Posting Date")
    {
    }
    fieldattribute(DocNo;
    "Supplier Invoices"."Document No.")
    {
    }
    fieldattribute(Desc;
    "Supplier Invoices".Description)
    {
    }
    fieldattribute(Amount;
    "Supplier Invoices".Amount)
    {
    }
    fieldattribute(BalAccType;
    "Supplier Invoices"."Bal. Account Type")
    {
    }
    fieldattribute(BalAccNo;
    "Supplier Invoices"."Bal. Account No.")
    {
    }
    }
    }
    }
}
