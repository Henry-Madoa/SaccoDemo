page 52204252 "Custodial Application"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = Card;
    SourceTable = "Custodial Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Service Type"; Rec."Service Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Refrence No."; Rec."Refrence No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Category"; Rec."Member Category")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Owner No"; Rec."Owner No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Owner Name"; Rec."Owner Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    MultiLine = true;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Storage Period"; Rec."Storage Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Collection Date"; Rec."Expected Collection Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Service Description"; Rec."Service Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grace Period"; Rec."Grace Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Start Date"; Rec."Payment Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                group("Storage Information")
                {
                    field("Storage Type"; Rec."Storage Type")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Storage Serial No."; Rec."Storage Serial No.")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            part(Control23; "Custodial Movement Entries")
            {
                Visible = Rec."Document Status" = Rec."Document Status"::Instore;
                UpdatePropagation = Both;
                ApplicationArea = Basic, Suite;
                SubPageLink = "Transaction No" = FIELD("No.");
            }
            part(Control20; "Custodial Entries")
            {
                UpdatePropagation = Both;
                ApplicationArea = Basic, Suite;
                SubPageLink = "Custodial No." = FIELD("No.");
            }
            group(Audit)
            {
                Editable = false;

                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approval Status"; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Status"; Rec."Document Status")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(Database::"Custodial Header"), "No." = FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(Database::"Custodial Header"), "Document No." = FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(Database::"Custodial Header"), "Document No." = FIELD("No.");
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action("Send Approval Request")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Visible = Rec.Status = Rec.Status::Open;
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';
                    AboutTitle = 'Approval Request';
                    AboutText = 'Send the Application for Approval before creation of the Accounts by clicking **Send Approval Request**';

                    trigger OnAction();
                    begin
                        Rec.OnBeforeSendForApproval;
                        //ApprovalsMgmtExt.OnSendCustodialForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Visible = Rec.Status = Rec.Status::"Pending Approval";
                    Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedOnly = true;
                    ToolTip = 'Cancel the approval request.';
                    AboutTitle = 'Cancel Approval Request';
                    AboutText = 'Incase of Corrections recall the document by clicking **Cancel Approval Request**';

                    trigger OnAction();
                    begin
                        //ApprovalsMgmtExt.OnCancelCustodialForApproval(Rec);
                        CurrPage.Close();
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
            action(DocAttach)
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
            action("Project Income")
            {
                ApplicationArea = Basic, Suite;
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    CustodialMgmt.CreateCustodialSchedule(Rec, false, true);
                end;
            }
            action(Post)
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Approved;

                trigger OnAction()
                begin
                    Rec.TESTFIELD("Posting Date");
                    Rec.TESTFIELD("Storage Serial No.");
                    Rec.TESTFIELD("Storage Period");
                    if CONFIRM('Do you want to Post?') then begin
                        Rec."Document Status" := Rec."Document Status"::Instore;
                        Rec.MODIFY;
                        CurrPage.CLOSE;
                    end;
                end;
            }
            action(Release)
            {
                Visible = Rec."Document Status" = Rec."Document Status"::Instore;
                ApplicationArea = Basic, Suite;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page Release;
                RunPageLink = "No." = FIELD("No.");
            }
            action("Check In/Out")
            {
                Visible = Rec."Document Status" = Rec."Document Status"::Instore;
                ApplicationArea = Basic, Suite;
                Image = UnApply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Custodial Checkins";
                RunPageLink = "No." = FIELD("No.");
            }
            action("Re-Compute Income")
            {
                Visible = Rec."Document Status" = Rec."Document Status"::Instore;
                ApplicationArea = Basic, Suite;
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not (Rec."Expected Collection Date" < WorkDate) then ERROR('Recalculation Only Permitted');
                    CustodialMgmt.CreateCustodialSchedule(Rec, true, true);
                end;
            }
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    CustodialHeader.RESET;
                    CustodialHeader.SETRANGE("No.", Rec."No.");
                    if CustodialHeader.FINDFIRST then Report.Run(Report::"Custodial Application Receipt", true, false, CustodialHeader);
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        SetControlAppearance;
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance;
    end;

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
        IsOfficeAddin := OfficeMgt.IsAvailable;
    end;

    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        OfficeMgt: Codeunit "Office Management";
        IsOfficeAddin: Boolean;
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. CBS Ext";
        CustodialMgmt: Codeunit "Custodial Management";
        CustodialHeader: Record "Custodial Header";
}
