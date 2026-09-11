pageextension 52203456 "Employee Card" extends "Employee Card"
{
    PromotedActionCategories = 'New,Process,Report,Employee,Navigate,Request Approval,Workflow,Attachments';

    layout
    {
        // Add changes to page layout here
        modify(Pager)
        {
            Visible = false;
        }
        modify("Application Method")
        {
            Visible = false;
        }
        modify("Job Title")
        {
            Visible = false;
        }
        modify("Salespers./Purch. Code")
        {
            Visible = false;
        }
        modify(Status)
        {
            Visible = false;
        }
        modify("Resource No.")
        {
            Visible = false;
        }
        modify("Company E-Mail")
        {
            Visible = false;
        }
        modify("Phone No.2")
        {
            Visible = false;
        }
        modify("Search Name")
        {
            Visible = false;
        }
        modify("Employment Date")
        {
            Visible = false;
        }
        modify("Birth Date")
        {
            Visible = false;
        }
        modify(Personal)
        {
            Visible = false;
        }
        modify("Employee Posting Group")
        {
            Visible = false;
        }
        modify("Bank Account No.")
        {
            Visible = false;
        }
        modify("Bank Branch No.")
        {
            Visible = false;
        }
        modify("Cause of Inactivity Code")
        {
            Visible = false;
        }
        modify("Termination Date")
        {
            Visible = false;
        }
        modify("Grounds for Term. Code")
        {
            Visible = false;
        }
        addafter(Status)
        {
            field("Employee Status"; Rec."Employee Status")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addbefore("First Name")
        {
            field(Title; Rec.Title)
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("Last Name")
        {
            field("User ID"; Rec."User ID")
            {
                Editable = false;
                ApplicationArea = BasicHR;
            }
            field("Full Name"; Rec.FullName())
            {
                Editable = false;
                ApplicationArea = BasicHR;
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
            field("Health Conditions"; Rec."Health Conditions")
            {
                ApplicationArea = Basic, Suite;
                MultiLine = true;
                RowSpan = 4;
            }
        }
        addbefore(Administration)
        {
            group("Important Dates")
            {
                field("Birth Date_"; Rec."Birth Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Birth Date';
                }
                field(Age; Rec.Age)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Employment Date_"; Rec."Employment Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Employment Date';
                }
                field("Probation Period"; Rec."Probation Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Service Period"; Rec."Service Period")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Period To Retirement"; Rec."Period To Retirement")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
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
                field(RetirementDate; RetirementDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Retirement Date';
                    Editable = false;
                }
            }
        }
        addafter("Country/Region Code")
        {
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
        }
        addbefore("E-Mail")
        {
            field("Company E-Mail_"; Rec."Company E-Mail")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("Employment Date")
        {
            field("Employee Type"; Rec."Employee Type")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Job Scale"; Rec."Job Scale")
            {
                ApplicationArea = Basic, Suite;
            }
            field("J-G Steps"; Rec."J-G Steps")
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
            field("Job Title_"; Rec."Job Title")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
            field("Maximum Applicable Trainings"; Rec."Maximum Applicable Trainings")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Nature Of Employment"; Rec."Nature Of Employment")
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
            field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Global Dimension 4 Code"; Rec."Global Dimension 4 Code")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Type of Employee"; Rec."Type of Employee")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Probation Status"; Rec."Probation Status")
            {
                ApplicationArea = Basic, Suite;
            }
            field("End of Probation Period"; Rec."End of Probation Period")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Probation Period Extended"; Rec."Probation Period Extended")
            {
                Editable = false;
            }
            field("Probabtion Extended By"; Rec."Probabtion Extended By")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Reasons For Extension"; Rec."Reasons For Extension")
            {
                ApplicationArea = Basic, Suite;
            }
            field("New Probation Period End Date"; Rec."New Probation Period End Date")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Notice Period"; Rec."Notice Period")
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
            }
            field("Serving Notice"; Rec."Serving Notice")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Manager No."; Rec."Manager No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Line Manager Name"; Rec."Line Manager Name")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Overview Manager"; Rec."Overview Manager")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Overview Manager Name"; Rec."Overview Manager Name")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Long Term"; Rec."Long Term")
            {
                ApplicationArea = Basic, Suite;
                //Editable = false;
            }
            field("Suspend Leave Application"; Rec."Suspend Leave Application")
            {
                ApplicationArea = Basic, Suite;
            }
            field(Disabled; Rec.Disabled)
            {
                ApplicationArea = Basic, Suite;

                trigger OnValidate()
                begin
                    if Rec.Disabled then
                        DisabledEditable := true
                    else
                        DisabledEditable := false;
                end;
            }
            group(Control43)
            {
                Editable = DisabledEditable;
                ShowCaption = false;
                Visible = DisabledEditable;

                field("Disability Id"; Rec."Disability Id")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Describe Disability"; Rec."Describe Disability")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        addafter("SWIFT Code")
        {
            field("Payment Methods"; Rec."Payment Methods")
            {
                ApplicationArea = Basic, Suite;
            }
            field(Currency; Rec.Currency)
            {
                ApplicationArea = Basic, Suite;
            }
            field("Membership No"; Rec."Member No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("FOSA Account"; Rec."FOSA Account")
            {
                ApplicationArea = BasicHR;
                ToolTip = 'Specifies the number used by the bank for the bank account.';
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
            field("Employee Posting Group_"; Rec."Employee Posting Group")
            {
                ApplicationArea = BasicHR;
                Caption = 'Employee Posting Group';
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
            field("Bank Branch No._"; Rec."Bank Branch No.")
            {
                ApplicationArea = BasicHR;
                Caption = 'Bank Branch No.';
                ToolTip = 'Specifies a number of the bank branch.';
            }
            field("Branch Name"; Rec."Branch Name")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Covered Medically"; Rec."Covered Medically")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter(Payments)
        {
            group("Termination Details")
            {
                Editable = TerminationEditable;

                field("Cause of Inactivity Code_"; Rec."Cause of Inactivity Code")
                {
                    Caption = 'Cause of Inactivity Code';
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies a code for the cause of inactivity by the employee.';
                }
                field("Termination Date_"; Rec."Termination Date")
                {
                    Caption = 'Termination Date';
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the date when the employee was terminated, due to retirement or dismissal, for example.';
                }
                field("Grounds for Term. Code_"; Rec."Grounds for Term. Code")
                {
                    Caption = 'Grounds for Term. Code';
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies a termination code for the employee who has been terminated.';
                }
            }
        }
        addafter(Control1905767507)
        {
            part(Control5; "Employee Statistics")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("No.");
            }
            part(Control17; "Leave Statistics")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("No.");
            }
        }
    }
    actions
    {
        modify("Mi&sc. Article Information")
        {
            Caption = 'Asset Assignment';
        }
        addbefore(AlternativeAddresses)
        {
            action("Exit Card")
            {
                Image = ContractPayment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec."Employee Status" = "Employee Status"::Inactive;
                RunObject = Page "Employee Exit Card";
                RunPageLink = "Employee No" = FIELD("No."), Status = const(Cleared);
            }
            action("Contract Details")
            {
                ApplicationArea = All;
                Image = ContractPayment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Employee Contract Details";
                RunPageLink = "Employee No" = FIELD("No.");
            }
        }
        addafter(AlternativeAddresses)
        {
            action(Beneficiaries)
            {
                ApplicationArea = BasicHR;
                Caption = 'Beneficiaries';
                Image = BulletList;
                RunObject = Page "Employee Beneficiaries";
                RunPageLink = "Employee No." = FIELD("No.");
                ToolTip = 'Open the list of relatives that are registered for the employee.';
            }
            // action("Employee Relatives")
            // {
            //     ApplicationArea = BasicHR;
            //     Caption = 'Next of Kin';
            //     Image = Relatives;
            //     RunObject = Page 
            //     RunPageLink = "Employee No." = FIELD("No.");
            //     ToolTip = 'Open the list of relatives that are registered for the employee.';
            //     Visible = true;
            // }
        }
        addafter("Q&ualifications")
        {
            action("<Page Employee Work History>")
            {
                ApplicationArea = BasicHR;
                Caption = 'Work History';
                Image = Workdays;
                RunObject = Page "Employee Work History";
                RunPageLink = "Employee No." = FIELD("No.");
                ToolTip = 'Open the list of qualifications that are registered for the employee.';
            }
            action("Trainings")
            {
                ApplicationArea = BasicHR;
                Image = Translations;
                RunObject = Page "Training Applications";
                RunPageLink = "Employee No" = FIELD("No."), Status = const(Attended);
            }
            action("Appraisals")
            {
                ApplicationArea = BasicHR;
                Image = ApplicationWorksheet;
                RunObject = Page "Appraisal List";
                RunPageLink = "Employee No" = FIELD("No."), Status = const(Closed);
            }
            action("<Page Proffesional Bodies>")
            {
                ApplicationArea = BasicHR;
                Caption = 'Proffesional Bodies';
                Image = Company;
                RunObject = Page "Employee Proffessional Bodies";
                RunPageLink = "Employee No." = FIELD("No.");
                ToolTip = 'Open the list of qualifications that are registered for the employee.';
            }
            action("<Page Medical Dependants>")
            {
                ApplicationArea = BasicHR;
                Caption = 'Medical Dependats';
                Image = Relatives;
                RunObject = Page "Employee Dependants";
                RunPageLink = "Employee No." = FIELD("No.");
                ToolTip = 'Open the list of qualifications that are registered for the employee.';
            }
        }
        addafter("A&bsences")
        {
            action("<Page Employee Languages>")
            {
                ApplicationArea = BasicHR;
                Caption = 'Langauges';
                Image = Language;
                RunObject = Page "Employee Languages";
                RunPageLink = "Employee No" = FIELD("No.");
                ToolTip = 'View absence information for the employee.';
            }
        }
        addafter(Attachments)
        {
            action("Payslip")
            {
                Image = "Report";
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PortalReport: Codeunit "Portal Reports";
                begin
                    PortalReport.GeneratePayslip(Rec."No.", WorkDate);
                end;
            }
            action("Convert To Long Term")
            {
                ApplicationArea = Basic, Suite;
                Image = LotInfo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    UserSetup.Get(UserId);
                    UserSetup.TestField("Store Admin", true);
                    if not Confirm('Are you sure you want to convert the staff to long term?') then exit;
                    Rec."Long Term" := true;
                    Rec."Covered Medically" := Rec."Covered Medically"::Yes;
                    if Rec.Modify(true) then Message('Successfully converted')
                end;
            }
            action("Send Approval Request")
            {
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Visible = SendApprovalVisible;

                trigger OnAction()
                begin
                    Rec.Testfield("Employee Status", Rec."Employee Status"::New);
                    if not Confirm('Are you sure you want to send it for approval?') then
                        exit
                    else begin
                        ApprovalsMgmt.OnSendEmployeeForApproval(Rec);
                        CurrPage.Close();
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
                Visible = CancelApprovalVisible;

                trigger OnAction()
                begin
                    Rec.Testfield("Employee Status", Rec."Employee Status"::"Pending Approval");
                    if not Confirm('Are you sure you want to cancel approval request?') then
                        exit
                    else begin
                        ApprovalsMgmt.OnCancelEmployeeApprovalRequest(Rec);
                        CurrPage.Close();
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
    trigger OnAfterGetCurrRecord()
    begin
        SetNoFieldVisible;
        ControlAppearance;
        SetControlAppearance;
        DateCalculation;
    end;

    trigger OnAfterGetRecord()
    begin
        SetNoFieldVisible;
        ControlAppearance;
        SetControlAppearance;
        DateCalculation;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Employee Status" := Rec."Employee Status"::New;
        Rec."Type of Employee" := Rec."Type of Employee"::Contract;
    end;

    trigger OnOpenPage()
    begin
        SetNoFieldVisible;
        ControlAppearance;
        SetControlAppearance
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not (Rec."Employee Status" in [Rec."Employee Status"::New]) then exit; //Rec.Testfield("Employment Date");
                                                                                  //Rec.Testfield("Birth Date");
    end;

    local procedure SetNoFieldVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
    begin
        if not (Rec."Employee Status" in [Rec."Employee Status"::New]) then
            NoFieldVisible := true
        else
            NoFieldVisible := false;
        NoFieldVisible := DocumentNoVisibility.EmployeeNoIsVisible;
        if Rec."Birth Date" <> 0D then begin
            Rec.Age := HRDates.DetermineDatesDiffrence(Rec."Birth Date", Today);
            Rec.Modify(true);
        end;
        if Rec."Employment Date" <> 0D then begin
            HumanResSetup.Get();
            HumanResSetup.TestField("Retirement Age");
            if Rec."Birth Date" <> 0D then Rec."Period To Retirement" := HRDates.DetermineDatesDiffrence(Today, CalcDate(HumanResSetup."Retirement Age", Rec."Birth Date"));
            Rec."Service Period" := HRDates.DetermineDatesDiffrence(Rec."Employment Date", Today);
            Rec.Modify(true);
        end;
    end;

    local procedure ControlAppearance()
    begin
        if Rec.Status in [Rec.Status::Active] then begin
            ApprovedEditable := false;
            PostingDetailsVisible := true;
        end
        else begin
            PostingDetailsVisible := false;
            ApprovedEditable := true;
        end;
        if Rec."No." = '' then
            GroupEditable := false
        else
            GroupEditable := true;
        if Rec."Employee Status" in [Rec."Employee Status"::New] then
            SendApprovalVisible := true
        else
            SendApprovalVisible := false;
        TerminationEditable := false;
        if Rec."Employee Status" in [Rec."Employee Status"::"Pending Approval"] then begin
            ApprovedEditable := false;
            PostingDetailsVisible := false;
            CancelApprovalVisible := true;
        end
        else begin
            CancelApprovalVisible := false;
        end;
        if UserSetup.Get(UserId) then begin
            if UserSetup."HR Admin" then
                OvertimeActionVisible := true
            else
                OvertimeActionVisible := false;
        end
        else
            OvertimeActionVisible := false;
        if Rec.Disabled then
            DisabledEditable := true
        else
            DisabledEditable := false;
        if Rec.Housed then
            HouseDetailsVisible := true
        else
            HouseDetailsVisible := false;
    end;

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
    end;

    local procedure DateCalculation()
    begin
        Rec.Age := '';
        LengthOfService := '';
        RetirementDate := '';
        //Recalculate Important Dates
        if (Rec."Termination Date" = 0D) then begin
            if (Rec."Birth Date" <> 0D) then
                Rec.Age := Dates.DetermineDatesDiffrence(Rec."Birth Date", Today);
            if (Rec."Employment Date" <> 0D) then
                if (Rec."Birth Date" <> 0D) then begin
                    D := CalcDate('<+60Y>', Rec."Birth Date");
                    RetirementDate := Format(D);
                end;
        end;
    end;

    var
        Dates: Codeunit "HR Dates";
        LengthOfService: Text[100];
        RetirementDate: Text[100];
        D: Date;
        NoFieldVisible: Boolean;
        UserSetup: Record "User Setup";
        HRDates: Codeunit "HR Dates";
        HumanResSetup: Record "Human Resources Setup";
        ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
        PostingDetailsVisible: Boolean;
        ApprovedEditable: Boolean;
        OpenApprovalEntriesExist: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        SendApprovalVisible: Boolean;
        CancelApprovalVisible: Boolean;
        OvertimeActionVisible: Boolean;
        TerminationEditable: Boolean;
        DisabledEditable: Boolean;
        GroupEditable: Boolean;
        ApprovalEntry: Record "Approval Entry";
        HouseDetailsVisible: Boolean;
        Employee: Record Employee;
}
