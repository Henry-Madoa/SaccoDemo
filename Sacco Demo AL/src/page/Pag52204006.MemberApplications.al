page 52204006 "Member Applications"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Member Application";
    CardPageId = "Member Application";
    Editable = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.FullName)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Class; Rec.Class)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Identification No."; Rec."Identification No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Passport No."; Rec."Passport No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recruited By"; Rec."Recruited By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recruiter Code"; Rec."Recruiter Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    StyleExpr = StatusStyleTxt;
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(Database::"Member Application"), "No." = FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(Database::"Member Application"), "Document No." = FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(Database::"Member Application"), "Document No." = FIELD("No.");
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Image = Print;

                trigger OnAction()
                var
                    MemberApp: Record "Member Application";
                begin
                    MemberApp.Reset();
                    MemberApp.SetRange("No.", Rec."No.");
                    if MemberApp.FindSet() then Report.Run(Report::"Member Application", true, false, MemberApp);
                end;
            }
            action("Print Application Form")
            {
                ApplicationArea = Basic, Suite;
                Image = Print;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;

                trigger OnAction()
                var
                    MemberApp: Record "Member Application";
                begin
                    MemberApp.Reset();
                    MemberApp.SetRange("No.", Rec."No.");
                    if MemberApp.FindFirst() then Report.Run(Report::"Membership Form", true, false, MemberApp);
                end;
            }
        }
        area(Processing)
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

                    trigger OnAction();
                    begin
                        MemberManagement.OnBeforeSendMemberApplicationForApproval(Rec);
                        ApprovalsMgmtExt.OnSendMemberApplicationForApproval(Rec);
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

                    trigger OnAction();
                    begin
                        ApprovalsMgmtExt.OnCancelMemberApplicationForApproval(Rec);
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
            group("Manual Approval")
            {
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action(Reopen)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&open';
                    Enabled = ((Rec.Status = Rec.Status::Approved) and (Rec."Account Created" = false));
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        if Confirm(StrSubstNo('You are about to Re-Open %1\\Do you wish to continue?', Rec."No.")) then begin
                            Rec.Validate(Status, Rec.Status::Open);
                            Rec.Modify(true);
                            CurrPage.Close;
                        end;
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
            action(Process)
            {
                ApplicationArea = Basic, Suite;
                Image = PostApplication;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and (not Rec.Processed));

                trigger OnAction()
                var
                    MNo: Code[20];
                begin
                    MemberManagement.OnBeforeSendMemberApplicationForApproval(Rec);
                    Rec.TestField(Processed, false);
                    Rec.TestField(Rec.Status, Rec.Status::Approved);
                    if Confirm('Do you want to Open Account') then begin
                        MNo := MemberManagement.CreateMember(Rec);
                        Message('Member Created Successfully -> ' + MNo);
                        CurrPage.Close();
                    end;
                end;
            }
            action("Validate IPRS Data")
            {
                ApplicationArea = Basic, Suite;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    if Confirm('Do you wish to validate from IPRS', false) then begin
                        MemberManagement.PopulateIPRSData(Rec.RecordId, Rec."Identification No.");
                        CurrPage.Update(true);
                    end;
                end;
            }
            action("Account Instructions")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = InsertAccount;
                RunObject = page "Member Account Instructions";
                RunPageLink = "Source Code" = field("No.");
            }
            action(Signatories)
            {
                ApplicationArea = Basic, Suite;
                Image = VendorBill;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "Signatories & Directors";
                RunPageLink = "Source Code" = field("No."), Type = const(Signatory);
            }
            action(Directors)
            {
                ApplicationArea = Basic, Suite;
                Image = VendorBill;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec."Category Type" = Rec."Category Type"::Institution;
                RunObject = page "Signatories & Directors";
                RunPageLink = "Source Code" = field("No."), Type = const(Director);
            }
            action("Nexts of KIN")
            {
                ApplicationArea = Basic, Suite;
                Image = AddContacts;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = not Rec."Is Group/Corporate";
                ToolTip = 'Next of Kins / Emergency Contact';
                RunObject = page "Member Nominees/Kins";
                RunPageLink = "Source Code" = field("No."), "Document Type" = const("Next of Kin");
            }
            action("Nominees")
            {
                ApplicationArea = Basic, Suite;
                Image = Relatives;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Nominees / Beneficiaries';
                Visible = not Rec."Is Group/Corporate";
                RunObject = page "Member Nominees/Kins";
                RunPageLink = "Source Code" = field("No."), "Document Type" = const(Nominee);
            }
            action(Benevolent)
            {
                ApplicationArea = Basic, Suite;
                Image = CoupledUsers;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Benevolent';
                Visible = not Rec."Is Group/Corporate";
                RunObject = page "Member Nominees/Kins";
                RunPageLink = "Source Code" = field("No."), "Document Type" = const(Benevolent);
            }
            action("Subscriptions")
            {
                ApplicationArea = Basic, Suite;
                RunObject = page "Application Subscriptions";
                RunPageLink = "Source Code" = field("No.");
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
            action("Application Documents")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                Ellipsis = true;
                Image = Documents;
                RunObject = page "Member App Doc. Checklist";
                RunPageLink = "Source Code" = field("No.");
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

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
        isOpen := (Rec.Status = Rec.Status::Open);
        isGroupMember := Rec."Is Group/Corporate";
        isProtected := Rec."Protected Account";
        isWebService := LoginMgmt.IsWebServiceUser;
        StatusStyleTxt := Rec.GetStatusStyleText;
    end;

    var
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. CBS Ext";
        MemberManagement: Codeunit "Member Management";
        isGroupMember, isOpen, isProtected : boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        isWebService: Boolean;
        LoginMgmt: Codeunit "User Management Ext";
        StatusStyleTxt: Text;
}
