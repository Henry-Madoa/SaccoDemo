table 52203609 "Training Employee Costs"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Attendees Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Plan Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Plan No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Expense Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Expense Codes" where("Account Type"=const("G/L Account"));

            trigger OnValidate()
            begin
                if Expenses.Get("Expense Code")then Description:=Expenses.Description;
            end;
        }
        field(6; "Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Cost"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Line No", "Attendees Line No.", "Plan Line No.", "Plan No.")
        {
            Clustered = true;
        }
    }
    var Expenses: Record "Expense Codes";
}
