xmlport 52203426 "TMF Payments"
{
    Direction = Import;
    Format = VariableText;

    schema
    {
    textelement(Root)
    {
    tableelement("Gen. Journal Line";
    "Gen. Journal Line")
    {
    XmlName = 'GL';

    fieldelement(Template;
    "Gen. Journal Line"."Journal Template Name")
    {
    }
    fieldelement(Batch;
    "Gen. Journal Line"."Journal Batch Name")
    {
    }
    fieldelement(LineNo;
    "Gen. Journal Line"."Line No.")
    {
    }
    fieldelement(AccountType;
    "Gen. Journal Line"."Account Type")
    {
    }
    fieldelement(AccountNo;
    "Gen. Journal Line"."Account No.")
    {
    }
    fieldelement(PostingDate;
    "Gen. Journal Line"."Posting Date")
    {
    }
    fieldelement(DocNo;
    "Gen. Journal Line"."Document No.")
    {
    }
    fieldelement(Desc;
    "Gen. Journal Line".Description)
    {
    }
    fieldelement(BalAccNo;
    "Gen. Journal Line"."Bal. Account No.")
    {
    }
    fieldelement(Currency;
    "Gen. Journal Line"."Currency Code")
    {
    }
    fieldelement(Amount;
    "Gen. Journal Line".Amount)
    {
    }
    fieldelement(BalAccType;
    "Gen. Journal Line"."Bal. Account Type")
    {
    }
    fieldelement(ExtDocNo;
    "Gen. Journal Line"."External Document No.")
    {
    }
    }
    }
    }
}
