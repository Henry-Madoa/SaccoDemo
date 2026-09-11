page 52203638 "Expetriate Card"
{
    Caption = 'Employee Card';
    PageType = Card;
    SourceTable = Employee;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    Visible = NoFieldVisible;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit;
                    end;
                }
                field("<Title>"; Rec.Title)
                {
                    ApplicationArea = BasicHR;
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = BasicHR;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the employee''s first name.';
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the employee''s middle name.';
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = BasicHR;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the employee''s last name.';
                }
                field("Full Name"; Rec.FullName)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the employee''s gender.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the country/region of the address.';
                }
                field("Allien Number"; Rec."National ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Passport Number"; Rec."Passport Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Marital Status"; Rec."Marital Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Religion; Rec.Religion)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Driving License"; Rec."Driving License")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Health Conditions"; Rec."Health Conditions")
                {
                    MultiLine = true;
                    RowSpan = 4;
                }
            }
            group(Communication)
            {
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Phone No.';
                    ToolTip = 'Specifies the employee''s telephone number.';
                }
                field("Alternative Phone No."; Rec."Mobile Phone No.")
                {
                    Caption = 'Alternative Phone No.';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Private Email';
                    Importance = Promoted;
                    ToolTip = 'Specifies the employee''s private email address.';
                }
                field("Company E-Mail"; Rec."Company E-Mail")
                {
                    ApplicationArea = BasicHR;
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the employee''s email address at the company.';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the employee''s address.';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the postal code.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the city of the address.';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies additional address information.';
                }
                field("Alt. Address Code"; Rec."Alt. Address Code")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies a code for an alternate address.';
                }
            }
            group("Important Dates")
            {
                Caption = 'Important Dates';

                field("Birth Date"; Rec."Birth Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Age; Rec.Age)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Starting Date"; Rec."Employment Date")
                {
                    ApplicationArea = BasicHR;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date when the employee began to work for the company.';
                }
                field("Service Period"; Rec."Service Period")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Job Details")
            {
                field("Job Code"; Rec."Job Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Division';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Department';
                }
                field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 4 Code"; Rec."Global Dimension 4 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 5 Code"; Rec."Global Dimension 5 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Disabled; Rec.Disabled)
                {
                    trigger OnValidate()
                    begin
                        if Rec.Disabled then DisabledEditable:=true
                        else
                            DisabledEditable:=false;
                    end;
                }
                group(Control31)
                {
                    Editable = DisabledEditable;
                    ShowCaption = false;
                    Visible = DisabledEditable;

                    field("Disability Id"; Rec."Disability Id")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = BasicHR;
                    Importance = Promoted;
                    ToolTip = 'Specifies the employment status of the employee.';
                }
            }
            group("Termination Details")
            {
                Editable = TerminationEditable;

                field("Cause of Inactivity Code"; Rec."Cause of Inactivity Code")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies a code for the cause of inactivity by the employee.';
                }
                field("Termination Date"; Rec."Termination Date")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the date when the employee was terminated, due to retirement or dismissal, for example.';
                }
                field("Grounds for Term. Code"; Rec."Grounds for Term. Code")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies a termination code for the employee who has been terminated.';
                }
            }
            part(Control131; "Employee Work Permits")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Employee No"=FIELD("No.");
            }
            part(Control12; "Employee Dependants")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Employee No."=FIELD("No.");
            }
            part(Control11; "Employee Relatives")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Employee No."=FIELD("No.");
            }
            part(Control10; "Employee Beneficiaries")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Employee No."=FIELD("No.");
            }
            part(Control9; "Employee Qualifications")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Employee No."=FIELD("No.");
            }
        }
        area(factboxes)
        {
            part(Control4; "Employee Picture")
            {
                ApplicationArea = BasicHR;
                SubPageLink = "No."=FIELD("No.");
            }
            systempart(Control2; Links)
            {
                Visible = false;
            }
            systempart(Control1; Notes)
            {
                Visible = true;
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("E&mployee")
            {
                Caption = 'E&mployee';
                Image = Employee;

                action("Co&mments")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Human Resource Comment Sheet";
                    RunPageLink = "Table Name"=CONST(Employee), "No."=FIELD("No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action(Dimensions)
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID"=CONST(5200), "No."=FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
                action("&Picture")
                {
                    ApplicationArea = BasicHR;
                    Caption = '&Picture';
                    Image = Picture;
                    RunObject = Page "Employee Picture";
                    RunPageLink = "No."=FIELD("No.");
                    ToolTip = 'View or add a picture of the employee or, for example, the company''s logo.';
                }
                action(AlternativeAddresses)
                {
                    ApplicationArea = BasicHR;
                    Caption = '&Alternate Addresses';
                    Image = Addresses;
                    RunObject = Page "Alternative Address List";
                    RunPageLink = "Employee No."=FIELD("No.");
                    ToolTip = 'Open the list of addresses that are registered for the employee.';
                }
                action(Beneficiaries)
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Beneficiaries';
                    Image = BulletList;
                    RunObject = Page "Employee Beneficiaries";
                    RunPageLink = "Employee No."=FIELD("No.");
                    ToolTip = 'Open the list of relatives that are registered for the employee.';
                }
                action("Employee Relatives")
                {
                    ApplicationArea = BasicHR;
                    Caption = '&Relatives';
                    Image = Relatives;
                    RunObject = Page "Employee Relatives";
                    RunPageLink = "Employee No."=FIELD("No.");
                    ToolTip = 'Open the list of relatives that are registered for the employee.';
                }
                action("Q&ualifications")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Q&ualifications';
                    Image = Certificate;
                    RunObject = Page "Employee Qualifications";
                    RunPageLink = "Employee No."=FIELD("No.");
                    ToolTip = 'Open the list of qualifications that are registered for the employee.';
                }
                action("<Page Employee Work History>")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Work History';
                    Image = Workdays;
                    RunObject = Page "Employee Work History";
                    RunPageLink = "Employee No."=FIELD("No.");
                    ToolTip = 'Open the list of qualifications that are registered for the employee.';
                }
                action("<Page Proffesional Bodies>")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Proffesional Bodies';
                    Image = Company;
                    RunObject = Page "Employee Proffessional Bodies";
                    RunPageLink = "Employee No."=FIELD("No.");
                    ToolTip = 'Open the list of qualifications that are registered for the employee.';
                }
                action("<Page Medical Dependants>")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Dependants Work Permit';
                    Image = Relatives;
                    RunObject = Page "Employee Dependants";
                    RunPageLink = "Employee No."=FIELD("No.");
                    ToolTip = 'Open the list of qualifications that are registered for the employee.';
                }
                separator(Separator23)
                {
                }
                action("Misc. Articles &Overview")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Misc. Articles &Overview';
                    Image = FiledOverview;
                    RunObject = Page "Misc. Articles Overview";
                    ToolTip = 'View miscellaneous articles that are registered for the employee.';
                }
                separator(Separator61)
                {
                }
                action(Attachments)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attachments';
                    Image = Attach;
                    Promoted = true;
                    PromotedCategory = Category9;
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
            group(Approvals)
            {
                action("Send Approval Request")
                {
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = SendApprovalVisible;

                    trigger OnAction()
                    begin
                        Rec.Testfield("Employee Status", Rec."Employee Status"::New);
                        if not Confirm('Are you sure you want to send it for approval?')then exit
                        else
                        begin
                            ApprovalsMgmt.OnSendEmployeeForApproval(Rec);
                            CurrPage.Close();
                        end;
                    end;
                }
                action("Cancel Approval Request")
                {
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = CancelApprovalVisible;

                    trigger OnAction()
                    begin
                        Rec.Testfield("Employee Status", Rec."Employee Status"::"Pending Approval");
                        if not Confirm('Are you sure you want to cancel approval request?')then exit
                        else
                        begin
                            ApprovalsMgmt.OnCancelEmployeeApprovalRequest(Rec);
                            CurrPage.Close();
                        end;
                    end;
                }
                action(Approve)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Approve the document?')then exit;
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                        CurrPage.Close();
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Reject the document?')then exit;
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                        CurrPage.Close;
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Approve the document?')then exit;
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                        CurrPage.Close();
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
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
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
    //"Division Name":="Division Name"::"2";
    end;
    trigger OnOpenPage()
    begin
        SetNoFieldVisible;
        ControlAppearance;
        SetControlAppearance end;
    trigger OnQueryClosePage(CloseAction: Action): Boolean begin
        if Rec."Employee Status" in[Rec."Employee Status"::New]then exit;
    // WorkPermits.RESET;
    // WorkPermits.SETRANGE("Employee No",Rec."No.");
    // WorkPermits.SETRANGE("Permit Status",WorkPermits."Permit Status"::Active);
    // IF NOT WorkPermits.FINDFIRST THEN
    //  ERROR('you have to atleast specify one active work permit');
    end;
    var ShowMapLbl: Label 'Show on Map';
    NoFieldVisible: Boolean;
    UserSetup: Record "User Setup";
    HRDates: Codeunit "HR Dates";
    HumanResSetup: Record "Human Resources Setup";
    ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
    ImprestManagement: Codeunit "Imprest Management";
    PostingDetailsVisible: Boolean;
    ApprovedEditable: Boolean;
    RequestForOtherEditable: Boolean;
    OpenApprovalEntriesExist: Boolean;
    OpenApprovalEntriesExistForCurrUser: Boolean;
    SendApprovalVisible: Boolean;
    CancelApprovalVisible: Boolean;
    CreateSickLeaveActionVisible: Boolean;
    OvertimeActionVisible: Boolean;
    Text0001: Label 'Extend,Terminate,Confirm';
    SelectedOption: Integer;
    ProbationExtension: Page "Probation Extension";
    EmployeeExit: Record "Employee Exit";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    GeneratedExitNo: Code[10];
    SenderName: Text;
    SenderAddress: Text;
    Recipients: List of[Text];
    Body: Text;
    Subject: Text;
    Text0002: Label 'Payable,Non-Payable';
    Selection: Integer;
    DisabledEditable: Boolean;
    TerminationEditable: Boolean;
    WorkPermits: Record "Work Permits";
    local procedure SetNoFieldVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
    begin
        NoFieldVisible:=DocumentNoVisibility.EmployeeNoIsVisible;
        if Rec."Birth Date" <> 0D then begin
            Rec.Age:=HRDates.DetermineDatesDiffrence(Rec."Birth Date", Today);
            Rec.Modify(true);
        end;
        if Rec."Employment Date" <> 0D then begin
            HumanResSetup.Get();
            HumanResSetup.TestField("Retirement Age");
            if Rec."Birth Date" <> 0D then Rec."Period To Retirement":=HRDates.DetermineDatesDiffrence(Today, CalcDate(HumanResSetup."Retirement Age", Rec."Birth Date"));
            Rec."Service Period":=HRDates.DetermineDatesDiffrence(Rec."Employment Date", Today);
            Rec.Modify(true);
        end;
    end;
    local procedure ControlAppearance()
    begin
        if Rec.Status in[Rec.Status::Active]then begin
            ApprovedEditable:=false;
            PostingDetailsVisible:=true;
        end
        else
        begin
            PostingDetailsVisible:=false;
            ApprovedEditable:=true;
        end;
        if Rec."Employee Status" in[Rec."Employee Status"::New]then SendApprovalVisible:=true
        else
            SendApprovalVisible:=false;
        if Rec."Employee Status" in[Rec."Employee Status"::"Pending Approval"]then begin
            ApprovedEditable:=false;
            PostingDetailsVisible:=false;
            CancelApprovalVisible:=true;
        end
        else
        begin
            CancelApprovalVisible:=false;
        end;
        if UserSetup.Get(UserId)then begin
            if UserSetup."HR Admin" then OvertimeActionVisible:=true
            else
                OvertimeActionVisible:=false;
        end
        else
            OvertimeActionVisible:=false;
    end;
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
    end;
}
