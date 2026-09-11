table 52203697 "Requisition Services"
{
    DrillDownPageID = "Requisition Services";
    LookupPageID = "Requisition Services";

    fields
    {
        field(1; Service; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Account No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." WHERE("Account Type"=CONST(Posting), "Income/Balance"=CONST("Income Statement"));

            trigger OnValidate()
            begin
                if GLAccount.Get("Account No")then "Account Name":=GLAccount.Name;
            end;
        }
        field(3; "Account Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Unit of Measure"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Unit of Measure";
        }
        field(5; "Service Category"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Requisition Item Categories".Category;
        }
    }
    keys
    {
        key(Key1; Service)
        {
        }
    }
    var GLAccount: Record "G/L Account";
}
