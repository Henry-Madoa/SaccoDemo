page 52203549 "Supplier Selection for PO"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Requisition Header";

    layout
    {
        area(content)
        {
            group(Group)
            {
                field("Requisition Type"; Rec."Requisition Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Requested By';
                    Editable = false;
                }
                field(Reason; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Supplier No"; Rec."Supplier No")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
