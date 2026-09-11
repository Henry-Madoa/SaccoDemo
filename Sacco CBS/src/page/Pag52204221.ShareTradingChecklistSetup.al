page 52204221 "Share Trading Checklist Setup"
{
    PageType = List;
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
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Mandatory; Rec.Mandatory)
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
}
