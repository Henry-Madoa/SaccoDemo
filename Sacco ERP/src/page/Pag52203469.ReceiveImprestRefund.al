page 52203469 "Receive Imprest Refund"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Request Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Surrender Date"; Rec."Surrender Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Net Refund (Net Claim)"; Rec."Net Refund (Net Claim)")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Receipt Mode"; Rec."Receipt Mode")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        if PaymentMethod.Get(Rec."Receipt Mode")then begin
                            if PaymentMethod.Type = PaymentMethod.Type::FOSA then FieldEditability:=false
                            else
                                FieldEditability:=true;
                        end;
                    end;
                }
                field("Receipt Tx No.(Cheque No.)"; Rec."Receipt Tx No.(Cheque No.)")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = FieldEditability;
                }
                field("Receiving Account"; Rec."Receiving Account")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = FieldEditability;
                }
            }
        }
    }
    trigger OnClosePage()
    begin
        if PaymentMethod.Get(Rec."Receipt Mode")then if PaymentMethod.Type <> PaymentMethod.Type::FOSA then Rec.Testfield("Receiving Account");
    end;
    var PaymentMethod: Record "Payment Method";
    FieldEditability: Boolean;
}
