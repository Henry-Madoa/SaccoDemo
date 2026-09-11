codeunit 52203479 "Proc & Store Management"
{
    trigger OnRun()
    begin
    end;
    var //    IanSoftFactory: Codeunit IanSoftFactory;
 UserSetup: Record "User Setup";
    ProcurementSetup: Record "Purchases & Payables Setup";
    Employee: Record Employee;
    RequisitionHeader: Record "Requisition Header";
    // procedure IanGetPlannedQuantity(Dim1: Code[50]; TypeParam: Option "G/L Account","Fixed Asset",Item; NoParam: Code[50]; PlanName: Text): Integer
    // var
    //     ConProcPlanLine: Record "Procurement Plan Lines";
    // begin
    //     ConProcPlanLine.Reset;
    //     ConProcPlanLine.SetRange("Global Dimension 2 Code", Dim1);
    //     ConProcPlanLine.SetRange(Type, TypeParam);
    //     ConProcPlanLine.SetRange(No, NoParam);
    //     ConProcPlanLine.SetRange(docu, PlanName);
    //     if ConProcPlanLine.FindSet then begin
    //         ConProcPlanLine.CalcSums(Quantity);
    //         exit(ConProcPlanLine.Quantity);
    //     end;
    // end;
    // procedure IanGetPlannedAmount(Dim1: Code[50]; TypeParam: Option "G/L Account","Fixed Asset",Item; NoParam: Code[50]; PlanName: Text): Decimal
    // var
    //     ConProcPlanLine: Record "Procurement Plan Lines";
    // begin
    //     ConProcPlanLine.Reset;
    //     ConProcPlanLine.SetRange("Global Dimension 2 Code", Dim1);
    //     ConProcPlanLine.SetRange(Type, TypeParam);
    //     ConProcPlanLine.SetRange(No, NoParam);
    //     ConProcPlanLine.SetRange("Plan No.", PlanName);
    //     if ConProcPlanLine.FindSet then begin
    //         ConProcPlanLine.CalcSums("Total Amount");
    //         exit(ConProcPlanLine."Total Amount");
    //     end;
    // end;
    // procedure IanGetRequisitionedQuantity(Dim1: Code[50]; TypeParam: Option "G/L Account","Fixed Asset",Item; NoParam: Code[50]; PlanName: Text): Integer
    // var
    //     RequsitionLines: Record "Requisition Lines";
    // begin
    //     RequsitionLines.Reset;
    //     RequsitionLines.SetRange("Global Dimension 1 Code", Dim1);
    //     RequsitionLines.SetRange(Type, TypeParam);
    //     RequsitionLines.SetRange(No, NoParam);
    //     RequsitionLines.SetRange("Plan No.", PlanName);
    //     RequsitionLines.SetRange(Approved, true);
    //     if RequsitionLines.FindSet then begin
    //         RequsitionLines.CalcSums(Quantity);
    //         exit(RequsitionLines.Quantity);
    //     end;
    // end;
    // procedure IanGetRequisitionedAmount(Dim1: Code[50]; TypeParam: Option "G/L Account","Fixed Asset",Item; NoParam: Code[50]; PlanName: Text): Decimal
    // var
    //     RequsitionLines: Record "Requisition Lines";
    // begin
    //     RequsitionLines.Reset;
    //     RequsitionLines.SetRange("Global Dimension 1 Code", Dim1);
    //     RequsitionLines.SetRange(Type, TypeParam);
    //     RequsitionLines.SetRange(No, NoParam);
    //     RequsitionLines.SetRange("Plan No.", PlanName);
    //     RequsitionLines.SetRange(Approved, true);
    //     if RequsitionLines.FindSet then begin
    //         RequsitionLines.CalcSums("Total Amount");
    //         exit(RequsitionLines."Total Amount");
    //     end;
    // end;
    procedure IanGetQuantityAvailableinStore(No: Code[20]; Location: Code[50]): Decimal begin
    end;
    procedure IanGenerateSupplierMandatoryRequirements(VenderName: Text; RequirementCode: Code[100]; RequirementDescription: Text; EvaluatorId: Code[70]; EvaluatorNo: Code[50]; EvaluatorName: Text; LineNo: Integer; TenderNo: Code[100]; Weight: Decimal)
    var
        SupplierMandatoryEvaluation: Record "Supplier Mandatory Evaluation";
    begin
        with SupplierMandatoryEvaluation do begin
            Init;
            "Reference No":=TenderNo;
            "Requirement Code":=RequirementCode;
            "Requirement Description":=RequirementDescription;
            "Evaluator ID":=EvaluatorId;
            "Evaluator Name":=EvaluatorName;
            "Evaluator No.":=EvaluatorNo;
            "Vendor Name":=VenderName;
            "Max Score":=Weight;
            if not SupplierMandatoryEvaluation.Get(TenderNo, RequirementCode, EvaluatorId, VenderName)then Insert;
        end;
    end;
    procedure IanGenerateSupplierTechnicalRequirements(VenderName: Text; RequirementCode: Code[100]; RequirementDescription: Text; EvaluatorId: Code[70]; EvaluatorNo: Code[50]; EvaluatorName: Text; LineNo: Integer; TenderNo: Code[100]; MaxScore: Decimal)
    var
        SupplierTechEvaluation: Record "Supplier Technical Evaluation";
    begin
        with SupplierTechEvaluation do begin
            Init;
            "Reference No":=TenderNo;
            "Requirement Code":=RequirementCode;
            "Requirement Description":=RequirementDescription;
            "Evaluator ID":=EvaluatorId;
            "Evaluator Name":=EvaluatorName;
            "Evaluator No.":=EvaluatorNo;
            "Vendor Name":=VenderName;
            "Max Score":=MaxScore;
            if not SupplierTechEvaluation.Get(TenderNo, RequirementCode, EvaluatorId, VenderName)then Insert;
        end;
    end;
    procedure IanGenerateSupplierFinacialEvaluation(VenderName: Text; TenderNo: Code[100]; Amount: Decimal; TechnicalScore: Decimal)
    var
        SupplierFinancialEvaluation: Record "Financial Evaluation";
    begin
        with SupplierFinancialEvaluation do begin
            Init;
            "Reference No.":=TenderNo;
            "Vendor Name":=VenderName;
            "Quoted Amount":=Amount;
            "Technical Score":=TechnicalScore;
            if not SupplierFinancialEvaluation.Get(TenderNo, VenderName)then Insert;
        end;
    end;
    procedure IanCheckIfPassedMandatory(ReferenceNo: Code[100]; VendorName: Text): Boolean var
        SupplierMandatoryEvaluation: Record "Supplier Mandatory Evaluation";
    begin
        SupplierMandatoryEvaluation.Reset;
        SupplierMandatoryEvaluation.SetRange("Reference No", ReferenceNo);
        SupplierMandatoryEvaluation.SetRange("Vendor Name", VendorName);
        SupplierMandatoryEvaluation.SetRange(Complied, false);
        exit(SupplierMandatoryEvaluation.FindFirst);
    end;
    procedure IanCalculateVendorTotal(ReferenceNo: Code[30]; VendorName: Text): Decimal var
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
    procedure IanUpdateSupplierIfPassedTechnical(ReferenceNo: Code[30]; VendorName: Text; Passed: Boolean)
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Vendor Name", VendorName);
        if TenderSuppliers.FindFirst then begin
            TenderSuppliers."Passed Technical":=Passed;
            TenderSuppliers.Modify(true);
        end;
    end;
    procedure IanUpdateSupplierIfPassedMandatory(ReferenceNo: Code[30]; VendorName: Text; Failed: Boolean)
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Vendor Name", VendorName);
        if TenderSuppliers.FindFirst then begin
            if Failed then TenderSuppliers."Passed Mandatory":=false
            else
                TenderSuppliers."Passed Mandatory":=true;
            TenderSuppliers.Modify(true);
        end;
    end;
    local procedure IanGetCalculateTotalScore(ReferenceNo: Code[50]): Code[50]var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        if TenderSuppliers.FindSet then begin
            repeat TenderSuppliers."Total Score":=TenderSuppliers."Financial Score" + TenderSuppliers."Technical Score";
                TenderSuppliers.Modify(true);
            until TenderSuppliers.Next = 0;
        end;
    end;
    procedure IanEndTenderProcess(ReferenceNo: Code[50])
    var
        FinancialScore: Decimal;
        TenderSuppliers: Record "Tender Suppliers";
        LeastScore: Decimal;
        MaxScore: Decimal;
        ProcurementRequest: Record "Procurement Request";
        Winner: Code[100];
    begin
        if ProcurementRequest.Get(ReferenceNo)then MaxScore:=ProcurementRequest."Financial Score";
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Passed Mandatory", true);
        TenderSuppliers.SetRange("Passed Technical", true);
        if TenderSuppliers.FindSet then begin
            repeat LeastScore:=IanGetLeastBidAmount(ReferenceNo);
                FinancialScore:=IanCalculateFinancialScore(LeastScore, TenderSuppliers."Bid Amount", MaxScore);
                IanUpdateSupplierWithFinScore(ReferenceNo, TenderSuppliers."Vendor Name", FinancialScore);
                IanUpdateSupplierWithTotalScore(ReferenceNo, TenderSuppliers."Vendor Name", FinancialScore, TenderSuppliers."Technical Score");
            until TenderSuppliers.Next = 0;
        end;
        Winner:=IanGetTenderWinner(ReferenceNo);
        Message('Winner is %1', Winner);
    end;
    local procedure IanGetTenderWinner(ReferenceNo: Code[50]): Text var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Passed Mandatory", true);
        TenderSuppliers.SetRange("Passed Technical", true);
        TenderSuppliers.SetCurrentKey("Total Score");
        TenderSuppliers.SetAscending("Total Score", true);
        if TenderSuppliers.FindLast then begin
            TenderSuppliers.Awarded:=true;
            if TenderSuppliers.Modify then exit(TenderSuppliers."Vendor Name");
        end;
    end;
    local procedure IanGetLeastBidAmount(ReferenceNo: Code[50]): Decimal var
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
    procedure IanGetNoofEvaluators(ReferenceNo: Code[30]): Integer var
        EvaluationCommittee: Record "Evaluation Committee";
    begin
        EvaluationCommittee.Reset;
        EvaluationCommittee.SetRange("Reference No", ReferenceNo);
        EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Technical);
        exit(EvaluationCommittee.Count);
    end;
    procedure IanEndTechnicalEvaluation(ProcurementRequest: Record "Procurement Request")
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
                repeat TotalScore:=IanCalculateVendorTotal("No.", TenderSuppliers."Vendor Name");
                    GetScore:=IanCalculateTechnicalScore(IanGetNoofEvaluators("No."), TotalScore);
                    IanUpdateSupplierWithScore("No.", TenderSuppliers."Vendor Name", GetScore);
                    if GetScore >= "Technical Pass Mark" then begin
                        Passed:=true;
                        CountPassed+=1;
                    end
                    else
                    begin
                        Passed:=false;
                        CountFailed+=1;
                    end;
                    IanUpdateSupplierIfPassedTechnical("No.", TenderSuppliers."Vendor Name", Passed);
                until TenderSuppliers.Next = 0;
            end;
        end;
        Message('Technical evaluation has ended \ %1 suppliers passed \ %2 Failed', CountPassed, CountFailed);
    end;
    procedure IanEndMandatoryEvaluation(ProcurementRequest: Record "Procurement Request")
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
                repeat Failed:=IanCheckIfPassedMandatory("No.", TenderSuppliers."Vendor Name");
                    if Failed then begin
                        CountFailed+=1;
                    end
                    else
                    begin
                        CountPassed+=1;
                    end;
                    IanUpdateSupplierIfPassedMandatory("No.", TenderSuppliers."Vendor Name", Failed);
                until TenderSuppliers.Next = 0;
            end;
        end;
        Message('Mandatory evaluation has ended \ %1 suppliers passed \ %2 Failed', CountPassed, CountFailed);
    end;
    procedure IanUpdateSupplierWithTotalScore(ReferenceNo: Code[30]; VendorName: Text; FinancialScore: Decimal; TechScore: Decimal)
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Vendor Name", VendorName);
        if TenderSuppliers.FindFirst then begin
            TenderSuppliers."Total Score":=FinancialScore + TechScore;
            TenderSuppliers.Modify(true);
        end;
    end;
    procedure IanUpdateSupplierWithFinScore(ReferenceNo: Code[30]; VendorName: Text; FinancialScore: Decimal)
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Vendor Name", VendorName);
        if TenderSuppliers.FindFirst then begin
            TenderSuppliers."Financial Score":=FinancialScore;
            TenderSuppliers.Modify(true);
        end;
    end;
    procedure IanCalculateFinancialScore(LeastScore: Decimal; SupplierScore: Decimal; FinacialMaxScore: Decimal): Decimal begin
        exit((LeastScore / SupplierScore) * FinacialMaxScore);
    end;
    procedure IanUpdateSupplierWithScore(ReferenceNo: Code[30]; VendorName: Text; TechnicalScore: Decimal)
    var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", ReferenceNo);
        TenderSuppliers.SetRange("Vendor Name", VendorName);
        if TenderSuppliers.FindFirst then begin
            TenderSuppliers."Technical Score":=TechnicalScore;
            TenderSuppliers.Modify(true);
        end;
    end;
    procedure IanCalculateTechnicalScore(NoOfEvaluators: Integer; TotalScore: Decimal): Decimal begin
        exit((TotalScore / NoOfEvaluators));
    end;
    procedure IanSubmitMandatoryScore(EvaluationCommittee: Record "Evaluation Committee")
    var
        SenderAddress: Text;
        SenderName: Text;
        Recepient: Text;
        Subject: Text;
        Body: Text;
    begin
        with EvaluationCommittee do begin
            "Submitted Mandatory Evaluation":=true;
            if Modify(true)then begin
                ProcurementSetup.Get;
                ProcurementSetup.TestField("Procurement Officer User Id");
                if UserSetup.Get(ProcurementSetup."Procurement Officer User Id")then begin
                    Recepient:=UserSetup."E-Mail";
                // SenderAddress := SMTPMailSetup."From Address";
                // SenderName := SMTPMailSetup."From Name";
                // Subject := 'Technical Evaluation Submition';
                // if Employee.Get(UserSetup."Employee No.") then
                //     Body := 'Dear ' + Format(Employee.FullName + ' <br> ' + Format(EvaluationCommittee."Employee Name") + ' has submitted their ' +
                //            'Mandatory evaluation for tender No. ' + Format("Reference No") + '<br><br> This is a system generated E-mail ' +
                //            'Please do not reply to it <br> Regards');
                //                IanSoftFactory.IanSendEmailWithoutAttachement(SenderName, SenderAddress, Recepient, Subject, Body);
                end;
                Message('Mandatory Evaluation successfully Submited');
            end;
        end;
    end;
    procedure IanSubmitTechnicalScore(EvaluationCommittee: Record "Evaluation Committee")
    var
        SenderAddress: Text;
        SenderName: Text;
        Recepient: Text;
        Subject: Text;
        Body: Text;
    begin
        with EvaluationCommittee do begin
            "Submitted Technical Evaluation":=true;
            if Modify(true)then begin
                ProcurementSetup.Get;
                ProcurementSetup.TestField("Procurement Officer User Id");
                if UserSetup.Get(ProcurementSetup."Procurement Officer User Id")then begin
                    Recepient:=UserSetup."E-Mail";
                // SenderAddress := SMTPMailSetup."From Address";
                // SenderName := SMTPMailSetup."From Name";
                // Subject := 'Technical Evaluation Submition';
                // if Employee.Get(UserSetup."Employee No.") then
                //     Body := 'Dear ' + Format(Employee.FullName) + ' <br> ' + Format(EvaluationCommittee."Employee Name") + ' has submitted their ' +
                //            'technical evaluation for tender No. ' + Format("Reference No") + '<br><br> This is a system generated E-mail ' +
                //            'Please do not reply to it <br> Regards';
                //            IanSoftFactory.IanSendEmailWithoutAttachement(SenderName, SenderAddress, Recepient, Subject, Body);
                end;
                Message('Technical Evaluation successfully Submited');
            end;
        end;
    end;
    procedure IanCreatePurchaseHeader(VendorNo: Code[50]; TenderNo: Code[100]; RequistionNo: Code[100]; RFQNo: Code[100]; RFPNo: Code[100]; ContractNo: Code[100]; "Require Inspection": Boolean; Dim1: Code[10]; Dim2: Code[10]; Currency: Code[10]; DescriptionN: Text[100]; DeliveryP: DateFormula): Code[70]var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        PurchaseHeader: Record "Purchase Header";
        InvoiceNo: Code[50];
        ProcurementRequest: Record "Procurement Request";
        PurchaseHeaderH: Record "Purchase Header";
        QuotationBidders: Record "Quotation Bidders";
        TenderSuppliers: Record "Tender Suppliers";
        DocType: Option Quote, Order, Invoice;
    begin
        with PurchaseHeader do begin
            PurchasesPayablesSetup.Get;
            PurchasesPayablesSetup.TestField("Order Nos.");
            PurchaseHeader.Init;
            // Message('Start Init');
            PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Order);
            InvoiceNo:=NoSeriesManagement.DoGetNextNo(PurchasesPayablesSetup."Order Nos.", Today, true, false);
            // if InvoiceNo <> '' then
            //     Message(Format(InvoiceNo));
            PurchaseHeader."No.":=InvoiceNo;
            PurchaseHeader.Insert(true);
            if PurchaseHeaderH.get(DocType::Order, InvoiceNo)then begin
                PurchaseHeaderH."Buy-from Vendor No.":=VendorNo;
                PurchaseHeaderH.Validate("Buy-from Vendor No.");
                PurchaseHeaderH."Document Date":=Today;
                PurchaseHeaderH.Validate("Document Date");
                PurchaseHeaderH."Tender No":=TenderNo;
                PurchaseHeaderH."Contract No":=ContractNo;
                PurchaseHeaderH."Requisition No":=RequistionNo;
                PurchaseHeaderH."Requires Inspection":="Require Inspection";
                PurchaseHeaderH."Procurement Doc. No.":=RFPNo;
                PurchaseHeaderH."Currency Code":=Currency;
                PurchaseHeaderH.Validate("Currency Code");
                PurchaseHeaderH."Shortcut Dimension 1 Code":=Dim1;
                PurchaseHeaderH."Shortcut Dimension 2 Code":=Dim2;
                PurchaseHeaderH."Posting Description":=DescriptionN;
                PurchaseHeaderH."Created By":=UserId;
                PurchaseHeaderH."Delivery Period":=DeliveryP;
                PurchaseHeaderH.Modify(true);
            end
            else
            begin
                Error('The document header has not been created.');
            end;
            exit(InvoiceNo);
        end;
    end;
    procedure IanCreatePurchaseLines(InvoiceNo: Code[50]; TypeParam: Option "G/L Account", "Fixed Asset", Item; No: Code[50]; QuantityParam: Integer; UnitPrice: Decimal; LocationParam: Code[50]; GlobalDim1: Code[50]; GlobalDim2: Code[50]; DescriptionParam: Text[250]; dimsetid: Integer; ProjectCode: Code[10]; DonorN: Code[20]; GrantN: Code[20]; ObjectiveN: Code[20]; Output: Code[20]; Outcome: Code[20]; ActivityN: Code[20]; PartnerN: Code[20]; UOM: Code[10]): Boolean var
        PurchaseLine: Record "Purchase Line";
        GLAccount: Record "G/L Account";
        FixedAsset: Record "Fixed Asset";
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseLine.Init;
        PurchaseLine.Validate("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.Validate("Document No.", InvoiceNo);
        if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, InvoiceNo)then PurchaseLine.Validate("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
        if TypeParam in[TypeParam::"Fixed Asset"]then PurchaseLine.Validate(Type, PurchaseLine.Type::"Fixed Asset");
        if TypeParam in[TypeParam::"G/L Account"]then PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
        if TypeParam in[TypeParam::Item]then PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine."No.":=No;
        PurchaseLine.Validate("No.");
        if TypeParam in[TypeParam::"Fixed Asset"]then begin
            FixedAsset.Get(PurchaseLine."No.");
            //        PurchaseLine.Description:=FixedAsset.Description + ' '+DescriptionParam;
            PurchaseLine.Validate("No.");
            PurchaseLine."FA Posting Type":=PurchaseLine."FA Posting Type"::Maintenance;
        end;
        if TypeParam in[TypeParam::"G/L Account"]then begin
            if GLAccount.Get(PurchaseLine."No.")then //        PurchaseLine.Description:=GLAccount.Name;
 PurchaseLine.Validate("No.");
        end;
        if TypeParam in[TypeParam::Item]then begin
            Item.Get(No);
            PurchaseLine.Description:=Item.Description;
            PurchaseLine.Validate("No.");
        end;
        PurchaseLine.Description:=CopyStr(DescriptionParam, 1, 50);
        PurchaseLine.Quantity:=QuantityParam;
        PurchaseLine.Validate(Quantity);
        PurchaseLine.Validate("Unit of Measure Code", UOM);
        PurchaseLine."Location Code":=LocationParam;
        //PurchaseLine."Dimension Set ID":= dimsetid;
        // PurchaseLine."Donor No." := DonorN;
        // PurchaseLine.Validate("Grant No.", GrantN);
        // PurchaseLine."Objective Code" := ObjectiveN;
        // PurchaseLine."Output Code" := Output;
        // PurchaseLine."Outcome Code" := Outcome;
        // PurchaseLine."Activity Code" := ActivityN;
        // PurchaseLine."Partner Code" := PartnerN;
        PurchaseLine."Shortcut Dimension 1 Code":=GlobalDim1;
        PurchaseLine.Validate("Shortcut Dimension 1 Code");
        PurchaseLine."Shortcut Dimension 2 Code":=GlobalDim2;
        PurchaseLine.Validate("Shortcut Dimension 2 Code");
        PurchaseLine."Direct Unit Cost":=UnitPrice;
        PurchaseLine.Validate("Direct Unit Cost");
        PurchaseLine."Line No.":=PurchaseLine.Count + 1;
        PurchaseLine.Insert;
    end;
    procedure IanSendQuoteToSuppliers(VendorNo: Code[10]; VendorName: Text; EmailAddress: Text; AttachementFilePath: Text; AttachementName: Text)
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        //      IanSoftFactory: Codeunit IanSoftFactory;
        SenderAddress: Text;
        SenderName: Text;
        Recepient: Text;
        Body: Text;
        Subject: Text;
        RCKRequestforQuotation: Report "Request for Quotation";
        Fpath: Text[255];
        FileManagement: Codeunit "File Management";
        FileName: Text[255];
        CCRecepient: Text[255];
        Text001: Label 'C:\RCKQuotes\Quotes.pdf';
    begin
    // SMTPMailSetup.Get;
    // SenderAddress := SMTPMailSetup."From Address";
    // SenderName := SMTPMailSetup."From Name";
    // Subject := 'Invitation For Quote';
    // Body := 'Hello <br> You have been invited for a quotation at RCK' +
    //        ' Please log in to the portal and submit your bids <br>' +
    //         ' This is a system generated Mail, Please dont reply to it <Br>Regards';
    //      IanSoftFactory.IanSendEmailWithoutAttachement(SenderName, SenderAddress, EmailAddress, Subject, Body);
    end;
    procedure IanSendTenderToSuppliers(VendorNo: Code[10]; VendorName: Text; EmailAddress: Text; AttachementFilePath: Text; AttachementName: Text; ClosingDate: Date)
    var
        //      IanSoftFactory: Codeunit IanSoftFactory;
        SenderAddress: Text;
        SenderName: Text;
        Body: Text;
        Subject: Text;
    begin
        //  SMTPMailSetup.Get;
        // SenderAddress := SMTPMailSetup."From Address";
        // SenderName := SMTPMailSetup."From Name";
        Subject:='Invitation For Tender';
        Body:='Hello <br> You have been invited for tendering at RCK' + ' Please log in to the portal and submit your bids <br>' + ' This is a system generated Mail, Please dont reply to it <Br>Regards';
    //      IanSoftFactory.IanSendEmailWithoutAttachement(SenderName, SenderAddress, EmailAddress, Subject, Body);
    end;
    procedure IanStartQuotationEvaluation(var ProcurementRequest: Record "Procurement Request"): Boolean var
        QuotationBidders: Record "Quotation Bidders";
        ProcurementRequestLines: Record "Procurement Request Lines";
    begin
        with ProcurementRequest do begin
            //QuotationBidders.Reset;
            //QuotationBidders.SetRange("Reference No", "No.");
            //if QuotationBidders.FindSet then QuotationBidders.DeleteAll;
            ProcurementRequestLines.Reset;
            ProcurementRequestLines.SetRange("Procurement No", "No.");
            if ProcurementRequestLines.FindSet then begin
                repeat QuotationBidders.Reset;
                    QuotationBidders.SetRange("Reference No", "No.");
                    if QuotationBidders.FindSet then begin
                        repeat IanCreateVendorBidsLines("No.", QuotationBidders."Vendor No.", QuotationBidders."Vendor Name", ProcurementRequestLines."Line No.", ProcurementRequestLines."No.", ProcurementRequestLines.Name, ProcurementRequestLines.Description, ProcurementRequestLines.Quantity);
                        until QuotationBidders.Next = 0;
                    end;
                until ProcurementRequestLines.Next = 0;
            end;
        end;
    end;
    local procedure IanCreateVendorBidsLines(QuoteNo: Code[100]; VendorNo: Code[100]; VendorName: Text; LineNo: Integer; ItemNo: Code[100]; ItemName: Text; LineDescription: Text; QuantityVar: Integer)
    var
        QuotationBidders: Record "Quotation Bidders";
        QuotationVendorsBids: Record "Quotation Vendors Bids";
    begin
        with QuotationVendorsBids do begin
            Init;
            "Quote No":=QuoteNo;
            "Vendor No":=VendorNo;
            "Vendor Name":=VendorName;
            "Line No":=LineNo;
            "Item No":=ItemNo;
            "Item Name":=ItemName;
            Description:=Description;
            Quantity:=QuantityVar;
            Insert;
        end;
    end;
    procedure IanGetTheLeastQuotedAmount(QuoteNo: Code[50]; ItemNo: Code[30]): Code[100]var
        QuotationVendorsBids: Record "Quotation Vendors Bids";
    begin
        QuotationVendorsBids.Reset;
        QuotationVendorsBids.SetRange("Quote No", QuoteNo);
        QuotationVendorsBids.SetRange("Item No", ItemNo);
        QuotationVendorsBids.SetFilter("Unit Price", '>%1', 0);
        QuotationVendorsBids.SetCurrentKey("Unit Price");
        QuotationVendorsBids.SetAscending("Unit Price", true);
        if QuotationVendorsBids.FindFirst then exit(QuotationVendorsBids."Vendor No");
    end;
    procedure IanChangeStatusOnVendorInvitation(ProcurementRequest: Record "Procurement Request")
    begin
        with ProcurementRequest do begin
            "Quotation Status":="Quotation Status"::"Supplier Invitation";
            "Date Advertisement":=Today;
            if Modify(true)then Message('Invitation Successfully Sent');
        end;
    end;
    procedure IanChangeStatusOnQuotationAward(ProcurementRequest: Record "Procurement Request"; OrderNo: Code[50])
    begin
        with ProcurementRequest do begin
            "Quotation Status":="Quotation Status"::"Order Created";
            "Order Created":=true;
            "Generated Order No":=OrderNo;
            "Date Awarded":=Today;
            if Modify(true)then Message('Order(s) Successfuly created');
        end;
    end;
    procedure IanChangeStatusOnRFPAward(ProcurementRequest: Record "Procurement Request"; OrderNo: Code[100])
    begin
        with ProcurementRequest do begin
            "RFP Status":="RFP Status"::"Order Created";
            "Order Created":=true;
            "Generated Order No":=OrderNo;
            "Date Awarded":=Today;
            if Modify(true)then Message('Order(s) Successfuly created');
        end;
    end;
    procedure IanChangeStatusOnDirectProcAward(ProcurementRequest: Record "Procurement Request"; OrderNo: Code[100])
    begin
        with ProcurementRequest do begin
            "Direct Procurement Status":="Direct Procurement Status"::"Order Created";
            "Order Created":=true;
            "Generated Order No":=OrderNo;
            "Date Awarded":=Today;
            if Modify(true)then Message('Order(s) Successfuly created');
        end;
    end;
    procedure IanStartTenderMandatoryEvaluation(var ProcurementRequest: Record "Procurement Request")
    var
        TenderSuppliers: Record "Tender Suppliers";
        EvaluationCommittee: Record "Evaluation Committee";
        TechnicalSpecifications: Record "Mandatory Requirements";
        SenderAddress: Text;
        SenderName: Text;
        Recepient: Text;
        Subject: Text;
        Body: Text;
        ProcurementSetup: Record "Purchases & Payables Setup";
        Employee: Record Employee;
        UserSetup: Record "User Setup";
        ProgressWindow: Dialog;
    begin
        with ProcurementRequest do begin
            TenderSuppliers.Reset;
            TenderSuppliers.SetRange("Reference No", "No.");
            if TenderSuppliers.FindSet then begin
                ProgressWindow.Open('Setting Up For : #1################ \ Creating Evaluation records For : #2################# Creating Mand. Spec. : #3####################');
                repeat ProgressWindow.Update(1, TenderSuppliers."Vendor Name");
                    EvaluationCommittee.Reset;
                    EvaluationCommittee.SetRange("Reference No", "No.");
                    EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Mandatory);
                    if EvaluationCommittee.FindSet then begin
                        repeat Sleep(100);
                            ProgressWindow.Update(2, EvaluationCommittee."User Name");
                            TechnicalSpecifications.Reset;
                            TechnicalSpecifications.SetRange("Reference No", "No.");
                            if TechnicalSpecifications.FindSet then begin
                                repeat Sleep(100);
                                    ProgressWindow.Update(3, TechnicalSpecifications."Requirement Description");
                                    Sleep(100);
                                    IanGenerateSupplierMandatoryRequirements(TenderSuppliers."Vendor Name", TechnicalSpecifications."Requirement Code", TechnicalSpecifications."Requirement Description", EvaluationCommittee."User Name", EvaluationCommittee."Employee No.", EvaluationCommittee."Employee Name", 0, "No.", TechnicalSpecifications."Max Weight");
                                until TechnicalSpecifications.Next = 0;
                            end;
                        until EvaluationCommittee.Next = 0;
                    end;
                until TenderSuppliers.Next = 0;
                ProgressWindow.Close();
            end;
            "Tender Status":="Tender Status"::"Mandatory Req Evaluation";
            "Date of Mandatory Evaluation":=Today;
            if Modify(true)then begin
                ProcurementSetup.Get;
                EvaluationCommittee.Reset;
                EvaluationCommittee.SetRange("Reference No", "No.");
                EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Mandatory);
                if EvaluationCommittee.FindSet then begin
                    ProgressWindow.Open('Notifying Evaluation Commitee Member : #1#########################');
                    repeat ProgressWindow.Update(1, EvaluationCommittee."Employee Name");
                        Sleep(100);
                    //     SenderAddress := SMTPMailSetup."From Address";
                    //     SenderName := SMTPMailSetup."From Name";
                    //     if UserSetup.Get(EvaluationCommittee."User Name") then
                    //         Recepient := UserSetup."E-Mail";
                    //     Subject := 'Mandatory Evaluation Invitation';
                    //     Body := 'Dear ' + Format(EvaluationCommittee."Employee Name") + ' <br> Mandatory Evaluation for tender No ' + Format("No.") +
                    //            ' has been initiated and you are invited to start the evaluation ' +
                    //            '<br><br> This is a system generated E-mail ' +
                    //            'Please do not reply to it <br> Regards';
                    // //                IanSoftFactory.IanSendEmailWithoutAttachement(SenderName, SenderAddress, Recepient, Subject, Body);
                    until EvaluationCommittee.Next = 0;
                    ProgressWindow.Close();
                end;
                Message('Tender Successfully moved to mandatory evaluation');
            end;
        end;
    end;
    procedure IanStartTenderTechnicalEvaluation(ProcurementRequest: Record "Procurement Request")
    var
        TenderSuppliers: Record "Tender Suppliers";
        EvaluationCommittee: Record "Evaluation Committee";
        TechnicalSpecifications: Record "Technical Specifications";
        SenderAddress: Text;
        SenderName: Text;
        Recepient: Text;
        Subject: Text;
        Body: Text;
        ProcurementSetup: Record "Purchases & Payables Setup";
        Employee: Record Employee;
        UserSetup: Record "User Setup";
        ProgressWindow: Dialog;
    begin
        with ProcurementRequest do begin
            IanEndMandatoryEvaluation(ProcurementRequest);
            TenderSuppliers.Reset;
            TenderSuppliers.SetRange("Reference No", "No.");
            TenderSuppliers.SetRange("Passed Mandatory", true);
            if TenderSuppliers.FindSet then begin
                ProgressWindow.Open('Setting Up For : #1################ \ Creating Evaluation records For : #2################# Creating Tech. Spec. : #3####################');
                repeat ProgressWindow.Update(1, TenderSuppliers."Vendor Name");
                    Sleep(100);
                    EvaluationCommittee.Reset;
                    EvaluationCommittee.SetRange("Reference No", "No.");
                    EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Technical);
                    if EvaluationCommittee.FindSet then begin
                        repeat ProgressWindow.Update(2, EvaluationCommittee."Employee Name");
                            Sleep(100);
                            TechnicalSpecifications.Reset;
                            TechnicalSpecifications.SetRange("Reference No.", "No.");
                            if TechnicalSpecifications.FindSet then begin
                                repeat ProgressWindow.Update(3, TechnicalSpecifications."Requirement Specification");
                                    Sleep(100);
                                    IanGenerateSupplierTechnicalRequirements(TenderSuppliers."Vendor Name", TechnicalSpecifications."Requirement Code", TechnicalSpecifications."Requirement Specification", EvaluationCommittee."User Name", EvaluationCommittee."Employee No.", EvaluationCommittee."Employee Name", 0, "No.", TechnicalSpecifications."Max Weigth");
                                until TechnicalSpecifications.Next = 0;
                            end;
                        until EvaluationCommittee.Next = 0;
                    end;
                until TenderSuppliers.Next = 0;
                ProgressWindow.Close();
            end
            else
            begin
                Message('No supplier passed Mandatory');
                exit;
            end;
            "Tender Status":="Tender Status"::"Technical Req Evaluation";
            "Date of Technical Evaluation":=Today;
            if Modify(true)then begin
                ProcurementSetup.Get;
                EvaluationCommittee.Reset;
                EvaluationCommittee.SetRange("Reference No", "No.");
                EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Technical);
                if EvaluationCommittee.FindSet then begin
                    ProgressWindow.Open('Notifying Evaluation Member : #1#######################');
                    repeat ProgressWindow.Update(1, EvaluationCommittee."Employee Name");
                        Sleep(100);
                        // SenderAddress := SMTPMailSetup."From Address";
                        // SenderName := SMTPMailSetup."From Name";
                        if UserSetup.Get(EvaluationCommittee."User Name")then Recepient:=UserSetup."E-Mail";
                        Subject:='Technical Evaluation Invitation';
                        Body:='Dear ' + Format(EvaluationCommittee."Employee Name") + ' <br> Technical Evaluation for tender No ' + Format("No.") + 'has been initiated and you are invited to start the evaluation ' + '<br><br> This is a system generated E-mail ' + 'Please do not reply to it <br> Regards';
                    //                    IanSoftFactory.IanSendEmailWithoutAttachement(SenderName, SenderAddress, Recepient, Subject, Body);
                    until EvaluationCommittee.Next = 0;
                    ProgressWindow.Close();
                end;
                Message('Tender Successfully moved to technical evaluation');
            end;
        end;
    end;
    procedure IanStartTenderFinancialEvaluation(ProcurementRequest: Record "Procurement Request")
    var
        TenderSuppliers: Record "Tender Suppliers";
        ProgressWindow: Dialog;
    begin
        with ProcurementRequest do begin
            IanEndTechnicalEvaluation(ProcurementRequest);
            TenderSuppliers.Reset;
            TenderSuppliers.SetRange("Reference No", "No.");
            TenderSuppliers.SetRange("Passed Technical", true);
            if TenderSuppliers.FindSet then begin
                ProgressWindow.Open('Creating Financial Evaluation For : #1###########################');
                repeat ProgressWindow.Update(1, TenderSuppliers."Vendor Name");
                    Sleep(100);
                    TenderSuppliers.TestField("Bid Amount");
                    IanGenerateSupplierFinacialEvaluation(TenderSuppliers."Vendor Name", "No.", TenderSuppliers."Bid Amount", TenderSuppliers."Technical Score");
                until TenderSuppliers.Next = 0;
                ProgressWindow.Close();
            end
            else
            begin
                Message('No supplier passed technical');
                exit;
            end;
            "Tender Status":="Tender Status"::"Financial Evaluation";
            "Date of Financial Evaluation":=Today;
            if Modify(true)then Message('Tender Successfully moved to financial evaluation');
        end;
    end;
    procedure IanChangeStatusToOrderCreated(ProcurementRequest: Record "Procurement Request"; OrderNo: Code[50])
    begin
        with ProcurementRequest do begin
            "Tender Status":="Tender Status"::"Order Created";
            "Order Created":=true;
            "Generated Order No":=OrderNo;
            "Date Awarded":=Today;
            if Modify(true)then Message('Order No [%1] successfully created', OrderNo);
        end;
    end;
    procedure IanChangeStatusToContractCreated(ProcurementRequest: Record "Procurement Request"; ContractNo: Code[50])
    begin
        with ProcurementRequest do begin
            "Tender Status":="Tender Status"::"Contract Created";
            "Order Created":=true;
            "Contract No Generated":=ContractNo;
            "Date Awarded":=Today;
            if Modify(true)then Message('Contract No [%1] successfully created', ContractNo);
        end;
    end;
    procedure IanMoveTenderToAdvertisementStage(ProcurementRequest: Record "Procurement Request")
    begin
        with ProcurementRequest do begin
            "Tender Status":="Tender Status"::Advertised;
            "Date Advertisement":=Today;
            if Modify(true)then Message('Tender Successfully moved to advertised staged');
        end;
    end;
    procedure IanCreateContractHeader(VendorNo: Code[50]; TenderNo: Code[100]; RequistionNo: Code[100]): Code[70]var
        ProcurementSetup: Record "Purchases & Payables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ContractHeader: Record "Contract Header";
        ContractNo: Code[50];
    begin
        with ContractHeader do begin
            Init;
            ProcurementSetup.Get;
            ContractNo:=NoSeriesManagement.GetNextNo(ProcurementSetup."Contract Nos", 0D, true);
            "No.":=ContractNo;
            "Vendor No.":=VendorNo;
            Validate("Vendor No.");
            "Tender No.":=TenderNo;
            Validate("Tender No.");
            "Requisition No":=RequistionNo;
            Insert;
        end;
        exit(ContractNo);
    end;
    procedure IanCreateContractLines(ContractNo: Code[50]; ProcurementRequestLines: Record "Procurement Request Lines"): Boolean var
        ContractLines: Record "Contract Lines";
    begin
        ContractLines.Init;
        ContractLines.TransferFields(ProcurementRequestLines);
        ContractLines."Contract No.":=ContractNo;
        ContractLines.Insert;
    end;
    procedure IanCreateVendorToAward(VendorName: Text; EmailAddress: Code[10]; PhoneNo: Code[10]; VendorCategoryParam: Code[100]): Code[100]var
        Vendor: Record Vendor;
        SupplierCategory: Record "Supplier Category";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        VendorNoAssigned: Code[100];
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        SupplierCategory.Reset;
        SupplierCategory.SetRange("Category Code", VendorCategoryParam);
        if SupplierCategory.FindFirst then begin
            PurchasesPayablesSetup.Get;
            PurchasesPayablesSetup.TestField("Vendor Nos.");
            VendorNoAssigned:=NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Vendor Nos.", 0D, true);
            with Vendor do begin
                Init;
                "No.":=VendorNoAssigned;
                Validate(Name, VendorName);
                "Supplier Category":=VendorCategoryParam;
                "Gen. Bus. Posting Group":=SupplierCategory."Gen. Bus. Posting Group";
                "VAT Bus. Posting Group":=SupplierCategory."VAT Bus. Posting Group";
                "Vendor Posting Group":=SupplierCategory."Vendor Posting Group";
                if VendorNoAssigned <> '' then Insert;
            end;
        end;
        exit(VendorNoAssigned);
    end;
    // procedure IanInitiateProcurementProcess(RequisitionHeader: Record "Requisition Header"): Code[50]
    // var
    //     RequisitionLines: Record "Requisition Lines";
    //     ProcurementRequest: Record "Procurement Request";
    //     ProcurementRequestLines: Record "Procurement Request Lines";
    //     ProcurementNo: Code[50];
    // begin
    //     with RequisitionHeader do begin
    //         RequisitionLines.Reset;
    //         RequisitionLines.SetRange("Requisition No", "No.");
    //         RequisitionLines.SetRange("Procurement Method", RequisitionLines."Procurement Method"::Tender);
    //         if RequisitionLines.FindFirst then begin
    //             ProcurementNo := IanCreateProcurementHeader(RequisitionHeader, RequisitionLines."Procurement Method");
    //             repeat
    //                 IanCreateProcurementLines(RequisitionLines, ProcurementNo);
    //             until RequisitionLines.Next = 0;
    //         end;
    //         RequisitionLines.Reset;
    //         RequisitionLines.SetRange("Requisition No", "No.");
    //         RequisitionLines.SetRange("Procurement Method", RequisitionLines."Procurement Method"::RFP);
    //         if RequisitionLines.FindFirst then begin
    //             ProcurementNo := IanCreateProcurementHeader(RequisitionHeader, RequisitionLines."Procurement Method");
    //             repeat
    //                 IanCreateProcurementLines(RequisitionLines, ProcurementNo);
    //             until RequisitionLines.Next = 0;
    //         end;
    //         RequisitionLines.Reset;
    //         RequisitionLines.SetRange("Requisition No", "No.");
    //         RequisitionLines.SetRange("Procurement Method", RequisitionLines."Procurement Method"::RFQ);
    //         if RequisitionLines.FindFirst then begin
    //             ProcurementNo := IanCreateProcurementHeader(RequisitionHeader, RequisitionLines."Procurement Method");
    //             repeat
    //                 IanCreateProcurementLines(RequisitionLines, ProcurementNo);
    //             until RequisitionLines.Next = 0;
    //         end;
    //         RequisitionLines.Reset;
    //         RequisitionLines.SetRange("Requisition No", "No.");
    //         RequisitionLines.SetRange("Procurement Method", RequisitionLines."Procurement Method"::"Direct Procurement");
    //         if RequisitionLines.FindFirst then begin
    //             ProcurementNo := IanCreateProcurementHeader(RequisitionHeader, RequisitionLines."Procurement Method");
    //             repeat
    //                 IanCreateProcurementLines(RequisitionLines, ProcurementNo);
    //             until RequisitionLines.Next = 0;
    //         end;
    //     end;
    //     exit(ProcurementNo);
    // end;
    local procedure IanCreateProcurementHeader(RequisitionHeader: Record "Requisition Header"; ProcurementMethod: enum "Procurement Methods"): Code[50]var
        ProcurementRequest: Record "Procurement Request";
        ProcurementSetup: Record "Purchases & Payables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ProcurementNo: Code[50];
    begin
        with ProcurementRequest do begin
            if ProcurementMethod in[ProcurementMethod::"Open Tendering"]then begin
                ProcurementSetup.Get;
                ProcurementSetup.TestField("Tender Nos");
                ProcurementNo:=NoSeriesManagement.GetNextNo(ProcurementSetup."Tender Nos", 0D, true);
                Validate("Procurement Method", "Procurement Method"::"Open Tendering");
            end;
            if ProcurementMethod in[ProcurementMethod::"Restricted Tendering"]then begin
                ProcurementSetup.Get;
                ProcurementSetup.TestField("Tender Nos");
                ProcurementNo:=NoSeriesManagement.GetNextNo(ProcurementSetup."Tender Nos", 0D, true);
                Validate("Procurement Method", "Procurement Method"::"Restricted Tendering");
            end;
            if ProcurementMethod in[ProcurementMethod::RFQ]then begin
                ProcurementSetup.Get;
                ProcurementSetup.TestField("Request for Quotation Nos.");
                ProcurementNo:=NoSeriesManagement.GetNextNo(ProcurementSetup."Request for Quotation Nos.", 0D, true);
                Validate("Procurement Method", "Procurement Method"::RFQ);
            end;
            if ProcurementMethod in[ProcurementMethod::RFP]then begin
                ProcurementSetup.Get;
                ProcurementSetup.TestField("RFP Nos");
                ProcurementNo:=NoSeriesManagement.GetNextNo(ProcurementSetup."RFP Nos", 0D, true);
                Validate("Procurement Method", "Procurement Method"::RFP);
            end;
            if ProcurementMethod in[ProcurementMethod::"Direct Procurement"]then begin
                ProcurementSetup.Get;
                ProcurementSetup.TestField("Direct Procurement Nos");
                ProcurementNo:=NoSeriesManagement.GetNextNo(ProcurementSetup."Direct Procurement Nos", 0D, true);
                Validate("Procurement Method", "Procurement Method"::"Direct Procurement");
            end;
            Init;
            "No.":=ProcurementNo;
            "Requisiton No":=RequisitionHeader."No.";
            "Global Dimension 1 Code":=RequisitionHeader."Global Dimension 1 Code";
            "Global Dimension 2 Code":=RequisitionHeader."Global Dimension 2 Code";
            "Current Budget":=RequisitionHeader."Current Budget";
            "Procurement Plan":=RequisitionHeader."Plan Name";
            //Currency:=RequisitionHeader.Currency;
            "Created By":=UserId;
            "Creation Date":=Today;
            Title:=RequisitionHeader.Title;
            Currency:=RequisitionHeader.Currency;
            "Procurement Method":=ProcurementMethod;
            if RequisitionHeader."Requisition Type" = RequisitionHeader."Requisition Type"::"FA Maintenance" then "Original Doc. Type":="Original Doc. Type"::Maintenance;
            Insert;
        end;
        exit(ProcurementNo);
    end;
    local procedure IanCreateProcurementLines(RequisitionLines: Record "Requisition Lines"; ProcurementNo: Code[50])
    var
        ProcurementRequestLines: Record "Procurement Request Lines";
    begin
        ProcurementRequestLines.Init;
        ProcurementRequestLines.TransferFields(RequisitionLines);
        ProcurementRequestLines."Procurement No":=ProcurementNo;
        ProcurementRequestLines.Insert;
    end;
    procedure IanInitateProcurementplan(ProcurementPlanInitiation: Record "Procurement Plan Initiation")
    var
        ProcurementPlanHeader: Record "Procurement Plans";
        DimensionValue: Record "Dimension Value";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ProcurementSetup: Record "Purchases & Payables Setup";
        UserSetup: Record "User Setup";
        Body: Text;
        SenderName: Text;
        SenderAddress: Text;
        Recepient: Text;
        Subject: Text;
        SMTPMailSetup: Record "Email Item";
        ProgressWindow: Dialog;
        PurchPayablesSetup: Record "Purchases & Payables Setup";
        PlanNo: code[40];
    begin
        IanOnBeforeProcurementPlanInitiation(ProcurementPlanInitiation);
        with ProcurementPlanInitiation do begin
            DimensionValue.Reset;
            DimensionValue.SetRange("Global Dimension No.", 1);
            if DimensionValue.FindSet()then begin
                //ProgressWindow.Open('Initiating for #1############# \ Sending Mail to #2#################');
                ProgressWindow.Open('Initiating for #1#############');
                repeat ProgressWindow.Update(1, DimensionValue.Code);
                    ProcurementPlanHeader.Init;
                    PurchPayablesSetup.Get;
                    PurchPayablesSetup.TestField("Procurement Plan No.");
                    PlanNo:=NoSeriesManagement.GetNextNo(PurchPayablesSetup."Procurement Plan No.", 0D, true);
                    ProcurementPlanHeader."No.":=PlanNo;
                    ProcurementPlanHeader."Plan Name":=ProcurementPlanInitiation."Plan Name";
                    ProcurementPlanHeader."Global Dimension 1 Code":=DimensionValue.Code;
                    UserSetup.Reset;
                    UserSetup.SetRange("Head of Branch", DimensionValue.Code);
                    if UserSetup.FindFirst then begin
                        ProcurementPlanHeader."Employee Code":=UserSetup."Employee No.";
                        ProcurementPlanHeader.Validate("Employee Code");
                    //SMTPMailSetup.Get;
                    // Recepient := UserSetup."E-Mail";
                    // SenderName := SMTPMailSetup."From Name";
                    // SenderAddress := SMTPMailSetup."From Address";
                    // Subject := 'Procurement Plan';
                    // Body := 'Dear ' + Format(ProcurementPlanHeader."Employee Name") + '<br>Procurement plan for ' + Format("Plan Name") +
                    //       ' has been initiated. Please log in to NAV ERP and plan for your department <br>This is a system generated Email' +
                    //       'Please do not reply to it <Br> Regards';
                    //Sleep(100);
                    //ProgressWindow.Update(2, Recepient);
                    //Sleep(100);
                    //IanSoftFactory.IanSendEmailWithoutAttachement(SenderName, SenderAddress, Recepient, Subject, Body);
                    end;
                    //            ELSE
                    //              ERROR('Dimension %1 has no user assigned as head in user setup',DimensionValue.Code);
                    ProcurementPlanHeader."Financial Year":="Financial Year";
                    ProcurementPlanHeader."Current Budget":="Current Budget";
                    ProcurementPlanHeader."Date Created":=Today;
                    ProcurementPlanHeader."Created By":=UserId;
                    ProcurementPlanHeader."Start Date":="Start Date";
                    ProcurementPlanHeader."End Date":="End Date";
                    ProcurementPlanHeader.Insert;
                until DimensionValue.Next = 0;
                ProgressWindow.Close();
            end;
        end;
        IanOnAfterProcurementPlanInitiation(ProcurementPlanInitiation);
    end;
    [IntegrationEvent(false, false)]
    local procedure IanOnBeforeProcurementPlanInitiation(ProcurementPlanInitiation: Record "Procurement Plan Initiation")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure IanOnAfterProcurementPlanInitiation(ProcurementPlanInitiation: Record "Procurement Plan Initiation")
    begin
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Proc & Store Management", 'IanOnAfterProcurementPlanInitiation', '', false, false)]
    local procedure IanChangeStatusToInitiated(ProcurementPlanInitiation: Record "Procurement Plan Initiation")
    begin
        with ProcurementPlanInitiation do begin
            Initiated:=true;
            if Modify(true)then Message('Successfully initiated');
        end;
    end;
    procedure IanCreateDisposalRecords(var DisposalRequest: Record "Disposal Request"): Code[50]var
        DisposalRequestLines: Record "Disposal Request Lines";
        Disposal: Record Disposal;
        ProcurementSetup: Record "Purchases & Payables Setup";
        GeneratedNo: Code[50];
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        with DisposalRequest do begin
            DisposalRequestLines.Reset;
            DisposalRequestLines.SetRange("Disposal No", "Disposal No");
            DisposalRequestLines.SetRange(Accept, true);
            if DisposalRequestLines.FindSet then begin
                repeat ProcurementSetup.Get;
                    ProcurementSetup.TestField("Disposal Nos");
                    GeneratedNo:=NoSeriesManagement.GetNextNo(ProcurementSetup."Disposal Nos", 0D, true);
                    Disposal.TransferFields(DisposalRequestLines);
                    Disposal."Disposal No":=GeneratedNo;
                    Disposal."Global Dimension 1":="Global Dimension 1 Code";
                    Disposal."Global Dimension 2":="Global Dimension 2 Code";
                    if Disposal.Insert then IanMarkAcceptedLinesForDisposal(DisposalRequest);
                until DisposalRequestLines.Next = 0;
            end;
        end;
    end;
    local procedure IanMarkAcceptedLinesForDisposal(DisposalRequest: Record "Disposal Request")
    var
        FixedAsset: Record "Fixed Asset";
        Item: Record Item;
        DisposalRequestLines: Record "Disposal Request Lines";
    begin
        with DisposalRequest do begin
            DisposalRequestLines.Reset;
            DisposalRequestLines.SetRange("Disposal No", "Disposal No");
            DisposalRequestLines.SetRange(Accept, true);
            if DisposalRequestLines.FindSet then begin
                if DisposalRequestLines.Type in[DisposalRequestLines.Type::"Fixed Asset"]then if FixedAsset.Get(DisposalRequestLines.No)then begin
                        FixedAsset."Marked For Disposal":=true;
                        //FixedAsset.Blocked:=TRUE;
                        FixedAsset.Modify(true);
                    end;
                if DisposalRequestLines.Type in[DisposalRequestLines.Type::Item]then if Item.Get(DisposalRequestLines.No)then begin
                        Item."Marked For Disposal":=true;
                        //Item.Blocked:=TRUE;
                        Item.Modify(true);
                    end;
            end;
        end;
    end;
    procedure IanCreateCustomerToAward(CustomerName: Text; EmailAddress: Code[10]; PhoneNo: Code[10]; CustomerCategoryParam: Code[100]): Code[100]var
        Customer: Record Customer;
        CustomerCategory: Record "Customer Category";
        SalesSetup: Record "Sales & Receivables Setup";
        CustomerNoAssigned: Code[100];
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        CustomerCategory.Reset;
        CustomerCategory.SetRange("Category Code", CustomerCategoryParam);
        if CustomerCategory.FindFirst then begin
            SalesSetup.Get;
            SalesSetup.TestField("Customer Nos.");
            CustomerNoAssigned:=NoSeriesManagement.GetNextNo(SalesSetup."Customer Nos.", 0D, true);
            with Customer do begin
                Init;
                "No.":=CustomerNoAssigned;
                Validate(Name, CustomerName);
                "Gen. Bus. Posting Group":=CustomerCategory."Gen. Bus. Posting Group";
                "VAT Bus. Posting Group":=CustomerCategory."VAT Bus. Posting Group";
                "Customer Posting Group":=CustomerCategory."Customer Posting Group";
                if CustomerNoAssigned <> '' then Insert;
            end;
        end;
        exit(CustomerNoAssigned);
    end;
    procedure IanSendMaintenanceEmail()
    var
        FA: Record "Fixed Asset";
        FASetup: Record "FA Setup";
        "FANo.": Text;
        FAName: Text;
        CombinedGeneratedString: Text;
        CountAssets: Integer;
        GeneratedFANoString: Text;
        GeneratedFANameString: Text;
        SenderAddress: Text;
        SenderName: Text;
        Subject: Text;
        Body: Text;
        Recepient: Text;
    begin
        CombinedGeneratedString:='';
        FA.Reset;
        //     FA.SetRange("Next Service Date", CalcDate(FASetup."Maintenance Period", Today));
        if FA.Find('-')then begin
            repeat GeneratedFANoString:='';
                GeneratedFANameString:='';
                GeneratedFANoString:=FA."No.";
                GeneratedFANameString:=FA.Description;
                CountAssets+=1;
                CombinedGeneratedString+=Format(CountAssets) + '. ' + '<b> Fixed Asset Name:</b>' + GeneratedFANameString + '.<b> FA No:</b>' + GeneratedFANoString + '<b>';
            until FA.Next = 0;
        end;
        UserSetup.Reset;
        UserSetup.SetRange("Head of Department", 'PROD');
        if UserSetup.FindFirst then begin
        // SMTPMailSetup.Get;
        // SenderName := SMTPMailSetup."From Name";
        // SenderAddress := SMTPMailSetup."From Address";
        // Recepient := UserSetup."E-Mail";
        // if Employee.Get(UserSetup."Employee No.") then begin
        //     Subject := 'Fixed Assets Due for Maintenance';
        //     Body := 'Hello ' + Employee.FullName + '<br> The Following Fixed Assets are due for Maintenance on <b>' + Format(Today) + '</b><br>' +
        //            CombinedGeneratedString + '<br> This is a system generated email please do not reply to it <br> Regards';
        // end;
        //        IanSoftFactory.IanSendEmailWithoutAttachement(SenderName, SenderAddress, Recepient, Subject, Body);
        end;
    end;
    [IntegrationEvent(false, false)]
    local procedure IanCheckIfDepartmentHasAssignedUser()
    begin
    end;
    local procedure IanCreateFixedAsset(Name: Integer)
    begin
    end;
    procedure IanGetTheLeastQuotedVendorAmount(QuoteNo: Code[50]; ItemNo: Code[30]): Decimal var
        QuotationVendorsBids: Record "Quotation Vendors Bids";
    begin
        QuotationVendorsBids.Reset;
        QuotationVendorsBids.SetRange("Quote No", QuoteNo);
        QuotationVendorsBids.SetRange("Item No", ItemNo);
        QuotationVendorsBids.SetFilter("Unit Price", '>%1', 0);
        QuotationVendorsBids.SetCurrentKey("Unit Price");
        QuotationVendorsBids.SetAscending("Unit Price", true);
        if QuotationVendorsBids.FindFirst then exit(QuotationVendorsBids."Unit Price");
    // EXIT(QuotationVendorsBids."Total Quoted Amount");
    end;
    procedure IanCreateVendorFromTenderBidder(var FinancialEvaluation: Record "Financial Evaluation"; DocumentNo: Code[30]): Code[30]var
        Vendor: Record Vendor;
        VendorCopy: Record Vendor;
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        TheVendorNo: Code[30];
    begin
        with FinancialEvaluation do begin
            Vendor.Reset;
            Vendor.SetRange("Tender No.", DocumentNo);
            if Vendor.FindFirst then begin
                Vendor.TestField("Gen. Bus. Posting Group");
                Vendor.TestField("Vendor Posting Group");
                Vendor.TestField("Supplier Category");
                Vendor.TestField("E-Mail");
                VendorCopy.Init;
                TheVendorNo:=NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Vendor Nos.", Today, true);
                VendorCopy."No.":=TheVendorNo;
                VendorCopy.Name:=Vendor.Name;
                VendorCopy."Vendor Type":=VendorCopy."Vendor Type"::Vendor;
                VendorCopy."Supplier Category":=Vendor."Supplier Category";
                VendorCopy."E-Mail":=Vendor."E-Mail";
                VendorCopy."Gen. Bus. Posting Group":=Vendor."Gen. Bus. Posting Group";
                VendorCopy.Validate("Gen. Bus. Posting Group");
                VendorCopy."Vendor Posting Group":=Vendor."Vendor Posting Group";
                VendorCopy.Validate("Vendor Posting Group");
                if VendorCopy.Insert then exit(TheVendorNo);
            end;
        end;
    end;
    procedure IanUpdateItemUnitOfMeasure(var Item: Record Item; ItemNum: Code[30]; UoM: Code[50]): Code[50]var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitofMeasure.Reset;
        ItemUnitofMeasure.SetRange("Item No.", ItemNum);
        ItemUnitofMeasure.SetRange(Code, UoM);
        if not ItemUnitofMeasure.FindFirst then begin
            ItemUnitofMeasure.Init;
            ItemUnitofMeasure."Item No.":=ItemNum;
            ItemUnitofMeasure.Code:=UoM;
            ItemUnitofMeasure."Qty. per Unit of Measure":=1;
            ItemUnitofMeasure.Insert;
        end;
        exit(UoM);
    end;
    // procedure IanGetPurchReQCommitmentAmount(var RequisitionLines: Record "Requisition Lines"; Location: Code[50]; GrantNo: Code[50]; ObjectiveCode: Code[50]; ActivityCode: Code[50]; PartnerCode: Code[50]): Decimal
    // var
    //     CommitmentEntries: Record "Commitment Entries";
    //     CommitmentAmount: Decimal;
    // begin
    //     CommitmentEntries.Reset;
    //     CommitmentEntries.SetRange("Location Code", Location);
    //     CommitmentEntries.SetRange("Grant No.", GrantNo);
    //     CommitmentEntries.SetRange(Objective, ObjectiveCode);
    //     CommitmentEntries.SetRange("Activty Code", ActivityCode);
    //     CommitmentEntries.SetRange("Partner Code", PartnerCode);
    //     if CommitmentEntries.FindSet then begin
    //         CommitmentEntries.CalcSums(Amount);
    //         CommitmentAmount := CommitmentEntries.Amount;
    //     end;
    //     exit(CommitmentAmount);
    // end;
    // procedure IanGetPurchReQBudgetAmount(var RequisitionLines: Record "Requisition Lines"; Location: Code[50]; GrantNo: Code[50]; ObjectiveCode: Code[50]; ActivityCode: Code[50]; PartnerCode: Code[50]): Decimal
    // var
    //     GrantLines: Record "Grant Detail Lines";
    //     BudgetAmount: Decimal;
    // begin
    //     BudgetAmount := 0;
    //     GrantLines.Reset;
    //     GrantLines.SetRange("Location Code", Location);
    //     GrantLines.SetRange("Grant Code", GrantNo);
    //     GrantLines.SetRange(Code, ActivityCode);
    //     GrantLines.SetRange("External Partner Code", PartnerCode);
    //     if GrantLines.FindSet then begin
    //         GrantLines.CalcSums("Total Cost");
    //         BudgetAmount := GrantLines."Total Cost";
    //     end;
    //     exit(BudgetAmount);
    // end;
    procedure IanGetPurchReQExpenditureAmount(var RequisitionLines: Record "Requisition Lines"; Location: Code[50]; GrantNo: Code[50]; ObjectiveCode: Code[50]; ActivityCode: Code[50]; PartnerCode: Code[50]): Decimal var
        GLEntry: Record "G/L Entry";
        ExpenditureAmount: Decimal;
    begin
        ExpenditureAmount:=0;
        // GLEntry.Reset;
        // GLEntry.SetRange("Location Code", Location);
        // GLEntry.SetRange("Grant Code", GrantNo);
        // GLEntry.SetRange("Activity Code", ActivityCode);
        // GLEntry.SetRange("Objective Code", ObjectiveCode);
        // GLEntry.SetRange("Partner Code", PartnerCode);
        // if GLEntry.FindSet then begin
        //     GLEntry.CalcSums(Amount);
        //     ExpenditureAmount := GLEntry.Amount;
        // end;
        exit(ExpenditureAmount);
    end;
    //  procedure IanGetPurchReQCommitmentAmountMinusPartnerCode(var RequisitionLines: Record "Requisition Lines"; Location: Code[50]; GrantNo: Code[50]; ObjectiveCode: Code[50]; ActivityCode: Code[50]): Decimal
    // var
    //     CommitmentEntries: Record "Commitment Entries";
    //     CommitmentAmount: Decimal;
    // begin
    //     CommitmentEntries.Reset;
    //     CommitmentEntries.SetRange("Location Code", Location);
    //     CommitmentEntries.SetRange("Grant No.", GrantNo);
    //     CommitmentEntries.SetRange(Objective, ObjectiveCode);
    //     CommitmentEntries.SetRange("Activty Code", ActivityCode);
    //     if CommitmentEntries.FindSet then begin
    //         CommitmentEntries.CalcSums(Amount);
    //         CommitmentAmount := CommitmentEntries.Amount;
    //     end;
    //     exit(CommitmentAmount);
    // end;
    procedure IanGetPurchReQBudgetAmountMinusPartnerCode(var RequisitionLines: Record "Requisition Lines"; Location: Code[50]; GrantNo: Code[50]; ObjectiveCode: Code[50]; ActivityCode: Code[50]): Decimal var
        // GrantLines: Record "Grant Lines";
        BudgetAmount: Decimal;
    begin
    // BudgetAmount := 0;
    // GrantLines.Reset;
    // GrantLines.SetRange("Location Code", Location);
    // GrantLines.SetRange("Grant No", GrantNo);
    // GrantLines.SetRange("Objective Code", ObjectiveCode);
    // GrantLines.SetRange(Code, ActivityCode);
    // if GrantLines.FindFirst then begin
    //     repeat
    //         GrantLines.CalcFields("Total Budget");
    //         BudgetAmount += GrantLines."Total Budget";
    //     until GrantLines.Next = 0;
    // end;
    // exit(BudgetAmount);
    end;
    procedure IanGetPurchReQExpenditureAmountMinusPartnerCode(var RequisitionLines: Record "Requisition Lines"; Location: Code[50]; GrantNo: Code[50]; ObjectiveCode: Code[50]; ActivityCode: Code[50]): Decimal var
        GLEntry: Record "G/L Entry";
        ExpenditureAmount: Decimal;
    begin
        ExpenditureAmount:=0;
        // GLEntry.Reset;
        // GLEntry.SetRange("Location Code", Location);
        // GLEntry.SetRange("Grant Code", GrantNo);
        // GLEntry.SetRange("Activity Code", ActivityCode);
        // GLEntry.SetRange("Objective Code", ObjectiveCode);
        // if GLEntry.FindSet then begin
        //     GLEntry.CalcSums(Amount);
        //     ExpenditureAmount := GLEntry.Amount;
        // end;
        exit(ExpenditureAmount);
    end;
}
