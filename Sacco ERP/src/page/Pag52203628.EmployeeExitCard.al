page 52203628 "Employee Exit Card"
{
    PageType = Card;
    SourceTable = "Employee Exit";
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Clearance';

    layout
    {
        area(content)
        {
            group("Employee Details")
            {
                // Editable = PageEditable and PortalEditability;
                field("Exit No"; Rec."No.")
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
                    Editable = false;
                }
                field("Job Title"; Rec."Job Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Job Description"; Rec."Job Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payroll Grade"; Rec."Payroll Grade")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
            group("Exit Details")
            {
                //  Editable = PageEditable and PortalEditability;
                field("Interview Conducted By"; Rec."Interview Conducted By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Reason For Exit"; Rec."Reason For Exit")
                {
                    MultiLine = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Reason Description"; Rec."Reason Description")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date Of Notice"; Rec."Date Of Notice")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Exit"; Rec."Date of Exit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expiry of Notice"; Rec."Expiry of Notice")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Date of Exit Interview"; Rec."Date of Exit Interview")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Notice Fully Served"; Rec."Notice Fully Served")
                {
                    ApplicationArea = Basic, Suite;
                //Editable = false;
                }
                field("Reasons For Not Serving Notice"; Rec."Reasons For Not Serving Notice")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("FL Dues Calculation"; "Final Dues Calculations")
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
                SubPageLink = "Exit No"=FIELD("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Contract Details")
            {
                Image = ContractPayment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Clearance Form Card";
                RunPageLink = "Employee No"=FIELD("No.");
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
                begin
                    Rec.Testfield(Status, Rec.Status::Open);
                    Rec.Testfield("Date of Exit");
                    Rec.Testfield("Reason For Exit");
                    Rec.Testfield("Employee No");
                    if Rec."Notice Fully Served" in[Rec."Notice Fully Served"::No]then Rec.Testfield("Reasons For Not Serving Notice");
                    if not Confirm('Are you sure you want to send it for approval?')then exit
                    else
                    begin
                        ApprovalsMgmt.OnSendEmployeeExitForApproval(Rec);
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
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    if not Confirm('Are you sure you want to cancel approval request?')then exit
                    else
                    begin
                        ApprovalsMgmt.OnCancelEmployeeExitApprovalRequest(Rec);
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
            action("Final Dues Report")
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.SetFilter("No.", '=%1', Rec."No.");
                    REPORT.Run(Report::"Employee Exit Final Dues", true, false, Rec);
                end;
            }
            action("Generate Clearance Form")
            {
                ApplicationArea = Basic, Suite;
                Image = Form;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to generate employee exit form?')then exit;
                    Message('Form No %1 has been generated ', EmployeeExitManagement.GenerateClearanceForm(Rec));
                end;
            }
            action("Clearance Form")
            {
                ApplicationArea = Basic, Suite;
                Image = Form;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                RunObject = Page "Clearance Form Card";
                RunPageLink = "Exit No"=field("No."), "Employee No"=FIELD("Employee No");
            }
            action("Resignation Acceptance Letter 1")
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Testfield(Status, Rec.Status::Approved);
                    Employee.Reset;
                    Employee.SetRange("No.", Rec."Employee No");
                    if Employee.FindFirst then begin
                        if Rec."Notice Fully Served" in[Rec."Notice Fully Served"::Yes]then begin
                            REPORT.Run(50289, true, false, Employee);
                        end;
                        if Rec."Notice Fully Served" in[Rec."Notice Fully Served"::No]then begin
                            REPORT.Run(50288, true, false, Employee);
                        end;
                    end;
                end;
            }
            action("Cerificate of Service")
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Visible = ShowOnAfterApproval;

                trigger OnAction()
                begin
                    Rec.Testfield(Status, Rec.Status::Approved);
                    Employee.Reset;
                    Employee.SetRange("No.", Rec."Employee No");
                    if Employee.FindFirst then begin
                    // REPORT.Run(Report::service, true, false, Employee);
                    end;
                end;
            }
            action("Transfer To Payroll")
            {
                ApplicationArea = Basic, Suite;
                Image = TransferFunds;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ShowOnAfterApproval;

                trigger OnAction()
                begin
                    Rec.Testfield(Status, Rec.Status::Cleared);
                    if not Confirm('Are you sure you want to transfer payments to payroll?')then exit;
                    EmployeeExitManagement.TransferToPayrollFinalDueCalsulations(Rec);
                end;
            }
            action("Resignation Acceptance Letter")
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //TESTFIELD("Probation Extended",TRUE);
                    //TESTFIELD("Probation Recomended Action","Probation Recomended Action"::"Extend Probation");
                    SelectedOption:=StrMenu(Text00001, 3, 'How do you wish to proceed?');
                    if SelectedOption = 2 then begin
                        if Rec."Notice Fully Served" in[Rec."Notice Fully Served"::Yes]then begin
                            Employee.Reset;
                            Employee.SetRange("No.", Rec."Employee No");
                            REPORT.Run(50289, true, false, Employee);
                        end;
                        if Rec."Notice Fully Served" in[Rec."Notice Fully Served"::No]then begin
                            Employee.Reset;
                            Employee.SetRange("No.", Rec."Employee No");
                            REPORT.Run(50288, true, false, Employee);
                        end;
                    end;
                    if SelectedOption = 1 then begin
                        Clear(Recipients);
                        Employee.Get(Rec."Employee No");
                        AttachementFilePaths.Get;
                        AttachementFilePaths.TestField("Appraisal Print Outs");
                        Employee.Reset;
                        Employee.SetRange("No.", Rec."Employee No");
                        if Employee.FindFirst then begin
                            if Rec."Notice Fully Served" in[Rec."Notice Fully Served"::No]then begin
                            // Clear(ResignationAcceptance);
                            // ResignationAcceptance.SetTableView(Employee);
                            // ResignationAcceptance.SaveAsPdf(FileName);
                            // REPORT.SaveAsPdf(REPORT::"Import Funds Req from Students", FileName, Employee);
                            end;
                            if Rec."Notice Fully Served" in[Rec."Notice Fully Served"::Yes]then begin
                            //        CLEAR(ResignationAcceptanceNotice);
                            //ResignationAcceptanceNotice.SETTABLEVIEW(Employee);
                            //ResignationAcceptanceNotice.SAVEASPDF(FileName);
                            // REPORT.SaveAsPdf(REPORT::"Import Petty Cash from Excel", FileName, Employee);
                            end;
                            Recipients.Add(Employee."E-Mail");
                            subject:='Resignation Acceptance';
                            Body:='Hello ' + Format(Rec."Employee Name") + '<br> Below is an attached resignation acceptance letter ' + '<br> If any other clarification is needed, kindly contact HR ' + '<br> Regards';
                        // CommunicationMgmt.SendEmailWithoutAttachement(SenderName, SenderAddress, Recipients, subject, Body, FileName, 'Resignation Letter');
                        end;
                    end;
                    if SelectedOption = 3 then exit;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance;
    end;
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
    end;
    trigger OnOpenPage()
    begin
        SetControlAppearance;
    end;
    var ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
    LoginMgmt: Codeunit "User Management Ext";
    CommunicationMgmt: Codeunit "Communications Mgmt";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    EmployeeExitManagement: Codeunit "Employee Exit Management";
    Employee: Record Employee;
    SendApprovalRequestVisible: Boolean;
    CancelApprovalRequestVisible: Boolean;
    ShowOnAfterApproval: Boolean;
    FileName: Text;
    SenderName: Text;
    SenderAddress: Text;
    Recipients: List of[Text];
    subject: Text;
    Body: Text;
    Text00001: Label 'Send Via Mail,Preview,Cancel';
    SelectedOption: Integer;
    AttachementFilePaths: Record "Attachement File Paths";
    PortalReports: Codeunit "Portal Reports";
    PageEditable: Boolean;
    PortalEditability: Boolean;
    local procedure ControlAppearance()
    begin
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
        if Rec.Status in[Rec.Status::Open]then SendApprovalRequestVisible:=true
        else
            SendApprovalRequestVisible:=false;
        CancelApprovalRequestVisible:=false;
        if Rec.Status in[Rec.Status::Cleared]then ShowOnAfterApproval:=true
        else
            ShowOnAfterApproval:=false;
        if Rec.Status in[Rec.Status::Open]then PageEditable:=true
        else
            PageEditable:=false;
        PortalEditability:=LoginMgmt.IsWebServiceUser;
    end;
}
