page 52204007 "Member Application"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Member Application";
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    AboutTitle = 'Welcome to Member Application Process';
    AboutText = 'This Process supports application for various membership types defined in the system namely; (a)Individual membership, (b)Joint /Group Membership, (c)Institution/Corporate membership';

    layout
    {
        area(Content)
        {
            group(General)
            {
                AboutTitle = 'General Information';
                AboutText = 'The system automatically generates **Application No.** and allows captuting of the following fields Member Category,Recruited By,Sales Person';
                Editable = Rec.Status = Rec.Status::Open;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Class; Rec.Class)
                {
                    ApplicationArea = Basic, Suite;
                }
                group(JointAccDetails)
                {
                    Visible = Rec."Category Type" = Rec."Category Type"::"Joint Account";
                    ShowCaption = false;

                    field("Group/Corporate Name"; Rec."Group/Corporate Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group(GroupMemberAccDetails)
                {
                    Visible = Rec."Category Type" = Rec."Category Type"::"Group Member";
                    ShowCaption = false;

                    field("Micro Finance Account"; Rec."Micro Finance Account")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                field("Recruited By"; Rec."Recruited By")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(RecruitmentsCondition)
                {
                    ShowCaption = false;
                    Visible = ((Rec."Recruited By" = Rec."Recruited By"::Member) or (Rec."Recruited By" = Rec."Recruited By"::"Sales Representative"));

                    field("Recruiter Code"; Rec."Recruiter Code")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Recruiter Name"; Rec."Recruiter Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group(Other_RecruitmentsCondition)
                {
                    ShowCaption = false;
                    Visible = Rec."Recruited By" = Rec."Recruited By"::Other;

                    field("Other Recruitment Details"; Rec."Other Recruitment Details")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Relationship Officer"; Rec."Relationship Officer")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Relationship Officer Name"; Rec."Relationship Officer Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
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
                field("Mobile Transacting No"; Rec."Mobile Transacting No")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
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
                group("Portal Remarks")
                {
                    ShowCaption = false;
                    Visible = isWebservice;

                    field("Portal Status"; Rec."Portal Status")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Rejection Comments"; Rec."Rejection Comments")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Source Type"; Rec."Source Type")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Source No"; Rec."Source No")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Payment Ref Code"; Rec."Payment Ref Code")
                    {
                        ApplicationArea = Basic, Suite;
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
                field(ATM; Rec.ATM)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Mobile; Rec.Mobile)
                {
                    ApplicationArea = Basic, Suite;
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
                Visible = NOT Rec."Is Group/Corporate";
                Editable = Rec.Status = Rec.Status::Open;
                AboutTitle = 'Personal Information';
                AboutText = 'The system allows capturing of the following details: Name (First, Second and Surname Name), Date of Birth, ID No,Nationality, Gender, Marital Status, KRA PIN no. **etc**';

                group(IPRSData)
                {
                    ShowCaption = false;
                    Editable = not Rec."IPRS Uneditability";

                    field(Title; Rec.Title)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("First Name"; Rec."First Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Middle Name"; Rec."Middle Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Las Name"; Rec."Last Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Full Name"; Rec."Full Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Date of Birth"; Rec."Date of Birth")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("KRA PIN"; Rec."KRA PIN")
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
                group("Employement Information")
                {
                    ShowCaption = false;
                    Visible = not Rec."Is Group/Corporate";
                    AboutTitle = 'Employement Information';
                    AboutText = 'Employment Type is Mandatory, For **Self Employed** Occupation is mandatory while for **Employeed** Type the following field are mandatory Employer code, Work Station Occupation, Payroll/Staff no., Terms of employment, Employer ';

                    label("**")
                    {
                        ApplicationArea = Basic, Suite;
                        Style = Favorable;
                        Caption = '*****Employement Information*****';
                    }
                    field("Emplyoment Type"; Rec."Emplyoment Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    group(Employed_CheckOff_Info)
                    {
                        ShowCaption = false;
                        Visible = Rec."Emplyoment Type" = Rec."Emplyoment Type"::"Employed (Checkoff)";

                        field("Employer Code"; Rec."Employer Code")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                        field("Department Code"; Rec."Department Code")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
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
                        }
                    }
                    group(Employed_Non_CheckOff_Info)
                    {
                        ShowCaption = false;
                        Visible = Rec."Emplyoment Type" = Rec."Emplyoment Type"::"Employed (Non-Checkoff)";

                        field("Employer Details"; Rec."Occupation Description")
                        {
                            ApplicationArea = Basic, Suite;
                            MultiLine = true;
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
            }
            group("Group/Corporate Information")
            {
                Visible = (Rec."Is Group/Corporate" and (Rec."Category Type" <> Rec."Category Type"::"Joint Account"));
                Editable = Rec.Status = Rec.Status::Open;
                AboutTitle = 'Group and Corporate General Information';
                AboutText = 'The system cap tures the following details; Name, Ownership type, KRA PIN, Date of Registration **etc**';

                field("Group Name"; Rec."Group/Corporate Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Group No"; Rec."Group/Corporate No.")
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
                field("Certificate Expiry"; Rec."Permit Expiry")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(KRADetails)
                {
                    ShowCaption = false;
                    Visible = ((Rec."Category Type" <> Rec."Category Type"::Group) and (Rec."Category Type" <> Rec."Category Type"::"Micro Finance"));

                    field("&KRA PIN"; Rec."KRA PIN")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group("&Employement Information")
                {
                    ShowCaption = false;

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

                        field("&Employer Code"; Rec."Employer Code")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                        field("&Payroll No."; Rec."Payroll No.")
                        {
                            ApplicationArea = Basic, Suite;
                        }
                    }
                }
            }
            group("Contacts and Addresses")
            {
                AboutTitle = 'Communication Details -';
                AboutText = 'The system allows capturing of the following details; Country, Office telephone no, Mobile Phone, Email Address, Postal Address and Postal code';
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
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(County; Rec.County)
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        if Counties.Get(Rec.County) then CountyName := Counties.Name;
                    end;
                }
                field("County Name"; CountyName)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                }
                field("Sub County"; Rec."Sub County")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        if SubCounties.Get(Rec.County, Rec."Sub County") then SubCountyName := SubCounties."Sub County Name";
                    end;
                }
                field("Sub County Name"; SubCountyName)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                }
                field("Town of Residence"; Rec."Town of Residence")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = not Rec."Is Group/Corporate";
                }
                field("Estate of Residence"; Rec."Estate of Residence")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = not Rec."Is Group/Corporate";
                }
            }
            group(Images)
            {
                Editable = Rec.Status = Rec.Status::Open;
                Visible = NOT Rec."Is Group/Corporate";

                field("Member Image"; Rec."Passport Size Photo")
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
                field("Signature Card"; Rec.Signature)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("&Goals")
            {
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
                    Importance = Promoted;
                    StyleExpr = StatusStyleTxt;
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
                Visible = false;

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
                Caption = 'Print';

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
                Image = Post;
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
            action("Check CRB Status")
            {
                ApplicationArea = Basic, Suite;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    if Confirm('Do you wish to Check CRB Status', false) then begin
                        Message('Kindly provide a valid endpoint');
                        //MemberManagement.PopulateIPRSData(Rec.RecordId, Rec."Identification No.");
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
        if Counties.Get(Rec.County) then CountyName := Counties.Name;
        if SubCounties.Get(Rec.County, Rec."Sub County") then SubCountyName := SubCounties."Sub County Name";
    end;

    trigger OnNextRecord(Steps: Integer): Integer
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
        isWebService := LoginMgmt.IsWebServiceUser;
        StatusStyleTxt := Rec.GetStatusStyleText;
    end;

    var
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. CBS Ext";
        MemberManagement: Codeunit "Member Management";
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        isWebService: Boolean;
        LoginMgmt: Codeunit "User Management Ext";
        StatusStyleTxt: Text;
        CountyName: Text;
        SubCountyName: Text;
        Counties: Record Counties;
        SubCounties: Record "Sub Counties";
}
