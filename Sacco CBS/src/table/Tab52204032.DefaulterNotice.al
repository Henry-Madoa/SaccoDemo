table 52204032 "Defaulter Notice"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Defaulter Notices";
    DrillDownPageId = "Defaulter Notices";

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; "Notice Date"; Date)
        {
        }
        field(3; Processed; Boolean)
        {
            Editable = false;
        }
        field(4; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(5; "Created By"; Code[100])
        {
            Editable = false;
        }
        field(6; "First Notice Sent On"; DateTime)
        {
            Editable = false;
        }
        field(7; "Second Notice Sent On"; DateTime)
        {
            Editable = false;
        }
        field(8; "Third Notice Sent On"; DateTime)
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
        SaccoSetup: Record "General Ledger Setup";

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Defaulter Notice Nos");
        "No." := NoSeries.GetNextNo(SaccoSetup."Defaulter Notice Nos", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        "Notice Date" := Today;
    end;

    trigger OnModify()
    begin
        TestField(Processed, false);
    end;

    trigger OnDelete()
    var
        Lines: Record "Defaulter Notice Lines";
    begin
        TestField(Processed, false);
        Lines.Reset();
        Lines.SetRange("No.", "No.");
        Lines.DeleteAll;
    end;
}
