table 52203491 "Payroll FMS Data"
{
    fields
    {
        field(1; "Journal Template Name"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Journal Batch Name"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
            OptionMembers = " ", Payment, Invoice, "Credit Memo", "Finance Charge Memo", Reminder, Refund;
        }
        field(5; "Document Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Account Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'G/L Account,Customer,Vendor,Bank Account,Fixed Asset,IC Partner,Employee';
            OptionMembers = "G/L Account", Customer, Vendor, "Bank Account", "Fixed Asset", "IC Partner", Employee;
        }
        field(7; "Account Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Fund code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Speed Key Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Activity Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Line Item code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Location code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(13; PIBUDHLD; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Payroll Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(15; RESTRICTIONS; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(16; SUBAWARD; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(17; Blank; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "External Document Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(19; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(20; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Budget Plan Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Currency Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Allocation No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Balancing Account Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'G/L Account,Customer,Vendor,Bank Account,Fixed Asset,IC Partner,Employee';
            OptionMembers = "G/L Account", Customer, Vendor, "Bank Account", "Fixed Asset", "IC Partner", Employee;
        }
        field(25; "Balancing Account Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Applies To Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
            OptionMembers = " ", Payment, Invoice, "Credit Memo", "Finance Charge Memo", Reminder, Refund;
        }
        field(27; "Applies To Document Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Amount Local currency"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Currency Factor"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Nature of transaction"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Inserted On"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(33; Sent; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(34; "Sent On"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Journal Template Name")
        {
        }
    }
}
