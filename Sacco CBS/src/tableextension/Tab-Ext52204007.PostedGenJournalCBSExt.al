tableextension 52204007 "Posted Gen. Journal CBS Ext." extends "Posted Gen. Journal Line"
{
    fields
    {
        field(52204000; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members;
            Editable = false;
        }
        field(52204001; "Transaction Type"; Enum "Sacco Transaction Type")
        {
            Editable = false;
        }
        field(52204002; "Product Posting Type"; Enum "Product Posting Type")
        {
            Editable = false;
        }
        field(52204003; "Loan No."; Code[20])
        {
            Editable = false;
        }
    }
}
