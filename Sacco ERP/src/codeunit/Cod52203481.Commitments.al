codeunit 52203481 "Commitments"
{
    procedure "Process Commitment Entry"("No.": Code[20]; Entry_type: Code[20])
    var
        CommitmentEntries: Record "Commitment Entries";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ImprestHeader: Record "Request Header";
        ImprestDetails: Record "Request Lines";
        lineno: Integer;
        CommitAmount: Decimal;
    begin
        if Entry_type = 'ITO' then begin
            if ImprestHeader.Get("No.")then begin
                ImprestDetails.Reset;
                ImprestDetails.SetRange("No.", ImprestHeader."No.");
                ImprestDetails.SetRange(Commited, false);
                if ImprestDetails.FindSet then repeat begin
                        lineno:=lineno + 1000;
                        CommitmentEntries.Init;
                        CommitmentEntries."No.":=ImprestDetails."No.";
                        CommitmentEntries."Line No.":=lineno;
                        CommitmentEntries."Document No":=ImprestHeader."No.";
                        CommitmentEntries."Commitment No":=ImprestHeader."No.";
                        CommitmentEntries.Description:=ImprestDetails.Narration;
                        CommitmentEntries."Commitment Type":=CommitmentEntries."Commitment Type"::Imprest;
                        CommitmentEntries."Account Type":=CommitmentEntries."Account Type"::"G/L Account";
                        CommitmentEntries.Validate("Account Type");
                        CommitmentEntries."Account No.":=ImprestDetails."Account No";
                        CommitmentEntries.Validate("Account No.");
                        CommitmentEntries."Account Name":=ImprestDetails."Account Name";
                        CommitmentEntries."Committed Amount":=ImprestDetails."Request Amount";
                        CommitmentEntries."Global Dimension 1":=ImprestDetails."Global Dimension 1 Code";
                        CommitmentEntries."Global Dimension 2":=ImprestDetails."Global Dimension 2 Code";
                        CommitmentEntries.Paid:=false;
                        CommitmentEntries.Insert(true);
                    end;
                        ImprestDetails.Commited:=true;
                        ImprestDetails.Modify(true);
                    until ImprestDetails.Next = 0;
                ImprestHeader.Committed:=true;
                ImprestHeader.Modify;
            end;
        end
        else if Entry_type = 'MYLPO' then begin
                PurchaseHeader.Reset;
                PurchaseHeader.SetRange("No.", "No.");
                if PurchaseHeader.FindFirst then begin
                    CommitAmount:=0;
                    PurchaseLine.Reset;
                    PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                    if PurchaseLine.FindSet then begin
                        PurchaseLine.CalcSums("Amount Including VAT");
                        CommitAmount:=PurchaseLine."Amount Including VAT";
                    end;
                    lineno:=lineno + 1000;
                    CommitmentEntries.Init;
                    CommitmentEntries."No.":=PurchaseHeader."No.";
                    CommitmentEntries."Document No":=PurchaseHeader."No.";
                    CommitmentEntries."Commitment No":=PurchaseHeader."No.";
                    CommitmentEntries."Commitment Type":=CommitmentEntries."Commitment Type"::LPO;
                    CommitmentEntries."Account Type":=CommitmentEntries."Account Type"::Vendor;
                    CommitmentEntries.Description:=PurchaseHeader."Posting Description";
                    CommitmentEntries.Validate("Account Type");
                    CommitmentEntries."Account No.":=PurchaseHeader."Buy-from Vendor No.";
                    CommitmentEntries.Validate("Account No.");
                    CommitmentEntries."Account Name":=PurchaseHeader."Buy-from Vendor Name";
                    CommitmentEntries."Committed Amount":=CommitAmount;
                    CommitmentEntries.Validate("Committed Amount");
                    CommitmentEntries."Global Dimension 1":=PurchaseHeader."Shortcut Dimension 1 Code";
                    CommitmentEntries."Global Dimension 2":=PurchaseHeader."Shortcut Dimension 2 Code";
                    CommitmentEntries.Paid:=false;
                    CommitmentEntries.Insert(true);
                    PurchaseHeader.Committed:=true;
                    PurchaseHeader.Modify(true);
                end;
            end
            else
            begin
                exit;
            end;
    end;
    procedure "Process UnCommitment Entry"("No.": Code[20]; Entry_type: Code[20]; LPO: Code[20])
    var
        CommitmentEntries: Record "Commitment Entries";
        ImprestHeader: Record "Request Header";
        ImprestDetails: Record "Request Lines";
        lineno: Integer;
        PVHeader: Record "Payment Voucher";
        PVLines: Record "Payment Voucher Lines";
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
    begin
        if Entry_type = 'ITO' then begin
            if ImprestHeader.Get("No.")then begin
                ImprestDetails.Reset;
                ImprestDetails.SetRange("No.", ImprestHeader."No.");
                ImprestDetails.SetRange(Commited, true);
                if ImprestDetails.FindSet then repeat begin
                        lineno:=lineno + 1000;
                        CommitmentEntries.Init;
                        CommitmentEntries."No.":=ImprestDetails."No.";
                        CommitmentEntries."Line No.":=lineno;
                        CommitmentEntries."Document No":=ImprestHeader."No.";
                        CommitmentEntries."Commitment No":=ImprestHeader."No.";
                        CommitmentEntries.Description:=ImprestDetails.Narration;
                        CommitmentEntries."Commitment Type":=CommitmentEntries."Commitment Type"::Imprest;
                        CommitmentEntries."Account Type":=CommitmentEntries."Account Type"::"G/L Account";
                        CommitmentEntries.Validate("Account Type");
                        CommitmentEntries."Account No.":=ImprestDetails."Account No";
                        CommitmentEntries.Validate("Account No.");
                        CommitmentEntries."Account Name":=ImprestDetails."Account Name";
                        CommitmentEntries."Committed Amount":=-ImprestDetails."Request Amount";
                        CommitmentEntries."Global Dimension 1":=ImprestDetails."Global Dimension 1 Code";
                        CommitmentEntries."Global Dimension 2":=ImprestDetails."Global Dimension 2 Code";
                        CommitmentEntries."Paid Date":=WorkDate;
                        CommitmentEntries."Uncommittment Date":=WorkDate;
                        CommitmentEntries.Paid:=true;
                        CommitmentEntries.Insert(true);
                    end;
                    until ImprestDetails.Next = 0;
                ImprestHeader.Uncommitted:=true;
            end;
        end
        else if Entry_type = 'MYLPO' then begin
                if PVHeader.Get("No.")then begin
                    PVLines.Reset;
                    PVLines.SetRange("No.", PVHeader."No.");
                    PVLines.SetRange(Uncommitted, false);
                    if PVLines.FindSet then repeat begin
                            lineno:=lineno + 1000;
                            CommitmentEntries.Init;
                            CommitmentEntries."No.":="No.";
                            CommitmentEntries."Line No.":=lineno;
                            CommitmentEntries."Document No":=LPO;
                            CommitmentEntries."Commitment No":="No.";
                            CommitmentEntries.Description:=PurchaseHeader."Posting Description";
                            CommitmentEntries."Commitment Type":=CommitmentEntries."Commitment Type"::LPO;
                            CommitmentEntries."Account Type":=CommitmentEntries."Account Type"::Vendor;
                            CommitmentEntries.Validate("Account Type");
                            CommitmentEntries."Account No.":=PVLines."Account No";
                            CommitmentEntries.Validate("Account No.");
                            CommitmentEntries."Account Name":=PVLines."Account Name";
                            CommitmentEntries."Committed Amount":=-PVLines.Amount;
                            CommitmentEntries."Global Dimension 1":=PVHeader."Global Dimension 1 Code";
                            CommitmentEntries."Global Dimension 2":=PVHeader."Global Dimension 2 Code";
                            CommitmentEntries."Paid Date":=WorkDate;
                            CommitmentEntries."Uncommittment Date":=WorkDate;
                            CommitmentEntries.Paid:=true;
                            CommitmentEntries.Insert(true);
                            PVLines.Uncommitted:=true;
                            PVLines.Modify;
                        end;
                        until PVLines.Next = 0;
                    PVHeader.Uncommited:=true;
                    PVHeader.Modify;
                end;
                PurchaseHeader.Reset;
                PurchaseHeader.SetRange("No.", LPO);
                if PurchaseHeader.FindFirst then begin
                    PurchaseHeader.Uncommitted:=true;
                    PurchaseHeader.Modify;
                end;
            end
            else
                exit;
    end;
}
