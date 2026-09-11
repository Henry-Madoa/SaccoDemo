codeunit 52203428 "Approval Notification Ext"
{
    [EventSubscriber(ObjectType::Report, Report::"Notification Email", 'OnSetReportFieldPlaceholders', '', true, true)]
    local procedure OnSetReportFieldPlaceholders(RecRef: RecordRef; var Field1Label: Text; var Field1Value: Text; var Field2Label: Text; var Field2Value: Text; var Field3Label: Text; var Field3Value: Text)
    var
        NotificationEmail: Report "Notification Email";
        HasApprovalEntryAmount: Boolean;
        ApprovalEntry: Record "Approval Entry";
        FieldRef: FieldRef;
        Employee: Record Employee;
        DimensionValue: Record "Dimension Value";
        UserSetup: Record "User Setup";
        //**********Finance**********
        PV: Record "Payment Voucher";
        RequestHeader: Record "Request Header";
        PettyCash: Record "Petty Cash Header";
        VirementBudget: Record "Virement Budget Request";
        BudgetPlan: Record "Budget Plan";
        FixedDeposit: Record "Fixed Deposit Header";
        //**********Procurement**********
        RequisitionHeader: Record "Requisition Header";
        RFQ: Record "RFQ Header";
        ProcurePlan: Record "Procurement Plans";
        SupplierApplication: Record "Supplier Application";
        ProcurementRequest: Record "Procurement Request";
        Contract: Record "Contract Header";
        ContractExtension: Record "Contract Extension";
        //**********Human Resource**********
        LeaveApp: Record "Leave Applications";
        TrainingApp: Record "Training Application";
        TrainingNeeds: Record "Training Needs";
        LeavePlan: Record "Leave Plan";
        Appraisal: Record "Appraisal Header";
        HRJobs: Record "Company Jobs";
        JobRequisition: Record "Job Requisition";
        EmployeeChange: Record "Employee Change Request";
        LeaveRecall: Record "Leave Recall";
        EmployeeExit: Record "Employee Exit";
        PayrollPeriod: Record "Payroll Periods";
    begin
        if RecRef.Number = DATABASE::"Approval Entry" then begin
            HasApprovalEntryAmount:=true;
            RecRef.SetTable(ApprovalEntry);
        end;
        case RecRef.Number of //**********Finance**********
 DATABASE::"Payment Voucher": begin
            RecRef.SetTable(PV);
            Field1Label:=PV.FieldCaption("Total Amount");
            if PV.Currency <> '' then Field1Value:=PV.Currency + ' ';
            if HasApprovalEntryAmount then Field1Value+=FormatAmount(ApprovalEntry.Amount)
            else
            begin
                PV.CalcFields("Total Amount");
                Field1Value+=FormatAmount(PV."Total Amount")end;
            Field2Label:=PV.FieldCaption(Description);
            FieldRef:=RecRef.Field(PV.FieldNo(Description));
            Field2Value:=Format(FieldRef.Value) + ' (#' + PV."No." + ')';
        end;
        DATABASE::"Request Header": begin
            RecRef.SetTable(RequestHeader);
            if RequestHeader."Request Type" = RequestHeader."Request Type"::Imprest then Field1Label:=RequestHeader.FieldCaption("Total Requested Amount")
            else
                Field1Label:=RequestHeader.FieldCaption("Total Surrender Amount");
            if RequestHeader."Currency Code" <> '' then Field1Value:=RequestHeader."Currency Code" + ' ';
            if HasApprovalEntryAmount then Field1Value+=FormatAmount(ApprovalEntry.Amount)
            else
            begin
                if RequestHeader."Request Type" = RequestHeader."Request Type"::Imprest then begin
                    RequestHeader.CalcFields("Total Requested Amount");
                    Field1Value+=FormatAmount(RequestHeader."Total Requested Amount")end
                else
                begin
                    RequestHeader.CalcFields("Total Surrender Amount");
                    Field1Value+=FormatAmount(RequestHeader."Total Surrender Amount")end;
            end;
            Field2Label:=RequestHeader.FieldCaption(Description);
            FieldRef:=RecRef.Field(RequestHeader.FieldNo(Description));
            Field2Value:=Format(FieldRef.Value) + ' (#' + RequestHeader."No." + ')';
        end;
        DATABASE::"Petty Cash Header": begin
            RecRef.SetTable(PettyCash);
            Field1Label:=PettyCash.FieldCaption("Total Amount");
            if PettyCash."Currency Code" <> '' then Field1Value:=PettyCash."Currency Code" + ' ';
            if HasApprovalEntryAmount then Field1Value+=FormatAmount(ApprovalEntry.Amount)
            else
            begin
                PettyCash.CalcFields("Total Amount");
                Field1Value+=FormatAmount(PettyCash."Total Amount")end;
            Field2Label:=PettyCash.FieldCaption("Payment Narration");
            FieldRef:=RecRef.Field(PettyCash.FieldNo("Payment Narration"));
            Field2Value:=Format(FieldRef.Value) + ' (#' + PettyCash."No." + ')';
        end;
        DATABASE::"Budget Plan": begin
            RecRef.SetTable(BudgetPlan);
            Field1Label:=BudgetPlan.FieldCaption(Amount);
            if HasApprovalEntryAmount then Field1Value:=FormatAmount(ApprovalEntry.Amount)
            else
            begin
                BudgetPlan.CalcFields(Amount);
                Field1Value:=FormatAmount(BudgetPlan.Amount)end;
            DimensionValue.RESET;
            DimensionValue.SETRANGE("Dimension Code", 'DEPARTMENT');
            DimensionValue.SETRANGE(Code, BudgetPlan."Global Dimension 2 Code");
            IF DimensionValue.FINDFIRST then begin
                Field2Label:=BudgetPlan.FieldCaption(Description);
                FieldRef:=RecRef.Field(PettyCash.FieldNo("Payment Narration"));
                Field2Value:=Format(FieldRef.Value) + ' (#' + BudgetPlan."No." + ', Department:' + DimensionValue.Name + ')';
            end;
        end;
        DATABASE::"Virement Budget Request": begin
            RecRef.SetTable(VirementBudget);
            Field1Label:=VirementBudget.FieldCaption(Amount);
            if HasApprovalEntryAmount then Field1Value:=FormatAmount(ApprovalEntry.Amount)
            else
            begin
                VirementBudget.CalcFields(Amount);
                Field1Value:=FormatAmount(VirementBudget.Amount)end;
            Field2Label:=VirementBudget.FieldCaption("Budget Name");
            FieldRef:=RecRef.Field(VirementBudget.FieldNo("Budget Name"));
            Field2Value:=Format(FieldRef.Value) + ' (#' + VirementBudget."No." + ')';
        end;
        DATABASE::"Fixed Deposit Header": begin
            RecRef.SetTable(FixedDeposit);
            Field1Label:=FixedDeposit.FieldCaption(Amount);
            if HasApprovalEntryAmount then Field1Value:=FormatAmount(ApprovalEntry.Amount)
            else
            begin
                FixedDeposit.CalcFields(Amount);
                Field1Value:=FormatAmount(FixedDeposit.Amount)end;
            Field2Label:=FixedDeposit.FieldCaption("No.");
            FieldRef:=RecRef.Field(FixedDeposit.FieldNo("No."));
            Field2Value:=Format(FieldRef.Value) + ' (# Investment Institution: ' + FixedDeposit."Investment Institution" + ')';
        end; //**********Procurement**********
        DATABASE::"Requisition Header": begin
            RecRef.SetTable(RequisitionHeader);
            Field1Label:=RequisitionHeader.FieldCaption("No.");
            FieldRef:=RecRef.Field(RequisitionHeader.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=RequisitionHeader.FieldCaption(Description);
            FieldRef:=RecRef.Field(RequisitionHeader.FieldNo(Description));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"RFQ Header": begin
            RecRef.SetTable(RFQ);
            Field1Label:=RFQ.FieldCaption("No.");
            FieldRef:=RecRef.Field(RFQ.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=RFQ.FieldCaption(Description);
            FieldRef:=RecRef.Field(RFQ.FieldNo(Description));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"Procurement Plans": begin
            RecRef.SetTable(ProcurePlan);
            Field1Label:=ProcurePlan.FieldCaption("No.");
            FieldRef:=RecRef.Field(ProcurePlan.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=ProcurePlan.FieldCaption("Global Dimension 1 Code");
            DimensionValue.RESET;
            DimensionValue.SETRANGE("Dimension Code", 'DEPARTMENT');
            DimensionValue.SETRANGE(Code, ProcurePlan."Global Dimension 1 Code");
            IF DimensionValue.FINDFIRST then Field2Value:=DimensionValue.Name;
        end;
        DATABASE::"Supplier Application": begin
            RecRef.SetTable(SupplierApplication);
            Field1Label:=SupplierApplication.FieldCaption("No.");
            FieldRef:=RecRef.Field(SupplierApplication.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=SupplierApplication.FieldCaption(Name);
            FieldRef:=RecRef.Field(SupplierApplication.FieldNo(Name));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"Procurement Request": begin
            RecRef.SetTable(ProcurementRequest);
            Field1Label:=ProcurementRequest.FieldCaption("Total Amount");
            if HasApprovalEntryAmount then Field1Value:=FormatAmount(ApprovalEntry.Amount)
            else
            begin
                ProcurementRequest.CalcFields("Total Amount");
                Field1Value+=FormatAmount(ProcurementRequest."Total Amount")end;
            Field2Label:=ProcurementRequest.FieldCaption(Description);
            FieldRef:=RecRef.Field(ProcurementRequest.FieldNo(Description));
            Field2Value:=Format(FieldRef.Value) + ' (#' + ProcurementRequest."No." + ')';
        end;
        DATABASE::"Contract Header": begin
            RecRef.SetTable(Contract);
            Field1Label:=Contract.FieldCaption("No.");
            FieldRef:=RecRef.Field(Contract.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=Contract.FieldCaption("Vendor Name");
            FieldRef:=RecRef.Field(Contract.FieldNo("Vendor Name"));
            Field2Value:=Format(FieldRef.Value) + '(# Contract Start Date: ' + Format(Contract."Contract Start Date") + ' Contract Expiry Date: ' + Format(Contract."Contract Expiry Date") + ')' end;
        DATABASE::"Contract Extension": begin
            RecRef.SetTable(ContractExtension);
            Field1Label:=ContractExtension.FieldCaption("No.");
            FieldRef:=RecRef.Field(ContractExtension.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=ContractExtension.FieldCaption("Contract Title");
            FieldRef:=RecRef.Field(ContractExtension.FieldNo("Contract Title"));
            Field2Value:=Format(FieldRef.Value) + '(# Initial End Date: ' + Format(ContractExtension."Initial End Date") + ')' end;
        //**********Human Resource**********
        DATABASE::"Leave Plan": begin
            RecRef.SetTable(LeavePlan);
            Field1Label:=LeavePlan.FieldCaption("No.");
            FieldRef:=RecRef.Field(LeavePlan.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=LeavePlan.FieldCaption("Leave Calendar Description");
            FieldRef:=RecRef.Field(LeavePlan.FieldNo("Leave Calendar Description"));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"Leave Applications": begin
            RecRef.SetTable(LeaveApp);
            Field1Label:=LeaveApp.FieldCaption("No.");
            FieldRef:=RecRef.Field(LeaveApp.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=LeaveApp.FieldCaption(Comments);
            FieldRef:=RecRef.Field(LeaveApp.FieldNo(Comments));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"Leave Recall": begin
            RecRef.SetTable(LeaveRecall);
            Field1Label:=LeaveRecall.FieldCaption("No.");
            FieldRef:=RecRef.Field(LeaveRecall.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=LeaveRecall.FieldCaption(Comments);
            FieldRef:=RecRef.Field(LeaveRecall.FieldNo(Comments));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"Training Application": begin
            RecRef.SetTable(TrainingApp);
            Field1Label:=TrainingApp.FieldCaption("No.");
            FieldRef:=RecRef.Field(TrainingApp.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=TrainingApp.FieldCaption("Training Need Description");
            FieldRef:=RecRef.Field(TrainingApp.FieldNo("Training Need Description"));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"Training Needs": begin
            RecRef.SetTable(TrainingNeeds);
            Field1Label:=TrainingNeeds.FieldCaption(Code);
            FieldRef:=RecRef.Field(TrainingNeeds.FieldNo(Code));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=TrainingNeeds.FieldCaption(Description);
            FieldRef:=RecRef.Field(TrainingNeeds.FieldNo(Description));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"Appraisal Header": begin
            RecRef.SetTable(Appraisal);
            Field1Label:=Appraisal.FieldCaption("No.");
            FieldRef:=RecRef.Field(Appraisal.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=Appraisal.FieldCaption("Employee Name");
            FieldRef:=RecRef.Field(Appraisal.FieldNo("Employee Name"));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"Company Jobs": begin
            RecRef.SetTable(HRJobs);
            Field1Label:=HRJobs.FieldCaption("Job ID");
            FieldRef:=RecRef.Field(HRJobs.FieldNo("Job ID"));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=HRJobs.FieldCaption(Name);
            FieldRef:=RecRef.Field(HRJobs.FieldNo(Name));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"Job Requisition": begin
            RecRef.SetTable(HRJobs);
            Field1Label:=HRJobs.FieldCaption("Job ID");
            FieldRef:=RecRef.Field(HRJobs.FieldNo("Job ID"));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=HRJobs.FieldCaption(Name);
            FieldRef:=RecRef.Field(HRJobs.FieldNo(Name));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"Employee Change Request": begin
            RecRef.SetTable(EmployeeChange);
            Field1Label:=EmployeeChange.FieldCaption("Employee No");
            FieldRef:=RecRef.Field(EmployeeChange.FieldNo("Employee No"));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=EmployeeChange.FieldCaption("Nature of Change");
            FieldRef:=RecRef.Field(EmployeeChange.FieldNo("Nature of Change"));
            Field2Value:=Format(FieldRef.Value);
        end;
        DATABASE::"Employee Exit": begin
            RecRef.SetTable(EmployeeExit);
            Field1Label:=EmployeeExit.FieldCaption("No.");
            FieldRef:=RecRef.Field(EmployeeExit.FieldNo("No."));
            Field1Value:=Format(FieldRef.Value);
            Field2Label:=EmployeeExit.FieldCaption("Employee Name");
            FieldRef:=RecRef.Field(EmployeeExit.FieldNo("Employee Name"));
            Field2Value:=Format(FieldRef.Value);
        end;
        end;
    end;
    [EventSubscriber(ObjectType::Report, Report::"Notification Email", 'OnAfterSetReportLinePlaceholders', '', true, true)]
    local procedure OnAfterSetReportLinePlaceholders(ReceipientUser: Record User; CompanyInformation: Record "Company Information"; var Line1: Text; var Line2: Text)
    begin
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnGetDocumentTypeAndNumber', '', true, true)]
    local procedure OnGetDocumentTypeAndNumber(var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean)
    var
        FieldRef: FieldRef;
    begin
        case RecRef.Number of //**********Finance**********
 Database::"Budget Plan Lines", DATABASE::"Payment Voucher", DATABASE::"Request Header", DATABASE::"Petty Cash Header", DATABASE::"Budget Plan", DATABASE::"Virement Budget Request", DATABASE::"Fixed Deposit Header", //**********Procurement**********
 DATABASE::"Requisition Header", DATABASE::"RFQ Header", DATABASE::"Procurement Plans", DATABASE::"Supplier Application", DATABASE::"Procurement Request", DATABASE::"Contract Header", DATABASE::"Contract Extension", //**********Human Resource**********
 DATABASE::"Leave Plan", DATABASE::"Leave Applications", DATABASE::"Leave Recall", DATABASE::"Training Application", DATABASE::"Training Needs", DATABASE::"Appraisal Header", DATABASE::"Company Documents", DATABASE::"Company Jobs", DATABASE::"Job Requisition", DATABASE::"Employee Change Request", DATABASE::"Employee Exit": begin
            DocumentType:=RecRef.Caption;
            FieldRef:=RecRef.Field(1);
            DocumentNo:=Format(FieldRef.Value);
        end;
        end;
        case RecRef.Number of DATABASE::"Payroll Periods": begin
            DocumentType:=RecRef.Caption;
            FieldRef:=RecRef.Field(2);
            DocumentNo:=Format(FieldRef.Value);
        end;
        end;
        case RecRef.Number of DATABASE::"Bank Acc. Reconciliation": begin
            DocumentType:=RecRef.Caption;
            FieldRef:=RecRef.Field(489);
            DocumentNo:=Format(FieldRef.Value);
        end;
        end;
    end;
    local procedure FormatAmount(Amount: Decimal): Text begin
        exit(Format(Amount, 0, '<Precision,2><Standard Format,0>'));
    end;
}
