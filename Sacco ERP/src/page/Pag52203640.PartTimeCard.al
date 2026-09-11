page 52203640 "Part-Time Card"
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
                field("+"; Rec.Title)
                {
                    ApplicationArea = Basic, Suite;
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
                field("County of Origin"; Rec."County of Origin")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sub-County"; Rec."Sub-County")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Location; Rec.Location)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sub-Location"; Rec."Sub-Location")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Village; Rec.Village)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Ethnic Origin"; Rec."Ethnic Origin")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("National ID"; Rec."National ID")
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
                field("User ID"; Rec."User ID")
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
                field(ShowMap; ShowMapLbl)
                {
                    ApplicationArea = BasicHR;
                    Editable = false;
                    ShowCaption = false;
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the employee''s address on your preferred online map.';

                    trigger OnDrillDown()
                    begin
                        CurrPage.Update(true);
                        Rec.DisplayMap;
                    end;
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
                    ApplicationArea = BasicHR;
                }
                field(Age; Rec.Age)
                {
                    ApplicationArea = BasicHR;
                }
                field("Employment Date"; Rec."Employment Date")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Secondment Date';
                    Importance = Promoted;
                    ToolTip = 'Specifies the date when the employee began to work for the company.';
                }
                field("Service Period"; Rec."Service Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Period To Retirement"; Rec."Period To Retirement")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Start Date"; Rec."Contract Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract End Date"; Rec."Contract End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of joining Medical Scheme"; Rec."Date of joining Medical Scheme")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Job Details")
            {
                field("Job Grade"; Rec."Job Scale")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Pointer; Rec."J-G Steps")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payroll Grade"; Rec."Payroll Grade")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Job Code"; Rec."Job Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Nature Of Employment"; Rec."Nature Of Employment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 6 Code"; Rec."Global Dimension 6 Code")
                {
                    ApplicationArea = Basic, Suite;
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
                    ApplicationArea = BasicHR;
                }
                field("Global Dimension 4 Code"; Rec."Global Dimension 4 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 5 Code"; Rec."Global Dimension 5 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Manager No."; Rec."Manager No.")
                {
                    Caption = 'Line manager';
                }
                field(Currency; Rec.Currency)
                {
                    Caption = 'Overview Manager';
                }
                field("Grant Approver"; Rec."Grant Approver")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Long Term"; Rec."Long Term")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
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
                field("Type of Employee"; Rec."Type of Employee")
                {
                    ApplicationArea = Basic, Suite;
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
                field("Covered Medically"; Rec."Covered Medically")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = BasicHR;
                    Importance = Promoted;
                    ToolTip = 'Specifies the employment status of the employee.';
                }
            }
            group(Payments)
            {
                Caption = 'Payments';

                field("Payment Methods"; Rec."Payment Methods")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("KRA Number"; Rec."KRA Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("SHIF Number"; Rec."SHIF No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("NSSF Number"; Rec."NSSF No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Posting Group"; Rec."Employee Posting Group")
                {
                    ApplicationArea = BasicHR;
                    LookupPageID = "Employee Posting Groups";
                    ToolTip = 'Specifies the employee''s type to link business transactions made for the employee with the appropriate account in the general ledger.';
                }
                field("Bank Code"; Rec."Bank Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bank Branch No."; Rec."Bank Branch No.")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies a number of the bank branch.';
                }
                field("Allocated Leave Days"; Rec."Allocated Leave Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
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

                action("Contract Details")
                {
                    ApplicationArea = BasicHR;
                    Image = ContractPayment;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Employee Contract Details";
                    RunPageLink = "Employee No"=FIELD("No.");
                }
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
                action("Employee emergency Contacts")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Emergency Contacts';
                    Image = Calls;
                    RunObject = Page "Employee Emergency Contacts";
                    RunPageLink = "Employee No."=FIELD("No.");
                    ToolTip = 'Open the list of relatives that are registered for the employee.';
                }
                action("Mi&sc. Article Information")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Mi&sc. Article Information';
                    Image = Filed;
                    RunObject = Page "Misc. Article Information";
                    RunPageLink = "Employee No."=FIELD("No.");
                    ToolTip = 'Open the list of miscellaneous articles that are registered for the employee.';
                }
                action("&Confidential Information")
                {
                    ApplicationArea = BasicHR;
                    Caption = '&Confidential Information';
                    Image = Lock;
                    RunObject = Page "Confidential Information";
                    RunPageLink = "Employee No."=FIELD("No.");
                    ToolTip = 'Open the list of any confidential information that is registered for the employee.';
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
                action("A&bsences")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'A&bsences';
                    Image = Absence;
                    RunObject = Page "Employee Absences";
                    RunPageLink = "Employee No."=FIELD("No.");
                    ToolTip = 'View absence information for the employee.';
                }
                separator(Separator23)
                {
                }
                action(Grants)
                {
                    Caption = 'Grants';
                    Image = History;
                    RunObject = Page "Employee Donors";
                    RunPageLink = "Employee No"=FIELD("No.");
                }
                separator(Separator61)
                {
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Ledger E&ntries';
                    Image = VendorLedger;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Employee Ledger Entries";
                    RunPageLink = "Employee No."=FIELD("No.");
                    RunPageView = SORTING("Employee No.")ORDER(Descending);
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                }
                action("Initiate Sick Leave")
                {
                    Image = ImplementRegAbsence;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        if Confirm('Are you sure you want to initiate sick leave for employee no. ' + Format(Rec."No.") + ' ?') = false then exit;
                        LeaveTypes.Reset;
                        LeaveTypes.SetRange("Unlimited Days", true);
                        if LeaveTypes.FindFirst then HumanResourceMgmt.CreateLeaveApplication(Rec."No.", LeaveTypes.Code)
                        else
                            Error('No leave type adhering to the filter(s) (%1) was found', LeaveTypes.GetFilters);
                    end;
                }
                action(Payslip)
                {
                    ApplicationArea = BasicHR;
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        REPORT.Run(52049, true, false, Rec);
                    end;
                }
                action("Aged Accounts")
                {
                    ApplicationArea = BasicHR;

                    trigger OnAction()
                    begin
                        Rec.Reset;
                        Rec.SetRange("No.", Rec."No.");
                        if Rec.FindFirst then REPORT.Run(50011, true, false, Rec);
                    end;
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
                action("Employee Statement")
                {
                    ApplicationArea = BasicHR;
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        REPORT.Run(50007, true, false, Rec);
                    end;
                }
            }
            group(Approvals)
            {
                action("Send Approval Request")
                {
                    ApplicationArea = BasicHR;
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
                    ApplicationArea = BasicHR;
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
                    ApplicationArea = BasicHR;
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
    //"Division Name":="Division Name"::"4";
    end;
    trigger OnOpenPage()
    begin
        SetNoFieldVisible;
        ControlAppearance;
        SetControlAppearance end;
    var ShowMapLbl: Label 'Show on Map';
    NoFieldVisible: Boolean;
    UserSetup: Record "User Setup";
    HumanResourceMgmt: Codeunit "Human Resource Management";
    LeaveTypes: Record "Leave Types";
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
    DisabledEditable: Boolean;
    TerminationEditable: Boolean;
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
        if Rec."Employee Status" in[Rec."Employee Status"::Active]then begin
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
