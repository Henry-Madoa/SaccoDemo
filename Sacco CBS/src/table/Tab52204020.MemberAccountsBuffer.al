table 52204020 "Member Accounts Buffer"
{
    Caption = 'Member Accounts Buffer';
    DataClassification = ToBeClassified;

    fields
    {
        field(10; "Account No."; Code[100])
        {
            Caption = 'Account No.';
            DataClassification = ToBeClassified;
        }
        field(20; "Account Type"; Code[50])
        {
            Caption = 'Account Type';
            DataClassification = ToBeClassified;
        }
        field(30; "Account Name"; Code[50])
        {
            Caption = 'Account Name';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Account No.")
        {
            Clustered = true;
        }
    }
}
