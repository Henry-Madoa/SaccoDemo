table 52203720 "Temporary Rights Assignment"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "User ID"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Permission Set"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Reason For Assignment"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Assigned; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; Expired; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Date Assigned"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Assigned By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "No. Series"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Month name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            GeneralLedgerSetup.Get;
            GeneralLedgerSetup.TestField("Temporary Rights Nos.");
            NoSeriesManagement.InitSeries(GeneralLedgerSetup."Temporary Rights Nos.", "No. Series", 0D, "No.", "No. Series");
        end;
        "Created By":=UserId;
        "Created On":=WorkDate;
        Validate("Created On");
    end;
    var GeneralLedgerSetup: Record "General Ledger Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    SystemDate: Record Date;
}
