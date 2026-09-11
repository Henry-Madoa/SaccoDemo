page 52203426 "Payment Req Review"
{
    PageType = Card;
    SourceTable = "Purch. Inv. Header";
    DeleteAllowed = false;
    InsertAllowed = false;
    Permissions = tabledata "Purch. Inv. Header"=rm;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = true;

                field(Decision; Rec.Decision)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                    ShowMandatory = true;
                }
                field(Target; Rec.Target)
                {
                    Editable = Rec.Decision = Rec.Decision::"Append";
                    ApplicationArea = Basic, Suite;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Amount Remaining To Request"; Rec."Amount Remaining To Request")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount To Request"; Rec."Amount To Request")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Editable = true;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Execute)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                Image = ExecuteAndPostBatch;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Enabled = Rec."Payment Requested" = false;
                Visible = Rec."Payment Requested" = false;

                trigger OnAction();
                begin
                    PaymentMngt.ExecutePaymentRequestReview(false, '');
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        if((Rec."Amount Remaining To Request" = 0) and (Rec."Payment Requested" = false))then begin
            Rec.CalcFields("Remaining Amount");
            Rec."Amount Remaining To Request":=Rec."Remaining Amount";
        end;
    end;
    var PaymentMngt: Codeunit "Payment Management";
    Emp: Record Employee;
}
