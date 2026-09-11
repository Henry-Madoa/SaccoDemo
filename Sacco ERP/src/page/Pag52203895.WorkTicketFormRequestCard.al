page 52203895 "WorkTicket Form Request Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "WorkTicket Form Request";
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
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                }
                field("Driver No."; Rec."Driver No.")
                {
                    ApplicationArea = All;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field("Previous WTKT No."; Rec."Previous WTKT No.")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                }
                field(Station; Rec.Station)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Submitted; Rec.Submitted)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part(Control1120054010; "WorkTicket Form Request Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Document No."=FIELD("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Submit Form Request")
            {
                ApplicationArea = All;
                Image = SendTo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Submitted, false);
                    if not Confirm('Are you sure you want to submit the form request?')then exit;
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.FindFirst then begin
                        Rec.Submitted:=true;
                        if Rec.Modify(true)then begin
                            FleetManagement.SendNotificationOnWorkFormRequestSubmission(Rec);
                            Message('Work ticket request has been submitted successfully');
                        end;
                    end;
                end;
            }
            action("Send Approval Request")
            {
                ApplicationArea = All;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Submitted, true);
                    Rec.TestField(Status, Rec.Status::New);
                    if not Confirm('Are you sure you want to send the request form for approval?')then exit;
                    Rec.Status:=Rec.Status::Approved;
                    Rec.Modify;
                // IF ApprovalsMgmt.CheckWorkTicketFormApprovalsWorkflowEnabled(Rec) THEN
                //  ApprovalsMgmt.OnSendWorkTicketFormForApproval(Rec);
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
                    if not Confirm('Are you sure you want to cancel the approval request?')then exit;
                    Rec.Status:=Rec.Status::New;
                    Rec.Modify;
                // IF ApprovalsMgmt.CheckWorkTicketFormApprovalsWorkflowEnabled(Rec) THEN
                //  ApprovalsMgmt.OnCancelWorkTicketFormApprovalRequest(Rec);
                end;
            }
            action("Print Completed Form")
            {
                ApplicationArea = All;
                Image = PrintForm;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    WorkTicketFormRequest.Reset;
                    WorkTicketFormRequest.SetRange("No.", Rec."No.");
                    WorkTicketFormRequest.SetRange(Completed, true);
                    if WorkTicketFormRequest.FindFirst then begin
                        REPORT.RunModal(60100, true, false, WorkTicketFormRequest);
                    end;
                end;
            }
            action("Print Form")
            {
                ApplicationArea = All;
                Image = PrintForm;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    WorkTicketFormRequest.Reset;
                    WorkTicketFormRequest.SetRange("No.", Rec."No.");
                    // WorkTicketFormRequest.SETRANGE(Completed,TRUE);
                    if WorkTicketFormRequest.FindFirst then begin
                        REPORT.RunModal(60100, true, false, WorkTicketFormRequest);
                    end;
                end;
            }
        }
    }
    trigger OnDeleteRecord(): Boolean begin
        Rec.TestField(Submitted, false);
    end;
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean begin
        Rec.TestField(Submitted, false);
    end;
    trigger OnModifyRecord(): Boolean begin
    // TESTFIELD(Submitted,FALSE);
    end;
    trigger OnOpenPage()
    begin
        FormEdit;
    end;
    var WorkTicketFormRequest: Record "WorkTicket Form Request";
    FleetManagement: Codeunit "Fleet Management";
    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    local procedure FormEdit(): Boolean var
        EditForm: Boolean;
    begin
        EditForm:=true;
        if Rec.Submitted = true then EditForm:=false;
    end;
}
