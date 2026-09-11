table 52204095 "Bulk SMS Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; Message; Text[1000])
        {
        }
        field(3; "Created By"; Code[50])
        {
            TableRelation = "User Setup";
            Editable = false;
        }
        field(4; Sent; Boolean)
        {
            Editable = false;
        }
        field(5; "Created On"; DateTime)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    var
        NoSeries: Codeunit NoSeriesManagement;
        GeneralLedgerSetup: Record "General Ledger Setup";

    trigger OnInsert()
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Bulk SMS Nos.");
        if "No." = '' then "No." := NoSeries.GetNextNo(GeneralLedgerSetup."Bulk SMS Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;

    trigger OnDelete()
    begin
        TestField(Sent, false);
    end;
}
