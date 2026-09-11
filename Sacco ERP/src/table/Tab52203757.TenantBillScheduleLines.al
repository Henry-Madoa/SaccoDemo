table 52203757 "Tenant Bill Schedule Lines"
{
    fields
    {
        field(1; "Schedule No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Schedule Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; "Tenant No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Cost Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Deposit,Water Deposit,Electricity Deposit,Other Deposit,Rent,Water,Electricity,Repairs,Other Expense';
            OptionMembers = " ", Deposit, "Water Deposit", "Electricity Deposit", "Other Deposit", Rent, Water, Electricity, Repairs, "Other Expense";
        }
        field(5; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(6; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Schedule No.", "Schedule Date", "Tenant No.", "Line No.")
        {
        }
    }
}
