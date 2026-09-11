table 52203536 "Purchaser Response"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Accept,Reject,Return';
            OptionMembers = , Accept, Reject, Return;
        }
        field(3; "Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,None';
            OptionMembers = Quote, "Order", Invoice, "Credit Memo", "Blanket Order", "Return Order", "None";
        }
        field(4; "Accept Note"; text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Reject Note"; text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Return Note"; text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
    trigger OnRename()
    begin
    end;
}
