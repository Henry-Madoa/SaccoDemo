tableextension 52204017 "Payment Voucher" extends "Payment Voucher"
{
    fields
    {
        modify("Payment Type")
        {
            trigger OnAfterValidate()
            var
                PaymentMethod: Record "Payment Method";
                ChargesLines: Record "PV EFT Charges";
            begin
                if Rec."Payment Type" <> Rec."Payment Type"::"Member Payment" then "Member No" := '';
                if Rec."Payment Type" = Rec."Payment Type"::"EFT Loan Payment" then begin
                    PaymentMethod.Reset();
                    PaymentMethod.SetRange(Type, PaymentMethod.Type::EFT);
                    if PaymentMethod.FindFirst then "Pay Mode" := PaymentMethod.Code;
                end
                else begin
                    "Clearing Date" := 0D;
                    ChargesLines.Reset();
                    ChargesLines.SetRange("No.", Rec."No.");
                    ChargesLines.DeleteAll(true);
                end;
            end;
        }
        field(52204000; "Member No"; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            var
                PaymentVoucherLines: Record "Payment Voucher Lines";
            begin
                PaymentVoucherLines.Reset;
                PaymentVoucherLines.SetRange("No.", Rec."No.");
                if PaymentVoucherLines.FindSet then begin
                    repeat
                        PaymentVoucherLines.Validate("Member No.", "Member No");
                        PaymentVoucherLines.Modify(true);
                    until PaymentVoucherLines.Next = 0;
                end;
            end;
        }
        field(52204001; "EFT Charges"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("PV EFT Charges".Amount where("No." = field("No.")));
            Editable = false;
        }
        field(52204002; "Charge Code"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(52204003; "Available Balance"; Decimal)
        {
            CalcFormula = Sum("Payment Voucher Lines"."Available Balance" WHERE("No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }
}
