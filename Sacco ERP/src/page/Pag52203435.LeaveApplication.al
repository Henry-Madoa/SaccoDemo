page 52203435 "Leave Application"
{
    PageType = Card;
    SourceTable = "Leave Applications";
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Admin Approval';

    layout
    {
        area(content)
        {
            group(General)
            {
                // Editable = ApprovalLevelEditable AND (IsPageEditable OR HRAdmin);
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appointment Date"; Rec."Appointment Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Grade; Rec.Grade)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("<Global Dimension 1 Code>"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Global Dimension 1 Code';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approval Entries"; Rec."Approval Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
            group("Leave Details")
            {
                //Editable = ApprovalLevelEditable AND (IsPageEditable OR HRAdmin);
                field("Leave Code"; Rec."Leave Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Type Decription"; Rec."Leave Type Decription")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Entitlement"; Rec."Leave Entitlement")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Days To Go on Leave"; Rec."Days Applied")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Total No Of Days"; Rec."Total No Of Days")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Leave Allowance Payable"; Rec."Leave Allowance Payable")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave balance"; Rec."Leave balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Half Day on Start Date"; Rec."Half Day on Start Date")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Half Day on End Date"; Rec."Half Day on End Date")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(Holidays; Rec.Holidays)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Weekend Days"; Rec."Weekend Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Days; Rec.Days)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Balance After"; Rec."Balance After")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Return Date"; Rec."Return Date")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Reporting Date"; Rec."Reporting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Reliever Details")
            {
                // Editable = ApprovalLevelEditable AND (IsPageEditable OR HRAdmin);
                field(Reliever; Rec.Reliever)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Reliever Name"; Rec."Reliever Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Rejection Comments"; Rec."Rejection Comments")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(51415), "No." = FIELD("No.");
            }
            part(Control30; "Leave Statistics")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("Employee No");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Admin Approval")
            {
                ApplicationArea = Basic, Suite;
                Image = Approve;
                Promoted = true;
                Caption = 'Approve';
                PromotedCategory = Category9;
                PromotedIsBig = true;
                Enabled = HRAdmin;

                trigger OnAction()
                begin
                    Rec.TestField("Leave Code");
                    Rec.TestField(Status, Rec.Status::Open);
                    Rec.TestField(Posted, false);
                    // Rec.TestField(Comments);
                    Rec.TestField("Phone No.");
                    Rec.TestField(Reliever);
                    Rec.TestField("E-Mail Address");
                    if not
                     Confirm(StrSubstNo('Are you sure you want to approve sick leave for %1?', Rec."Employee Name")) then
                        exit;
                    Rec.Validate(Status, Rec.Status::Approved);
                    CurrPage.Close();
                end;
            }
            action("Send Approval Request")
            {
                ApplicationArea = Basic, Suite;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
                begin
                    Rec.TestField("Leave Code");
                    Rec.TestField(Status, Rec.Status::Open);
                    Rec.TestField(Posted, false);
                    // Rec.TestField(Comments);
                    Rec.TestField("Phone No.");
                    Rec.TestField(Reliever);
                    Rec.TestField("E-Mail Address");
                    if LeaveTypes.Get(Rec."Leave Code") then begin
                        if not LeaveTypes."Unlimited Days" then begin
                            Rec.TestField("Start Date");
                            Rec.TestField("End Date");
                        end;
                    end;
                    if not Confirm('Are you sure you want to send leave application for approval?') then
                        exit
                    else begin
                        ApprovalsMgmt.OnSendLeaveForApproval(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = Basic, Suite;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;

                trigger OnAction()
                begin
                    Rec.TestField(Posted, false);
                    if not Confirm('Are you sure you want to cancel Approval request?') then
                        exit
                    else begin
                        ApprovalsMgmt.OnCancelLeaveApprovalRequest(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            group("Approval Details")
            {
                Visible = NOT OpenApprovalEntriesExistForCurrUser;
                Caption = 'Approvals';

                action(Approvals)
                {
                    //AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category7;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
            }
            group(Approval)
            {
                Caption = 'Approval';

                action(Approve)
                {
                    ApplicationArea = Suite;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        Text001: Label 'You are about to approve the document, Do you wish to continue';
                        Text002: Label 'You have approved the document';
                    begin
                        if Confirm(Text001, false) = true then begin
                            ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                            Message(Text002);
                            CurrPage.Close();
                        end
                        else
                            exit;
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = Suite;
                    Caption = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Reject the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        ApprovalMgmt_Ext: Codeunit "Approval Mgmt. Ext";
                        Text001: Label 'You are about to Reject the document, Do you wish to continue';
                        Text002: Label 'You have rejected the document';
                    begin
                        if Confirm(Text001, false) = true then begin
                            ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                            Message(Text002);
                            CurrPage.Close();
                        end
                        else
                            exit;
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = Suite;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Delegate the requested changes to the substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        Text001: Label 'You are about to Delegate the document, Do you wish to continue';
                        Text002: Label 'You have delegated the document';
                    begin
                        if Confirm(Text001, false) = true then begin
                            ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                            Message(Text002);
                            CurrPage.Close();
                        end
                        else
                            exit;
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = Suite;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            action(Attachments)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                Image = Attach;
                Promoted = true;
                PromotedCategory = Category8;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal;
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
    end;

    trigger OnOpenPage()
    begin
        SetControlAppearance;
    end;

    var
        LeaveTypes: Record "Leave Types";
        ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
        ApprovalLevelEditable: Boolean;
        ControlCancelApprovalActionVisibility: Boolean;
        ControlSendApprovalActionVisibility: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        LoginMgmt: Codeunit "User Management Ext";
        IsPageEditable: Boolean;
        ApprovalEntry: Record "Approval Entry";
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        UserSetup: Record "User Setup";
        HRAdmin: Boolean;

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        ApprovalLevelEditable := true;
        ControlCancelApprovalActionVisibility := false;
        ControlSendApprovalActionVisibility := false;
        if not (Rec.Status in [Rec.Status::Open]) then begin
            ApprovalLevelEditable := false;
            ControlSendApprovalActionVisibility := false;
        end;
        if Rec.Status in [Rec.Status::Open] then begin
            ControlSendApprovalActionVisibility := true;
            ControlCancelApprovalActionVisibility := false;
        end;
        if Rec.Status in [Rec.Status::"Pending Approval"] then begin
            ControlSendApprovalActionVisibility := false;
            ControlCancelApprovalActionVisibility := true;
        end;
        if LoginMgmt.IsWebServiceUser then
            IsPageEditable := true
        else
            IsPageEditable := false;
        HRAdmin := false;
        if UserSetup.Get(UserId) then if UserSetup."HR Admin" then HRAdmin := true;
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;
}
