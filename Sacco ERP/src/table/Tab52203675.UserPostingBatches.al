table 52203675 "User Posting Batches"
{
    fields
    {
        field(1; User; Code[70])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup"."User ID";
        }
        field(2; "General Jounral"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Template".Name WHERE(Type=CONST(General));
        }
        field(3; "General Journal Batch"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name"=FIELD("General Jounral"));
        }
        field(4; "Payment Jurnal"; Code[100])
        {
            Caption = 'Payment Journal';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Template".Name WHERE(Type=CONST(Payments));
        }
        field(5; "Payment Journal Batch"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name"=FIELD("Payment Jurnal"));
        }
        field(6; "Receipt Journal"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Template".Name WHERE(Type=CONST(General));
        }
        field(7; "Receipt Journal Batch"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name"=FIELD("Receipt Journal"));
        }
        field(8; "Item Journal"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Journal Template".Name WHERE(Type=CONST(Item));
        }
        field(9; "Item Journal Batch"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name"=FIELD("Item Journal"));
        }
        field(10; "Transfer Journal"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Journal Template".Name WHERE(Type=CONST(Transfer));
        }
        field(11; "Transfer Journal Batch"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name"=FIELD("Item Journal"));
        }
    }
    keys
    {
        key(Key1; User)
        {
        }
    }
}
