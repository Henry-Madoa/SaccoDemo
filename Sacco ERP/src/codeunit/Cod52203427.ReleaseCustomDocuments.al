codeunit 52203427 "Release Custom Documents"
{
    var Text003: Label 'The approval process must be cancelled or completed to reopen this document.';
    ApprovalsMgmtExt: Codeunit "Approval Mgmt. Ext";
    local procedure "**************Payment Voucher*******************"()
    begin
    end;
    procedure PerformManualReopenPV(var PV: Record "Payment Voucher")
    begin
        with PV do begin
            if Status = Status::Open then exit;
            Status:=Status::Open;
            Modify(true);
        end;
    end;
    procedure PerformManualReleasePV(var PV: Record "Payment Voucher")
    begin
        PV.OnBeforeApproval;
        if ApprovalsMgmtExt.CheckPVApprovalsWorkflowEnable(PV)then Error('Approval Workflow is enabled, Kindly disable the workflow and try again Or Contact Admin')
        else
        begin
            if Confirm(StrSubstNo('You are about to perform a manual release for %1, Do you wish to continue?', PV."No."))then begin
                with PV do begin
                    if Status = Status::Approved then exit;
                    PV.Status:=PV.Status::Approved;
                    PV.Modify(true);
                end;
            end;
        end;
    end;
    local procedure "**************Procurement Plan*******************"()
    begin
    end;
    procedure ReopenProcurementPlan(var ProcurementPlan: Record "Procurement Plans")
    begin
        OnBeforeReopenProcurementPlan(ProcurementPlan);
        with ProcurementPlan do begin
            if Status = Status::Open then exit;
            Status:=Status::Open;
            Modify(true);
        end;
        OnAfterReopenProcurementPlan(ProcurementPlan);
    end;
    procedure PerformManualReleaseProcurementPlan(var ProcurementPlan: Record "Procurement Plans")
    var
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
    begin
        OnBeforeReleaseProcurementPlan(ProcurementPlan);
        with ProcurementPlan do begin
            ProcurementPlan.Status:=ProcurementPlan.Status::Approved;
            ProcurementPlan.Modify(true);
        end;
        OnAfterReleasProcurementPlan(ProcurementPlan);
    end;
    procedure PerformManualReopenProcurementPlan(var ProcurementPlan: Record "Procurement Plans")
    begin
        if ProcurementPlan.Status = ProcurementPlan.Status::Approved then Error(Text003);
        ReopenProcurementPlan(ProcurementPlan);
    end;
    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseProcurementPlan(var ProcurementPlan: Record "Procurement Plans")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnAfterReleasProcurementPlan(var ProcurementPlan: Record "Procurement Plans")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopenProcurementPlan(var ProcurementPlan: Record "Procurement Plans")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnAfterReopenProcurementPlan(var ProcurementPlan: Record "Procurement Plans")
    begin
    end;
    local procedure "**************Supplier Application*******************"()
    begin
    end;
    procedure ReopenSupplierApplication(var SupplierApplication: Record "Supplier Application")
    begin
        OnBeforeReopenSupplierApplication(SupplierApplication);
        with SupplierApplication do begin
            if Status = Status::Open then exit;
            Status:=Status::Rejected;
            Modify(true);
        end;
        OnAfterReopenSupplierApplication(SupplierApplication);
    end;
    procedure PerformManualReleaseSupplierApplication(var SupplierApplication: Record "Supplier Application")
    var
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
    begin
        OnBeforeReleaseSupplierApplication(SupplierApplication);
        with SupplierApplication do begin
            SupplierApplication.Status:=SupplierApplication.Status::Approved;
            SupplierApplication."Approval Date":=Today;
            SupplierApplication.Modify(true);
        end;
        OnAfterReleasSupplierApplication(SupplierApplication);
    end;
    procedure PerformManualReopenSupplierApplication(var SupplierApplication: Record "Supplier Application")
    begin
        if SupplierApplication.Status = SupplierApplication.Status::Approved then Error(Text003);
        ReopenSupplierApplication(SupplierApplication);
    end;
    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseSupplierApplication(var SupplierApplication: Record "Supplier Application")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnAfterReleasSupplierApplication(var SupplierApplication: Record "Supplier Application")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopenSupplierApplication(var SupplierApplication: Record "Supplier Application")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnAfterReopenSupplierApplication(var SupplierApplication: Record "Supplier Application")
    begin
    end;
    local procedure "**************Requisition Header*******************"()
    begin
    end;
    procedure ReopenRequisitionHeader(var RequisitionHeader: Record "Requisition Header")
    begin
        OnBeforeReopenRequisitionHeader(RequisitionHeader);
        with RequisitionHeader do begin
            if Status = Status::Open then exit;
            Status:=Status::Open;
            Modify(true);
        end;
        OnAfterReopenRequisitionHeader(RequisitionHeader);
    end;
    procedure PerformManualReleaseRequisitionHeader(var RequisitionHeader: Record "Requisition Header")
    var
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
    begin
        OnBeforeReleaseRequisitionHeader(RequisitionHeader);
        with RequisitionHeader do begin
            RequisitionHeader.Status:=RequisitionHeader.Status::Approved;
            RequisitionHeader.Modify(true);
        end;
        OnAfterReleaseRequisitionHeader(RequisitionHeader);
    end;
    procedure PerformManualReopenRequisitionHeader(var RequisitionHeader: Record "Requisition Header")
    begin
        if RequisitionHeader.Status = RequisitionHeader.Status::Approved then Error(Text003);
        ReopenRequisitionHeader(RequisitionHeader);
    end;
    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseRequisitionHeader(var RequisitionHeader: Record "Requisition Header")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseRequisitionHeader(var RequisitionHeader: Record "Requisition Header")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopenRequisitionHeader(var RequisitionHeader: Record "Requisition Header")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnAfterReopenRequisitionHeader(var RequisitionHeader: Record "Requisition Header")
    begin
    end;
}
