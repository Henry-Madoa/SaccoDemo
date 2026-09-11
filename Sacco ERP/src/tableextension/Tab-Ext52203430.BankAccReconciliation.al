tableextension 52203430 "Bank Acc. Reconciliation" extends "Bank Acc. Reconciliation"
{
    fields
    {
        // Add changes to table fields here
        field(481; "Created By"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup";
        }
        field(482; "Created On"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(483; "Action ID"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup";
        }
        field(484; Status; Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(485; "Approval Loop"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(486; "Current Level"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(487; Printed; Boolean)
        {
            FieldClass = FlowFilter;
        }
        field(488; "No. Series"; Code[20])
        {
        }
        field(489; "Reconciliation No."; Code[20])
        {
        }
    }
    var
        GLSetup: Record "General Ledger Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnAfterInsert()
    begin
        GLSetup.Get();
        GLSetup.TestField(GLSetup."Reconsiliation Nos.");
        if "Reconciliation No." = '' then NoSeriesMgt.InitSeries(GLSetup."Reconsiliation Nos.", xRec."No. Series", 0D, "Reconciliation No.", "No. Series");
    end;
}
