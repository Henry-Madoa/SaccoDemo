page 52203547 "Company Documents Card"
{
    Caption = 'Company Documents';
    PageType = Card;
    SourceTable = "Company Documents";

    layout
    {
        area(content)
        {
            group(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Name"; Rec."Document Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Visible To"; Rec."Visible To")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(50636), "No."=FIELD("No.");
            }
            systempart(Control7; Notes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
