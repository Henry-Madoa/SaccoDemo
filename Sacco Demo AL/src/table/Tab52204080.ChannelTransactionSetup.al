table 52204080 "Channel Transaction Setup"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Channel Transaction Setup";
    LookupPageId = "Channel Transaction Setup";

    fields
    {
        field(1; Code; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[100])
        {
        }
        field(3; "SMS Notification"; Text[20])
        {
        }
        field(4; "Posting Type"; Option)
        {
            OptionMembers = Debit,Credit,Reversal;
        }
        field(5; "Charge Code"; code[20])
        {
            TableRelation = "Transaction Charges";

            trigger OnValidate()
            var
                TransactionCharges: Record "Transaction Charges";
            begin
                if TransactionCharges.Get("Charge Code") then "Charge Description" := TransactionCharges.Description;
            end;
        }
        field(6; "Charge Description"; Text[80])
        {
            Editable = false;
        }
        field(7; "Balancing Account No"; Code[20])
        {
            TableRelation = "Bank Account";
        }
        field(8; "Minimum Amount"; Decimal)
        {
        }
        field(9; "Maximum Amount"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}
