page 52204016 "Member Editing"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    ApplicationArea = Basic, Suite;
    PageType = Card;
    SourceTable = "Member Editing";
    UsageCategory = Administration;

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
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                }
                field("Member No."; Rec."Member No.")
                {
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Relationship Officer"; Rec."Relationship Officer")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Relationship Officer Name"; Rec."Relationship Officer Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(NationalityInfo)
                {
                    ShowCaption = false;
                    Visible = NOT Rec."Is Group/Corporate";

                    field(Nationality; Rec.Nationality)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    group(DomicileInfo)
                    {
                        ShowCaption = false;
                        Visible = Rec.Nationality = Rec.Nationality::Diaspora;

                        field(Domicile; Rec.Domicile)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                    }
                    field("Identification Type"; Rec."Identification Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Identification No."; Rec."Identification No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    group(PassportDetails)
                    {
                        ShowCaption = false;

                        field("Passport No."; Rec."Passport No.")
                        {
                            ApplicationArea = Basic, Suite;
                        }
                        field("Date of Issue"; Rec."Date of Issue")
                        {
                            ApplicationArea = Basic, Suite;
                        }
                        field("Date of Expiry"; Rec."Date of Expiry")
                        {
                            ApplicationArea = Basic, Suite;
                        }
                    }
                }
                field("Protected Account"; Rec."Protected Account")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                group(AccountAct)
                {
                    ShowCaption = false;
                    Visible = Rec."Protected Account";

                    field("Account Owner"; Rec."Account Owner")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
            }
            group(Activations)
            {
                ShowCaption = false;
                Visible = ((not Rec."Is Group/Corporate") and (Rec."Category Type" <> Rec."Category Type"::"Group Member"));
                Editable = Rec.Status = Rec.Status::Open;

                label(ActivationLable)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Favorable;
                    Caption = '*****Activations*****';
                }
                field("Marketing Texts"; Rec."Marketing Texts")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("E-Statement"; Rec."E-Statement")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(EstatementPeriod)
                {
                    ShowCaption = false;
                    Visible = Rec."E-Statement";

                    field("E-Statement Period"; Rec."E-Statement Period")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
            }
            group("Basic Information")
            {
                Editable = Rec.Status = Rec.Status::Open;
                Visible = NOT isGroupMember;
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mobile Transacting No"; Rec."Mobile Transacting No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ATM Limit"; Rec."ATM Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mobi Loan Limit"; Rec."Mobi Loan Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Prior Year Dividend"; Rec."Prior Year Dividend")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Birth"; Rec."Date of Birth")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Type of Residence"; Rec."Type of Residence")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Marital Status"; Rec."Marital Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Employement Information*****")
                {
                    Style = Favorable;
                }
                field("Emplyoment Type"; Rec."Emplyoment Type")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                group(EmployedInfo)
                {
                    ShowCaption = false;
                    Visible = Rec."Emplyoment Type" = Rec."Emplyoment Type"::"Employed (Checkoff)";

                    field("Employer Code"; Rec."Employer Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field(Salaried; Rec.Salaried)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Station Code"; Rec."Station Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field(Designation; Rec.Designation)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Payroll No."; Rec."Payroll No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                group(Employed_Non_CheckOff_Info)
                {
                    ShowCaption = false;
                    Visible = Rec."Emplyoment Type" = Rec."Emplyoment Type"::"Employed (Non-Checkoff)";

                    field("Employer Details"; Rec."Occupation Description")
                    {
                        MultiLine = true;
                        ApplicationArea = Basic, Suite;
                        Caption = 'Employer Details';
                    }
                }
                group(SelfEmployedInfo)
                {
                    ShowCaption = false;
                    Visible = Rec."Emplyoment Type" = Rec."Emplyoment Type"::"Self Employed";

                    field(Occupation; Rec.Occupation)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Occupation Description"; Rec."Occupation Description")
                    {
                        MultiLine = true;
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            group("Group Information")
            {
                Editable = Rec.Status = Rec.Status::Open;
                Visible = isGroupMember;

                field("Group Name"; Rec."Group Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Group No"; Rec."Group No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Certificate of Incoop"; Rec."Certificate of Incoop")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Registration"; Rec."Date of Registration")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Certificate Expiry"; Rec."Certificate Expiry")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&Mobile Transacting No"; Rec."Mobile Transacting No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&KRA PIN"; Rec."KRA PIN")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&E-Mail Address"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&Address"; Rec.Address)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&County"; Rec.County)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&Sub County"; Rec."Sub County")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&ATM Limit"; Rec."ATM Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&Mobi Loan Limit"; Rec."Mobi Loan Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&Prior Year Dividend"; Rec."Prior Year Dividend")
                {
                    ApplicationArea = Basic, Suite;
                }
                group("&Employement Information")
                {
                    ShowCaption = false;

                    //Visible = not Rec."Is Group/Corporate";
                    //Visible = not Rec."Is Group/Corporate";
                    label("&**")
                    {
                        ApplicationArea = Basic, Suite;
                        Style = Favorable;
                        Caption = '*****Employement Information*****';
                    }
                    field("&Emplyoment Type"; Rec."Emplyoment Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    group("&EmployedInfo")
                    {
                        ShowCaption = false;
                        Visible = Rec."Emplyoment Type" = Rec."Emplyoment Type"::"Employed (Checkoff)";

                        field("&Salaried"; Rec.Salaried)
                        {
                            ApplicationArea = Basic, Suite;
                        }
                        field("&Employer Code"; Rec."Employer Code")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                        field("&Payroll No."; Rec."Payroll No.")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                    }
                }
            }
            group("Contacts and Addresses")
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Alt. Phone No"; Rec."Alt. Phone No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(County; Rec.County)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sub County"; Rec."Sub County")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Town of Residence"; Rec."Town of Residence")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Estate of Residence"; Rec."Estate of Residence")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("KRA PIN"; Rec."KRA PIN")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Images)
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("Member Image"; Rec."Passport Size Photo")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Signature"; Rec.Signature)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Front ID Image"; Rec."Front ID Photo")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Back ID Image"; Rec."Back ID Photo")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("&Goals")
            {
                Editable = Rec.Status = Rec.Status::Open;

                field(Goals; Rec.Goals)
                {
                    ApplicationArea = Basic, Suite;
                    ShowCaption = false;
                    ShowMandatory = true;
                    MultiLine = true;
                }
            }
            group("Audit Trail")
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Portal Status"; Rec."Portal Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Processed; Rec.Processed)
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
                AboutTitle = 'Documents Upload';
                AboutText = 'The system allows upload of the following document filesAttachment; Company Reg. Certificate image, Signatory Passport Photos, Specimen Signature and Bylaws.';
                SubPageLink = "Table ID" = CONST(Database::"Member Editing"), "No." = FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(Database::"Member Editing"), "Document No." = FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(Database::"Member Editing"), "Document No." = FIELD("No.");
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
                        Rec.TestField(Description);
                        ApprovalsMgmtExt.OnSendMemberEditingForApproval(Rec);
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
                        ApprovalsMgmtExt.OnCancelMemberEditingForApproval(Rec);
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
            action(Post)
            {
                ApplicationArea = Basic, Suite;
                PromotedCategory = Process;
                Visible = ((not Rec.Processed) and (Rec.Status = Rec.Status::Approved));
                PromotedIsBig = true;
                Image = Post;
                Promoted = true;

                trigger OnAction()
                begin
                    Rec.TestField(Rec.Status, Rec.Status::Approved);
                    if NOT Confirm('Do you want to update Member Details?') then exit;
                    MemberManagement.ProcessMemberEditing(Rec);
                    CurrPage.Close();
                end;
            }
            action("Next of Kins")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = AddContacts;
                RunObject = page "Member Nominees/Kins";
                RunPageLink = "Source Code" = field("No."), "Document Type" = const("Next of Kin");
            }
            action(Nominee)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = AddContacts;
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
            action("Signatories")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = BankContact;
                RunObject = page "Signatories & Directors";
                RunPageLink = "Source Code" = field("No.");
            }
            action("Account Instructions")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = BankContact;
                RunObject = page "Member Account Instructions";
                RunPageLink = "Source Code" = field("No.");
            }
            action(Subscriptions)
            {
                ApplicationArea = Basic, Suite;
                RunObject = page "Member Subscriptions";
                RunPageLink = "Source Code" = field("No.");
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
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

    trigger OnInit()
    begin
        MemberManagement.GetBcrqSetup(UserId, GlobalEditor, PartialEditor, CanRejoin, MPOAEditor);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
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
        isGroupMember := Rec."Is Group/Corporate";
        MemberManagement.GetBcrqSetup(UserId, GlobalEditor, PartialEditor, CanRejoin, MPOAEditor);
        isWebService := LoginMgmt.IsWebServiceUser;
    end;

    var
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. CBS Ext";
        MemberManagement: Codeunit "Member Management";
        CanRejoin, GlobalEditor, isGroupMember, MPOAEditor, PartialEditor : boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        isWebService: Boolean;
        LoginMgmt: Codeunit "User Management Ext";
}
