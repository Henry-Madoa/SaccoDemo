page 52204124 "Standing Order"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Standing Order";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("STO Type"; Rec."STO Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Standing Order Class"; Rec."Standing Order Class")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary Based"; Rec."Salary Based")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(Salary)
                {
                    ShowCaption = false;
                    Visible = Rec."Salary Based";

                    field(Priority; Rec.Priority)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            group("Funds Source")
            {
                // Editable = Rec.Status = Rec.Status::Open;
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Type"; Rec."Amount Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(NonFixed)
                {
                    ShowCaption = false;
                    Visible = Rec."Amount Type" = Rec."Amount Type"::"Amount Based";

                    field("Amount Limit"; Rec."Amount Limit")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                group(Fixed)
                {
                    ShowCaption = false;
                    Visible = Rec."Amount Type" = Rec."Amount Type"::Fixed;

                    field(Amount; Rec.Amount)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Till Further Notice"; Rec."Till Further Notice")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Period; Rec.Period)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Funds Destination")
            {
                Editable = Rec.Status = Rec.Status::Open;

                group(Internal)
                {
                    ShowCaption = false;
                    Visible = (Rec."Standing Order Class" <> Rec."Standing Order Class"::External);

                    field("Destination Member No"; Rec."Destination Member No")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Destination Account"; Rec."Destination Account")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = Rec."Destination Type" = Rec."Destination Type"::Own;
                    }
                    field("Destination Name"; Rec."Destination Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group("External Transfer Details")
                {
                    ShowCaption = false;
                    Visible = (Rec."Standing Order Class" = Rec."Standing Order Class"::External);

                    field("&Destination Account"; Rec."Destination Account")
                    {
                        ShowMandatory = true;
                        ApplicationArea = Basic, Suite;
                    }
                    field("EFT Bank Code"; Rec."EFT Bank Code")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("EFT Branch Code"; Rec."EFT Branch Code")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("EFT Account Name"; Rec."EFT Account Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("EFT Bank Name"; Rec."EFT Bank Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("EFT Branch Name"; Rec."EFT Branch Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("EFT Swift Code"; Rec."EFT Swift Code")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("EFT Transfer Account No"; Rec."EFT Transfer Account No")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Payment Refrence Code"; Rec."Policy No.")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            group("Operating Parameters")
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(Non_AmountBased)
                {
                    ShowCaption = false;
                    Visible = (Rec."Amount Type" <> Rec."Amount Type"::"Amount Based") and (not Rec."Salary Based");

                    field("Run Type"; Rec."Run Type")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    group(RunType)
                    {
                        ShowCaption = false;
                        Visible = Rec."Run Type" = Rec."Run Type"::"Specific Day";

                        field("Run From Day"; Rec."Run From Day")
                        {
                            ApplicationArea = Basic, Suite;
                        }
                    }
                }
            }
            group("Audit Trail")
            {
                Editable = false;

                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Running; Rec.Running)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(FactBoxes)
        {
            part("Member Statistics"; "Member Statistics")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("Member No");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(Database::"Standing Order"), "No." = FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(Database::"Standing Order"), "Document No." = FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(Database::"Standing Order"), "Document No." = FIELD("No.");
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
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
                    AboutTitle = 'Approval Request';
                    AboutText = 'Send the Application for Approval before creation of the Accounts by clicking **Send Approval Request**';

                    trigger OnAction();
                    begin
                        Rec.OnBeforeSendingForApproval;
                        ApprovalsMgmtExt.OnSendStandingOrderForApproval(Rec);
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
                        ApprovalsMgmtExt.OnCancelStandingOrderForApproval(Rec);
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
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&open';
                    Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Running and not Rec.Terminated);
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        if Confirm(StrSubstNo('You are about to Re-Open %1\\Do you wish to continue?', Rec."No.")) then begin
                            Rec.Validate(Status, Rec.Status::Open);
                            Rec.Running := false;
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
            action(Terminate)
            {
                ApplicationArea = Basic, Suite;
                Image = CancelAllLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Running and not Rec.Terminated);

                trigger OnAction()
                begin
                    Rec.TestField(Rec.Running, true);
                    if Confirm('Do you want to Cancel?') then begin
                        Rec.Terminated := true;
                        Rec.Running := false;
                        Rec.modify;
                        CurrPage.Close();
                    end;
                end;
            }
            action(Freeze)
            {
                ApplicationArea = Basic, Suite;
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Running and not Rec.Terminated);

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.Findset then Report.Run(Report::"STO Freeze Management", false, false, Rec);
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
}
