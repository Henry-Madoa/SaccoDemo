xmlport 52203424 "Import Receipts"
{
    Direction = Import;
    Format = VariableText;

    schema
    {
    textelement(Root)
    {
    tableelement("Receipts Tx";
    "Receipts Tx")
    {
    XmlName = 'Receipts';

    fieldattribute(LineNo;
    "Receipts Tx"."Line No")
    {
    }
    fieldattribute(AccType;
    "Receipts Tx"."Account Type")
    {
    }
    fieldattribute(AccNo;
    "Receipts Tx"."Account No.")
    {
    }
    fieldattribute(Date;
    "Receipts Tx"."Posting Date")
    {
    }
    fieldattribute(DocNo;
    "Receipts Tx"."Document No.")
    {
    }
    fieldattribute(Desc;
    "Receipts Tx".Description)
    {
    }
    fieldattribute(Amount;
    "Receipts Tx".Amount)
    {
    }
    fieldattribute(BalAccType;
    "Receipts Tx"."Bal Account Type")
    {
    }
    fieldattribute(BalAccNo;
    "Receipts Tx"."Bal. Account No.")
    {
    }
    }
    }
    }
}
