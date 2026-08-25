table 52204081 "Loan Batch Header"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Loan Batches";
    DrillDownPageId = "Loan Batches";

    fields
    {
        field(1; "No."; code[20])
        {
            editable = false;
        }
        field(2; "Posting Date"; Date)
        {
        }
        field(3; "Description"; Text[50])
        {
        }
        field(4; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(5; Posted; Boolean)
        {
            Editable = false;
        }
        field(6; "Posted On"; DateTime)
        {
            Editable = false;
        }
        field(7; "Posted By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(8; "Created By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(9; "Created On"; DateTime)
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
        NoSeries: codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";

    trigger OnInsert()
    begin
        SaccoSetup.get;
        SaccoSetup.TestField("Loan Batch Nos");
        "No." := NoSeries.GetNextNo(SaccoSetup."Loan Batch Nos", Today, true);
        "Posting Date" := WorkDate;
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        Description := 'Loan Posting batch ' + "No.";
    end;

    trigger OnDelete()
    var
        LoanBatchLines: Record "Loan Batch Lines";
    begin
        TestField(Status, Status::Open);
        LoanBatchLines.Reset();
        LoanBatchLines.SetRange("No.", "No.");
        LoanBatchLines.DeleteAll(true);
    end;

    trigger OnRename()
    begin
        TestField(Status, Status::Open);
    end;
}
