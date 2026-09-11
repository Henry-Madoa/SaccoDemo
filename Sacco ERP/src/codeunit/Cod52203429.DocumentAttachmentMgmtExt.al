codeunit 52203429 "Document Attachment Mgmt Ext"
{
    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', false, false)]
    local procedure DocumentAttachmentOnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        //**********Finance**********
        PV: Record "Payment Voucher";
        RequestHeader: Record "Request Header";
        PettyCash: Record "Petty Cash Header";
        VirementBudget: Record "Virement Budget Request";
        BudgetPlan: Record "Budget Plan";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        FixedDeposit: Record "Fixed Deposit Header";
        CompanyDocuments: Record "Company Documents";
        //**********Procurement**********
        RequisitionHeader: Record "Requisition Header";
        RFQ: Record "RFQ Header";
        BudgetPlanHeader: Record "Budget Plan";
        VirementBudgetRequest: Record "Virement Budget Request";
        ProcurePlan: Record "Procurement Plans";
        SupplierApplication: Record "Supplier Application";
        ProcurementRequest: Record "Procurement Request";
        Contract: Record "Contract Header";
        ContractExtension: Record "Contract Extension";
        //**********Human Resource**********
        Leave: Record "Leave Applications";
        Training: Record "Training Application";
        TrainingNeeds: Record "Training Needs";
        LeavePlan: Record "Leave Plan";
        Appraisal: Record "Appraisal Header";
        HrJobs: Record "Company Jobs";
        JobRequisition: Record "Job Requisition";
        EmployeeChange: Record "Employee Change Request";
        LeaveRecall: Record "Leave Recall";
        EmployeeExit: Record "Employee Exit";
        PayrollPeriod: Record "Payroll Periods";
    begin
        case DocumentAttachment."Table ID" of //**********Finance**********
 DATABASE::"Payment Voucher": begin
            RecRef.Open(DATABASE::"Payment Voucher");
            if PV.Get(DocumentAttachment."No.")then begin
                RecRef.GetTable(PV);
            end;
        end;
        DATABASE::"Request Header": begin
            RecRef.Open(DATABASE::"Request Header");
            if RequestHeader.Get(DocumentAttachment."No.")then RecRef.GetTable(RequestHeader);
        end;
        DATABASE::"Petty Cash Header": begin
            RecRef.Open(DATABASE::"Petty Cash Header");
            if PettyCash.Get(DocumentAttachment."No.")then RecRef.GetTable(PettyCash);
        end;
        DATABASE::"Budget Plan": begin
            RecRef.Open(DATABASE::"Budget Plan");
            if BudgetPlanHeader.Get(DocumentAttachment."No.")then RecRef.GetTable(BudgetPlanHeader);
        end;
        DATABASE::"Virement Budget Request": begin
            RecRef.Open(DATABASE::"Virement Budget Request");
            if VirementBudgetRequest.Get(DocumentAttachment."No.")then RecRef.GetTable(VirementBudgetRequest);
        end;
        DATABASE::"Fixed Deposit Header": begin
            RecRef.Open(DATABASE::"Fixed Deposit Header");
            if FixedDeposit.Get(DocumentAttachment."No.")then RecRef.GetTable(FixedDeposit);
        end;
        DATABASE::"Bank Acc. Reconciliation": begin
            RecRef.Open(DATABASE::"Bank Acc. Reconciliation");
            BankAccReconciliation.Reset();
            BankAccReconciliation.SetRange("Reconciliation No.", DocumentAttachment."No.");
            if BankAccReconciliation.FindFirst then RecRef.GetTable(BankAccReconciliation);
        end;
        //**********Procurement**********
        DATABASE::"Requisition Header": begin
            RecRef.Open(DATABASE::"Requisition Header");
            if RequisitionHeader.Get(DocumentAttachment."No.")then RecRef.GetTable(RequisitionHeader);
        end;
        DATABASE::"RFQ Header": begin
            RecRef.Open(DATABASE::"RFQ Header");
            if RFQ.Get(DocumentAttachment."No.")then RecRef.GetTable(RFQ);
        end;
        DATABASE::"Procurement Plans": begin
            RecRef.Open(DATABASE::"Procurement Plans");
            if ProcurePlan.Get(DocumentAttachment."No.")then RecRef.GetTable(ProcurePlan);
        end;
        DATABASE::"Supplier Application": begin
            RecRef.Open(DATABASE::"Supplier Application");
            if SupplierApplication.Get(DocumentAttachment."No.")then RecRef.GetTable(SupplierApplication);
        end;
        DATABASE::"Procurement Request": begin
            RecRef.Open(DATABASE::"Procurement Request");
            if ProcurementRequest.Get(DocumentAttachment."No.")then RecRef.GetTable(ProcurementRequest);
        end;
        DATABASE::"Contract Header": begin
            RecRef.Open(DATABASE::"Contract Header");
            if Contract.Get(DocumentAttachment."No.")then RecRef.GetTable(Contract);
        end;
        DATABASE::"Contract Extension": begin
            RecRef.Open(DATABASE::"Contract Extension");
            if ContractExtension.Get(DocumentAttachment."No.")then RecRef.GetTable(ContractExtension);
        end;
        //**********Human Resource**********
        DATABASE::"Leave Plan": begin
            RecRef.Open(DATABASE::"Leave Plan");
            if LeavePlan.Get(DocumentAttachment."No.")then RecRef.GetTable(LeavePlan);
        end;
        DATABASE::"Leave Applications": begin
            RecRef.Open(DATABASE::"Leave Applications");
            if Leave.Get(DocumentAttachment."No.")then RecRef.GetTable(Leave);
        end;
        DATABASE::"Leave Recall": begin
            RecRef.Open(DATABASE::"Leave Recall");
            if LeaveRecall.Get(DocumentAttachment."No.")then RecRef.GetTable(LeaveRecall);
        end;
        DATABASE::"Training Application": begin
            RecRef.Open(DATABASE::"Training Application");
            if Training.Get(DocumentAttachment."No.")then RecRef.GetTable(Training);
        end;
        DATABASE::"Training Needs": begin
            RecRef.Open(DATABASE::"Training Needs");
            if TrainingNeeds.Get(DocumentAttachment."No.")then RecRef.GetTable(TrainingNeeds);
        end;
        DATABASE::"Appraisal Header": begin
            RecRef.Open(DATABASE::"Appraisal Header");
            if Appraisal.Get(DocumentAttachment."No.")then RecRef.GetTable(Appraisal);
        end;
        DATABASE::"Company Documents": begin
            RecRef.Open(DATABASE::"Company Documents");
            if CompanyDocuments.Get(DocumentAttachment."No.")then RecRef.GetTable(CompanyDocuments);
        end;
        DATABASE::"Company Jobs": begin
            RecRef.Open(DATABASE::"Company Jobs");
            if HrJobs.Get(DocumentAttachment."No.")then RecRef.GetTable(HrJobs);
        end;
        DATABASE::"Job Requisition": begin
            RecRef.Open(DATABASE::"Job Requisition");
            if JobRequisition.Get(DocumentAttachment."No.")then RecRef.GetTable(JobRequisition);
        end;
        DATABASE::"Employee Change Request": begin
            RecRef.Open(DATABASE::"Employee Change Request");
            if EmployeeChange.Get(DocumentAttachment."No.")then RecRef.GetTable(EmployeeChange);
        end;
        DATABASE::"Employee Exit": begin
            RecRef.Open(DATABASE::"Employee Exit");
            if EmployeeExit.Get(DocumentAttachment."No.")then RecRef.GetTable(EmployeeExit);
        end;
        DATABASE::"Payroll Periods": begin
            RecRef.Open(DATABASE::"Payroll Periods");
            if PayrollPeriod.Get(DocumentAttachment."No.")then RecRef.GetTable(PayrollPeriod);
        end;
        end;
    end;
    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure DocumentAtachmentOnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
        LineNo: Integer;
    begin
        case RecRef.Number of Database::"Budget Plan Lines": begin
            FieldRef:=RecRef.Field(1);
            RecNo:=FieldRef.Value;
            DocumentAttachment.SetRange("No.", RecNo);
            FieldRef:=RecRef.Field(2);
            LineNo:=FieldRef.Value;
            DocumentAttachment.SetRange("Line No.", LineNo);
        end;
        end;
        case RecRef.Number of //**********Finance**********
 DATABASE::"Payment Voucher", DATABASE::"Request Header", DATABASE::"Petty Cash Header", DATABASE::"Budget Plan", DATABASE::"Virement Budget Request", DATABASE::"Fixed Deposit Header", //**********Procurement**********
 DATABASE::"Requisition Header", DATABASE::"RFQ Header", DATABASE::"Procurement Plans", DATABASE::"Supplier Application", DATABASE::"Procurement Request", DATABASE::"Contract Header", DATABASE::"Contract Extension", //**********Human Resource**********
 DATABASE::"Leave Plan", DATABASE::"Leave Applications", DATABASE::"Leave Recall", DATABASE::"Training Application", DATABASE::"Training Needs", DATABASE::"Appraisal Header", DATABASE::"Company Documents", DATABASE::"Company Jobs", DATABASE::"Job Requisition", DATABASE::"Employee Change Request", DATABASE::"Employee Exit": begin
            FieldRef:=RecRef.Field(1);
            RecNo:=FieldRef.Value;
            DocumentAttachment.SetRange("No.", RecNo);
        end;
        end;
        case RecRef.Number of DATABASE::"Payroll Periods": begin
            FieldRef:=RecRef.Field(2);
            RecNo:=FieldRef.Value;
            DocumentAttachment.SetRange("No.", RecNo);
        end;
        end;
        case RecRef.Number of DATABASE::"Bank Acc. Reconciliation": begin
            FieldRef:=RecRef.Field(489);
            RecNo:=FieldRef.Value;
            DocumentAttachment.SetRange("No.", RecNo);
        end;
        end;
    end;
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
    local procedure DocAttachmentOnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
        LineNo: Integer;
    begin
        DocumentAttachment.Validate("Table ID", RecRef.Number);
        case RecRef.Number of //**********Finance**********
 DATABASE::"Payment Voucher", DATABASE::"Request Header", DATABASE::"Petty Cash Header", DATABASE::"Budget Plan", DATABASE::"Virement Budget Request", DATABASE::"Fixed Deposit Header", //**********Procurement**********
 DATABASE::"Requisition Header", DATABASE::"RFQ Header", DATABASE::"Procurement Plans", DATABASE::"Supplier Application", DATABASE::"Procurement Request", DATABASE::"Contract Header", DATABASE::"Contract Extension", //**********Human Resource**********
 DATABASE::"Leave Plan", DATABASE::"Leave Applications", DATABASE::"Leave Recall", DATABASE::"Training Application", DATABASE::"Training Needs", DATABASE::"Appraisal Header", DATABASE::"Company Documents", DATABASE::"Company Jobs", DATABASE::"Job Requisition", DATABASE::"Employee Change Request", DATABASE::"Employee Exit": begin
            FieldRef:=RecRef.Field(1);
            RecNo:=FieldRef.Value;
            DocumentAttachment.Validate("No.", RecNo);
        end;
        end;
    end;
    procedure PortalDocumentAttchment(RecordID: RecordID; Base64: Text; FileName: Text)
    var
        DocAttachment: Record "Document Attachment";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        RecNo: Code[20];
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        varInstream: InStream;
        varOutstream: OutStream;
    begin
        RecRef:=RecordID.GetRecord;
        case RecRef.Number of //**********Finance**********
 DATABASE::"Payment Voucher", DATABASE::"Request Header", DATABASE::"Petty Cash Header", DATABASE::"Budget Plan", DATABASE::"Virement Budget Request", DATABASE::"Fixed Deposit Header", //**********Procurement**********
 DATABASE::"Requisition Header", DATABASE::"RFQ Header", DATABASE::"Procurement Plans", DATABASE::"Supplier Application", DATABASE::"Procurement Request", DATABASE::"Contract Header", DATABASE::"Contract Extension", //**********Human Resource**********
 DATABASE::"Leave Plan", DATABASE::"Leave Applications", DATABASE::"Leave Recall", DATABASE::"Training Application", DATABASE::"Training Needs", DATABASE::"Appraisal Header", DATABASE::"Company Documents", DATABASE::"Company Jobs", DATABASE::"Job Requisition", DATABASE::"Employee Change Request", DATABASE::"Employee Exit": begin
            FieldRef:=RecRef.Field(1);
            RecNo:=FieldRef.Value;
        end;
        end;
        TempBlob.CreateOutStream(varOutstream);
        TempBlob.CreateInStream(varInstream);
        Base64Convert.FromBase64(Base64, VarOutStream);
        DocAttachment.InitFieldsFromRecRef(RecRef);
        DocAttachment."Document Flow Sales":=RecRef.Number() = Database::"Sales Header";
        DocAttachment."Document Flow Purchase":=RecRef.Number() = Database::"Purchase Header";
        DocAttachment.SaveAttachmentFromStream(varInstream, RecRef, StrSubstNo('%1.pdf', FileName));
    end;
}
