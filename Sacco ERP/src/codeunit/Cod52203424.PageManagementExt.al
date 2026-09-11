codeunit 52203424 "Page Management Ext"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, true)]
    local Procedure OnAfterGetPageID(RecordRef: RecordRef; var PageId: Integer)
    begin
        if PageId = 0 then PageId:=GetConditionalCardPageID(RecordRef);
    end;
    local procedure GetConditionalCardPageID(RecordRef: RecordRef): Integer begin
        case RecordRef.Number of //**********************SOFT - BASIC FINANCE MODULE CUSTOMIZATIONS***********************
 //1. Payment Voucher
        DATABASE::"Payment Voucher": exit(PAGE::"Payment Voucher");
        //1. Payment Voucher
        DATABASE::"Receipt Header": exit(PAGE::Receipt);
        //2. Petty Cash
        DATABASE::"Petty Cash Header": exit(PAGE::"Petty Cash");
        //3. Request Header
        DATABASE::"Request Header": exit(GetImprestHeaderPageID(RecordRef));
        //
        //4. Virement Budget Request
        DATABASE::"Virement Budget Request": exit(PAGE::"Virement Budget Request");
        //
        //5. Budget Plan
        DATABASE::"Budget Plan": exit(PAGE::"Budget Plan Approval");
        //
        //7. Bank Acc. Reconciliation
        DATABASE::"Bank Acc. Reconciliation": exit(PAGE::"Bank Acc. Reconciliation");
        //
        //8. FD Header
        DATABASE::"Fixed Deposit Header": exit(PAGE::"Fixed Deposit");
        //
        //**********************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS***********************
        //1. Requisition
        DATABASE::"Requisition Header": exit(PAGE::"Requisition Header-Pe");
        //
        //2. Procurement Inspection
        DATABASE::"Procurement Inspection": exit(PAGE::"Procurement Inspection");
        // 
        //2. Procurement Plan
        Database::"Procurement Plans": exit(page::"Procurement Plan");
        //
        //3. RFQ
        Database::"RFQ Header": exit(page::"RFQ Header");
        //
        //5. Supplier Application
        Database::"Supplier Application": exit(page::"Supplier Application");
        //
        //6. Procurement Request
        Database::"Procurement Request": exit(page::"Tender Card");
        //
        //7. Contract Header
        Database::"Contract Header": exit(page::"Contract Card");
        //
        //8. Contract Extension
        Database::"Contract Extension": exit(page::"Contract Extension Card");
        //      
        //**********************SOFT - HR MODULE CUSTOMIZATIONS***********************
        //2. Training Needs
        DATABASE::"Training Needs": exit(PAGE::"Training Need Card");
        //
        //3. Employee Leave Plan
        DATABASE::"Leave Plan": exit(PAGE::"Leave Plan Pending Approval");
        //
        //4. Leave Application
        DATABASE::"Leave Applications": exit(PAGE::"Leave Application");
        // 
        //5. Leave Recall
        DATABASE::"Leave Recall": exit(PAGE::"Leave Recall");
        //
        //6. Appraisal Header0
        DATABASE::"Appraisal Header": exit(PAGE::"Appraisal Card");
        //
        //7. HR Jobs
        DATABASE::"Company Jobs": exit(PAGE::"Company Jobs");
        //
        //8. Job Requisition
        DATABASE::"Job Requisition": exit(PAGE::"Job Requisition");
        //
        //9. Employee
        DATABASE::Employee: exit(PAGE::"Employee Card");
        //
        //10. Employee Change Request
        DATABASE::"Employee Change Request": exit(PAGE::"Change Request Card");
        //
        //11. Employee Exit
        DATABASE::"Employee Exit": exit(PAGE::"Employee Exit Card");
        //
        //12. Payroll Periods
        DATABASE::"Payroll Periods": exit(PAGE::"Payroll Approval Card");
        //
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, true)]
    local procedure OnAfterGetListPageID(RecordRef: RecordRef; var PageId: Integer)
    begin
        if PageId = 0 then PageId:=GetConditionalListPageID(RecordRef);
    end;
    local procedure GetConditionalListPageID(RecRef: RecordRef): Integer begin
        case RecRef.Number of end;
    end;
    local procedure GetImprestHeaderPageID(RecRef: RecordRef): Integer var
        RequestHeader: Record "Request Header";
    begin
        RecRef.SetTable(RequestHeader);
        case RequestHeader."Request Type" of RequestHeader."Request Type"::Imprest: exit(PAGE::"Imprest Request");
        RequestHeader."Request Type"::Surrender: exit(PAGE::"Staff Claim");
        end;
    end;
}
