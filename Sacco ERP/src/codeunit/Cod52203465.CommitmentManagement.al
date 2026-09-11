codeunit 52203465 "Commitment Management"
{
    procedure POCommitment(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLines: Record "Purchase Line";
        Committments: Record "Commitment Entries";
        Item: Record Item;
        GLAccount: Record "G/L Account";
        FixedAsset: Record "Fixed Asset";
        EntryNo: Integer;
        InventoryPostingSetup: Record "Inventory Posting Setup";
        FixedAssetPG: Record "FA Posting Group";
        GenLedSetup: Record "General Ledger Setup";
        InventoryAccount: Code[20];
        AcquisitionAccount: Code[20];
        BudgetAmount: Decimal;
        Expenses: Decimal;
        BudgetAvailable: Decimal;
        CommitmentEntries: Record "Commitment Entries";
        CommittedAmount: Decimal;
        Vendor: Record Vendor;
    begin
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then begin
            PurchaseLines.Reset;
            PurchaseLines.SetRange(PurchaseLines."Document No.", PurchaseHeader."No.");
            PurchaseLines.SetRange(PurchaseLines."Document Type", PurchaseLines."Document Type"::Order);
            if PurchaseLines.FindFirst then begin
                if Committments.FindLast then EntryNo:=Committments."Entry No";
                repeat Committments.Init;
                    Committments."Commitment No":=PurchaseHeader."No.";
                    Committments."Commitment Type":=Committments."Commitment Type"::Committed;
                    // PurchaseHeader.VALIDATE("Order Date");
                    if PurchaseHeader."Order Date" = 0D then Error('Please enter the order date');
                    Committments."Commitment Date":=PurchaseHeader."Order Date";
                    Committments."Global Dimension 1":=PurchaseLines."Shortcut Dimension 1 Code";
                    Committments."Global Dimension 2":=PurchaseLines."Shortcut Dimension 2 Code";
                    //Case of G/L Account,Item,Fixed Asset
                    case PurchaseLines.Type of PurchaseLines.Type::Item: begin
                        Item.Reset;
                        if Item.Get(PurchaseLines."No.")then if Item."Inventory Posting Group" = '' then Error('Assign Posting Group to Item No %1', Item."No.");
                        InventoryPostingSetup.Get(PurchaseLines."Location Code", Item."Inventory Posting Group");
                        InventoryAccount:=InventoryPostingSetup."Inventory Account";
                        Committments.Account:=InventoryAccount;
                    end;
                    PurchaseLines.Type::"G/L Account": begin
                        Committments.Account:=PurchaseLines."No.";
                    end;
                    PurchaseLines.Type::"Fixed Asset": begin
                        if FixedAssetPG.Get(PurchaseLines."Posting Group")then begin
                            FixedAssetPG.TestField("Acquisition Cost Account");
                            AcquisitionAccount:=FixedAssetPG."Acquisition Cost Account";
                            Committments.Account:=AcquisitionAccount;
                        end;
                    end;
                    end;
                    Committments."Committed Amount":=PurchaseLines."Line Amount";
                    //Confirm the Amount to be issued does not exceed the budget and amount Committed
                    //Get Budget for the G/L
                    GenLedSetup.Get;
                    GLAccount.SetFilter(GLAccount."Budget Filter", GenLedSetup."Current Budget");
                    case PurchaseLines.Type of PurchaseLines.Type::Item: begin
                        GLAccount.SetRange(GLAccount."No.", InventoryAccount);
                    end;
                    PurchaseLines.Type::"G/L Account": begin
                        GLAccount.SetRange(GLAccount."No.", PurchaseLines."No.");
                    end;
                    PurchaseLines.Type::"Fixed Asset": GLAccount.SetRange(GLAccount."No.", AcquisitionAccount);
                    end;
                    GLAccount.CalcFields(GLAccount."Budgeted Amount", GLAccount."Net Change");
                    //Get budget amount avaliable
                    GLAccount.SetRange(GLAccount."Date Filter", GenLedSetup."Current Budget Start Date", GenLedSetup."Current Budget End Date");
                    if GLAccount.Find('-')then begin
                        GLAccount.CalcFields(GLAccount."Budgeted Amount", GLAccount."Net Change");
                        BudgetAmount:=GLAccount."Budgeted Amount";
                        Expenses:=GLAccount."Net Change";
                        BudgetAvailable:=GLAccount."Budgeted Amount" - GLAccount."Net Change";
                    end;
                    //Get committed Amount
                    CommittedAmount:=0;
                    CommitmentEntries.Reset;
                    CommitmentEntries.SetCurrentKey(CommitmentEntries.Account);
                    if PurchaseLines.Type = PurchaseLines.Type::Item then CommitmentEntries.SetRange(CommitmentEntries.Account, InventoryAccount);
                    if PurchaseLines.Type = PurchaseLines.Type::"G/L Account" then CommitmentEntries.SetRange(CommitmentEntries.Account, PurchaseLines."No.");
                    if PurchaseLines.Type = PurchaseLines.Type::"Fixed Asset" then CommitmentEntries.SetRange(CommitmentEntries.Account, AcquisitionAccount);
                    CommitmentEntries.SetRange(CommitmentEntries."Commitment Date", GenLedSetup."Current Budget Start Date", PurchaseHeader."Order Date");
                    CommitmentEntries.CalcSums(CommitmentEntries."Committed Amount");
                    CommittedAmount:=CommitmentEntries."Committed Amount";
                    if LineCommitted(PurchaseHeader."No.", PurchaseLines."No.", PurchaseLines."Line No.")then Message('Line No %1 has been commited', PurchaseLines."Line No.")
                    else /*IF CommittedAmount+PurchaseLines."Line Amount">BudgetAvailable THEN
                          IF (BudgetAvailable < 0) OR (BudgetAvailable = 0) THEN
                            ERROR('There is no budget available for %1',PurchaseLines.Description)
                           ELSE
                           ERROR('You have Exceeded Budget for G/L Account No %1 By %2 Budget Available %3 CommittedAmount %4'
                           ,Committments.Account,
                           ABS(BudgetAvailable-(CommittedAmount+PurchaseLines."Line Amount")),BudgetAvailable,CommittedAmount);*/
                        Committments.User:=UserId;
                    Committments."Document No":=PurchaseHeader."No.";
                    Committments."No.":=PurchaseLines."No.";
                    Committments."Line No.":=PurchaseLines."Line No.";
                    Committments."Account Type":=Committments."Account Type"::Vendor;
                    Committments."Account No.":=PurchaseLines."Buy-from Vendor No.";
                    if Vendor.Get(PurchaseLines."Buy-from Vendor No.")then Committments."Account Name":=Vendor.Name;
                    Committments.Description:=PurchaseLines.Description; //Check whether line is committed.
                    if not LineCommitted(PurchaseHeader."No.", PurchaseLines."No.", PurchaseLines."Line No.")then begin
                        EntryNo:=EntryNo + 1;
                        Committments."Entry No":=EntryNo;
                        Committments.Insert;
                        PurchaseLines.Status:=PurchaseLines.Status::Committed;
                        PurchaseLines.Modify;
                    end;
                until PurchaseLines.Next = 0;
            end;
        //MESSAGE('Items Committed Successfully');
        end;
    end;
    procedure LineCommitted(var CommittmentNo: Code[20]; var No: Code[20]; var LineNo: Integer)Exists: Boolean var
        Committed: Record "Commitment Entries";
    begin
        Exists:=false;
        Committed.Reset;
        Committed.SetRange(Committed."Commitment No", CommittmentNo);
        Committed.SetRange(Committed."No.", No);
        Committed.SetRange(Committed."Line No.", LineNo);
        if Committed.Find('-')then Exists:=true;
    end;
    procedure ReversePOCommittmentOnPosting(var PurchHeader: Record "Purchase Header")
    var
        Committment: Record "Commitment Entries";
        PurchLine: Record "Purchase Line";
        EntryNo: Integer;
        Item: Record Item;
        InventoryPostingSetup: Record "Inventory Posting Setup";
        FixedAssetPG: Record "FA Posting Group";
        GenLedSetup: Record "General Ledger Setup";
        InventoryAccount: Code[20];
        Vendor: Record Vendor;
        FixedAsset: Record "Fixed Asset";
        AcquisitionAccount: Code[20];
    begin
        if Confirm('Are you sure you want to reverse the committed entries for Order no ' + PurchHeader."No." + '?', false) = true then begin
            Committment.Reset;
            Committment.SetRange(Committment."Commitment No", PurchHeader."No.");
            if Committment.Find('-')then begin
                Committment.DeleteAll;
            end;
            PurchLine.Reset;
            PurchLine.SetRange(PurchLine."Document Type", PurchLine."Document Type"::Order);
            PurchLine.SetRange(PurchLine."Document No.", PurchHeader."No.");
            if PurchLine.FindFirst then begin
                repeat //Insert Reversal entries in the committment entries table
 if Committment.Find('+')then EntryNo:=Committment."Entry No";
                    EntryNo:=EntryNo + 1;
                    if LineCommitted(PurchHeader."No.", PurchLine."No.", PurchLine."Line No.")then begin
                        Committment.Init;
                        Committment."Entry No":=EntryNo;
                        Committment."Commitment No":=PurchHeader."No.";
                        Committment."Commitment Type":=Committment."Commitment Type"::Reversal;
                        Committment."Commitment Date":=PurchLine."Order Date";
                        //Dimensions
                        Committment."Global Dimension 1":=PurchLine."Shortcut Dimension 1 Code";
                        Committment."Global Dimension 2":=PurchLine."Shortcut Dimension 2 Code";
                        //Dimensions
                        //Case of G/L Account,Item,Fixed Asset
                        case PurchLine.Type of PurchLine.Type::Item: begin
                            Item.Reset;
                            if Item.Get(PurchLine."No.")then if Item."Inventory Posting Group" = '' then Error('Assign Posting Group to Item No %1', Item."No.");
                            InventoryPostingSetup.Get(PurchLine."Location Code", Item."Inventory Posting Group");
                            InventoryAccount:=InventoryPostingSetup."Inventory Account";
                            Committment.Account:=InventoryAccount;
                        end;
                        PurchLine.Type::"G/L Account": begin
                            Committment.Account:=PurchLine."No.";
                        end;
                        PurchLine.Type::"Fixed Asset": begin
                            FixedAsset.Reset;
                            FixedAsset.Get(PurchLine."No.");
                            FixedAssetPG.Get(FixedAsset."FA Posting Group");
                            AcquisitionAccount:=FixedAssetPG."Acquisition Cost Account";
                            Committment.Account:=AcquisitionAccount;
                        end;
                        end;
                        Committment."Committed Amount":=-PurchLine."Line Amount";
                        Committment.User:=UserId;
                        Committment."Document No":=PurchHeader."No.";
                        Committment."No.":=PurchLine."No.";
                        Committment."Account Type":=Committment."Account Type"::Vendor;
                        Committment."Account No.":=PurchLine."Buy-from Vendor No.";
                        if Vendor.Get(PurchLine."Buy-from Vendor No.")then Committment."Account Name":=Vendor.Name;
                        Committment.Description:=PurchLine.Description;
                        Committment.Insert; //Mark entries as uncommited
                    //vooPurchLine.Committed:=FALSE;
                    //vooPurchLine.MODIFY;
                    end;
                until PurchLine.Next = 0;
            end;
        //MESSAGE('Committed entries for Order No %1 Have been reversed Successfully',PurchHeader."No.");
        end;
    end;
    procedure ReversePOCommittmentOnReopenDocument(var PurchHeader: Record "Purchase Header")
    var
        Committment: Record "Commitment Entries";
        PurchLine: Record "Purchase Line";
        EntryNo: Integer;
        Item: Record Item;
        InventoryPostingSetup: Record "Inventory Posting Setup";
        FixedAssetPG: Record "FA Posting Group";
        GenLedSetup: Record "General Ledger Setup";
        InventoryAccount: Code[20];
        Vendor: Record Vendor;
        FixedAsset: Record "Fixed Asset";
        AcquisitionAccount: Code[20];
    begin
        Committment.Reset;
        Committment.SetRange(Committment."Commitment No", PurchHeader."No.");
        if Committment.Find('-')then begin
            Committment.DeleteAll;
        end;
        PurchLine.Reset;
        PurchLine.SetRange(PurchLine."Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange(PurchLine."Document No.", PurchHeader."No.");
        if PurchLine.FindFirst then begin
            repeat //Insert Reversal entries in the committment entries table
 if Committment.Find('+')then EntryNo:=Committment."Entry No";
                EntryNo:=EntryNo + 1;
                if LineCommitted(PurchHeader."No.", PurchLine."No.", PurchLine."Line No.")then begin
                    Committment.Init;
                    Committment."Entry No":=EntryNo;
                    Committment."Commitment No":=PurchHeader."No.";
                    Committment."Commitment Type":=Committment."Commitment Type"::Reversal;
                    Committment."Commitment Date":=PurchLine."Order Date";
                    //Dimensions
                    Committment."Global Dimension 1":=PurchLine."Shortcut Dimension 1 Code";
                    Committment."Global Dimension 2":=PurchLine."Shortcut Dimension 2 Code";
                    //Dimensions
                    //Case of G/L Account,Item,Fixed Asset
                    case PurchLine.Type of PurchLine.Type::Item: begin
                        Item.Reset;
                        if Item.Get(PurchLine."No.")then if Item."Inventory Posting Group" = '' then Error('Assign Posting Group to Item No %1', Item."No.");
                        InventoryPostingSetup.Get(PurchLine."Location Code", Item."Inventory Posting Group");
                        InventoryAccount:=InventoryPostingSetup."Inventory Account";
                        Committment.Account:=InventoryAccount;
                    end;
                    PurchLine.Type::"G/L Account": begin
                        Committment.Account:=PurchLine."No.";
                    end;
                    PurchLine.Type::"Fixed Asset": begin
                        FixedAsset.Reset;
                        FixedAsset.Get(PurchLine."No.");
                        FixedAssetPG.Get(FixedAsset."FA Posting Group");
                        AcquisitionAccount:=FixedAssetPG."Acquisition Cost Account";
                        Committment.Account:=AcquisitionAccount;
                    end;
                    end;
                    Committment."Committed Amount":=-PurchLine."Line Amount";
                    Committment.User:=UserId;
                    Committment."Document No":=PurchHeader."No.";
                    Committment."No.":=PurchLine."No.";
                    Committment."Account Type":=Committment."Account Type"::Vendor;
                    Committment."Account No.":=PurchLine."Buy-from Vendor No.";
                    if Vendor.Get(PurchLine."Buy-from Vendor No.")then Committment."Account Name":=Vendor.Name;
                    Committment.Description:=PurchLine.Description;
                    Committment.Insert; //Mark entries as uncommited
                //vooPurchLine.Committed:=FALSE;
                //vooPurchLine.MODIFY;
                end;
            until PurchLine.Next = 0;
        end;
    end;
}
