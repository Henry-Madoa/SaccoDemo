page 52203664 "Change Request Card"
{
    PageType = Card;
    SourceTable = "Employee Change Request";
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';

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
                    Editable = false;
                }
                field("Nature of Change"; Rec."Nature of Change")
                {
                    trigger OnValidate()
                    begin
                        ControlAppearance;
                    end;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
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
                }
            }
            part("Depedants Change Subform"; "Employee Dependants C")
            {
                ApplicationArea = All;
                Editable = Rec.Status = Rec.Status::Open;
                Caption = 'Depedants Change Subform';
                SubPageLink = "Employee No."=FIELD("Employee No"), "Change No"=FIELD("No.");
                Visible = MedicalDependantsVisible;
            }
            part("Relatives Change Subform"; "Employee Relatives Change")
            {
                ApplicationArea = All;
                Editable = Rec.Status = Rec.Status::Open;
                Caption = 'Relatives Change Subform';
                SubPageLink = "Employee No."=FIELD("Employee No"), "Change No"=FIELD("No.");
                Visible = NextofKinVisible;
            }
            part("Beneficiaries Change Subform"; "Employee Beneficiaries Change")
            {
                ApplicationArea = All;
                Editable = Rec.Status = Rec.Status::Open;
                Caption = 'Beneficiaries Change Subform';
                SubPageLink = "Employee No."=FIELD("Employee No"), "Change No"=FIELD("No.");
                Visible = BeneficiariesVisible;
            }
            part("Work Exp Change Subform"; "Employee Work History Change")
            {
                ApplicationArea = All;
                Editable = Rec.Status = Rec.Status::Open;
                Caption = 'Work Exp Change Subform';
                SubPageLink = "Employee No."=FIELD("Employee No"), "Change No"=FIELD("No.");
                Visible = WorkHistoryVisible;
            }
            part("Professional Bodies Change Subform"; "Employee Proffesional Bodies C")
            {
                ApplicationArea = All;
                Editable = Rec.Status = Rec.Status::Open;
                Caption = 'Professional Bodies Change Subform';
                SubPageLink = "Employee No."=FIELD("Employee No"), "Change No"=FIELD("No.");
                Visible = ProffesionalBodiesVisible;
            }
            part("Qualifications Change Subform"; "Employee Qualifications Change")
            {
                ApplicationArea = All;
                Editable = Rec.Status = Rec.Status::Open;
                Caption = 'Qualifications Change Subform';
                SubPageLink = "Employee No."=FIELD("Employee No"), "Change No"=FIELD("No.");
                Visible = QualificationVisible;
            }
            part("Emergency Contacts Change Subform"; "Employee Emergency Contacts C")
            {
                ApplicationArea = All;
                Editable = Rec.Status = Rec.Status::Open;
                Caption = 'Emergency Contacts Change Subform';
                SubPageLink = "Employee No."=FIELD("Employee No"), "Change No"=FIELD("No.");
                Visible = EmergencyContactVisible;
            }
            part("Asset Assignment Subform"; "Misc. artical information ch")
            {
                ApplicationArea = All;
                Editable = Rec.Status = Rec.Status::Open;
                Caption = 'Asset Assignment Subform';
                SubPageLink = "Employee No."=FIELD("Employee No"), "Change No"=FIELD("No.");
                Visible = AssetVisible;
            }
            part(Control18; "Employee Bio Data Change")
            {
                ApplicationArea = All;
                Editable = Rec.Status = Rec.Status::Open;
                SubPageLink = "Employee No."=FIELD("Employee No"), "Change No."=FIELD("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Send Approval Request")
            {
                ApplicationArea = BasicHR;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Category6;
                Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to effect change')then exit
                    else
                    begin
                        ApprovalsMgmt.OnSendEmployeeChangeForApproval(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = BasicHR;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Category6;
                Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to effect change')then exit
                    else
                    begin
                        ApprovalsMgmt.OnCancelEmployeeChangeApprovalRequest(Rec);
                        CurrPage.Close();
                    end;
                end;
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
        }
    }
    trigger OnAfterGetRecord()
    begin
        ControlAppearance;
    end;
    trigger OnOpenPage()
    begin
        ControlAppearance;
    end;
    var QualificationVisible: Boolean;
    WorkHistoryVisible: Boolean;
    EmergencyContactVisible: Boolean;
    NextofKinVisible: Boolean;
    BeneficiariesVisible: Boolean;
    AssetVisible: Boolean;
    MedicalDependantsVisible: Boolean;
    ProffesionalBodiesVisible: Boolean;
    EmployeeChangeRequest: Codeunit "Employee Change Request";
    ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    local procedure ControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord:=ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
        if Rec."Nature of Change" in[Rec."Nature of Change"::Qualifications]then QualificationVisible:=true
        else
            QualificationVisible:=false;
        if Rec."Nature of Change" in[Rec."Nature of Change"::"Work History"]then WorkHistoryVisible:=true
        else
            WorkHistoryVisible:=false;
        if Rec."Nature of Change" in[Rec."Nature of Change"::"Next Of Kin"]then NextofKinVisible:=true
        else
            NextofKinVisible:=false;
        if Rec."Nature of Change" in[Rec."Nature of Change"::Beneficiaries]then BeneficiariesVisible:=true
        else
            BeneficiariesVisible:=false;
        if Rec."Nature of Change" in[Rec."Nature of Change"::"Emergency Contacts"]then EmergencyContactVisible:=true
        else
            EmergencyContactVisible:=false;
        if Rec."Nature of Change" in[Rec."Nature of Change"::"Proffesional Bodies"]then ProffesionalBodiesVisible:=true
        else
            ProffesionalBodiesVisible:=false;
        if Rec."Nature of Change" in[Rec."Nature of Change"::"Medical Dependants"]then MedicalDependantsVisible:=true
        else
            MedicalDependantsVisible:=false;
        if Rec."Nature of Change" in[Rec."Nature of Change"::"Asset Assignment"]then AssetVisible:=true
        else
            AssetVisible:=false;
    end;
}
