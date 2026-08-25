page 52204222 "Share Trading Checklist"
{
    PageType = List;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Doc. Attachments Checklist";
    SourceTableView = where("Application Area" = const("Share Transfer"));

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Provided; Rec.Provided)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Received On"; Rec."Received On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Received By"; Rec."Received By")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Application Area" := Rec."Application Area"::"Share Transfer";
    end;

    trigger OnModifyRecord(): Boolean
    var
        ShareFloating: Record "Share Floating";
    begin
        if ShareFloating.Get(Rec."Source Code") then ShareFloating.TestField(Status, ShareFloating.Status::Open);
    end;
}
