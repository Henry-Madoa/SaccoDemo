page 52204137 "Channel Guarantor Sub."
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Channel Guarantor Sub.";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoap;
                }
                field("Guarantor No"; Rec."Guarantor No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoap;
                }
                field("Replace With"; Rec."Replace With")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoap;
                }
                field("Replace With Name"; Rec."Replace With Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoap;
                }
                field("Loan Balance"; Rec."Loan Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoap;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoap;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoap;
                }
                field("Accepted Amount"; Rec."Accepted Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoap;
                }
                field("Requested On"; Rec."Requested On")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoap;
                }
                field("Responded On"; Rec."Responded On")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isSoap;
                }
                field("Outstanding Guarantee"; Rec."Outstanding Guarantee")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    var
        isSoap: Boolean;

    trigger OnOpenPage()
    begin
        isSoap := NOT GuiAllowed;
    end;
}
