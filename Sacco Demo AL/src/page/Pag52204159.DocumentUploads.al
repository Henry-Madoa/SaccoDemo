page 52204159 "Document Uploads"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Document Uploads";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSOAP;
                }
                field("Parent Type"; Rec."Parent Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSOAP;
                }
                field("Parent No"; Rec."Parent No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSOAP;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSOAP;
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSOAP;
                }
                field(URL; Rec.URL)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSOAP;
                }
                field("Added By"; Rec."Added By")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSOAP;
                }
                field("Added On"; Rec."Added On")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSOAP;
                }
            }
        }
    }
    var
        isSOAP: Boolean;

    trigger OnOpenPage()
    begin
        isSOAP := (CurrentClientType <> ClientType::Web);
    end;
}
