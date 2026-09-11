page 52203620 "SS Budget Plan"
{
    PageType = Card;
    SourceTable = "Budget Plan";
    Caption = 'Budget Plan';
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';
    RefreshOnActivate = true;

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
                }
                field(Budget; Rec.Budget)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                    ShowMandatory = true;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Budget Acounts Range"; Rec."Budget Acounts Range")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Reference Date"; Rec."Reference Date")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control25; "Budget Plan Lines")
            {
                Editable = Rec.Status = Rec.Status::Open;
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document No"=field("No.");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(Database::"Budget Plan"), "No."=FIELD("No.");
            }
            systempart(Control13; Notes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(Processing)
        {
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
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::Open);
                        Rec.Testfield(Budget);
                        Rec.Testfield("Global Dimension 1 Code");
                        if Rec.OnBeforeSendForApprovalValidator()then ApprovalsMgt.OnSendBudgetPlanForApproval(Rec)
                        else
                            Error(Rec.ValidatorResponse);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedOnly = true;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    var
                        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        ApprovalsMgt.OnCancelBudgetPlanApprovalRequest(Rec);
                        CurrPage.Close();
                        WorkflowWebhookMgt.FindAndCancel(Rec.RecordId);
                    end;
                }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Status:=Rec.Status::Open;
        UserSetup.Reset();
        UserSetup.SetRange("User ID", UserId);
        if UserSetup.FindFirst()then begin
            if Emp.Get(UserSetup."Employee No.")then begin
                Emp.TestField("Global Dimension 2 Code");
                Rec.Validate("Global Dimension 1 Code", Emp."Global Dimension 1 Code");
                Rec.Validate("Global Dimension 2 Code", Emp."Global Dimension 2 Code");
            end;
        end
        else
            Error(Text000);
    end;
    trigger OnOpenPage()
    begin
        SetControlAppearance;
        UserSetup.Reset();
        UserSetup.SetRange("User ID", UserId);
        if UserSetup.FindFirst()then begin
            if Emp.Get(UserSetup."Employee No.")then begin
                Emp.TestField("Global Dimension 2 Code");
                Rec.SetRange("Global Dimension 2 Code", Emp."Global Dimension 2 Code");
            end;
        end
        else
            Error(Text000);
    end;
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord:=ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;
    var Budgetmgmt: Codeunit "Budget Management";
    UserSetup: Record "User Setup";
    Emp: Record Employee;
    Text000: Label 'Please Contact For QuantumJumps User Setup';
    ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
}
