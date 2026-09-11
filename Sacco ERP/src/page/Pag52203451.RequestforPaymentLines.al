page 52203451 "Request for Payment Lines"
{
    PageType = ListPart;
    SourceTable = "Request for Payment Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Source Document"; Rec."Source Document")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Being Payment for"; Rec."Being Payment for")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("View Source Document")
            {
                ApplicationArea = Basic, Suite;
                Image = ViewDocumentLine;

                trigger OnAction()
                begin
                    if Rec."Source Document No." = '' then Error('There is no Source Document No. This is mandatory.')
                    else
                        Rec.ViewSourceDocument;
                end;
            }
        }
    }
}
