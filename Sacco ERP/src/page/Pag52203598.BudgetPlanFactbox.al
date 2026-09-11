page 52203598 "Budget Plan Factbox"
{
    Caption = 'Budget Plan Line Details';
    PageType = CardPart;
    SourceTable = "Budget Plan Lines";
    Editable = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            field(Date; Rec.Date)
            {
                ApplicationArea = Basic, Suite;
            }
            field(Description; Rec.Description)
            {
                ApplicationArea = Basic, Suite;
            }
            field(Amount; Rec.Amount)
            {
                ApplicationArea = Basic, Suite;
            }
            group(Attachments)
            {
                Caption = 'Attachments';

                field("Attached Doc Count"; Rec."Attached Doc Count")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Documents';
                    ToolTip = 'Specifies the number of attachments.';

                    trigger OnDrillDown()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal;
                    end;
                }
            }
        }
    }
}
