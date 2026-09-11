page 52204024 "Member App Doc. Checklist"
{
    PageType = List;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Doc. Attachments Checklist";
    SourceTableView = where("Application Area" = const("Application Documents"));

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
        Rec."Application Area" := Rec."Application Area"::"Application Documents";
    end;

    trigger OnModifyRecord(): Boolean
    var
        MemberApplication: Record "Member Application";
    begin
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
    end;
}
