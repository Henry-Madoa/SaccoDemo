table 52204042 "Teller Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup";
        }
        field(2; "Setup Type"; Option)
        {
            OptionMembers = Teller, Treasury;
        }
        field(3; "Account Code"; Code[20])
        {
            TableRelation = if("Setup Type"=const(Teller))"Bank Account" where("Account Type"=const(Teller))
            else if("Setup Type"=const(Treasury))"Bank Account" where("Account Type"=const(Treasury));
        }
        field(4; "Maximum Capacity"; Decimal)
        {
        }
        field(5; "Minimum Capacity"; Decimal)
        {
        }
        field(6; "Journal Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(7; "Journal Bacth"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name"=field("Journal Template"));
        }
        field(8; "Approval Limit"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "User ID", "Setup Type")
        {
            Clustered = true;
        }
    }
}
