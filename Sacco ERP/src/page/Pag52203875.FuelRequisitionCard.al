page 52203875 "Fuel Requisition Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Fuel Requisition";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = EditPage;

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field("Fueling Date"; Rec."Fueling Date")
                {
                    ApplicationArea = All;
                }
                field("Vendor Code"; Rec."Vendor Code")
                {
                    ApplicationArea = All;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Driver Emp. No"; Rec."Driver Emp. No")
                {
                    ApplicationArea = All;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = All;
                }
                field("Card No."; Rec."Card No.")
                {
                    ApplicationArea = All;
                }
                field("Paybill No."; Rec."Paybill No.")
                {
                    ApplicationArea = All;
                }
                field("Quantity Fueled (ltrs)"; Rec."Quantity Fueled (ltrs)")
                {
                    ApplicationArea = All;
                }
                field("Total Fuel Cost"; Rec."Total Fuel Cost")
                {
                    ApplicationArea = All;
                }
                field("Cost Per Litre"; Rec."Cost Per Litre")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
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
                begin
                    Rec.TestField(Status, Rec.Status::New);
                    Rec.TestField("Vehicle REG. No.");
                    Rec.TestField("Vendor Code");
                    Rec.TestField("Driver Emp. No");
                    Rec.TestField("Fueling Date");
                    Rec.TestField("Quantity Fueled (ltrs)");
                    Rec.TestField("Total Fuel Cost");
                    if not Confirm('Do you want to send the fuel request for approval?')then exit;
                    Rec.Status:=Rec.Status::Approved;
                    Rec.Modify;
                // IF ApprovalsMgmt.CheckFuelRequisitionApprovalsWorkflowEnabled(Rec) THEN
                //  ApprovalsMgmt.OnSendFuelRequisitionForApproval(Rec);
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
                    if not Confirm('Do you want to cancel the fuel approval request?')then exit;
                    Rec.Status:=Rec.Status::New;
                    Rec.Modify;
                // IF ApprovalsMgmt.CheckFuelRequisitionApprovalsWorkflowEnabled(Rec) THEN
                //  ApprovalsMgmt.OnCancelFuelRequisitionApprovalRequest(Rec);
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
                    Rec.TestField(Posted, true);
                    if not Confirm('Are you sure you want to create an invoice from this fuel requisition?')then exit;
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
                    Rec.TestField(Status, Rec.Status::Approved);
                    Rec.TestField(Posted, false);
                    if not Confirm('Are you sure you want to submit the fuel log?')then exit;
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.FindFirst then begin
                        FleetManagement.PostVehicleExpenses(Rec."Posting Date", Rec."Transaction Type", Rec."No.", Rec."Vendor Name", Rec."Total Fuel Cost", Rec."Total Fuel Cost", Rec."Vehicle REG. No.");
                    end;
                    Rec.Posted:=true;
                    Rec.Modify(true);
                    CurrPage.Close;
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        EditControls;
    end;
    var FleetManagement: Codeunit "Fleet Management";
    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    EditPage: Boolean;
    local procedure EditControls(): Boolean begin
        EditPage:=true;
        if Rec.Status <> Rec.Status::New then EditPage:=false;
    end;
}
