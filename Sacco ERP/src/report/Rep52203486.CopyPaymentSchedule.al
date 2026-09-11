report 52203486 "Copy Payment Schedule"
{
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field("Payment Type"; PaymentType)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                    }
                    field(PVNo; PVNo)
                    {
                        Caption = 'Payment Voucher No.';
                        TableRelation = "Payment Voucher" where("Payment Type"=filter("Petty Cash Topup"|"Staff Bulk Payment"|"Board Allowances"), Posted=const(true));
                        ApplicationArea = Basic, Suite;

                        trigger OnValidate()
                        begin
                            If PVHeader[3].Get(PVNo)then begin
                                if PVHeader[3]."Payment Type" <> PVHeader[1]."Payment Type" then Error('You have selected a Payment Voucher of Type %1, Please select a Payment Voucher of Type %2', Format(PVHeader[3]."Payment Type"), Format(PVHeader[1]."Payment Type"));
                            end;
                        end;
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        CreatePaymentShedule(PVHeader[1], PVLines[1], PVNo);
    end;
    trigger OnPostReport()
    begin
        Message('Complete');
    end;
    procedure PettyCashVariableSetting(PV_Header: Record "Payment Voucher")
    begin
        PVHeader[1]:=PV_Header;
        PaymentType:=PV_Header."Payment Type";
    end;
    procedure BoardStaffAllowanceVariableSetting(PVLine: Record "Payment Voucher Lines")
    begin
        if PVHeader[2].Get(PVLine."No.")then PVHeader[1]:=PVHeader[2];
        PVLines[1]:=PVLine;
        PaymentType:=PVLine."Payment Type";
    end;
    local procedure CreatePaymentShedule(PaymentHeader: Record "Payment Voucher"; PVLine: Record "Payment Voucher Lines"; CopyFromNo: Code[20])
    var
        PaymentSchedule: array[3]of Record "Payment Schedule";
    begin
        PaymentSchedule[1].Reset;
        PaymentSchedule[1].SetRange("PV No.", PaymentHeader."No.");
        PaymentSchedule[1].DeleteAll(true);
        PaymentSchedule[2].Reset;
        PaymentSchedule[2].SetRange("PV No.", CopyFromNo);
        if PaymentSchedule[2].FindSet()then begin
            repeat PaymentSchedule[3].Init;
                PaymentSchedule[3].TransferFields(PaymentSchedule[2]);
                PaymentSchedule[3]."PV No.":=PaymentHeader."No.";
                if PaymentHeader."Payment Type" in[PaymentHeader."Payment Type"::"Board Allowances", PaymentHeader."Payment Type"::"Staff Bulk Payment"]then PaymentSchedule[3]."PV Line No.":=PVLine."Line No";
                PaymentSchedule[3].Insert(true);
            until PaymentSchedule[2].Next = 0;
        end;
    end;
    var PVNo: Code[20];
    PVHeader: array[3]of Record "Payment Voucher";
    PVLines: array[2]of Record "Payment Voucher Lines";
    PaymentType: Enum "Payment Types";
}
