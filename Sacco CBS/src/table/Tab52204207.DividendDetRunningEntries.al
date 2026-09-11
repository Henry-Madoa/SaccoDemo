table 52204207 "Dividend Det. Running Entries"
{
    LookupPageId = "Dividend Det. Running Entries";
    DrillDownPageId = "Dividend Det. Running Entries";

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Dividend Det. Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Dividend Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members;
        }
        field(5; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Int. Earned,Charges,Loan Principal,Share Boost,Loan Interest';
            OptionMembers = "Int. Earned",Charges,"Loan Principal","Share Boost","Loan Interest";
        }
        field(6; "Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor;
        }
        field(7; "Month Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Month No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(11; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Running Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Entry No", "Dividend Det. Entry No", "Dividend Code", "Member No.", "Entry Type", "Code", "Month Code")
        {
            Clustered = true;
        }
        key(Key2; "Entry No")
        {
        }
    }

    procedure GetLastEntryNo(): Integer
    var
        DividendDetRunningEntries: Record "Dividend Det. Running Entries";
    begin
        DividendDetRunningEntries.Reset();
        DividendDetRunningEntries.SetAscending("Entry No", false);
        if DividendDetRunningEntries.FindFirst then exit(DividendDetRunningEntries."Entry No");
    end;
}
