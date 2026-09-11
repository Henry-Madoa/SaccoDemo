codeunit 52204029 "Custodial Management"
{
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        PostingDate: Date;
        PostingAmount: Decimal;
        DocumentNo: Code[20];
        Dim1: Code[20];
        Dim2: Code[20];
        LineNo: Integer;
        JournalBatch: Code[20];
        JournalTemplate: Code[20];
        JournalManagement: Codeunit "Journal Management";

    [Scope('Cloud')]
    procedure CreateCustodialSchedule(CustodialHeader: Record "Custodial Header"; Recompute: Boolean; ShowMessage: Boolean)
    var
        CustodialServicesEntries: Record "Custodial Services Entries";
        CustodiaServiceTypes: Record "Custodia Service Types";
        Date1: Date;
        EDDate: Date;
    begin
        if ShowMessage then if not Confirm('You are about to Create Custodial Schedule, Do you wish to continue') then exit;
        CustodialServicesEntries.RESET;
        CustodialServicesEntries.SETRANGE("Custodial No.", CustodialHeader."No.");
        if CustodialServicesEntries.FINDFIRST then CustodialServicesEntries.DELETEALL;
        CustodiaServiceTypes.GET(CustodialHeader."Service Type");
        Date1 := CustodialHeader."Posting Date";
        if not Recompute then
            EDDate := CustodialHeader."Expected Collection Date"
        else
            EDDate := TODAY;
        repeat
            CustodialServicesEntries.INIT;
            CustodialServicesEntries."Custodial No." := CustodialHeader."No.";
            CustodialServicesEntries."Document No." := FORMAT(Date1);
            CustodialServicesEntries."Posting Date" := Date1;
            CustodialServicesEntries.Description := 'Service Charge as At ' + FORMAT(Date1);
            if Date1 >= CustodialHeader."Payment Start Date" then CustodialServicesEntries.Amount := CustodiaServiceTypes.Amount;
            CustodialServicesEntries."Entry Type" := CustodialServicesEntries."Entry Type"::Billable;
            CustodialServicesEntries.INSERT;
            Date1 := CALCDATE(CustodiaServiceTypes."Charge Frequency", Date1);
        until Date1 >= EDDate;
        if ShowMessage then Message('Schedule Created.');
    end;

    [Scope('Cloud')]
    procedure PostCustodialReceipt(CustodialHeader: Record "Custodial Header")
    var
        CustodiaServiceTypes: Record "Custodia Service Types";
    begin
        CustodialHeader.TESTFIELD("Payment Refrence");
        CustodialHeader.CALCFIELDS("Amount Expected");
        CustodialHeader.TESTFIELD("Amount Expected", CustodialHeader."Amount Paid");
        CustodiaServiceTypes.GET(CustodialHeader."Service Type");
        PostingDate := CustodialHeader."Payment Date";
        PostingAmount := CustodialHeader."Amount Paid";
        DocumentNo := CustodialHeader."No.";
        Dim1 := CustodialHeader."Global Dimension 1 Code";
        Dim2 := CustodialHeader."Global Dimension 2 Code";
        JournalBatch := 'INV-CUS';
        JournalTemplate := 'PAYMENT';
        PostingDate := TODAY;
        LineNo := 1000;
        if not GenJournalBatch.GET(JournalTemplate, JournalBatch) then begin
            GenJournalBatch.INIT;
            GenJournalBatch."Journal Template Name" := JournalTemplate;
            GenJournalBatch.Name := JournalBatch;
            GenJournalBatch.Description := 'Custodial Service Payments';
            GenJournalBatch.INSERT;
        end;
        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", JournalTemplate);
        GenJournalLine.SETRANGE("Journal Batch Name", JournalBatch);
        if GenJournalLine.FINDFIRST then GenJournalLine.DELETEALL;
        LineNo := 1000;
        GenJournalLine.INIT;
        GenJournalLine."Journal Template Name" := JournalTemplate;
        GenJournalLine."Journal Batch Name" := JournalBatch;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Posting Date" := PostingDate;
        LineNo += 1000;
        if CustodialHeader."Source Type" = CustodialHeader."Source Type"::"Bank Account" then
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account"
        else
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
        GenJournalLine.VALIDATE("Account No.", CustodialHeader."Source Account No");
        GenJournalLine."Debit Amount" := ABS(PostingAmount);
        GenJournalLine.VALIDATE("Debit Amount");
        GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::General;
        GenJournalLine."Message to Recipient" := 'Payments for Custodial Services ';
        GenJournalLine.Description := 'Payments for Custodial Services ';
        GenJournalLine."Due Date" := CALCDATE('1M', PostingDate);
        GenJournalLine."Reason Code" := 'CUSTD';
        GenJournalLine."Source Code" := 'CUSTD';
        GenJournalLine."Payer Information" := 'CUSTD';
        GenJournalLine."External Document No." := CustodialHeader."No.";
        GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
        GenJournalLine.VALIDATE("Bal. Account No.", CustodiaServiceTypes."Income Account");
        GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", Dim1);
        GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", Dim2);
        if GenJournalLine.Amount <> 0 then GenJournalLine.INSERT;
        COMMIT;
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        CustodialHeader."Payment Posted" := true;
        CustodialHeader."Document Status" := CustodialHeader."Document Status"::Released;
        CustodialHeader.MODIFY;
    end;
}
