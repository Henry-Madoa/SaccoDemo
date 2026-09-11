page 52203433 "Leave Adjustment Card"
{
    SourceTable = "Leave Adjustment Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Leave Adjustments No."; Rec."Leave Adjustments No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Group"; Rec."Job Group")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("No. Of Days"; Rec."No. Of Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Type"; Rec."Leave Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Type Name"; Rec."Leave Type Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("Leave Adjustments"; "Leave Adjustment Matrix")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Leave Adjustments';
                SubPageLink = "No."=FIELD("Leave Adjustments No.");
            }
            group(Audit)
            {
                Caption = 'Audit';

                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date Created"; Rec."Date Created")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Modified By"; Rec."Last Modified By")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action("Assign Employees")
            {
                ApplicationArea = Basic, Suite;
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Clear(LeaveADjEmployeeLookup);
                    Rec.TestField("Leave Type");
                    Employee.Reset;
                    LeaveTypes.Get(Rec."Leave Type");
                    if LeaveTypes.Gender <> LeaveTypes.Gender::Both then begin
                        Message('%1', LeaveTypes.Gender);
                        if LeaveTypes.Gender = LeaveTypes.Gender::Male then Employee.SetRange(Gender, Employee.Gender::Male)
                        else
                            Employee.SetRange(Gender, Employee.Gender::Female);
                    end;
                    Employee.SetRange(Status, Employee.Status::Active);
                    if Employee.FindSet then begin
                        LeaveADjEmployeeLookup.SetTableView(Employee);
                        LeaveADjEmployeeLookup.LookupMode:=true;
                        LeaveADjEmployeeLookup.InitializePaarams(Rec."Leave Adjustments No.", Rec."No. Of Days");
                        LeaveADjEmployeeLookup.RunModal;
                    end;
                end;
            }
            action(Post)
            {
                ApplicationArea = Basic, Suite;
                Image = AdjustEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    EntryNo: Integer;
                begin
                    //TESTFIELD(Status,Status::Approved);
                    if LeaveEntries.FindLast then EntryNo:=LeaveEntries."Entry No." + 1
                    else
                        EntryNo:=1;
                    Rec.TestField("Leave Type");
                    LeaveTypes.Get(Rec."Leave Type");
                    LeaveSetup.Get;
                    JournalBatch:=LeaveSetup."Leave Journal Batch";
                    JournalTemplate:=LeaveSetup."Leave Journal Template";
                    LeaveCalendar.Reset;
                    LeaveCalendar.SetRange("Current Leave Calendar", true);
                    if LeaveCalendar.FindFirst then LeaveYearPeriod:=LeaveCalendar."Calendar Code"
                    else
                        Error('No current leave year was found');
                    HumanResourceMgmt.CreateLeaveJournalBatch(JournalTemplate, JournalBatch);
                    HumanResourceMgmt.DeleteLeaveJournalLines(JournalTemplate, JournalBatch);
                    if Rec.Type in[Rec.Type::Negative]then LeaveEntryType:=LeaveEntryType::Negative
                    else
                        LeaveEntryType:=LeaveEntryType::Positive;
                    LeaveAdjustmentsLine.Reset;
                    LeaveAdjustmentsLine.SetRange("No.", Rec."Leave Adjustments No.");
                    if LeaveAdjustmentsLine.FindFirst then begin
                        repeat LineNo:=LineNo + 1;
                            HumanResourceMgmt.BuildLeaveJournal(JournalTemplate, JournalBatch, LineNo, LeaveYearPeriod, LeaveAdjustmentsLine."Employee No.", Today, LeaveEntryType, Rec."Leave Adjustments No.", LeaveAdjustmentsLine."Adjustment Days", Rec.Description, EmployeesHR."Global Dimension 1 Code", EmployeesHR."Global Dimension 2 Code", Rec."Leave Type", 0D, 0D, Rec."Leave Adjustments No.");
                        until LeaveAdjustmentsLine.Next = 0;
                    end;
                    HumanResourceMgmt.PostLeaveJournalLines(JournalTemplate, JournalBatch);
                    LeaveEntries.Reset;
                    LeaveEntries.SetRange("Document No.", Rec."Leave Adjustments No.");
                    if LeaveEntries.FindFirst then begin
                        Rec.Status:=Rec.Status::Closed;
                        if Rec.Modify then Message('Successfully posted');
                    end;
                end;
            }
            action("Send Approval Request")
            {
                ApplicationArea = Basic, Suite;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Open);
                    Rec.TestField("Leave Type");
                    //TESTFIELD(Type);
                    Rec.TestField(Description);
                    Rec.TestField("No. Of Days");
                    if not Confirm('Are you sure you want to send the document for approval')then exit;
                    if not CheckForLines then //  IF ApprovalsMgmt.CheckLeaveAdjApprovalPossible(Rec) THEN
 //   ApprovalsMgmt.OnSendLeaveAdjForApproval(Rec);
                        CurrPage.Close();
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = Basic, Suite;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    Rec.TestField("Leave Type");
                    Rec.TestField(Type);
                    Rec.TestField(Description);
                    Rec.TestField("No. Of Days");
                    if not Confirm('Are you sure you want to cancel Approval Request')then exit
                    else
                    begin
                        // ApprovalsMgmt.OnCancelLeaveAdjForRequest(Rec);
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
    trigger OnOpenPage()
    begin
        LeaveAdjustmentsLine.Reset;
        LeaveAdjustmentsLine.SetRange("No.", Rec."Leave Adjustments No.");
        if LeaveAdjustmentsLine.FindFirst then begin
            repeat LeaveAdjustmentsLine.Validate("Employee No.");
                LeaveAdjustmentsLine.Modify;
            until LeaveAdjustmentsLine.Next = 0;
        end;
    end;
    var Text000: Label 'Completed Successfully.';
    Employee: Record Employee;
    LeaveADjEmployeeLookup: Page "Leave Adj. Employee Lookup";
    LeaveAdjustmentsLine: Record "Leave Adjustment Line";
    Ok: Boolean;
    Window: Dialog;
    LeaveEntries: Record "Leave Ledger Entries";
    LeaveTypes: Record "Leave Types";
    UserSetup: Record "User Setup";
    HumanResourceMgmt: Codeunit "Human Resource Management";
    LineNo: Integer;
    LeaveSetup: Record "Leave Setup";
    LeaveJournalLine: Record "Leave Journal Line";
    JournalBatch: Code[40];
    JournalTemplate: Code[50];
    LeaveCalendar: Record "Leave Calendar";
    LeaveYearPeriod: Code[30];
    EmployeesHR: Record Employee;
    LeaveEntryType: Option Positive, Negative, Reimbursement, OpeinigBalance;
    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    OpenApprovalEntriesExist: Boolean;
    OpenApprovalEntriesExistForCurrUser: Boolean;
    local procedure CheckForLines(): Boolean begin
        LeaveAdjustmentsLine.Reset;
        LeaveAdjustmentsLine.SetRange("No.", Rec."Leave Adjustments No.");
        exit(LeaveAdjustmentsLine.FindFirst);
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
