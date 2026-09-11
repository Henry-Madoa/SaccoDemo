page 52203473 "Pay Imprest Claim"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Request Header";

    layout
    {
        area(content)
        {
            group("Receive Imprest Refund")
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
                field("Claim Pay Mode"; Rec."Claim Pay Mode")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        if PaymentMethod.Get(Rec."Claim Pay Mode")then begin
                            if PaymentMethod.Type = PaymentMethod.Type::FOSA then FieldEditability:=false
                            else
                                FieldEditability:=true;
                        end;
                    end;
                }
                field("Claim Payment Tx No"; Rec."Claim Payment Tx No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = FieldEditability;
                }
                field("Claim Paying Account"; Rec."Claim Paying Account")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = FieldEditability;
                }
            }
        }
    }
    trigger OnClosePage()
    begin
        if PaymentMethod.Get(Rec."Claim Pay Mode")then if PaymentMethod.Type <> PaymentMethod.Type::FOSA then Rec.Testfield("Claim Paying Account");
    end;
    var PaymentMethod: Record "Payment Method";
    FieldEditability: Boolean;
}
