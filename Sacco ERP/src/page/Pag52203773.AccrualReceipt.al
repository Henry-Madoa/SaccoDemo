page 52203773 "Accrual Receipt"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Fixed Deposit Schedule";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = false;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Entry Type"; Rec."Entry Type")
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
            }
            group(Actuals)
            {
                Editable = IsEditable;

                field("Actual Amount"; Rec."Actual Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Witholding Tax"; Rec."Witholding Tax")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Actual Posting Date"; Rec."Actual Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        IsEditable:=(not Rec.Posted);
    end;
    var IsEditable: Boolean;
}
