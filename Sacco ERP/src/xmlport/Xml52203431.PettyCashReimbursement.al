xmlport 52203431 "Petty Cash Reimbursement"
{
    Direction = Import;
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
    textelement(RootNodeName)
    {
    tableelement("Payment Schedule";
    "Payment Schedule")
    {
    XmlName = 'PettyCashReimbursement';

    fieldattribute(PettyCashAccount;
    "Payment Schedule"."Petty Cash Account")
    {
    }
    fieldattribute(Amount;
    "Payment Schedule".Amount)
    {
    }
    trigger OnBeforeInsertRecord()
    begin
        if "Payment Schedule"."Petty Cash Account" = '' then currXMLport.Skip();
        "Payment Schedule".Validate("PV No.", PVHeader."No.");
    end;
    trigger OnAfterInsertRecord()
    begin
        "Payment Schedule".Validate(Amount);
        "Payment Schedule".Validate("Line No");
    end;
    }
    }
    }
    trigger OnPostXmlPort()
    begin
        Message('Import Completed.');
    end;
    trigger OnPreXmlPort()
    begin
        PaymentSchedule.Reset;
        PaymentSchedule.SetRange("PV No.", PVHeader."No.");
        PaymentSchedule.DeleteAll(true);
    end;
    procedure GetHeader(PvNo: Code[20])
    begin
        PVHeader.Get(PvNo);
    end;
    var PVHeader: Record "Payment Voucher";
    PaymentSchedule: Record "Payment Schedule";
}
