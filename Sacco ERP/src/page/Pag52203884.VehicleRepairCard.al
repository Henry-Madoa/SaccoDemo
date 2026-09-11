page 52203884 "Vehicle Repair Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Vehicle Repair Header";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Mileage at Service (kms)"; Rec."Mileage at Service (kms)")
                {
                    ApplicationArea = All;
                }
                field("Service Proforma No"; Rec."Service Proforma No")
                {
                    ApplicationArea = All;
                }
            }
            part("Vehicle Repair Subform"; "Vehicle Repair Subform")
            {
                ApplicationArea = All;
                Caption = 'Vehicle Repair Subform';
                SubPageLink = "Requisition No."=FIELD("No.");
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
                begin
                    Rec.TestField(Status, Rec.Status::New);
                    if not Confirm('Are you sure you want to send the repair request for approval?')then exit;
                    Rec.Status:=Rec.Status::Approved;
                    Rec.Modify;
                // IF ApprovalsMgmt.CheckRepairRequisitionApprovalsWorkflowEnabled(Rec) THEN
                //  ApprovalsMgmt.OnSendRepairRequisitionForApproval(Rec);
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
                    if not Confirm('Are you sure you want to cancel the vehicle repair request?')then exit;
                    Rec.Status:=Rec.Status::New;
                    Rec.Modify;
                // IF ApprovalsMgmt.CheckRepairRequisitionApprovalsWorkflowEnabled(Rec) THEN
                //  ApprovalsMgmt.OnCancelRepairRequisitionApprovalRequest(Rec);
                end;
            }
            action("Create Purchase Invoice")
            {
                ApplicationArea = All;
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Approved);
                    if not Confirm('Are you sure you want to create an invoice from this repair requisition?')then exit;
                    CurrPage.Close;
                end;
            }
            action(Post)
            {
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to post the maintenance expense?')then exit;
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.FindFirst then begin
                        VehicleRepairLine.Reset;
                        VehicleRepairLine.SetRange("Requisition No.", Rec."No.");
                        if VehicleRepairLine.FindFirst then begin
                            Rec.TestField("Posting Date");
                            Rec.TestField("Vehicle REG. No.");
                            repeat VehicleRepairLine.TestField(Narration);
                                VehicleRepairLine.TestField("Total + Sundries");
                                FleetManagement.PostVehicleExpenses(Rec."Posting Date", Rec."Transaction Type", Rec."No.", VehicleRepairLine.Narration, VehicleRepairLine."Total + Sundries", VehicleRepairLine."Total + Sundries", Rec."Vehicle REG. No.");
                            until VehicleRepairLine.Next = 0;
                        end;
                        Rec.Posted:=true;
                        Rec.Modify(true);
                    end;
                    CurrPage.Close;
                end;
            }
        }
    }
    var FleetManagement: Codeunit "Fleet Management";
    VehicleRepairLine: Record "Vehicle Repair Line";
    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
}
