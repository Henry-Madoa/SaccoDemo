report 52203433 "Generate Purch. Inv Journal"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Generate Purch. Inv Journal.rdlc';

    dataset
    {
        dataitem("Receipts Tx"; "Supplier Invoices")
        {
            trigger OnAfterGetRecord()
            begin
                GenJnLine.Init;
                GenJnLine."Journal Template Name":='GENERAL';
                GenJnLine."Journal Batch Name":='TRANS-PI';
                GenJnLine."Line No.":="Receipts Tx"."Line No.";
                if "Receipts Tx"."Account Type" = 'Bank Account' then GenJnLine."Account Type":=GenJnLine."Account Type"::"Bank Account"
                else if "Receipts Tx"."Account Type" = 'Customer' then GenJnLine."Account Type":=GenJnLine."Account Type"::Customer
                    else if "Receipts Tx"."Account Type" = 'G/L Account' then GenJnLine."Account Type":=GenJnLine."Account Type"::"G/L Account"
                        else if "Receipts Tx"."Account Type" = 'Vendor' then GenJnLine."Account Type":=GenJnLine."Account Type"::Vendor;
                GenJnLine."Account No.":="Receipts Tx"."Account No.";
                GenJnLine."Posting Date":="Receipts Tx"."Posting Date";
                GenJnLine."Document No.":='PITX-' + Format("Receipts Tx"."Line No.");
                GenJnLine."External Document No.":="Receipts Tx"."Document No.";
                GenJnLine.Description:="Receipts Tx".Description;
                GenJnLine.Amount:="Receipts Tx".Amount;
                GenJnLine.Validate(GenJnLine.Amount);
                if "Receipts Tx"."Bal. Account Type" = 'Bank Account' then GenJnLine."Bal. Account Type":=GenJnLine."Bal. Account Type"::"Bank Account"
                else if "Receipts Tx"."Bal. Account Type" = 'Customer' then GenJnLine."Bal. Account Type":=GenJnLine."Bal. Account Type"::Customer
                    else if "Receipts Tx"."Bal. Account Type" = 'G/L Account' then GenJnLine."Bal. Account Type":=GenJnLine."Bal. Account Type"::"G/L Account"
                        else if "Receipts Tx"."Bal. Account Type" = 'Vendor' then GenJnLine."Bal. Account Type":=GenJnLine."Bal. Account Type"::Vendor;
                GenJnLine."Bal. Account No.":="Receipts Tx"."Bal. Account No.";
                if GenJnLine.Amount <> 0 then GenJnLine.Insert;
            end;
            trigger OnPreDataItem()
            begin
                // Delete Lines Present on the General Journal Line
                GenJnLine.Reset;
                GenJnLine.SetRange(GenJnLine."Journal Template Name", 'GENERAL');
                GenJnLine.SetRange(GenJnLine."Journal Batch Name", 'TRANS-PI');
                GenJnLine.DeleteAll;
                Batch.Init;
                Batch."Journal Template Name":='GENERAL';
                Batch.Name:='TRANS-PI';
                if not Batch.Get('GENERAL', 'TRANS-PI')then Batch.Insert;
                LineNo:=10000;
            end;
        }
    }
    var GenJnLine: Record "Gen. Journal Line";
    Batch: Record "Gen. Journal Batch";
    LineNo: Integer;
}
