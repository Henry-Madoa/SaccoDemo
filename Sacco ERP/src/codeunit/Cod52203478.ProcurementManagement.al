codeunit 52203478 "Procurement Management"
{
    trigger OnRun()
    begin
        ReorderLevelsNotifications;
    end;

    var
        ProcurementPlanLines: Record "Procurement Plan Lines";
        ItemBudgetEntry: Record "Item Budget Entry";
        CommunicationMgmt: Codeunit "Communications Mgmt";
        PurchPayablesSetup: Record "Purchases & Payables Setup";
        UserSetup: Record "User Setup";
        Employee: Record Employee;
        PurchasePayablesSetup: Record "Purchases & Payables Setup";
        Window: Dialog;
        Names: Text;
        RequisitionHeader: Record "Requisition Header";
        CompInfo: Record "Company Information";
        PayBankDetail: Record "Payee Bank Details";
        Items: Record Item;
        Recipients: List of [Text];
        Body: Text;
        Subject: Text;
        TempBlob: Codeunit "Temp Blob";
        outStreamReport: OutStream;
        inStreamReport: InStream;
        Recordr: RecordRef;
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
        Supplier: Record Vendor;
        PurchHeader: Record "Purchase Header";

    procedure UpdateItemBudgetEntries(ProcurementPlanHeader: Record "Procurement Plans")
    begin
        if Confirm(StrSubstNo('You are about to Post %1 Procurement Plan, Do you wish to continue', ProcurementPlanHeader."No."), true) = false then exit;
        ProcurementPlanLines.Reset();
        ProcurementPlanLines.SetRange("Document No", ProcurementPlanHeader."No.");
        if ProcurementPlanLines.FindSet() then begin
            repeat
                InsertBudgetEntry(ProcurementPlanLines);
            until ProcurementPlanLines.Next() = 0;
        end;
        ProcurementPlanHeader.Posted := true;
        ProcurementPlanHeader.Modify(true);
    end;

    local procedure InsertBudgetEntry(ProcurementPlanLines: Record "Procurement Plan Lines")
    begin
        ItemBudgetEntry.Init();
        ItemBudgetEntry."Entry No." := GetLastItemBudgetEntry + 1;
        ItemBudgetEntry."Analysis Area" := ItemBudgetEntry."Analysis Area"::Purchase;
        ItemBudgetEntry."Budget Name" := ProcurementPlanLines."Item Budget Name";
        ItemBudgetEntry.Date := ProcurementPlanLines.Date;
        ItemBudgetEntry.Validate("Item No.", ProcurementPlanLines."No.");
        ItemBudgetEntry.Description := ProcurementPlanLines.Description;
        ItemBudgetEntry."Source Type" := ItemBudgetEntry."Source Type"::Vendor;
        ItemBudgetEntry."Location Code" := ProcurementPlanLines."Location Code";
        ItemBudgetEntry."Global Dimension 1 Code" := ProcurementPlanLines."Global Dimension 1 Code";
        ItemBudgetEntry."Global Dimension 2 Code" := ProcurementPlanLines."Global Dimension 2 Code";
        ItemBudgetEntry.Quantity := ProcurementPlanLines."Quantity (Base)";
        ItemBudgetEntry."Cost Amount" := ProcurementPlanLines."Unit Cost (Base)";
        ItemBudgetEntry.Insert(true);
        Commit;
    end;

    local procedure GetLastItemBudgetEntry(): Integer
    begin
        ItemBudgetEntry.Reset();
        ItemBudgetEntry.SetCurrentKey("Entry No.");
        ItemBudgetEntry.SetFilter("Item No.", '<>%1', '');
        if ItemBudgetEntry.FindLast() then exit(ItemBudgetEntry."Entry No.");
    end;

    procedure SubmitMandatoryScore(EvaluationCommittee: Record "Evaluation Committee")
    var
        SenderAddress: Text;
        SenderName: Text;
        Recipient: List of [Text];
        Subject: Text;
        Body: Text;
    begin
        with EvaluationCommittee do begin
            "Submitted Mandatory Evaluation" := true;
            Clear(Recipient);
            if Modify(true) then begin
                PurchPayablesSetup.Get;
                PurchPayablesSetup.TestField("Procurement Officer User Id");
                if UserSetup.Get(PurchPayablesSetup."Procurement Officer User Id") then begin
                    Recipient.Add(UserSetup."E-Mail");
                    Subject := 'Technical Evaluation Submition';
                    if Employee.Get(UserSetup."Employee No.") then Body := 'Dear ' + Format(Employee.FullName) + ' <br> ' + Format(EvaluationCommittee."Employee Name") + ' has submitted their ' + 'Mandatory evaluation for tender No. ' + Format("Reference No") + '<br><br> This is a system generated E-mail ' + 'Please do not reply to it <br> Regards';
                    CommunicationMgmt.SendEmailWithoutAttachement(Recipient, Subject, Body);
                end;
                Message('Mandatory Evaluation successfully Submited');
            end;
        end;
    end;

    procedure GetPlannedQuantity(Dim1: Code[50]; TypeParam: Enum "Purchase Line Type"; NoParam: Code[50]; PlanName: Text): Integer
    var
        ConProcPlanLine: Record "Procurement Plan Lines";
    begin
        ConProcPlanLine.Reset;
        ConProcPlanLine.SetRange("Global Dimension 2 Code", Dim1);
        ConProcPlanLine.SetRange("No.", NoParam);
        ConProcPlanLine.SetRange("Document No", PlanName);
        if ConProcPlanLine.FindSet then begin
            ConProcPlanLine.CalcSums(Quantity);
            exit(ConProcPlanLine.Quantity);
        end;
    end;

    procedure GetPlannedAmount(Dim1: Code[50]; TypeParam: Enum "Purchase Line Type"; NoParam: Code[50]; PlanName: Text): Decimal
    var
        ConProcPlanLine: Record "Procurement Plan Lines";
    begin
        ConProcPlanLine.Reset;
        ConProcPlanLine.SetRange("Global Dimension 2 Code", Dim1);
        ConProcPlanLine.SetRange("No.", NoParam);
        ConProcPlanLine.SetRange("Document No", PlanName);
        if ConProcPlanLine.FindSet then begin
            ConProcPlanLine.CalcSums("Total Cost");
            exit(ConProcPlanLine."Total Cost");
        end;
    end;

    procedure GetRequisitionedQuantity(Dim1: Code[50]; NoParam: Text; PlanName: Text): Integer
    var
        RequsitionLines: Record "Requisition Lines";
    begin
        RequsitionLines.Reset;
        RequsitionLines.SetRange("Global Dimension 1 Code", Dim1);
        RequsitionLines.SetRange("No.", NoParam);
        RequsitionLines.SetRange("Procurement Plan", PlanName);
        //RequsitionLines.SETRANGE(Approved,TRUE);
        if RequsitionLines.FindSet then begin
            RequsitionLines.CalcSums(Quantity);
            exit(RequsitionLines.Quantity);
        end;
    end;

    procedure GetRequisitionedAmount(Dim1: Code[50]; Dim2: Code[50]; NoParam: Text; PlanNo: Text): Decimal
    var
        RequsitionLines: Record "Requisition Lines";
    begin
        RequsitionLines.Reset;
        RequsitionLines.SetRange("Global Dimension 1 Code", Dim1);
        RequsitionLines.SetRange("Global Dimension 2 Code", Dim2);
        RequsitionLines.SetRange("No.", NoParam);
        RequsitionLines.SetRange("Procurement Plan", PlanNo);
        if RequsitionLines.FindSet then begin
            RequsitionLines.CalcSums(Amount);
            exit(RequsitionLines.Amount);
        end;
    end;

    procedure GenerateSupplierMandatoryRequirements(VenderName: Text; RequirementCode: Code[100]; RequirementDescription: Text; EvaluatorId: Code[70]; EvaluatorNo: Code[50]; EvaluatorName: Text; LineNo: Integer; TenderNo: Code[100])
    var
        SupplierMandatoryEvaluation: Record "Supplier Mandatory Evaluation";
    begin
        with SupplierMandatoryEvaluation do begin
            Init;
            "Reference No" := TenderNo;
            "Requirement Code" := RequirementCode;
            "Requirement Description" := RequirementDescription;
            "Evaluator ID" := EvaluatorId;
            "Evaluator Name" := EvaluatorName;
            "Evaluator No." := EvaluatorNo;
            "Vendor Name" := VenderName;
            if not SupplierMandatoryEvaluation.Get(TenderNo, RequirementCode, EvaluatorId, VenderName) then Insert;
        end;
    end;

    procedure GenerateSupplierTechnicalRequirements(VenderName: Text; RequirementCode: Code[100]; RequirementDescription: Text; EvaluatorId: Code[70]; EvaluatorNo: Code[50]; EvaluatorName: Text; LineNo: Integer; TenderNo: Code[100]; MaxScore: Decimal)
    var
        SupplierTechEvaluation: Record "Supplier Technical Evaluation";
    begin
        with SupplierTechEvaluation do begin
            Init;
            "Reference No" := TenderNo;
            "Requirement Code" := RequirementCode;
            "Requirement Description" := RequirementDescription;
            "Evaluator ID" := EvaluatorId;
            "Evaluator Name" := EvaluatorName;
            "Evaluator No." := EvaluatorNo;
            "Vendor Name" := VenderName;
            "Max Score" := MaxScore;
            if not SupplierTechEvaluation.Get(TenderNo, RequirementCode, EvaluatorId, VenderName) then Insert;
        end;
    end;

    procedure GenerateSupplierFinacialEvaluation(VenderName: Text; TenderNo: Code[100]; Amount: Decimal; TechnicalScore: Decimal)
    var
        SupplierFinancialEvaluation: Record "Financial Evaluation";
    begin
        with SupplierFinancialEvaluation do begin
            Init;
            "Reference No." := TenderNo;
            "Vendor Name" := VenderName;
            "Quoted Amount" := Amount;
            "Technical Score" := TechnicalScore;
            if not SupplierFinancialEvaluation.Get(TenderNo, VenderName) then Insert;
        end;
    end;

    procedure CheckIfPassedMandatory(ReferenceNo: Code[100]; VendorName: Text): Boolean
    var
        SupplierMandatoryEvaluation: Record "Supplier Mandatory Evaluation";
    begin
        SupplierMandatoryEvaluation.Reset;
        SupplierMandatoryEvaluation.SetRange("Reference No", ReferenceNo);
        SupplierMandatoryEvaluation.SetRange("Vendor Name", VendorName);
        SupplierMandatoryEvaluation.SetRange(Complied, false);
        exit(SupplierMandatoryEvaluation.FindFirst);
    end;

    procedure CalculateVendorTotal(ReferenceNo: Code[30]; VendorName: Text): Decimal
    var
        SupplierTechnicalEvaluation: Record "Supplier Technical Evaluation";
    begin
        SupplierTechnicalEvaluation.Reset;
        SupplierTechnicalEvaluation.SetRange("Reference No", ReferenceNo);
        SupplierTechnicalEvaluation.SetRange("Vendor Name", VendorName);
        if SupplierTechnicalEvaluation.FindSet then begin
            SupplierTechnicalEvaluation.CalcSums(Score);
            exit(SupplierTechnicalEvaluation.Score);
        end;
    end;

    procedure UpdateSupplierIfPassedTechnical(ReferenceNo: Code[30]; VendorName: Text; Passed: Boolean)
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Vendor Name", VendorName);
        if TenderSuppliers.FindFirst then begin
            TenderSuppliers."Passed Technical" := Passed;
            TenderSuppliers.Modify(true);
        end;
    end;

    procedure UpdateSupplierIfPassedMandatory(ReferenceNo: Code[30]; VendorName: Text; Failed: Boolean)
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Vendor Name", VendorName);
        if TenderSuppliers.FindFirst then begin
            if Failed then
                TenderSuppliers."Passed Mandatory" := false
            else
                TenderSuppliers."Passed Mandatory" := true;
            TenderSuppliers.Modify(true);
        end;
    end;

    local procedure GetCalculateTotalScore(ReferenceNo: Code[50]): Code[50]
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        if TenderSuppliers.FindSet then begin
            repeat
                TenderSuppliers."Total Score" := TenderSuppliers."Financial Score" + TenderSuppliers."Technical Score";
                TenderSuppliers.Modify(true);
            until TenderSuppliers.Next = 0;
        end;
    end;

    procedure EndTenderProcess(ReferenceNo: Code[50])
    var
        FinancialScore: Decimal;
        TenderSuppliers: Record "Tender Suppliers";
        LeastScore: Decimal;
        MaxScore: Decimal;
        ProcurementRequest: Record "Procurement Request";
        Winner: Code[100];
    begin
        if ProcurementRequest.Get(ReferenceNo) then MaxScore := ProcurementRequest."Financial Score";
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Passed Mandatory", true);
        TenderSuppliers.SetRange("Passed Technical", true);
        if TenderSuppliers.FindSet then begin
            repeat
                LeastScore := GetLeastBidAmount(ReferenceNo);
                FinancialScore := CalculateFinancialScore(LeastScore, TenderSuppliers."Bid Amount", MaxScore);
                UpdateSupplierWithFinScore(ReferenceNo, TenderSuppliers."Vendor Name", FinancialScore);
                UpdateSupplierWithTotalScore(ReferenceNo, TenderSuppliers."Vendor Name", FinancialScore, TenderSuppliers."Technical Score");
            until TenderSuppliers.Next = 0;
        end;
        Winner := GetTenderWinner(ReferenceNo);
        Message('Winner is %1', Winner);
    end;

    local procedure GetTenderWinner(ReferenceNo: Code[50]): Text
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Passed Mandatory", true);
        TenderSuppliers.SetRange("Passed Technical", true);
        TenderSuppliers.SetCurrentKey("Total Score");
        TenderSuppliers.SetAscending("Total Score", true);
        if TenderSuppliers.FindLast then begin
            TenderSuppliers.Awarded := true;
            if TenderSuppliers.Modify then exit(TenderSuppliers."Vendor Name");
        end;
    end;

    local procedure GetLeastBidAmount(ReferenceNo: Code[50]): Decimal
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Passed Mandatory", true);
        TenderSuppliers.SetRange("Passed Technical", true);
        TenderSuppliers.SetCurrentKey("Bid Amount");
        TenderSuppliers.SetAscending("Bid Amount", true);
        if TenderSuppliers.FindFirst then exit(TenderSuppliers."Bid Amount");
    end;

    procedure GetNoofEvaluators(ReferenceNo: Code[30]): Integer
    var
        EvaluationCommittee: Record "Evaluation Committee";
    begin
        EvaluationCommittee.Reset;
        EvaluationCommittee.SetRange("Reference No", ReferenceNo);
        EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Technical);
        exit(EvaluationCommittee.Count);
    end;

    procedure EndTechnicalEvaluation(ProcurementRequest: Record "Procurement Request")
    var
        TenderSuppliers: Record "Tender Suppliers";
        TotalScore: Decimal;
        GetScore: Decimal;
        Passed: Boolean;
        CountFailed: Integer;
        CountPassed: Integer;
    begin
        with ProcurementRequest do begin
            TestField("Technical Pass Mark");
            TenderSuppliers.Reset;
            TenderSuppliers.SetRange("Reference No", "No.");
            if TenderSuppliers.FindSet then begin
                repeat
                    TotalScore := CalculateVendorTotal("No.", TenderSuppliers."Vendor Name");
                    GetScore := CalculateTechnicalScore(GetNoofEvaluators("No."), TotalScore, "Technical Score", "Tender Max Score");
                    UpdateSupplierWithScore("No.", TenderSuppliers."Vendor Name", GetScore);
                    if GetScore >= "Technical Pass Mark" then begin
                        Passed := true;
                        CountPassed += 1;
                    end
                    else begin
                        Passed := false;
                        CountFailed += 1;
                    end;
                    UpdateSupplierIfPassedTechnical("No.", TenderSuppliers."Vendor Name", Passed);
                until TenderSuppliers.Next = 0;
            end;
        end;
        Message('Technical evaluation has ended \ %1 suppliers passed \ %2 Failed', CountPassed, CountFailed);
    end;

    procedure EndMandatoryEvaluation(ProcurementRequest: Record "Procurement Request")
    var
        TenderSuppliers: Record "Tender Suppliers";
        Failed: Boolean;
        CountFailed: Integer;
        CountPassed: Integer;
    begin
        with ProcurementRequest do begin
            TestField("Technical Pass Mark");
            TenderSuppliers.Reset;
            TenderSuppliers.SetRange("Reference No", "No.");
            if TenderSuppliers.FindSet then begin
                repeat
                    Failed := CheckIfPassedMandatory("No.", TenderSuppliers."Vendor Name");
                    if Failed then begin
                        CountFailed += 1;
                    end
                    else begin
                        CountPassed += 1;
                    end;
                    UpdateSupplierIfPassedMandatory("No.", TenderSuppliers."Vendor Name", Failed);
                until TenderSuppliers.Next = 0;
            end;
        end;
        Message('Mandatory evaluation has ended \ %1 suppliers passed \ %2 Failed', CountPassed, CountFailed)
    end;

    procedure UpdateSupplierWithTotalScore(ReferenceNo: Code[30]; VendorName: Text; FinancialScore: Decimal; TechScore: Decimal)
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Vendor Name", VendorName);
        if TenderSuppliers.FindFirst then begin
            TenderSuppliers."Total Score" := FinancialScore + TechScore;
            TenderSuppliers.Modify(true);
        end;
    end;

    procedure UpdateSupplierWithFinScore(ReferenceNo: Code[30]; VendorName: Text; FinancialScore: Decimal)
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Vendor Name", VendorName);
        if TenderSuppliers.FindFirst then begin
            TenderSuppliers."Financial Score" := FinancialScore;
            TenderSuppliers.Modify(true);
        end;
    end;

    procedure CalculateFinancialScore(LeastScore: Decimal; SupplierScore: Decimal; FinacialMaxScore: Decimal): Decimal
    begin
        exit((LeastScore / SupplierScore) * FinacialMaxScore);
    end;

    procedure UpdateSupplierWithScore(ReferenceNo: Code[30]; VendorName: Text; TechnicalScore: Decimal)
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Vendor Name", VendorName);
        if TenderSuppliers.FindFirst then begin
            TenderSuppliers."Technical Score" := TechnicalScore;
            TenderSuppliers.Modify(true);
        end;
    end;

    procedure CalculateTechnicalScore(NoOfEvaluators: Integer; TotalScore: Decimal; MaxTechScore: Decimal; MaxTenderScore: Decimal): Decimal
    begin
        // exit(((TotalScore / NoOfEvaluators) / MaxTenderScore) * MaxTechScore);
        exit(TotalScore / NoOfEvaluators);
    end;

    procedure SubmitTechnicalScore(EvaluationCommittee: Record "Evaluation Committee")
    var
        SenderAddress: Text;
        SenderName: Text;
        Recepient: List of [Text];
        Subject: Text;
        Body: Text;
    begin
        with EvaluationCommittee do begin
            "Submitted Technical Evaluation" := true;
            if Modify(true) then begin
                PurchasePayablesSetup.Get;
                PurchasePayablesSetup.TestField("Procurement Officer User Id");
                if UserSetup.Get(PurchasePayablesSetup."Procurement Officer User Id") then begin
                    Clear(Recepient);
                    Recepient.Add(UserSetup."E-Mail");
                    Subject := 'Technical Evaluation Submition';
                    if Employee.Get(UserSetup."Employee No.") then Body := 'Dear ' + Format(Employee.FullName) + ' <br> ' + Format(EvaluationCommittee."Employee Name") + ' has submitted their ' + 'technical evaluation for tender No. ' + Format("Reference No") + '<br><br> This is a system generated E-mail ' + 'Please do not reply to it <br> Regards';
                    CommunicationMgmt.SendEmailWithoutAttachement(Recepient, Subject, Body);
                end;
                Message('Technical Evaluation successfully Submited');
            end;
        end;
    end;

    procedure CreatePurchaseHeader(VendorNo: Code[50]; TenderNo: Code[100]; RequistionNo: Code[100]; RFQNo: Code[100]; RFPNo: Code[100]; ContractNo: Code[100]; "Require Inspection": Boolean; Dim1: Code[20]; Dim2: Code[20]): Code[70]
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        PurchaseHeader: Record "Purchase Header";
        InvoiceNo: Code[50];
        ProcurementRequest: Record "Procurement Request";
    begin
        with PurchaseHeader do begin
            Init;
            Validate("Document Type", "Document Type"::Order);
            Validate("Buy-from Vendor No.", VendorNo);
            PurchasesPayablesSetup.Get;
            InvoiceNo := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Order Nos.", 0D, true);
            Validate("No.", InvoiceNo);
            // Validate("Document Date", Today);
            // "Tender No" := TenderNo;
            // "Contract No" := ContractNo;
            // "Requisition No" := RequistionNo;
            // "Requires Inspection" := "Require Inspection";
            // "RFP No" := RFPNo;
            // "RFQ No" := RFQNo;
            "Raised By" := UserId;
            "Shortcut Dimension 1 Code" := Dim1;
            "Shortcut Dimension 2 Code" := Dim2;
            // "From Procurement" := true;
            Insert;
            //PurchaseHeader.Reset;
            //PurchaseHeader.SetRange(Procu, ProcurementRequest."No.");
            // if PurchaseHeader.FindFirst then begin
            //     PurchaseHeader."Order Type" := PurchaseHeader."Order Type"::"3";
            //     PurchaseHeader.Modify;
            // end;
        end;
        exit(InvoiceNo)
    end;

    procedure CreatePurchaseLines(InvoiceNo: Code[50]; TypeParam: Option "G/L Account","Fixed Asset",Item,"Medical Item"; No: Code[50]; QuantityParam: Integer; UnitPrice: Decimal; LocationParam: Code[50]; GlobalDim1: Code[50]; GlobalDim2: Code[50]; DescriptionParam: Text[250]; dimsetid: Integer; UnitOfMeasureParam: Code[20]): Boolean
    var
        PurchaseLine: Record "Purchase Line";
        GLAccount: Record "G/L Account";
        FixedAsset: Record "Fixed Asset";
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseLine.Init;
        PurchaseLine.Validate("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.Validate("Document No.", InvoiceNo);
        PurchaseLine.Validate("Document No.");
        if TypeParam in [TypeParam::"Fixed Asset"] then PurchaseLine.Validate(Type, PurchaseLine.Type::"Fixed Asset");
        if TypeParam in [TypeParam::"G/L Account"] then PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
        if TypeParam in [TypeParam::Item, TypeParam::"Medical Item"] then PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine."No." := No;
        PurchaseLine.Description := DescriptionParam;
        if TypeParam in [TypeParam::"Fixed Asset"] then begin
            if PurchaseLine."No." <> '' then begin
                FixedAsset.Get(PurchaseLine."No.");
                //        PurchaseLine.Description:=FixedAsset.Description + ' '+DescriptionParam;
                PurchaseLine.Validate("No.");
                PurchaseLine."FA Posting Type" := PurchaseLine."FA Posting Type"::Maintenance;
            end;
        end;
        if TypeParam in [TypeParam::"G/L Account"] then begin
            if GLAccount.Get(PurchaseLine."No.") then PurchaseLine.Description := GLAccount.Name;
            PurchaseLine.Validate("No.");
        end;
        if TypeParam in [TypeParam::Item, TypeParam::"Medical Item"] then begin
            if PurchaseLine."No." <> '' then begin
                Item.Get(PurchaseLine."No.");
                PurchaseLine.Description := Item.Description;
                PurchaseLine.Validate("No.");
            end;
        end;
        PurchaseLine.Quantity := QuantityParam;
        if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, InvoiceNo) then PurchaseLine.Validate("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
        PurchaseLine.Validate(Quantity);
        PurchaseLine."Unit of Measure" := UnitOfMeasureParam;
        PurchaseLine."Unit Cost" := UnitPrice;
        PurchaseLine."Direct Unit Cost" := UnitPrice;
        PurchaseLine.Validate("Direct Unit Cost");
        PurchaseLine."Line Amount" := PurchaseLine.Quantity * UnitPrice;
        PurchaseLine."Location Code" := LocationParam;
        PurchaseLine."Shortcut Dimension 1 Code" := GlobalDim1;
        PurchaseLine."Shortcut Dimension 2 Code" := GlobalDim2;
        PurchaseLine."Dimension Set ID" := dimsetid;
        //PurchaseLine.Description:=DescriptionParam;
        PurchaseLine."Line No." := PurchaseLine.Count + 1;
        PurchaseLine.Validate("Document No.");
        PurchaseLine.Insert;
    end;

    procedure StartTenderMandatoryEvaluation(var ProcurementRequest: Record "Procurement Request")
    var
        TenderSuppliers: Record "Tender Suppliers";
        EvaluationCommittee: Record "Evaluation Committee";
        TechnicalSpecifications: Record "Mandatory Requirements";
        Recepient: List of [Text];
        Subject: Text;
        Body: Text;
        PurchPayablesSetup: Record "Purchases & Payables Setup";
        Employee: Record Employee;
        UserSetup: Record "User Setup";
        ProgressWindow: Dialog;
    begin
        with ProcurementRequest do begin
            TenderSuppliers.Reset;
            TenderSuppliers.SetRange("Reference No", "No.");
            if TenderSuppliers.FindSet then begin
                ProgressWindow.Open('Setting Up For : #1################ \ Creating Evaluation records For : #2################# Creating Mand. Spec. : #3####################');
                repeat
                    ProgressWindow.Update(1, TenderSuppliers."Vendor Name");
                    EvaluationCommittee.Reset;
                    EvaluationCommittee.SetRange("Reference No", "No.");
                    EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Mandatory);
                    if EvaluationCommittee.FindSet then begin
                        repeat
                            Sleep(100);
                            ProgressWindow.Update(2, EvaluationCommittee."User Name");
                            TechnicalSpecifications.Reset;
                            TechnicalSpecifications.SetRange("Reference No", "No.");
                            if TechnicalSpecifications.FindSet then begin
                                repeat
                                    Sleep(100);
                                    ProgressWindow.Update(3, TechnicalSpecifications."Requirement Description");
                                    Sleep(100);
                                    GenerateSupplierMandatoryRequirements(TenderSuppliers."Vendor Name", TechnicalSpecifications."Requirement Code", TechnicalSpecifications."Requirement Description", EvaluationCommittee."User Name", EvaluationCommittee."Employee No.", EvaluationCommittee."Employee Name", 0, "No.");
                                until TechnicalSpecifications.Next = 0;
                            end;
                        until EvaluationCommittee.Next = 0;
                    end;
                until TenderSuppliers.Next = 0;
                ProgressWindow.Close();
            end;
            "Tender Status" := "Tender Status"::"Mandatory Req Evaluation";
            "Date of Mandatory Evaluation" := WorkDate;
            if Modify(true) then begin
                PurchPayablesSetup.Get;
                EvaluationCommittee.Reset;
                EvaluationCommittee.SetRange("Reference No", "No.");
                EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Mandatory);
                if EvaluationCommittee.FindSet then begin
                    ProgressWindow.Open('Notifying Evaluation Commitee Member : #1#########################');
                    repeat
                        Clear(Recepient);
                        ProgressWindow.Update(1, EvaluationCommittee."Employee Name");
                        Sleep(100);
                        if UserSetup.Get(EvaluationCommittee."User Name") then Recepient.Add(UserSetup."E-Mail");
                        Subject := 'Mandatory Evaluation Invitation';
                        Body := 'Dear ' + Format(EvaluationCommittee."Employee Name") + ' <br> Mandatory Evaluation for tender No ' + Format("No.") + ' has been initiated and you are invited to start the evaluation ' + '<br><br> This is a system generated E-mail ' + 'Please do not reply to it <br> Regards';
                        CommunicationMgmt.SendEmailWithoutAttachement(Recepient, Subject, Body);
                    until EvaluationCommittee.Next = 0;
                    ProgressWindow.Close();
                end;
                Message('Tender Successfully moved to mandatory evaluation');
            end;
        end;
    end;

    procedure StartTenderTechnicalEvaluation(ProcurementRequest: Record "Procurement Request")
    var
        TenderSuppliers: Record "Tender Suppliers";
        EvaluationCommittee: Record "Evaluation Committee";
        TechnicalSpecifications: Record "Technical Specifications";
        SenderAddress: Text;
        SenderName: Text;
        Recepient: List of [Text];
        Subject: Text;
        Body: Text;
        PurchPayablesSetup: Record "Purchases & Payables Setup";
        Employee: Record Employee;
        UserSetup: Record "User Setup";
        ProgressWindow: Dialog;
    begin
        with ProcurementRequest do begin
            EndMandatoryEvaluation(ProcurementRequest);
            TenderSuppliers.Reset;
            TenderSuppliers.SetRange("Reference No", "No.");
            TenderSuppliers.SetRange("Passed Mandatory", true);
            if TenderSuppliers.FindSet then begin
                ProgressWindow.Open('Setting Up For : #1################ \ Creating Evaluation records For : #2################# Creating Tech. Spec. : #3####################');
                repeat
                    ProgressWindow.Update(1, TenderSuppliers."Vendor Name");
                    Sleep(100);
                    EvaluationCommittee.Reset;
                    EvaluationCommittee.SetRange("Reference No", "No.");
                    EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Technical);
                    if EvaluationCommittee.FindSet then begin
                        repeat
                            ProgressWindow.Update(2, EvaluationCommittee."Employee Name");
                            Sleep(100);
                            TechnicalSpecifications.Reset;
                            TechnicalSpecifications.SetRange("Reference No.", "No.");
                            if TechnicalSpecifications.FindSet then begin
                                repeat
                                    ProgressWindow.Update(3, TechnicalSpecifications."Requirement Specification");
                                    Sleep(100);
                                    GenerateSupplierTechnicalRequirements(TenderSuppliers."Vendor Name", TechnicalSpecifications."Requirement Code", TechnicalSpecifications."Requirement Specification", EvaluationCommittee."User Name", EvaluationCommittee."Employee No.", EvaluationCommittee."Employee Name", 0, "No.", TechnicalSpecifications."Max Weigth");
                                until TechnicalSpecifications.Next = 0;
                            end;
                        until EvaluationCommittee.Next = 0;
                    end;
                until TenderSuppliers.Next = 0;
                ProgressWindow.Close();
            end
            else begin
                Message('No supplier passed Mandatory');
                exit;
            end;
            "Tender Status" := "Tender Status"::"Technical Req Evaluation";
            "Date of Technical Evaluation" := WorkDate;
            if Modify(true) then begin
                PurchPayablesSetup.Get;
                EvaluationCommittee.Reset;
                EvaluationCommittee.SetRange("Reference No", "No.");
                EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Technical);
                if EvaluationCommittee.FindSet then begin
                    ProgressWindow.Open('Notifying Evaluation Member : #1#######################');
                    repeat
                        Clear(Recepient);
                        ProgressWindow.Update(1, EvaluationCommittee."Employee Name");
                        Sleep(100);
                        if UserSetup.Get(EvaluationCommittee."User Name") then Recepient.Add(UserSetup."E-Mail");
                        Subject := 'Technical Evaluation Invitation';
                        Body := 'Dear ' + Format(EvaluationCommittee."Employee Name") + ' <br> Technical Evaluation for tender No ' + Format("No.") + 'has been initiated and you are invited to start the evaluation ' + '<br><br> This is a system generated E-mail ' + 'Please do not reply to it <br> Regards';
                        CommunicationMgmt.SendEmailWithoutAttachement(Recepient, Subject, Body);
                    until EvaluationCommittee.Next = 0;
                    ProgressWindow.Close();
                end;
                Message('Tender Successfully moved to technical evaluation');
            end;
        end;
    end;

    procedure StartTenderFinancialEvaluation(ProcurementRequest: Record "Procurement Request")
    var
        TenderSuppliers: Record "Tender Suppliers";
        ProgressWindow: Dialog;
    begin
        with ProcurementRequest do begin
            EndTechnicalEvaluation(ProcurementRequest);
            TenderSuppliers.Reset;
            TenderSuppliers.SetRange("Reference No", "No.");
            TenderSuppliers.SetRange("Passed Technical", true);
            if TenderSuppliers.FindSet then begin
                ProgressWindow.Open('Creating Financial Evaluation For : #1###########################');
                repeat
                    ProgressWindow.Update(1, TenderSuppliers."Vendor Name");
                    Sleep(100);
                    TenderSuppliers.TestField("Bid Amount");
                    GenerateSupplierFinacialEvaluation(TenderSuppliers."Vendor Name", "No.", TenderSuppliers."Bid Amount", TenderSuppliers."Technical Score");
                until TenderSuppliers.Next = 0;
                ProgressWindow.Close();
            end
            else begin
                Message('No supplier passed technical');
                exit;
            end;
            "Tender Status" := "Tender Status"::"Financial Evaluation";
            "Date of Financial Evaluation" := WorkDate;
            if Modify(true) then Message('Tender Successfully moved to financial evaluation');
        end;
    end;

    procedure ChangeStatusToOrderCreated(ProcurementRequest: Record "Procurement Request"; OrderNo: Code[50])
    begin
        with ProcurementRequest do begin
            "Tender Status" := "Tender Status"::"Order Created";
            "Generated Order No" := OrderNo;
            "Date Awarded" := WorkDate;
            if Modify(true) then Message('Order No [%1] successfully created', OrderNo);
        end;
    end;

    procedure ChangeStatusToContractCreated(ProcurementRequest: Record "Procurement Request"; ContractNo: Code[50])
    begin
        with ProcurementRequest do begin
            "Tender Status" := "Tender Status"::"Contract Created";
            "Contract No Generated" := ContractNo;
            "Date Awarded" := WorkDate;
            if Modify(true) then Message('Contract No [%1] successfully created', ContractNo);
        end;
    end;

    procedure MoveTenderToAdvertisementStage(ProcurementRequest: Record "Procurement Request")
    begin
        with ProcurementRequest do begin
            "Tender Status" := "Tender Status"::Advertised;
            "Date Advertisement" := WorkDate;
            if Modify(true) then Message('Tender Successfully moved to advertised staged');
        end;
    end;

    procedure CreateContractHeader(VendorNo: Code[50]; TenderNo: Code[100]; RequistionNo: Code[100]): Code[70]
    var
        PurchPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ContractHeader: Record "Contract Header";
        ContractNo: Code[50];
    begin
        with ContractHeader do begin
            Init;
            PurchPayablesSetup.Get;
            ContractNo := NoSeriesManagement.GetNextNo(PurchPayablesSetup."Contract Nos", 0D, true);
            "No." := ContractNo;
            "Vendor No." := VendorNo;
            Validate("Vendor No.");
            "Tender No." := TenderNo;
            Validate("Tender No.");
            "Requisition No" := RequistionNo;
            Insert;
        end;
        exit(ContractNo)
    end;

    procedure CreateContractLines(ContractNo: Code[50]; ProcurementRequestLines: Record "Procurement Request Lines"): Boolean
    var
        ContractLines: Record "Contract Lines";
    begin
        ContractLines.Init;
        ContractLines.TransferFields(ProcurementRequestLines);
        ContractLines."Contract No." := ContractNo;
        ContractLines.Insert;
    end;

    procedure CreateVendorToAward(VendorName: Text; EmailAddress: Code[10]; PhoneNo: Code[10]; VendorCategoryParam: Code[100]): Code[100]
    var
        Vendor: Record Vendor;
        SUpplierApplication: Record "Supplier Application";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        VendorNoAssigned: Code[100];
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        SUpplierApplication.Reset;
        SUpplierApplication.SetRange(Name, VendorName);
        if SUpplierApplication.FindFirst then begin
            SUpplierApplication.TestField("Gen. Bus. Posting Group");
            SUpplierApplication.TestField("VAT Bus. Posting Group");
            SUpplierApplication.TestField("Vendor Posting Group");
            PurchasesPayablesSetup.Get;
            PurchasesPayablesSetup.TestField("Vendor Nos.");
            VendorNoAssigned := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Vendor Nos.", 0D, true);
            with Vendor do begin
                Init;
                "No." := VendorNoAssigned;
                Validate("No.");
                Name := SUpplierApplication.Name;
                "Account Type" := "Account Type"::Supplier;
                "E-Mail" := EmailAddress;
                "Phone No." := PhoneNo;
                "Gen. Bus. Posting Group" := SUpplierApplication."Gen. Bus. Posting Group";
                Validate("Gen. Bus. Posting Group");
                "VAT Bus. Posting Group" := SUpplierApplication."VAT Bus. Posting Group";
                Validate("VAT Bus. Posting Group");
                "Vendor Posting Group" := SUpplierApplication."Vendor Posting Group";
                Validate("Vendor Posting Group");
                if VendorNoAssigned <> '' then Insert;
            end;
        end;
        exit(VendorNoAssigned);
    end;

    procedure CreateVendor(SupplierNo: Code[20]; EmailAddress: Code[10]; PhoneNo: Code[10]; VendorCategoryParam: Code[100])
    var
        Vendor: Record Vendor;
        SUpplierApplication: Record "Supplier Application";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        VendorNoAssigned: Code[100];
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        SUpplierApplication.Reset;
        SUpplierApplication.SetRange("No.", SupplierNo);
        if SUpplierApplication.FindFirst then begin
            SUpplierApplication.TestField("Gen. Bus. Posting Group");
            SUpplierApplication.TestField("VAT Bus. Posting Group");
            SUpplierApplication.TestField("Vendor Posting Group");
            PurchasesPayablesSetup.Get;
            PurchasesPayablesSetup.TestField("Vendor Nos.");
            VendorNoAssigned := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Vendor Nos.", 0D, true);
            with Vendor do begin
                Init;
                "No." := VendorNoAssigned;
                Validate("No.");
                Name := SUpplierApplication.Name;
                "Account Type" := "Account Type"::Supplier;
                "E-Mail" := EmailAddress;
                "Phone No." := PhoneNo;
                "Gen. Bus. Posting Group" := SUpplierApplication."Gen. Bus. Posting Group";
                Validate("Gen. Bus. Posting Group");
                "VAT Bus. Posting Group" := SUpplierApplication."VAT Bus. Posting Group";
                Validate("VAT Bus. Posting Group");
                "Vendor Posting Group" := SUpplierApplication."Vendor Posting Group";
                Validate("Vendor Posting Group");
                if VendorNoAssigned <> '' then Insert;
            end;
        end;
    end;

    procedure SendQuoteToSuppliers(VendorNo: Code[10]; VendorName: Text; EmailAddress: List of [Text]; AttachementFilePath: Text; AttachementName: Text)
    var
        CommunicationsMgmt: Codeunit "Communications Mgmt";
        Body: Text;
        Subject: Text;
    begin
        Subject := 'Invitation For Quote';
        Body := 'Hello <br> You have been invited for a quotation at COGRI' + ' Please log in to the portal and submit your bids <br>' + ' This is a system generated Mail, Please dont reply to it <Br>Regards';
        CommunicationsMgmt.SendEmailWithoutAttachement(EmailAddress, Subject, Body);
    end;

    procedure SendTenderToSuppliers(VendorNo: Code[10]; VendorName: Text; EmailAddress: list of [Text]; AttachementFilePath: Text; AttachementName: Text; ClosingDate: Date)
    var
        CommunicationsMgmt: Codeunit "Communications Mgmt";
        Body: Text;
        Subject: Text;
    begin
        Subject := 'Invitation For Tender';
        Body := 'Hello <br> You have been invited for tendering at COGRI' + ' Please log in to the portal and submit your bids <br>' + ' This is a system generated Mail, Please dont reply to it <Br>Regards';
        CommunicationsMgmt.SendEmailWithoutAttachement(EmailAddress, Subject, Body);
    end;

    procedure ChangeStatusOnVendorInvitation(ProcurementRequest: Record "Procurement Request")
    begin
        with ProcurementRequest do begin
            "Quotation Status" := "Quotation Status"::"Supplier Invitation";
            "Date Advertisement" := WorkDate;
            if Modify(true) then Message('Invitation Successfully Sent');
        end;
    end;

    procedure StartQuotationEvaluation(var ProcurementRequest: Record "Procurement Request")
    var
        QuotationBidders: Record "Quotation Bidders";
        ProcurementRequestLines: Record "Procurement Request Lines";
    begin
        with ProcurementRequest do begin
            ProcurementRequestLines.Reset;
            ProcurementRequestLines.SetRange("Procurement No", "No.");
            if ProcurementRequestLines.FindSet then begin
                repeat
                    QuotationBidders.Reset;
                    QuotationBidders.SetRange("Reference No", "No.");
                    if QuotationBidders.FindSet then begin
                        repeat
                            CreateVendorBidsLines("No.", QuotationBidders."Vendor No.", QuotationBidders."Vendor Name", ProcurementRequestLines."Line No.", ProcurementRequestLines."No.", ProcurementRequestLines.Name, ProcurementRequestLines.Description, ProcurementRequestLines.Quantity);
                        until QuotationBidders.Next = 0;
                    end;
                until ProcurementRequestLines.Next = 0;
            end;
            Message('Quotation successfuly moved to evaluation');
        end;
    end;

    local procedure CreateVendorBidsLines(QuoteNo: Code[100]; VendorNo: Code[100]; VendorName: Text; LineNo: Integer; ItemNo: Code[100]; ItemName: Text; LineDescription: Text; QuantityVar: Integer)
    var
        QuotationBidders: Record "Quotation Bidders";
        QuotationVendorsBids: Record "Quotation Vendors Bids";
    begin
        with QuotationVendorsBids do begin
            Init;
            "Quote No" := QuoteNo;
            "Vendor No" := VendorNo;
            "Vendor Name" := VendorName;
            "Line No" := LineNo;
            "Item No" := ItemNo;
            "Item Name" := ItemName;
            Description := Description;
            Quantity := QuantityVar;
            Insert;
        end;
    end;

    procedure InitiateProcurementProcess(RequisitionHeader: Record "Requisition Header"): Code[50]
    var
        RequisitionLines: Record "Requisition Lines";
        ProcurementRequest: Record "Procurement Request";
        ProcurementRequestLines: Record "Procurement Request Lines";
        ProcurementNo: Code[50];
    begin
        with RequisitionHeader do begin
            case "Procurement Method" of
                "Procurement Method"::"Open Tendering", "Procurement Method"::"Restricted Tendering":
                    begin
                        RequisitionLines.Reset;
                        RequisitionLines.SetRange("Requisition No", "No.");
                        if RequisitionLines.FindFirst then begin
                            ProcurementNo := CreateProcurementHeader(RequisitionHeader, "Procurement Method");
                            repeat
                                CreateProcurementLines(RequisitionLines, ProcurementNo);
                            until RequisitionLines.Next = 0;
                        end;
                    end;
                "Procurement Method"::RFP:
                    begin
                        RequisitionLines.Reset;
                        RequisitionLines.SetRange("Requisition No", "No.");
                        if RequisitionLines.FindFirst then begin
                            ProcurementNo := CreateProcurementHeader(RequisitionHeader, "Procurement Method");
                            repeat
                                CreateProcurementLines(RequisitionLines, ProcurementNo);
                            until RequisitionLines.Next = 0;
                        end;
                    end;
                "Procurement Method"::RFQ:
                    begin
                        RequisitionLines.Reset;
                        RequisitionLines.SetRange("Requisition No", "No.");
                        if RequisitionLines.FindFirst then begin
                            ProcurementNo := CreateProcurementHeader(RequisitionHeader, "Procurement Method");
                            repeat
                                CreateProcurementLines(RequisitionLines, ProcurementNo);
                            until RequisitionLines.Next = 0;
                        end;
                    end;
                "Procurement Method"::"Direct Procurement", "Procurement Method"::"Low Value Procurement":
                    begin
                        ProcurementNo := GenerateOrderFromRequisition(RequisitionHeader);
                    end;
            end;
            if ProcurementNo <> '' then begin
                RequisitionHeader."Process Initiated" := true;
                RequisitionHeader.Modify(true);
            end;
        end;
        exit(ProcurementNo);
    end;

    local procedure CreateProcurementHeader(RequisitionHeader: Record "Requisition Header"; ProcurementMethod: Enum "Procurement Methods"): Code[50]
    var
        ProcurementRequest: Record "Procurement Request";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ProcurementNo: Code[50];
    begin
        with ProcurementRequest do begin
            if ProcurementMethod in [ProcurementMethod::"Open Tendering", ProcurementMethod::"Restricted Tendering"] then begin
                PurchasesPayablesSetup.Get;
                PurchasesPayablesSetup.TestField("Tender Nos");
                ProcurementNo := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Tender Nos", 0D, true);
            end;
            if ProcurementMethod in [ProcurementMethod::RFQ] then begin
                PurchasesPayablesSetup.Get;
                PurchasesPayablesSetup.TestField("Request for Quotation Nos.");
                ProcurementNo := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Request for Quotation Nos.", 0D, true);
            end;
            if ProcurementMethod in [ProcurementMethod::RFP] then begin
                PurchasesPayablesSetup.Get;
                PurchasesPayablesSetup.TestField("RFP Nos");
                ProcurementNo := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."RFP Nos", 0D, true);
            end;
            if ProcurementMethod in [ProcurementMethod::"Direct Procurement", ProcurementMethod::"Low Value Procurement"] then begin
                PurchasesPayablesSetup.Get;
                PurchasesPayablesSetup.TestField("Direct Procurement Nos");
                ProcurementNo := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Direct Procurement Nos", 0D, true);
            end;
            Init;
            "No." := ProcurementNo;
            "Requisiton No" := RequisitionHeader."No.";
            "Global Dimension 1 Code" := RequisitionHeader."Global Dimension 1 Code";
            "Global Dimension 2 Code" := RequisitionHeader."Global Dimension 2 Code";
            "Current Budget" := RequisitionHeader."Current Budget";
            Title := RequisitionHeader.Description;
            "Procurement Plan" := RequisitionHeader."Plan Name";
            "Created By" := UserId;
            "Creation Date" := WorkDate;
            Description := RequisitionHeader.Description;
            "Procurement Method" := ProcurementMethod;
            Validate("Procurement Method");
            if RequisitionHeader."Requisition Type" = RequisitionHeader."Requisition Type"::"FA Maintenance" then "Original Doc. Type" := "Original Doc. Type"::Maintenance;
            Insert;
        end;
        exit(ProcurementNo);
    end;

    local procedure CreateProcurementLines(RequisitionLines: Record "Requisition Lines"; ProcurementNo: Code[50])
    var
        ProcurementRequestLines: Record "Procurement Request Lines";
    begin
        ProcurementRequestLines.Init;
        ProcurementRequestLines."Procurement No" := ProcurementNo;
        ProcurementRequestLines."Line No." := RequisitionLines."Line No";
        ProcurementRequestLines.Validate(Type, RequisitionLines.Type);
        ProcurementRequestLines.Validate("No.", RequisitionLines."No.");
        ProcurementRequestLines."Unit of Measure" := RequisitionLines."Unit of Measure";
        ProcurementRequestLines.Validate(Quantity, RequisitionLines.Quantity);
        ProcurementRequestLines.Validate("Unit Price", RequisitionLines."Unit Price");
        ProcurementRequestLines.Validate("Location Code", RequisitionLines."Location Code");
        ProcurementRequestLines.Insert(true);
    end;

    procedure GetRequisitionsToRFQ(var RFQ: Record "RFQ Header")
    var
        RFQLines: Record "RFQ Lines";
        RequisitionHeader: Record "Requisition Header";
        RequisitionLines: Record "Requisition Lines";
        LineNo: Integer;
        RequisitionsPage: Page "Purchase Requisitions";
        SelectedRecord: Record "Requisition Header";
        RequestHeader: Record "Requisition Header";
    begin
        with RFQ do begin
            LineNo := 10000;
            RequisitionHeader.Reset;
            RequisitionHeader.SetCurrentKey("No.");
            RequisitionHeader.SetRange("Requisition Type", RequisitionHeader."Requisition Type"::"Purchase Requisition");
            RequisitionHeader.SetRange(Status, RequisitionHeader.Status::Approved);
            RequisitionHeader.SetFilter("Procurement Method", '%1|%2', RequisitionHeader."Procurement Method"::RFP, RequisitionHeader."Procurement Method"::RFQ);
            RequisitionHeader.SetRange("PR Closed", false);
            RequisitionsPage.SetTableView(RequisitionHeader);
            RequisitionsPage.LookupMode(true);
            if RequisitionsPage.RunModal = ACTION::LookupOK then begin
                SelectedRecord := RequisitionHeader;
                RequisitionsPage.SetSelectionFilter(SelectedRecord);
                if SelectedRecord.Find('-') then begin
                    repeat
                        "Requisition No." := SelectedRecord."No.";
                        Description := SelectedRecord.Description;
                        "Global Dimension 1 Code" := SelectedRecord."Global Dimension 1 Code";
                        "Global Dimension 2 Code" := SelectedRecord."Global Dimension 2 Code";
                        "Location Code" := SelectedRecord."Location Code";
                        Modify; //Insert requisition items into the Lines
                        Window.Open('Fetching Requisition Details for #####1', Names);
                        RequisitionLines.Reset;
                        RequisitionLines.SetRange("Requisition No", SelectedRecord."No.");
                        if RequisitionLines.Find('-') then begin
                            repeat
                                LineNo := LineNo + 1000;
                                RFQLines.Init;
                                RFQLines."RFQ No" := RFQ."No.";
                                RFQLines."Line No" := LineNo;
                                if RequisitionLines.Type = RequisitionLines.Type::"G/L Account" then begin
                                    RFQLines.Type := RFQLines.Type::"G/L Account";
                                    RFQLines.No := RequisitionLines."No.";
                                end
                                else if RequisitionLines.Type = RequisitionLines.Type::Item then begin
                                    RFQLines.Type := RFQLines.Type::Item;
                                    RFQLines.No := RequisitionLines."No.";
                                end
                                else if RequisitionLines.Type = RequisitionLines.Type::"Fixed Asset" then begin
                                    RFQLines.Type := RFQLines.Type::"Fixed Asset";
                                    RFQLines.No := RequisitionLines."No.";
                                end;
                                RFQLines.Description := RequisitionLines.Description;
                                RFQLines."Unit of Measure" := RequisitionLines."Unit of Measure";
                                if RequisitionLines."Quantity Approved" <> 0 then
                                    RFQLines.Quantity := RequisitionLines."Quantity Approved"
                                else
                                    RFQLines.Quantity := RequisitionLines.Quantity;
                                RFQLines."Currency Code" := RequisitionLines."Currency Code";
                                RFQLines."Store of Delivery" := RequisitionLines."Location Code";
                                RFQLines."Requisition No" := SelectedRecord."No.";
                                RFQLines."Req Line No" := RequisitionLines."Line No";
                                if RequestHeader.Get(SelectedRecord."No.") then begin
                                    RFQLines."Global Dimension 1 Code" := RequestHeader."Global Dimension 1 Code";
                                    RFQLines."Global Dimension 2 Code" := RequestHeader."Global Dimension 2 Code";
                                    RFQLines."Responsibility Center" := RequestHeader."Global Dimension 3 Code";
                                    //RFQLines."Cost Center" := RequestHeader."Cost Center";
                                end;
                                RFQLines."Catalog No." := RequisitionLines."Catalog No.";
                                RFQLines.MFR := RequisitionLines.MFR;
                                RFQLines.Insert;
                                Window.Update(1, RequisitionLines.Description);
                            until RequisitionLines.Next = 0;
                        end; //Requisition Lines FIND
                    until SelectedRecord.Next = 0;
                end;
                Window.Close;
            end; //Page Lookup
        end; //RFQ Header
    end;

    procedure GenerateQuote(var RFQNo: Code[20]; var VendorNo: Code[20])
    var
        QuoteHeader: Record "Purchase Header";
        QuoteLines: Record "Purchase Line";
        RFQ: Record "RFQ Header";
        RFQLines: Record "RFQ Lines";
        LineNo: Integer;
        RFQVendors: Record "RFQ Vendors";
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        PurchPayablesSetup: Record "Purchases & Payables Setup";
        QuoteNo: Code[20];
    begin
        /*//Check if quote had been generated
        IF NOT RFQVendors.GET(RFQNo,VendorNo) THEN
        */
        if RFQ.Get(RFQNo) then begin
            //Quote Header
            PurchPayablesSetup.Get();
            PurchPayablesSetup.TestField("Quote Nos.");
            QuoteHeader.Init;
            QuoteHeader."No." := NoSeriesMgmt.GetNextNo(PurchPayablesSetup."Quote Nos.", WorkDate(), true);
            QuoteHeader."Document Type" := QuoteHeader."Document Type"::Quote;
            QuoteHeader.Validate("Document Type");
            QuoteHeader.Insert();
            QuoteHeader."Requisition No" := RFQ."Requisition No.";
            QuoteHeader.Validate("Buy-from Vendor No.", VendorNo);
            QuoteHeader."Requisition No" := RFQ."Requisition No.";
            QuoteHeader."Location Code" := RFQ."Location Code";
            If QuoteHeader.Modify(true) then begin
                //Quote Lines
                LineNo := 10000;
                RFQLines.Reset;
                RFQLines.SetRange("RFQ No", RFQNo);
                if RFQLines.Find('-') then begin
                    repeat
                        LineNo := LineNo + 1000;
                        QuoteLines.Init;
                        QuoteLines."Document Type" := QuoteLines."Document Type"::Quote;
                        QuoteLines.Validate("Document Type");
                        QuoteLines."Document No." := QuoteHeader."No.";
                        QuoteLines.Validate("Document No.");
                        QuoteLines."Line No." := LineNo;
                        QuoteLines.Insert();
                        QuoteLines.Type := RFQLines.Type;
                        QuoteLines.Validate("No.", RFQLines.No);
                        QuoteLines.Description := RFQLines.Description;
                        QuoteLines."Location Code" := RFQLines."Store of Delivery";
                        QuoteLines."Catalog No." := RFQLines."Catalog No.";
                        QuoteLines.MFR := RFQLines.MFR;
                        QuoteLines.Validate(Quantity, RFQLines.Quantity);
                        QuoteLines.Validate("Unit of Measure Code", RFQLines."Unit of Measure");
                        QuoteLines.Validate("Shortcut Dimension 1 Code", RFQLines."Global Dimension 1 Code");
                        QuoteLines.Validate("Shortcut Dimension 2 Code", RFQLines."Global Dimension 2 Code");
                        //QuoteLines."Shortcut Dimension 3 Code" := RFQLines."Responsibility Center";
                        //QuoteLines."Cost Center" := RFQLines."Cost Center";
                        //QuoteLines.ValidateShortcutDimCode(3,RFQLines."Cost Center");
                        QuoteLines."RFQ No" := RFQNo;
                        QuoteLines.Modify(true);
                    until RFQLines.Next = 0;
                end;
            end;
            //Update RFQ Vendor with the quote no
            if RFQVendors.Get(RFQNo, VendorNo) then begin
                RFQVendors."Quote No" := QuoteHeader."No.";
                RFQVendors.Modify;
            end;
            Message('Quote No: %1 generated for Vendor: %2', QuoteHeader."No.", QuoteHeader."Buy-from Vendor Name");
            PAGE.Run(Page::"Purchase Quote", QuoteHeader);
        end;
    end;

    procedure GenerateOrderFromRequisition(var Requisition: Record "Requisition Header"): Code[20]
    var
        PurchOrderHeader: Record "Purchase Header";
        PurchOrderLine: Record "Purchase Line";
        RequisitionLines: Record "Requisition Lines";
        DocumentAttachment: array[2] of Record "Document Attachment";
        VendorRec: Record Vendor;
        Text001: Label 'Please make sure the Payment Details have been set on Vendors Card!';
        Text003: Label 'Vendor No.: %1, classification can not be empty in the vendor.';
    begin
        with Requisition do begin
            if Status <> Status::Approved then Error('This requisition has not been fully approved.');
            if "PO Generated Directly" then Error('A Purchase Order No. %1 has already been generated for this Requisition.', "PO Number");
            //Create Header
            PurchOrderHeader.INIT;
            PurchOrderHeader."Document Type" := PurchOrderHeader."Document Type"::Order;
            PurchOrderHeader."No. Printed" := 0;
            PurchOrderHeader.Status := PurchOrderHeader.Status::Open;
            PurchOrderHeader."Requisition No" := "No.";
            PurchOrderHeader."Order Date" := TODAY;
            PurchOrderHeader."Document Date" := TODAY;
            PurchOrderHeader."Expected Receipt Date" := TODAY;
            PurchOrderHeader."Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
            PurchOrderHeader."Shortcut Dimension 2 Code" := "Global Dimension 2 Code";
            PurchOrderHeader."Location Code" := "Location Code";
            PurchOrderHeader."Currency Code" := "Currency Code";
            PurchOrderHeader."Posting Date" := WORKDATE;
            PurchOrderHeader.INSERT(TRUE);
            //Fetch Supplier Details
            Requisition.Reset;
            Requisition.SetRange("No.", "No.");
            Commit;
            if PAGE.RunModal(PAGE::"Supplier Selection for PO", Requisition) = ACTION::LookupOK then begin
                TestField("Supplier No"); //Check Bank Detail
                PayBankDetail.Reset();
                PayBankDetail.SetRange("Vendor No", "Supplier No");
                if PayBankDetail.FindSet() then begin
                    //
                end
                else
                    Error(Text001);
                PurchOrderHeader.VALIDATE("Buy-from Vendor No.", "Supplier No");
                PurchOrderHeader.VALIDATE("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                PurchOrderHeader.VALIDATE("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
            end
            else begin
                exit;
            end;
            Commit;
            PurchOrderHeader.Modify(true);
            //Transfer Document attachment
            DocumentAttachment[1].Reset();
            DocumentAttachment[1].SetRange("Table ID", Database::"Requisition Header");
            DocumentAttachment[1].SetRange("No.", "No.");
            if DocumentAttachment[1].FindSet() then begin
                repeat
                    DocumentAttachment[2].Init();
                    DocumentAttachment[2].TransferFields(DocumentAttachment[1]);
                    DocumentAttachment[2]."Table ID" := Database::"Purchase Header";
                    DocumentAttachment[2]."No." := PurchOrderHeader."No.";
                    DocumentAttachment[2]."Document Type" := DocumentAttachment[2]."Document Type"::Order;
                    DocumentAttachment[2].Insert(true);
                until DocumentAttachment[1].Next() = 0;
            end;
            //Create Lines
            RequisitionLines.Reset;
            RequisitionLines.SetRange("Requisition No", "No.");
            if RequisitionLines.Find('-') then begin
                repeat
                    GeneratePurchaseOrderLines(RequisitionLines, PurchOrderHeader);
                until RequisitionLines.Next = 0;
            end;
            //Update Requisition
            "PO Generated Directly" := true;
            "PO Generated By" := UserId;
            "PO Generated Date" := WorkDate;
            "PO Number" := PurchOrderHeader."No.";
            "PR Closed" := true;
            "PR Closed By" := "PR Closed By"::"Purchase Order";
            Modify;
            exit(PurchOrderHeader."No.");
        end;
    end;

    local procedure GeneratePurchaseOrderLines(RequisitionLines: Record "Requisition Lines"; PurchOrderHeader: Record "Purchase Header")
    var
        PurchOrderLine: Record "Purchase Line";
    begin
        PurchOrderLine.Init;
        PurchOrderLine."Document Type" := PurchOrderLine."Document Type"::Order;
        PurchOrderLine.Validate("Document No.", PurchOrderHeader."No.");
        PurchOrderLine."Line No." := RequisitionLines."Line No";
        PurchOrderLine.Validate(Type, RequisitionLines.Type);
        PurchOrderLine.Validate("No.", RequisitionLines."No.");
        PurchOrderLine.Description := RequisitionLines.Description;
        PurchOrderLine."Catalog No." := RequisitionLines."Catalog No.";
        PurchOrderLine.MFR := RequisitionLines.MFR;
        PurchOrderLine."Cost Center" := PurchOrderHeader."Cost Center";
        PurchOrderLine.Description := CopyStr(RequisitionLines.Description, 1, 250);
        PurchOrderLine."Location Code" := RequisitionLines."Location Code";
        PurchOrderLine."Currency Code" := RequisitionLines."Currency Code";
        PurchOrderLine.Validate(Quantity, RequisitionLines.Quantity);
        PurchOrderLine.Validate("Unit of Measure Code", RequisitionLines."Unit of Measure");
        PurchOrderLine.Validate("Direct Unit Cost", RequisitionLines."Unit Price");
        PurchOrderLine.Validate("Unit Cost", RequisitionLines."Unit Price");
        PurchOrderLine."Shortcut Dimension 1 Code" := RequisitionLines."Global Dimension 1 Code";
        PurchOrderLine."Shortcut Dimension 2 Code" := RequisitionLines."Global Dimension 2 Code";
        PurchOrderLine.INSERT;
        RequisitionLines.Decision := RequisitionLines.Decision::Order;
        RequisitionLines."Target No." := PurchOrderHeader."Buy-from Vendor No.";
        RequisitionLines."Order No" := PurchOrderHeader."No.";
        RequisitionLines.Processed := TRUE;
        RequisitionLines.MODIFY;
    end;

    procedure SuggestLPOInspection(var Inspection: Record "Procurement Inspection")
    var
        LPO: Record "Purchase Header";
        LPOLines: Record "Purchase Line";
        Quote: Record "Purchase Header";
        QuoteLines: Record "Purchase Line";
        RFQ: Record "RFQ Header";
        RFQLines: Record "RFQ Lines";
        PurchaseOrders: Page "Purchase Order List";
        SelectedRecord: Record "Purchase Header";
        InspectionLines: Record "Inspection Lines";
    begin
        with Inspection do begin
            //Header
            LPO.Reset;
            LPO.SetCurrentKey("Document Type", "No.");
            LPO.SetRange("Document Type", LPO."Document Type"::Order);
            LPO.SETRANGE(Status, LPO.Status::Released);
            if "Supplier No." <> '' then LPO.SetRange("Buy-from Vendor No.", "Supplier No.");
            PurchaseOrders.SetTableView(LPO);
            PurchaseOrders.LookupMode(true);
            if PurchaseOrders.RunModal = ACTION::LookupOK then begin
                SelectedRecord := LPO;
                PurchaseOrders.SetSelectionFilter(SelectedRecord);
                if SelectedRecord.FindFirst then begin
                    "LPO No" := SelectedRecord."No.";
                    Validate("Supplier No.", SelectedRecord."Buy-from Vendor No.");
                    "RFQ No." := SelectedRecord."Quote No.";
                    Quote.Reset;
                    Quote.SetRange("Document Type", Quote."Document Type"::Quote);
                    Quote.SetRange("No.", SelectedRecord."Quote No.");
                    if Quote.FindFirst then "RFQ Date" := RFQ."Created Date";
                    "LPO Date" := SelectedRecord."Posting Date";
                    "Invoice No." := SelectedRecord."Vendor Invoice No.";
                    Modify;
                end;
            end;
            //Lines
            InspectionLines.Reset;
            InspectionLines.SetRange("No.", "No.");
            InspectionLines.DeleteAll;
            LPOLines.Reset;
            LPOLines.SetCurrentKey("Document Type", "Document No.", "Line No.");
            LPOLines.SetRange("Document Type", LPOLines."Document Type"::Order);
            LPOLines.SetRange("Document No.", "LPO No");
            if LPOLines.FindSet then begin
                repeat
                    InspectionLines.Init;
                    InspectionLines."No." := "No.";
                    InspectionLines."Line No." := LPOLines."Line No.";
                    InspectionLines."Item No." := LPOLines."No.";
                    InspectionLines.Description := LPOLines.Description;
                    InspectionLines.Quantity := LPOLines.Quantity;
                    InspectionLines.UoM := LPOLines."Unit of Measure Code";
                    InspectionLines."Unit Cost" := LPOLines."Unit Cost";
                    InspectionLines."Total Cost" := LPOLines."Line Amount";
                    InspectionLines."Catalog No." := LPOLines."Catalog No.";
                    InspectionLines.MFR := LPOLines.MFR;
                    InspectionLines.Insert;
                until LPOLines.Next = 0;
            end;
        end;
    end;

    procedure GenerateRFQEmail(var RFQ: Record "Purchase Header")
    begin
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        if Supplier.Get(RFQ."Buy-from Vendor No.") then Recipients.Add(Supplier."E-Mail");
        Subject := 'REQUEST FOR QUOTATION';
        Body += 'Dear Sir/Madam';
        Body += '<br><br>';
        Body += 'We are pleased to invite quotations from your company as per attached RFQ document.';
        Body += '<br><br>';
        Body += 'For any queries kindly do not hesitate to contact the undersigned.';
        Body += '<br><br>';
        Body += 'Should you experience any difficulty viewing this attachment, kindly click on the link below to download adobe PDF reader';
        Body += '<br>';
        Body += 'from http://www.adobe.com/products/acrobat/readstep2.html.';
        Body += '<br><br>';
        Body += 'You can also login to our vendor portal with your credential to view the RFQ';
        Body += '<br>';
        Body += '<a href = "https://procurement-app-499d9.web.app/"> Click here to vendor portal</a>';
        Body += '<br><br>';
        Body += 'Thank you.';
        Body += '<br><br>';
        Body += 'Yours Sincerely,';
        Body += '<br><br>';
        Body += '<b>Procurement Office<b>';
        Body += '<br>';
        Mail.Create(Recipients, Subject, Body, true);
        PurchHeader.Reset();
        PurchHeader.SetRange("Document Type", RFQ."Document Type");
        PurchHeader.SetRange("No.", RFQ."No.");
        if PurchHeader.FindFirst then begin
            Recordr.GetTable(PurchHeader);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::RFQ, PurchHeader."No.", ReportFormat::Pdf, outStreamReport, Recordr);
            Mail.AddAttachment(PurchHeader."No." + '.pdf', 'PDF', inStreamReport);
        end;
        Email.Send(Mail);
    end;

    procedure ReplaceString(var String: Text; var FindWhat: Text; var ReplaceWith: Text) NewString: Text[250]
    begin
        while StrPos(String, FindWhat) > 0 do String := DelStr(String, StrPos(String, FindWhat)) + ReplaceWith + CopyStr(String, StrPos(String, FindWhat) + StrLen(FindWhat));
        NewString := String;
    end;

    procedure GenerateLPOEmail(var LPO: Record "Purchase Header")
    var
        VendorEmail: List of [Text];
        Supplier: Record Vendor;
        LPOFormatedNo: Text;
        ToReplace: Text;
        ReplaceWith: Text;
        OldLPONo: Text;
    begin
        //Generation
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        if Supplier.Get(LPO."Buy-from Vendor No.") then Recipients.Add(Supplier."E-Mail");
        Subject := 'PURCHASE ORDER';
        CompInfo.Get;
        Body += 'Dear Sir/Madam';
        Body += '<br><br>';
        Body += 'Kindly find attached our Purchase Order attached for the listed items/services.';
        Body += '<br><br>';
        Body += 'Please read and understand the terms and conditions of the LPO carefully.';
        Body += '<br><br>';
        Body += 'For any queries kindly do not hesitate to contact the undersigned.';
        Body += '<br><br>';
        Body += 'Should you experience any difficulty viewing this attachment, kindly click on the link below to download adobe PDF reader';
        Body += '<br>';
        Body += 'from http://www.adobe.com/products/acrobat/readstep2.html.';
        Body += '<br><br>';
        Body += 'You can also login to our vendor portal with your credential to view the LPO';
        Body += '<br>';
        Body += '<a href = "https://procurement-app-499d9.web.app/"> Click here to vendor portal</a>';
        Body += 'Thank you.';
        Body += '<br><br>';
        Body += 'Yours Sincerely,';
        Body += '<br><br>';
        Body += '<b>Procurement Office<b>';
        Body += '<br>';
        Body += CompInfo.Name;
        Body += '<br>';
        Mail.Create(Recipients, Subject, Body, true);
        PurchHeader.Reset();
        PurchHeader.SetRange("Document Type", LPO."Document Type");
        PurchHeader.SetRange("No.", LPO."No.");
        if PurchHeader.FindFirst then begin
            Recordr.GetTable(PurchHeader);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Purchase Order", PurchHeader."No.", ReportFormat::Pdf, outStreamReport, Recordr);
            Mail.AddAttachment(PurchHeader."No." + '.pdf', 'PDF', inStreamReport);
        end;
        Email.Send(Mail);
    end;

    procedure CopyRequisitionDetails(var Requisition: Record "Requisition Header")
    var
        SourceHeader: Record "Requisition Header";
        SourceLines: Record "Requisition Lines";
        DestinationLines: Record "Requisition Lines";
        SelectedRecord: Record "Requisition Header";
        RequisitionsPage: Page "Purchase Requisitions";
        LineNo: Integer;
    begin
        with Requisition do begin
            LineNo := 0;
            RequisitionHeader.Reset;
            RequisitionHeader.SetCurrentKey("No.");
            RequisitionHeader.SetRange("Requisition Type", RequisitionHeader."Requisition Type"::"Purchase Requisition");
            RequisitionHeader.SETRANGE(Status, RequisitionHeader.Status::Approved);
            RequisitionsPage.SetTableView(RequisitionHeader);
            RequisitionsPage.LookupMode(true);
            if RequisitionsPage.RunModal = ACTION::LookupOK then begin
                SelectedRecord := RequisitionHeader;
                RequisitionsPage.SetSelectionFilter(SelectedRecord);
                if SelectedRecord.Find('-') then begin
                    repeat
                        SourceLines.Reset;
                        SourceLines.SetCurrentKey("Requisition No", "Line No");
                        SourceLines.SetRange("Requisition No", SelectedRecord."No.");
                        if SourceLines.Find('-') then begin
                            repeat
                                LineNo := LineNo + 1;
                                DestinationLines.Init;
                                DestinationLines."Requisition No" := "No.";
                                DestinationLines."Line No" := LineNo;
                                DestinationLines.Validate("Requisition No", SourceLines."Requisition No");
                                DestinationLines.Description := SourceLines.Description;
                                DestinationLines.Quantity := SourceLines.Quantity;
                                DestinationLines."Unit of Measure" := SourceLines."Unit of Measure";
                                DestinationLines."Unit Price" := SourceLines."Unit Price";
                                DestinationLines.Amount := SourceLines.Amount;
                                DestinationLines."Procurement Plan" := SourceLines."Procurement Plan";
                                DestinationLines."Quantity Approved" := SourceLines."Quantity Approved";
                                DestinationLines."Quantity in Store" := SourceLines."Quantity in Store";
                                DestinationLines."Location Code" := SourceLines."Location Code";
                                DestinationLines."GL Account" := SourceLines."GL Account";
                                DestinationLines."Global Dimension 1 Code" := SourceLines."Global Dimension 1 Code";
                                DestinationLines."Global Dimension 2 Code" := SourceLines."Global Dimension 2 Code";
                                DestinationLines."Global Dimension 3 Code" := SourceLines."Global Dimension 3 Code";
                                DestinationLines."Global Dimension 4 Code" := SourceLines."Global Dimension 4 Code";
                                DestinationLines."Global Dimension 5 Code" := SourceLines."Global Dimension 5 Code";
                                DestinationLines.MFR := SourceLines.MFR;
                                DestinationLines."Catalog No." := SourceLines."Catalog No.";
                                DestinationLines.Insert;
                            until SourceLines.Next = 0;
                        end;
                    until SelectedRecord.Next = 0;
                end;
            end;
        end;
    end;

    procedure AppendRequisitionToOrder(var Requisition: Record "Requisition Header")
    var
        PurchOrderHeader: Record "Purchase Header";
        PurchOrderLine: Record "Purchase Line";
        RequisitionLines: Record "Requisition Lines";
        LineNo: Integer;
    begin
        with Requisition do begin
            if Status <> Status::Approved then Error('This requisition has not been fully approved.');
            if "PO Generated Directly" then Error('A Purchase Order No. %1 has already been generated for this Requisition.', "PO Number");
            //Create Header
            PurchOrderHeader.Reset;
            PurchOrderHeader.SetRange("Document Type", PurchOrderHeader."Document Type"::Order);
            PurchOrderHeader.SetRange(Status, PurchOrderHeader.Status::Open);
            if PAGE.RunModal(PAGE::"Purchase Order List", PurchOrderHeader) = ACTION::LookupOK then begin
                PurchOrderHeader."Requisition No" := "No.";
                PurchOrderHeader."Order Date" := WorkDate;
                PurchOrderHeader."Document Date" := WorkDate;
                PurchOrderHeader."Expected Receipt Date" := WorkDate;
                PurchOrderHeader."Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
                PurchOrderHeader."Shortcut Dimension 2 Code" := "Global Dimension 2 Code";
                PurchOrderHeader."Location Code" := "Location Code";
                PurchOrderHeader."Currency Code" := "Currency Code";
                PurchOrderHeader."Posting Date" := WorkDate;
                PurchOrderHeader.Modify;
                //Append Lines
                RequisitionLines.Reset;
                RequisitionLines.SetRange("Requisition No", "No.");
                if RequisitionLines.FindLast then LineNo := RequisitionLines."Line No" * 100;
                RequisitionLines.Reset;
                RequisitionLines.SetRange("Requisition No", "No.");
                if RequisitionLines.Find('-') then begin
                    repeat
                        LineNo := LineNo + 1000;
                        PurchOrderLine.Init;
                        PurchOrderLine."Document Type" := PurchOrderLine."Document Type"::Order;
                        PurchOrderLine."Document No." := PurchOrderHeader."No.";
                        PurchOrderLine."Line No." := LineNo;
                        PurchOrderLine.Insert(true);
                        PurchOrderLine."Catalog No." := RequisitionLines."Catalog No.";
                        PurchOrderLine.MFR := RequisitionLines.MFR;
                        PurchOrderLine.Type := RequisitionLines.Type;
                        PurchOrderLine.Validate("No.", RequisitionLines."No.");
                        PurchOrderLine.Description := CopyStr(RequisitionLines.Description, 1, 250);
                        PurchOrderLine."Location Code" := RequisitionLines."Location Code";
                        PurchOrderLine."Currency Code" := RequisitionLines."Currency Code";
                        PurchOrderLine.Validate(Quantity, RequisitionLines.Quantity);
                        PurchOrderLine.Validate("Unit of Measure Code", RequisitionLines."Unit of Measure");
                        PurchOrderLine.Validate("Direct Unit Cost", RequisitionLines."Unit Price");
                        PurchOrderLine.Validate("Unit Cost", RequisitionLines."Unit Price");
                        PurchOrderLine.Validate("Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                        PurchOrderLine.Validate("Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                        //PurchOrderLine.Insert;
                        PurchOrderLine.Modify(true);
                        RequisitionLines.Decision := RequisitionLines.Decision::Order;
                        RequisitionLines."Target No." := PurchOrderHeader."Buy-from Vendor No.";
                        RequisitionLines."Order No" := PurchOrderHeader."No.";
                        RequisitionLines.Processed := true;
                        RequisitionLines.Modify;
                    until RequisitionLines.Next = 0;
                end;
                //Update Requisition
                "PO Generated Directly" := true;
                "PO Generated By" := UserId;
                "PO Generated Date" := WorkDate;
                "PO Number" := PurchOrderHeader."No.";
                "PR Closed" := true;
                "PR Closed By" := "PR Closed By"::"Purchase Order";
                Modify;
                Message('Purchase Order No. %1 has been updated with this Requisition.', PurchOrderHeader."No.");
                PAGE.Run(50, PurchOrderHeader);
            end;
        end;
    end;

    procedure ReorderLevelsNotifications()
    var
        LineNo: Integer;
    begin
        CompInfo.Get;
        Clear(Recipients);
        Subject := '';
        Body := '';
        LineNo := 0;
        UserSetup.Reset;
        UserSetup.SetRange("Procurement Admin", true);
        if UserSetup.FindSet then begin
            repeat
                Recipients.Add(UserSetup."E-Mail");
            until UserSetup.Next = 0;
        end;
        Subject := 'REORDER LEVELS REMINDER';
        Body += '<span style="font-family: Calibri; color: #5B9BD5; font-size: 11pt>';
        Body += '<span style="font-family: Calibri; color: #5B9BD5; font-size: 11pt>';
        Body += 'Dear Sir/Madam';
        Body += '<br></br>';
        Body += '<p>This is to bring to your notice that the following Items have reached their reoder levels, Please consider Restocking';
        Body += '<br></br>';
        Items.Reset;
        Items.SetRange(Blocked, false);
        Items.SetFilter("Reorder Quantity", '<>%1', 0);
        Items.SetFilter(Inventory, '<>%1', 0);
        if Items.FindSet then begin
            repeat
                Items.CalcFields(Inventory);
                If Items.Inventory <= Items."Reorder Quantity" then begin
                    LineNo := LineNo + 1;
                    Body += '<li>' + StrSubstNo('%1. %2 %3, Quantity: %4', Format(LineNo), Items."No.", Items.Description, Format(Items.Inventory)) + '</li>';
                    Body += '<br></br>';
                end;
            until Items.Next = 0;
        end;
        Body += 'Yours Sincerely,';
        Body += '<br></br>';
        Body += '<b>System Notifications<b>';
        Body += '<br/>';
        Body += CompInfo.Name;
        CommunicationMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
    end;

    procedure NotifyCEOonProcurementPlanApproval()
    var
        UserSetUp: Record "User Setup";
    begin
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        UserSetup.Reset();
        UserSetup.SetRange(CEO, true);
        if UserSetUp.FindFirst() then begin
            Recipients.Add(UserSetUp."E-Mail");
            Subject := 'Procurement Plan Approval';
            Body += 'Dear Sir/Madam';
            Body += '<br><br>';
            Body += 'This is to inform you that the procurement plan has been approved.';
            Body += '<br><br>';
            Body += 'THIS IS A SYSTEM GENERATED EMAIL.';
            Body += '<br>';
            Mail.Create(Recipients, Subject, Body, true);
            Email.Send(Mail);
        end;
    end;

    procedure ProcessProcurementInspection(Inspection: Record "Procurement Inspection")
    var
        PurchOrder: array[2] of Record "Purchase Header";
        RecRef: array[2] of RecordRef;
        InStreamReport: InStream;
        OutStreamReport: OutStream;
        TempBlob: Codeunit "Temp Blob";
        InspectionHeader: Record "Procurement Inspection";
        DocAttachment: Record "Document Attachment";
    begin
        if not Confirm(StrSubstNo('You are about to close Inspection %1 for %2 do you wish to continue?', Inspection."No.", Inspection."Supplier Name"), false) then
            exit
        else begin
            if PurchOrder[1].Get(PurchOrder[1]."Document Type"::Order, Inspection."LPO No") then begin
                PurchOrder[2].Reset;
                PurchOrder[2].SetRange("No.", PurchOrder[1]."No.");
                If PurchOrder[2].FindSet then RecRef[1].GetTable(PurchOrder[2]);
                InspectionHeader.Reset;
                InspectionHeader.SetRange("No.", Inspection."No.");
                If InspectionHeader.FindSet then RecRef[2].GetTable(InspectionHeader);
                TempBlob.CreateOutStream(OutStreamReport);
                TempBlob.CreateInStream(InStreamReport);
                Report.SaveAs(Report::"Procurement Inspection", '', ReportFormat::Pdf, OutStreamReport, RecRef[2]);
                DocAttachment.InitFieldsFromRecRef(RecRef[1]);
                DocAttachment."Document Flow Sales" := RecRef[1].Number() = Database::"Sales Header";
                DocAttachment."Document Flow Purchase" := RecRef[1].Number() = Database::"Purchase Header";
                DocAttachment."Document Type" := DocAttachment."Document Type"::Order;
                DocAttachment.SaveAttachmentFromStream(InStreamReport, RecRef[1], StrSubstNo('%1 Inspection Cert.pdf', InspectionHeader."Supplier Name"));
                PurchOrder[1].Inspected := true;
                PurchOrder[1].Modify(true);
                Inspection.Processed := true;
                Inspection.Modify(true);
            end;
        end;
    end;

    local procedure GetFieldCaption(TableNumber: Integer; FieldNumber: Integer): Text
    var
        GlobalField: Record "Field";
    begin
        if (GlobalField.TableNo <> TableNumber) or (GlobalField."No." <> FieldNumber) then GlobalField.Get(TableNumber, FieldNumber);
        exit(GlobalField."Field Caption");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Line CaptionClass Mgmt", 'OnGetPurchaseLineCaptionClass', '', false, false)]
    local procedure OnGetPurchaseLineCaptionClass(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; FieldNumber: Integer; var IsHandled: Boolean; var Caption: Text)
    begin
        case FieldNumber of
            PurchaseLine.FieldNo("No."):
                Caption := StrSubstNo('3,%1', GetFieldCaption(DATABASE::"Purchase Line", FieldNumber));
            else begin
                Caption := ('2,1,' + GetFieldCaption(DATABASE::"Purchase Line", FieldNumber));
            end;
        end;
        IsHandled := true;
    end;
}
