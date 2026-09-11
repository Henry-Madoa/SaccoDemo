table 52204115 "STO Buffer"
{
    Caption = 'STO Buffer';
    DataClassification = ToBeClassified;

    fields
    {
        field(10; "Member No."; Code[20])
        {
            Caption = 'Member No.';
            DataClassification = ToBeClassified;
        }
        field(20; "STO No."; Code[20])
        {
            Caption = 'STO No.';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "STO No.")
        {
            Clustered = true;
        }
    }
}
