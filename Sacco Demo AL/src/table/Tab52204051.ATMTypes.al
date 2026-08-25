table 52204051 "ATM Types"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20])
        {
        }
        field(2; "Description"; Text[200])
        {
        }
        field(3; Type;Enum "ATM Types")
        {
        }
        field(4; "ATM Settlment Account"; Code[20])
        {
            TableRelation = "Bank Account";
        }
        field(5; "Application Charge"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(6; "Withdrawal (Coop)"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(7; "Withdrawal (VISA)"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(8; "Utility Payments"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(9; "Airtime Purchase"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(10; "POS School Payment"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(11; "POS Purchase (CBack)"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(12; "POS Cash Deposit"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(13; "POS Benefit Cash Withdrawal"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(14; "POS Card Deposit"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(15; "POS M Banking"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(16; "POS Cash Withdrawal"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(17; "POS Balance Enquiry"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(18; "POS Ministatement"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(19; "POS Purchase (Normal)"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(20; "POS Deposit T. Code (Normal)"; Code[20])
        {
            TableRelation = "Transaction Charges";
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
