codeunit 52203480 "Budget Management"
{
    var BudgetEnries: array[2]of Record "G/L Budget Entry";
    Lines: Record "Virement Budget Request Lines";
    GLSetup: Record "General Ledger Setup";
    Direction: Text[10];
    GLAcc: Record "G/L Account";
    Committments: Record "Commitment Entries";
    Item: Record Item;
    BudgetPlanScheduleLines: Record "Budget Plan Schedule Lines";
    GeneralPostingSetup: Record "General Posting Setup";
    FixedAssetPG: Record "FA Posting Group";
    Text001: Label 'There is not enough space to insert the balance accounts.';
    Text002: Label 'Virement Budget Request have been Posted Successifully';
    Text005: Label 'There is no budget available in some of the lines.';
    Text006: Label 'You are about to Commit %1 do you wish to continue?';
    Text007: Label 'You are about to UnCommit %1 do you wish to continue?';
    DraftBudget: Record "Draft Budget Entry";
    DraftBudget_Check: Record "Draft Budget Entry";
    GLBudgetEntry: Record "G/L Budget Entry";
    EntryNo: Integer;
    procedure PostVirementBudget(var Header: Record "Virement Budget Request")
    begin
        if Confirm(StrSubstNo('You are about to post %1, Do you wish to continue?', Header."No."), false) = true then begin
            Lines.Reset();
            Lines.SetRange("Document No", Header."No.");
            if Lines.FindSet()then begin
                repeat //Reverse Budget Entry
 BudgetEnries[1].Init();
                    BudgetEnries[1]."Budget Name":=Lines."Budget Name";
                    BudgetEnries[1].Date:=Lines."Document Date";
                    BudgetEnries[1]."G/L Account No.":=Lines."Transfer From";
                    BudgetEnries[1]."Global Dimension 1 Code":=Lines."Global Dimension 1 Code";
                    BudgetEnries[1]."Global Dimension 2 Code":=Lines."Global Dimension 2 Code";
                    BudgetEnries[1]."Budget Dimension 1 Code":=Header."Budget Dimension 1 Code";
                    BudgetEnries[1]."Budget Dimension 2 Code":=Header."Budget Dimension 2 Code";
                    BudgetEnries[1]."Budget Dimension 3 Code":=Header."Budget Dimension 3 Code";
                    BudgetEnries[1]."Budget Dimension 4 Code":=Header."Budget Dimension 4 Code";
                    BudgetEnries[1].Description:=Lines.Description;
                    BudgetEnries[1].Amount:=-Lines.Amount;
                    BudgetEnries[1].Insert(true);
                    //Create New Budget Entry
                    BudgetEnries[2].Init();
                    BudgetEnries[2]."Budget Name":=Lines."Budget Name";
                    BudgetEnries[2].Date:=Lines."Document Date";
                    BudgetEnries[2]."G/L Account No.":=Lines."Transfer To";
                    BudgetEnries[2]."Global Dimension 1 Code":=Lines."Global Dimension 1 Code";
                    BudgetEnries[2]."Global Dimension 2 Code":=Lines."Global Dimension 2 Code";
                    BudgetEnries[2]."Budget Dimension 1 Code":=Header."Budget Dimension 1 Code";
                    BudgetEnries[2]."Budget Dimension 2 Code":=Header."Budget Dimension 2 Code";
                    BudgetEnries[2]."Budget Dimension 3 Code":=Header."Budget Dimension 3 Code";
                    BudgetEnries[2]."Budget Dimension 4 Code":=Header."Budget Dimension 4 Code";
                    BudgetEnries[2].Description:=Lines.Description;
                    BudgetEnries[2].Amount:=Lines.Amount;
                    BudgetEnries[2].Insert(true);
                until Lines.Next = 0;
                Header.Effected:=true;
                Header."Effected By":=UserId;
                Header."Effected Date":=WorkDate;
                Message(Text002);
            end;
        end
        else
        begin
            exit;
        end;
    end;
    procedure GenerateBudgetPlanSchedule(BudgetPlan: Record "Budget Plan")
    var
        BudgetPlanLines: Record "Budget Plan Lines";
        Periods: Integer;
        PeriodDate: Date;
        PeriodAmount: Decimal;
    begin
        with BudgetPlan do begin
            TestField(Scheduled, false);
            TestField(Posted, false);
            if not Confirm(StrSubstNo('You are about to create a schedule for %1, Do you wish continue?', "No."), false)then exit;
            GLSetup.Get;
            GLSetup.TestField("Rounding Type");
            GLSetup.TestField("Amount Rounding Precision");
            if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Up then Direction:='>'
            else if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Nearest then Direction:='='
                else if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Down then Direction:='<';
            BudgetPlanLines.Reset();
            BudgetPlanLines.SetRange("Document No", "No.");
            if BudgetPlanLines.FindSet()then begin
                repeat if BudgetPlanLines."Period Type" = BudgetPlanLines."Period Type"::Annual then begin
                        CreateBudgetPlanScheduleLine(BudgetPlanLines, BudgetPlanLines.Date, BudgetPlanLines.Amount);
                    end
                    else if BudgetPlanLines."Period Type" = BudgetPlanLines."Period Type"::Monthly then begin
                            Periods:=12;
                            PeriodAmount:=Round((BudgetPlanLines.Amount / 12), GLSetup."Amount Rounding Precision", Direction);
                            PeriodDate:=BudgetPlanLines.Date;
                            repeat CreateBudgetPlanScheduleLine(BudgetPlanLines, PeriodDate, PeriodAmount);
                                Periods:=Periods - 1;
                                PeriodDate:=CalcDate('+1M', PeriodDate);
                            until Periods = 0;
                        end
                        else if BudgetPlanLines."Period Type" = BudgetPlanLines."Period Type"::Quarterly then begin
                                Periods:=4;
                                PeriodAmount:=Round((BudgetPlanLines.Amount / 4), GLSetup."Amount Rounding Precision", Direction);
                                PeriodDate:=BudgetPlanLines.Date;
                                repeat CreateBudgetPlanScheduleLine(BudgetPlanLines, PeriodDate, PeriodAmount);
                                    Periods:=Periods - 1;
                                    PeriodDate:=CalcDate('+3M', PeriodDate);
                                until Periods = 0;
                            end;
                until BudgetPlanLines.Next = 0;
                Scheduled:=true;
                Modify(true);
                Message('Budget Plan Schedule have been created');
            end;
        end;
    end;
    local procedure CreateBudgetPlanScheduleLine(PlanLine: Record "Budget Plan Lines"; PostingDate: Date; PeriodAmount: Decimal)
    var
        BudgetPlanScheduleLines: Record "Budget Plan Schedule Lines";
    begin
        with PlanLine do begin
            BudgetPlanScheduleLines.Init();
            BudgetPlanScheduleLines."Document No":="Document No";
            BudgetPlanScheduleLines."Plan Line No":="Line No";
            BudgetPlanScheduleLines.Date:=PostingDate;
            BudgetPlanScheduleLines.Budget:=Budget;
            BudgetPlanScheduleLines."Budget Line Account":="Budget Line Account";
            BudgetPlanScheduleLines.Description:=Description;
            BudgetPlanScheduleLines.Amount:=PeriodAmount;
            BudgetPlanScheduleLines."Global Dimension 1 Code":="Global Dimension 1 Code";
            BudgetPlanScheduleLines."Global Dimension 2 Code":="Global Dimension 2 Code";
            BudgetPlanScheduleLines."Global Dimension 3 Code":="Global Dimension 3 Code";
            BudgetPlanScheduleLines.Insert(true);
        end;
    end;
    procedure PostBudgetPlan(var BudgetPlan: Record "Budget Plan")
    var
        Counter: Integer;
    begin
        BudgetPlan.TestField(Status, BudgetPlan.Status::Approved);
        BudgetPlan.TestField(Posted, false);
        BudgetPlan.TestField(Scheduled, true);
        if not Confirm(StrSubstNo('You are about to Post %1, Do you wish continue?', BudgetPlan."No."), false)then exit;
        Counter:=GetLastDraftEntryNo;
        BudgetPlanScheduleLines.Reset();
        BudgetPlanScheduleLines.SetRange("Document No", BudgetPlan."No.");
        BudgetPlanScheduleLines.SetRange(Posted, false);
        if BudgetPlanScheduleLines.FindSet()then begin
            repeat Counter:=Counter + 1;
                DraftBudget.Init;
                DraftBudget."Entry No.":=Counter;
                DraftBudget."Budget Name":=BudgetPlanScheduleLines.Budget;
                DraftBudget."G/L Account No.":=BudgetPlanScheduleLines."Budget Line Account";
                DraftBudget.Date:=BudgetPlanScheduleLines.Date;
                DraftBudget."Global Dimension 1 Code":=BudgetPlanScheduleLines."Global Dimension 1 Code";
                DraftBudget."Global Dimension 2 Code":=BudgetPlanScheduleLines."Global Dimension 2 Code";
                DraftBudget.Amount:=BudgetPlanScheduleLines.Amount;
                DraftBudget.Description:=BudgetPlanScheduleLines.Description;
                DraftBudget."User ID":=UserId;
                DraftBudget."Budget Dimension 3 Code":=BudgetPlanScheduleLines."Global Dimension 3 Code";
                DraftBudget_Check.Reset;
                DraftBudget_Check.SetRange("Budget Name", BudgetPlanScheduleLines.Budget);
                DraftBudget_Check.SetRange(Date, BudgetPlanScheduleLines.Date);
                DraftBudget_Check.SetRange("G/L Account No.", BudgetPlanScheduleLines."Budget Line Account");
                DraftBudget_Check.SetRange("Global Dimension 1 Code", BudgetPlanScheduleLines."Global Dimension 1 Code");
                DraftBudget_Check.SetRange("Global Dimension 2 Code", BudgetPlanScheduleLines."Global Dimension 2 Code");
                DraftBudget_Check.SetRange("Budget Dimension 3 Code", BudgetPlanScheduleLines."Global Dimension 3 Code");
                if DraftBudget_Check.FindFirst = false then DraftBudget.Insert(true)
                else
                begin
                    DraftBudget_Check.Amount:=BudgetPlanScheduleLines.Amount;
                    DraftBudget_Check.Description:=BudgetPlanScheduleLines.Description;
                    DraftBudget_Check.Modify(true);
                end;
                BudgetPlanScheduleLines.Posted:=true;
                BudgetPlanScheduleLines.Modify(true);
            until BudgetPlanScheduleLines.Next() = 0;
            BudgetPlan.Validate(Posted, true);
            BudgetPlan.Validate(Status, BudgetPlan.Status::Closed);
            BudgetPlan.Modify(true);
            Message('Budget Plan have been posted');
        end;
    end;
    procedure MoveDraftToMainBudget(var BudgetName: Record "G/L Budget Name")
    begin
        GetLastEntryNo;
        EntryNo:=GetLastEntryNo;
        DraftBudget.Reset;
        DraftBudget.SetRange("Budget Name", BudgetName.Name);
        if DraftBudget.FindSet then begin
            repeat EntryNo:=EntryNo + 1;
                GLBudgetEntry.Init;
                GLBudgetEntry.TransferFields(DraftBudget);
                GLBudgetEntry."Entry No.":=EntryNo;
                GLBudgetEntry.Insert(true);
            until DraftBudget.Next = 0;
        end;
        DraftBudget.DeleteAll;
        BudgetName.Status:=BudgetName.Status::Approved;
        BudgetName.Modify;
    end;
    local procedure GetLastEntryNo()LastEntryNo: Integer var
        MainBudget: Record "G/L Budget Entry";
    begin
        MainBudget.Reset;
        MainBudget.SetCurrentKey("Entry No.");
        MainBudget.Ascending;
        if MainBudget.FindLast then LastEntryNo:=MainBudget."Entry No.";
    end;
    local procedure GetLastDraftEntryNo()LastEntryNo: Integer var
        MainBudget: Record "Draft Budget Entry";
    begin
        MainBudget.Reset;
        MainBudget.SetCurrentKey("Entry No.");
        MainBudget.Ascending;
        if MainBudget.FindLast then LastEntryNo:=MainBudget."Entry No.";
    end;
    procedure ValidatePurchaseLinesBudget(var PurchaseLines: Record "Purchase Line"; var Amount: Decimal)
    var
        AccountNo: Code[20];
    begin
        with PurchaseLines do begin
            case PurchaseLines.Type of PurchaseLines.Type::Item: begin
                Item.Reset;
                if Item.Get(PurchaseLines."No.")then begin
                    Item.TestField("Inventory Posting Group");
                    Item.TestField("Gen. Prod. Posting Group");
                    GeneralPostingSetup.Get(PurchaseLines."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
                    AccountNo:=GeneralPostingSetup."Purch. Account";
                end;
            end;
            PurchaseLines.Type::"G/L Account": begin
                AccountNo:=PurchaseLines."No.";
            end;
            PurchaseLines.Type::"Fixed Asset": begin
                if FixedAssetPG.Get(PurchaseLines."Posting Group")then begin
                    FixedAssetPG.TestField("Acquisition Cost Account");
                    AccountNo:=FixedAssetPG."Acquisition Cost Account";
                end;
            end;
            end;
            if ValidateBudgetBalance(AccountNo, "Amount Including VAT", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Shortcut Dimension 3 Code")then begin
                "Budget Available":=true;
            //              Modify;
            end;
        end;
    end;
    procedure ValidatePurchaseLinesBudgetPI(var PurchaseLines: Record "Purch. Inv. Line"; var Amount: Decimal)
    var
        AccountNo: Code[20];
    begin
        with PurchaseLines do begin
            case PurchaseLines.Type of PurchaseLines.Type::Item: begin
                Item.Reset;
                if Item.Get(PurchaseLines."No.")then if Item."Inventory Posting Group" = '' then Error('Assign Posting Group to Item No %1', Item."No.");
                GeneralPostingSetup.Reset();
                GeneralPostingSetup.SetRange("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                if GeneralPostingSetup.FindFirst()then AccountNo:=GeneralPostingSetup."Purch. Account";
            end;
            PurchaseLines.Type::"G/L Account": begin
                AccountNo:=PurchaseLines."No.";
            end;
            PurchaseLines.Type::"Fixed Asset": begin
                if FixedAssetPG.Get(PurchaseLines."Posting Group")then begin
                    FixedAssetPG.TestField("Acquisition Cost Account");
                    AccountNo:=FixedAssetPG."Acquisition Cost Account";
                end;
            end;
            end;
            if ValidateBudgetBalance(AccountNo, "Amount Including VAT", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Shortcut Dimension 3 Code")then begin
                "Budget Available":=true;
                Modify;
            end;
        end;
    end;
    procedure ValidateBudgetBalance(var BudgetLine: Code[20]; var Amount: Decimal; var DimOne: Code[20]; var DimTwo: Code[20]; var DimThree: Code[20])Available: Boolean var
        GLAcc: Record "G/L Account";
        GLEntries: Record "G/L Entry";
        BudgetEntries: Record "G/L Budget Entry";
        CommitmentEntries: Record "Commitment Entries";
        NetChangeAmount: Decimal;
        CommitmentAmount: Decimal;
        BudgetAmount: Decimal;
        RemainingBalance: Decimal;
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get;
        if GLAcc.Get(BudgetLine)then begin
            // if DimOne = '' then
            //     Error('Kindly first capture all the Dimensions Codes for Department and the others necessary.');
            Available:=true;
            NetChangeAmount:=0;
            CommitmentAmount:=0;
            BudgetAmount:=0;
            RemainingBalance:=0;
            GLSetup.Get;
            GLSetup.TestField("Current Budget");
            GLSetup.TestField("Current Budget Start Date");
            GLSetup.TestField("Current Budget End Date");
            BudgetEntries.Reset();
            BudgetEntries.SetRange("G/L Account No.", BudgetLine);
            //   BudgetEntries.SetRange("Global Dimension 1 Code", DimOne); To be uncommented on Production        // if DimTwo <> '' then
            BudgetEntries.SetFilter(Date, '%1..%2', GLSetup."Current Budget Start Date", GLSetup."Current Budget End Date");
            BudgetEntries.CalcSums(Amount);
            BudgetAmount:=BudgetEntries.Amount;
            GLEntries.Reset();
            GLEntries.SetRange("G/L Account No.", BudgetLine);
            //GLEntries.SetRange("Global Dimension 1 Code", DimOne); To be uncommented on Production        // if DimTwo <> '' then
            GLEntries.SetFilter("Posting Date", '%1..%2', GLSetup."Current Budget Start Date", GLSetup."Current Budget End Date");
            GLEntries.CalcSums(Amount);
            NetChangeAmount:=GLEntries.Amount;
            CommitmentEntries.Reset();
            CommitmentEntries.SetRange(Account, BudgetLine);
            //CommitmentEntries.SetRange("Global Dimension 1", DimOne); To be uncommented on Production;
            // if DimTwo <> '' then
            //     CommitmentEntries.SetRange("Global Dimension 2", DimTwo);
            CommitmentEntries.SetFilter("Commitment Date", '%1..%2', GLSetup."Current Budget Start Date", GLSetup."Current Budget End Date");
            CommitmentEntries.CalcSums("Committed Amount");
            CommitmentAmount:=CommitmentEntries."Committed Amount";
            RemainingBalance:=BudgetAmount - NetChangeAmount - CommitmentAmount;
            if(GLSetup."Budget Check" and (Amount > RemainingBalance))then Error('The remaining budget balance of KSH. ' + Format(RemainingBalance) + ' cannot accomodate an expenditure of KSH. ' + Format(Amount) + ' Dept: ' + DimOne + ' Branch: ' + DimTwo);
            exit(Available);
        end;
    end;
    procedure ConfirmBudgetAvailabilityPO(var PO: Record "Purchase Header")
    var
        Lines: Record "Purchase Line";
    begin
        with PO do begin
            Lines.Reset();
            Lines.SetRange("Document No.", "No.");
            Lines.SetRange("Document Type", "Document Type");
            Lines.SetRange("Budget Available", false);
            if Lines.FindFirst()then Error(Text005);
        end;
    end;
    procedure ConfirmBudgetAvailabilityPR(var PR: Record "Requisition Header")
    var
        Lines: Record "Requisition Lines";
    begin
        with PR do begin
            Lines.Reset();
            Lines.SetRange("Requisition No", "No.");
            Lines.SetRange("Budget Available", false);
            if Lines.FindFirst()then Error(Text005);
        end;
    end;
    procedure ValidatePurchaseRequisitionBudget(var RequisitionLines: Record "Requisition Lines"; var Amount: Decimal)
    var
        AccountNo: Code[20];
    begin
        with RequisitionLines do begin
            case RequisitionLines.Type of RequisitionLines.Type::Item: begin
                if Item.Get(RequisitionLines."No.")then if Item."Gen. Prod. Posting Group" = '' then Error('Assign Posting Group to Item No %1', Item."No.");
                GeneralPostingSetup.Reset();
                GeneralPostingSetup.SetRange("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                if GeneralPostingSetup.FindFirst()then AccountNo:=GeneralPostingSetup."Purch. Account";
            end;
            RequisitionLines.Type::"G/L Account": begin
                AccountNo:=RequisitionLines."No.";
            end;
            RequisitionLines.Type::"Fixed Asset": begin
                AccountNo:="Asset Acquisition Account";
            end;
            end;
            if ValidateBudgetBalance(AccountNo, Amount, "Global Dimension 1 Code", "Global Dimension 2 Code", "Global Dimension 3 Code")then begin
                "Budget Available":=true;
                Modify;
            end;
        end;
    end;
    procedure ConfirmBudgetAvailabilityImprest(var Imprest: Record "Request Header")
    var
        Lines: Record "Request Lines";
    begin
        with Imprest do begin
            Lines.Reset;
            Lines.SetRange("No.", "No.");
            Lines.SetRange("Budget Available", false);
            if Lines.FindFirst then Error('There is no budget available in some of the lines.');
        end;
    end;
    procedure ValidateImprestBudget(var ImprestDetails: Record "Request Lines"; var Amount: Decimal)
    var
        AccountNo: Code[20];
        CashAmount: Decimal;
        ImprestHeader: Record "Request Header";
    begin
        with ImprestDetails do begin
            case ImprestDetails.Type of ImprestDetails.Type::Item: begin
                if Item.Get(ImprestDetails."Account No")then if Item."Inventory Posting Group" = '' then Error('Assign Posting Group to Item No %1', Item."No.");
                GeneralPostingSetup.Reset();
                GeneralPostingSetup.SetRange("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                if GeneralPostingSetup.FindFirst()then AccountNo:=GeneralPostingSetup."Purch. Account";
            end;
            ImprestDetails.Type::"G/L Account": begin
                AccountNo:=ImprestDetails."Account No";
            end;
            ImprestDetails.Type::"Fixed Asset": begin
                Error('You cannot do Imprest request for Fixed Assets.');
            end;
            end;
            if ImprestHeader.Get("No.")then begin
                if ImprestHeader."Request Type" = ImprestHeader."Request Type"::"Staff Claim" then CashAmount:="Actual Spent"
                else
                    CashAmount:="Request Amount";
            end;
            if ValidateBudgetBalance(AccountNo, CashAmount, "Global Dimension 1 Code", "Global Dimension 2 Code", "Global Dimension 3 Code")then begin
                "Budget Available":=true;
                Modify;
            end;
        end;
    end;
    procedure CommitImprest(var ImprestNumber: Code[20])
    var
        Lines: Record "Request Lines";
        Header: Record "Request Header";
    begin
        if Confirm(StrSubstNo(Text006, ImprestNumber), false) = true then begin
            if Header.Get(ImprestNumber)then begin
                Lines.Reset;
                Lines.SetRange("No.", Header."No.");
                if Lines.Find('-')then begin
                    repeat ValidateImprestBudget(Lines, Lines."Request Amount");
                        if Header."Request Type" = Header."Request Type"::"Staff Claim" then CommitFunds(Lines."Account No", Lines."Actual Spent", Header.Date, Lines.Narration, Lines."Global Dimension 1 Code", Lines."Global Dimension 2 Code", Lines."Global Dimension 3 Code", Header."No.", Lines."Line No")
                        else
                            CommitFunds(Lines."Account No", Lines."Request Amount", Header.Date, Lines.Narration, Lines."Global Dimension 1 Code", Lines."Global Dimension 2 Code", Lines."Global Dimension 3 Code", Header."No.", Lines."Line No");
                    until Lines.Next = 0;
                end;
                Header.Committed:=true;
                Header."Committed By":=UserId;
                Header."Committed Date":=WorkDate;
                Header.Modify;
            end;
        end
        else
            exit;
    end;
    procedure UnCommitImprest(var ImprestNumber: Code[20])
    var
        Lines: Record "Request Lines";
        Header: Record "Request Header";
    begin
        if Confirm(StrSubstNo(Text007, ImprestNumber), false) = true then begin
            if Header.Get(ImprestNumber)then begin
                Lines.Reset;
                Lines.SetRange("No.", Header."No.");
                if Lines.Find('-')then begin
                    repeat if Header."Request Type" = Header."Request Type"::"Staff Claim" then UnCommitFunds(Lines."Account No", Lines."Actual Spent", Header.Date, Lines.Narration, Lines."Global Dimension 1 Code", Lines."Global Dimension 2 Code", Lines."Global Dimension 3 Code", Header."No.", Lines."Line No")
                        else
                            UnCommitFunds(Lines."Account No", Lines."Request Amount", Header.Date, Lines.Narration, Lines."Global Dimension 1 Code", Lines."Global Dimension 2 Code", Lines."Global Dimension 3 Code", Header."No.", Lines."Line No");
                    until Lines.Next = 0;
                end;
                Header.Committed:=false;
                Header."Committed By":='';
                Header."Committed Date":=0D;
                Header.Modify;
            end;
        end
        else
            exit;
    end;
    procedure CommitFunds(var BudgetLine: Code[20]; var Amount: Decimal; var Date: Date; var Desc: Text; var DimOne: Code[20]; var DimTwo: Code[20]; var DimThree: Code[20]; var DocumentNo: Code[20]; var LineNo: Integer)
    var
        PurchaseLines: Record "Purchase Line";
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
        //Check if item has been commited before
        if FundsCommitted(BudgetLine, Date, DimOne, DimTwo, DimThree, DocumentNo, LineNo)then exit; //Confirm the Amount to be issued does not exceed the budget and amount Committed
        Committments.Reset;
        if Committments.FindLast then EntryNo:=Committments."Entry No";
        EntryNo:=EntryNo + 1;
        Committments.Init;
        Committments."Commitment No":=DocumentNo;
        Committments."Commitment Type":=Committments."Commitment Type"::Committed;
        Committments."Commitment Date":=Date;
        Committments."Global Dimension 1":=DimOne;
        Committments."Global Dimension 2":=DimTwo;
        Committments."Global Dimension 3":=DimThree;
        Committments.Account:=BudgetLine;
        Committments."Committed Amount":=Amount;
        Committments.User:=UserId;
        Committments."Document No":=DocumentNo;
        Committments."No.":=DocumentNo;
        Committments."Line No.":=LineNo;
        Committments."Account Type":=Committments."Account Type"::"G/L Account";
        Committments."Account No.":=BudgetLine;
        if GLAcc.Get(BudgetLine)then Committments."Account Name":=GLAcc.Name;
        Committments.Description:=Desc;
        Committments."Entry No":=EntryNo;
        GLSetup.Get;
        Committments.Budget:=GLSetup."Current Budget";
        Committments.Insert;
    end;
    local procedure FundsCommitted(var BudgetLine: Code[20]; var Date: Date; var DimOne: Code[20]; var DimTwo: Code[20]; var DimThree: Code[20]; var DocumentNo: Code[20]; var LineNo: Integer)Committed: Boolean begin
        Committed:=false;
        Committments.Reset;
        Committments.SetCurrentKey(Account, "Commitment Date", "Global Dimension 1", "Global Dimension 2");
        Committments.SetRange(Account, BudgetLine);
        Committments.SetRange("Commitment Date", Date);
        Committments.SetRange("Global Dimension 1", DimOne);
        if DimTwo <> '' then Committments.SetRange("Global Dimension 2", DimTwo);
        if DimThree <> '' then Committments.SetRange("Global Dimension 3", DimThree);
        Committments.SetRange("Commitment No", DocumentNo);
        Committments.SetRange("Line No.", LineNo);
        if Committments.FindFirst then Committed:=true;
    end;
    procedure UnCommitFunds(var BudgetLine: Code[20]; var Amount: Decimal; var Date: Date; var Desc: Text; var DimOne: Code[20]; var DimTwo: Code[20]; var DimThree: Code[20]; var DocumentNo: Code[20]; var LineNo: Integer)
    var
        PurchaseLines: Record "Purchase Line";
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
        //Check if item has been commited before
        if not FundsCommitted(BudgetLine, Date, DimOne, DimTwo, DimThree, DocumentNo, LineNo)then exit; //Check if item has been uncommited before
        if FundsUnCommitted(BudgetLine, Date, DimOne, DimTwo, DimThree, DocumentNo, LineNo)then exit;
        Committments.Reset;
        if Committments.FindLast then EntryNo:=Committments."Entry No";
        EntryNo:=EntryNo + 1;
        Committments.Init;
        Committments."Commitment No":=DocumentNo;
        Committments."Commitment Type":=Committments."Commitment Type"::Uncommitted;
        Committments."Commitment Date":=Date;
        Committments."Global Dimension 1":=DimOne;
        Committments."Global Dimension 2":=DimTwo;
        Committments."Global Dimension 3":=DimThree;
        Committments.Account:=BudgetLine;
        Committments."Committed Amount":=-1 * Amount;
        Committments.User:=UserId;
        Committments."Document No":=DocumentNo;
        Committments."No.":=DocumentNo;
        Committments."Line No.":=LineNo;
        Committments."Account Type":=Committments."Account Type"::"G/L Account";
        Committments."Account No.":=BudgetLine;
        if GLAcc.Get(BudgetLine)then Committments."Account Name":=GLAcc.Name;
        Committments.Description:=Desc;
        GLSetup.Get;
        Committments.Budget:=GLSetup."Current Budget";
        Committments."Entry No":=EntryNo;
        Committments.Insert;
    end;
    local procedure FundsUnCommitted(var BudgetLine: Code[20]; var Date: Date; var DimOne: Code[20]; var DimTwo: Code[20]; var DimThree: Code[20]; var DocumentNo: Code[20]; var LineNo: Integer)Committed: Boolean begin
        Committed:=false;
        Committments.Reset;
        Committments.SetCurrentKey(Account, "Commitment Date", "Global Dimension 1", "Global Dimension 2");
        Committments.SetRange(Account, BudgetLine);
        Committments.SetRange("Commitment Date", Date);
        Committments.SetRange("Global Dimension 1", DimOne);
        if DimTwo <> '' then Committments.SetRange("Global Dimension 2", DimTwo);
        if DimThree <> '' then Committments.SetRange("Global Dimension 3", DimThree);
        Committments.SetRange("Commitment No", DocumentNo);
        Committments.SetRange("Line No.", LineNo);
        Committments.SetRange("Commitment Type", Committments."Commitment Type"::Uncommitted);
        if Committments.FindFirst then Committed:=true;
    end;
    procedure CommitPO(var PONumber: Code[20])
    var
        Lines: Record "Purchase Line";
        Header: Record "Purchase Header";
    begin
        if Confirm(StrSubstNo(Text006, PONumber), false) = true then begin
            if Header.Get(Header."Document Type"::Order, PONumber)then begin
                Lines.Reset;
                Lines.SetRange("Document No.", Header."No.");
                Lines.SetRange("Document Type", Header."Document Type");
                if Lines.Find('-')then begin
                    repeat ValidatePurchaseLinesBudget(Lines, Lines."Amount Including VAT");
                        CommitFunds(Lines."No.", Lines."Amount Including VAT", Header."Posting Date", Lines.Description, Lines."Shortcut Dimension 1 Code", Lines."Shortcut Dimension 2 Code", Lines."Shortcut Dimension 3 Code", Header."No.", Lines."Line No.");
                    until Lines.Next = 0;
                end;
                Header.Committed:=true;
                Header.Modify;
            end;
        end
        else
            exit;
    end;
    procedure UnCommitPO(var PONumber: Code[20])
    var
        Lines: Record "Purchase Line";
        Header: Record "Purchase Header";
    begin
        if Confirm(StrSubstNo(Text007, PONumber), false) = true then begin
            if Header.Get(Header."Document Type"::Order, PONumber)then begin
                Lines.Reset;
                Lines.SetRange("Document No.", Header."No.");
                Lines.SetRange("Document Type", Header."Document Type");
                if Lines.Find('-')then begin
                    repeat UnCommitFunds(Lines."No.", Lines."Amount Including VAT", Header."Posting Date", Lines.Description, Lines."Shortcut Dimension 1 Code", Lines."Shortcut Dimension 2 Code", Lines."Shortcut Dimension 3 Code", Header."No.", Lines."Line No.");
                    until Lines.Next = 0;
                end;
                Header.Committed:=false;
                Header.Modify;
            end;
        end
        else
            exit;
    end;
}
