table 52204030 "Product Interest Bands"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Loan Interest Bands";
    DrillDownPageId = "Loan Interest Bands";

    fields
    {
        field(1; "Source Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(3; "Min Installments"; Integer)
        {
            trigger OnValidate()
            begin
                if "Max Installments" < "Min Installments" then Error('Maximum Installments Cannot be less than Minimum Installments');
            end;
        }
        field(4; "Max Installments"; Integer)
        {
            trigger OnValidate()
            begin
                if "Max Installments" < "Min Installments" then Error('Maximum Installments Cannot be less than Minimum Installments');
            end;
        }
        field(5; "Interest Rate"; Decimal)
        {
        }
        field(6; Active; Boolean)
        {
            trigger OnValidate()
            begin
                //Rec.Testfield("Interest Rate");
                if "Max Installments" < "Min Installments" then
                    Error('Maximum Installments Cannot be less than Minimum Installments');
            end;
        }
        field(7; "Processing Fee"; Decimal)
        {
            MinValue = 0;
            MaxValue = 100;
        }
        field(8; "Post to Account Type"; Option)
        {
            OptionMembers = " ","G/L Account","Liability Account";
        }
        field(9; "Post-to Account No."; Code[20])
        {
            TableRelation = if ("Post to Account Type" = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true), "Account Type" = const(Posting))
            else if ("Post to Account Type" = const("Liability Account")) Vendor where("Account Type" = filter(<> Sacco));
        }
        field(10; "Excise Duty Rate"; Decimal)
        {
            MinValue = 0;
            MaxValue = 100;
        }
        field(11; "Excise Duty Account Type"; Option)
        {
            OptionMembers = " ","G/L Account","Liability Account";
        }
        field(12; "Excise Duty Account No."; Code[20])
        {
            TableRelation = if ("Excise Duty Account Type" = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true))
            else if ("Excise Duty Account Type" = const("Liability Account")) Vendor where("Account Type" = filter(<> Sacco));
        }
    }
    keys
    {
        key(PK; "Source Code", "Entry No.")
        {
            Clustered = true;
        }
    }
}
