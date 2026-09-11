page 52203922 "Service Proforma Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Service Proforma Header";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'Service Proforma';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                }
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field(Model; Rec.Model)
                {
                    ApplicationArea = All;
                }
                field("Chassis No."; Rec."Chassis No.")
                {
                    ApplicationArea = All;
                }
                field("Engine No."; Rec."Engine No.")
                {
                    ApplicationArea = All;
                }
                field("Mileage (Kms)"; Rec."Mileage (Kms)")
                {
                    ApplicationArea = All;
                }
                field("Dealer No."; Rec."Dealer No.")
                {
                    ApplicationArea = All;
                }
                field("Dealer Name"; Rec."Dealer Name")
                {
                    ApplicationArea = All;
                }
                field("Proforma Date"; Rec."Proforma Date")
                {
                    ApplicationArea = All;
                }
                field("Last Service Date"; Rec."Last Service Date")
                {
                    ApplicationArea = All;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
                field("Contact Person"; Rec."Contact Person")
                {
                    ApplicationArea = All;
                }
                field("Contact Person Name"; Rec."Contact Person Name")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part(Control1120054016; "Service Proforma SubForm")
            {
                ApplicationArea = All;
                Editable = EditLines;
                SubPageLink = "Document No."=FIELD("No.");
            }
            group("Total Amounts")
            {
                Caption = 'Total Amounts';

                field("Total Amount"; Rec."Total Amount")
                {
                }
                field("Total Sundries"; Rec."Total Sundries")
                {
                }
                field("Total Amount + Sundries"; Rec."Total Amount + Sundries")
                {
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Send Approval Request")
            {
                ApplicationArea = All;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ServiceProformaLine: Record "Service Proforma Line";
                begin
                    Rec.TestField(Status, Rec.Status::New);
                    ServiceProformaLine.Reset;
                    ServiceProformaLine.SetRange("Document No.", Rec."No.");
                    if ServiceProformaLine.FindFirst then begin
                        repeat ServiceProformaLine.TestField("Item No");
                            ServiceProformaLine.TestField(Quantity);
                            ServiceProformaLine.TestField("Unit Price");
                        until ServiceProformaLine.Next = 0;
                    end;
                    if not Confirm('Are you sure you want to send the document for approval?')then exit;
                    Rec.Status:=Rec.Status::Approved;
                    Rec.Modify;
                // IF ApprovalsMgmt.CheckServiceProformaApprovalsWorkflowEnabled(Rec) THEN
                //  ApprovalsMgmt.OnSendServiceProformaForApproval(Rec);
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = All;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    if not Confirm('Do you want to cancel the approval request?')then exit;
                    Rec.Status:=Rec.Status::New;
                    Rec.Modify;
                // IF ApprovalsMgmt.CheckServiceProformaApprovalsWorkflowEnabled(Rec) THEN
                //  ApprovalsMgmt.OnCancelServiceProformaApprovalRequest(Rec);
                end;
            }
            action(Approvals)
            {
            }
            action(Print)
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to print the service proforma?')then exit;
                    ServiceProformaHeader.Reset;
                    ServiceProformaHeader.SetRange("No.", Rec."No.");
                    if ServiceProformaHeader.FindFirst then begin
                        REPORT.RunModal(REPORT::"Service Proforma Report", true, false, ServiceProformaHeader);
                    end;
                end;
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean begin
        Rec."Created Date":=Today;
        Rec."Created By":=UserId;
    end;
    trigger OnOpenPage()
    begin
        EditControls;
    end;
    var TotalAmount: Decimal;
    TotalSundries: Decimal;
    TotalAmountSundries: Decimal;
    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    EditLines: Boolean;
    ServiceProformaHeader: Record "Service Proforma Header";
    local procedure EditControls(): Boolean begin
        EditLines:=true;
        if Rec.Status <> Rec.Status::New then EditLines:=false;
    end;
}
