page 52204041 "Loan"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate,Recoveries,Securities';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = Loans;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = isOpen;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Prorated Days"; Rec."Prorated Days")
                {
                    ApplicationArea = Basic, Suite;
                    editable = false;
                }
                field("Sales Representative"; Rec."Sales Representative")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sales Representative Name"; Rec."Sales Representative Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Member Details")
            {
                Editable = isOpen;

                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Witness; Rec.Witness)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Loan Details")
            {
                Editable = isOpen;

                field("Loan Type"; Rec."Loan Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Description"; Rec."Product Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Multiplier"; Rec."Loan Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Requested Amount"; Rec."Requested Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Amount"; Rec."Loan Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(Salary)
                {
                    ShowCaption = false;
                    Visible = ((Rec.Category <> Rec.Category::HR) and (Rec.Category <> Rec.Category::DEBT));
                    field("Qualified Salarywise"; Rec."Qualified Salarywise")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Charges Amount"; Rec."Charges Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                group("Economic Sector")
                {
                    Visible = ((Rec.Category <> Rec.Category::HR) and (Rec.Category <> Rec.Category::DEBT));
                    field("Sector Code"; Rec."Sector Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Sector Name"; Rec."Sector Name")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Sub Sector Code"; Rec."Sub Sector Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Sub Sector Name"; Rec."Sub Sector Name")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Sub-Susector Code"; Rec."Sub-Subsector Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Sub-SubSector Name"; Rec."Sub-SubSector Name")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                group(NoHRBOSA_1)
                {
                    ShowCaption = false;
                    Visible = ((Rec.Category <> Rec.Category::HR) and (Rec.Category <> Rec.Category::DEBT));

                    field("Recovery Mode"; Rec."Recovery Mode")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    group(RecoveryType)
                    {
                        ShowCaption = false;
                        Visible = ((Rec."Recovery Mode" = Rec."Recovery Mode"::Mpesa) or (Rec."Recovery Mode" = Rec."Recovery Mode"::Cash) or (Rec."Recovery Mode" = Rec."Recovery Mode"::"Direct_Debit"));

                        field("Payment Date"; Rec."Payment Date")
                        {
                            ShowMandatory = true;
                            ApplicationArea = Basic, Suite;
                        }
                    }
                    field("Repayment Start Date"; Rec."Repayment Start Date")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field(Installments; Rec.Installments)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Repayment End Date"; Rec."Repayment End Date")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                label("*****Disbursement*****")
                {
                    Style = Favorable;
                }
                field("Mode of Disbursement"; Rec."Mode of Disbursement")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = ((Rec."Mode of Disbursement" = Rec."Mode of Disbursement"::"FOSA (Full)") or (Rec."Mode of Disbursement" = Rec."Mode of Disbursement"::"FOSA (Partial)"));
                }
                group("ModeOfDisbursement")
                {
                    ShowCaption = false;
                    Visible = ((Rec."Mode of Disbursement" = Rec."Mode of Disbursement"::BOSA) or (Rec."Mode of Disbursement" = Rec."Mode of Disbursement"::"Receivable Account") or (Rec."Mode of Disbursement" = Rec."Mode of Disbursement"::"Debt Collector"));

                    field("Disbursement Account"; Rec."Disbursement Account")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                group(PayableDisbursement)
                {
                    ShowCaption = false;
                    Visible = Rec."Mode of Disbursement" = Rec."Mode of Disbursement"::Payables;

                    field("&Payable Advice"; Rec."Payable Advice")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group(Disbursement)
                {
                    ShowCaption = false;
                    Visible = Rec."Mode of Disbursement" = Rec."Mode of Disbursement"::"FOSA (Partial)";

                    field("First Disbursement"; Rec."First Disbursement")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group(NoHRBOSA_2)
                {
                    Visible = ((Rec.Category <> Rec.Category::HR) and (Rec.Category <> Rec.Category::DEBT));
                    field("Interest Repayment Method"; Rec."Interest Repayment Method")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Interest Rate"; Rec."Interest Rate")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Rate Type"; Rec."Rate Type")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Total Guarantees"; Rec."Total Guarantees")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Total Securities"; Rec."Total Securities")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Insurance Amount"; Rec."Insurance Amount")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("New Monthly Installment"; Rec."New Monthly Installment")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            group("Payslip Details")
            {
                Visible = ((Rec.Category <> Rec.Category::HR) and (Rec.Category <> Rec.Category::DEBT));
                field(Earnings; Rec.Earnings)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Deductions; Rec.Deductions)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Net Income"; Rec."Net Income")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Repayment Details")
            {
                Visible = ((Rec.Category <> Rec.Category::HR) and (Rec.Category <> Rec.Category::DEBT));
                Editable = isOpen;

                field("Principal Repayment"; Rec."Principal Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Repayment"; Rec."Interest Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Monthly Principal"; Rec."Monthly Principal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Monthly Interest"; Rec."Monthly Interest")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Monthly Installment"; Rec."Monthly Installment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Repayment"; Rec."Total Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Account"; Rec."Loan Account")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Transfer Details")
            {
                Visible = false;

                field("Pay to Bank Code"; Rec."Pay to Bank Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Pay to Branch Code"; Rec."Pay to Branch Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Pay to Account No"; Rec."Pay to Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Pay to Account Name"; Rec."Pay to Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Portal Information")
            {
                Visible = false;
                Editable = NOT IsWindows;

                field("Portal Status"; Rec."Portal Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Rejection Remarks"; Rec."Rejection Remarks")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Deposits"; LoansManagement.GetMemberDeposits(Rec."Member No."))
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Amount"; LoansManagement.GetNetAmount(Rec."No."))
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Repayment Period"; Rec."Maximum Repayment Period")
                {
                    ApplicationArea = Basic, Suite;
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
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Posted; Rec.Posted)
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
                Visible = Rec.Posted;
                SubPageLink = "No." = field("Member No.");
            }
            part("Loan Statistics"; "Loan Statistics")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("No.");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(Database::Loans), "No." = FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(Database::Loans), "Document No." = FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(Database::Loans), "Document No." = FIELD("No.");
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
            action("Print Schedule")
            {
                ApplicationArea = Basic, Suite;
                Image = Print;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                Visible = (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR);

                trigger OnAction()
                var
                    Loans: Record Loans;
                begin
                    Loans.Reset();
                    Loans.SetRange("No.", Rec."No.");
                    if Loans.FindSet() then Report.Run(Report::"Loan Repayment Schedule", true, false, Loans);
                end;
            }
            action("Print Appraisal")
            {
                ApplicationArea = Basic, Suite;
                Image = Report;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                Visible = ((Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR));

                trigger OnAction()
                var
                    Loans: Record Loans;
                    LProduct: Record "Sacco Products";
                begin
                    if Loans."Appraisal Commited" = false then begin
                        LoansManagement.ValidateAppraisal(Rec);
                        Rec.CalcFields("Monthly Installment");
                        if Rec."Monthly Installment" = 0 then Error('Please Generate the loan schedule first');
                        LoansManagement.AppraiseZeroDeposits(Rec);
                    end;
                    Loans.Reset();
                    Loans.SetRange("No.", Rec."No.");
                    if Loans.FindSet() then begin
                        LProduct.Get(Loans."Product Code");
                        Report.Run(Report::"Loan Appraisal", true, false, Loans);
                    end;
                end;
            }
            action("Print Application")
            {
                ApplicationArea = Basic, Suite;
                Image = Report2;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;

                trigger OnAction()
                var
                    Loans: Record Loans;
                begin
                    if Loans."Appraisal Commited" = false then begin
                        LoansManagement.ValidateAppraisal(Rec);
                        Rec.CalcFields("Monthly Installment");
                        if Rec."Monthly Installment" = 0 then Error('Please Generate the loan schedule first');
                        LoansManagement.AppraiseZeroDeposits(Rec);
                    end;
                    Loans.Reset();
                    Loans.SetRange("No.", Rec."No.");
                    if Loans.FindSet() then Report.Run(Report::"Loan Application", true, false, Loans);
                end;
            }
            action("Print Statement")
            {
                ApplicationArea = Basic, Suite;
                Image = PrintInstallment;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                Visible = Rec.Posted;

                trigger OnAction()
                var
                    Vendor: Record Vendor;
                begin
                    Vendor.Reset();
                    Vendor.SetRange("Member No.", Rec."Member No.");
                    if Vendor.FindSet() then Report.RunModal(Report::"Member Statement", true, false, Vendor);
                end;
            }
            action("Print Statement - With Reversals")
            {
                ApplicationArea = Basic, Suite;
                Image = ReverseLines;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                Visible = Rec.Posted;

                trigger OnAction();
                var
                    Member: Record Members;
                begin
                    Member.Reset();
                    Member.SetRange("No.", Rec."Member No.");
                    if Member.FindSet() then Report.RunModal(Report::"Member Statement2", true, false, Member);
                end;
            }
        }
        area(Navigation)
        {
            action(Navigate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Category9;
                ShortCutKey = 'Shift+Ctrl+I';
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';
                Visible = not IsOfficeAddin and Rec.Posted;

                trigger OnAction()
                begin
                    Rec.Navigate;
                end;
            }
            action(Archive)
            {
                ApplicationArea = Basic, Suite;
                Image = Archive;
                Promoted = true;
                PromotedCategory = Category9;
                Visible = ((Rec.Status = Rec.Status::Open) or ((Rec.Status = Rec.Status::Approved) and (Rec."Mobile Loan" = true)));
                trigger OnAction()
                begin
                    if Confirm(StrSubstNo('You are about to Archive %1\\ Do you wish to continue?', Rec."No."))
                    then begin
                        LoansManagement.LoanArchiving(Rec);
                    end;
                end;
            }
            action(UnArchive)
            {
                ApplicationArea = Basic, Suite;
                Image = UndoCategory;
                Promoted = true;
                PromotedCategory = Category9;
                Visible = Rec.Status = Rec.Status::Archived;
                trigger OnAction()
                begin
                    if Confirm(StrSubstNo('You are about to UnArchive %1\\ Do you wish to continue?', Rec."No."))
                    then begin
                        LoansManagement.LoanArchiving(Rec);
                    end;
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
                    AboutTitle = 'Approval Request';
                    AboutText = 'Send the Application for Approval before creation of the Accounts by clicking **Send Approval Request**';

                    trigger OnAction();
                    begin
                        LoansManagement.OnBeforeSendLoanForApproval(Rec);
                        ApprovalsMgmtExt.OnSendLoanApplicationForApproval(Rec);
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
                        ApprovalsMgmtExt.OnCancelLoanApplicationForApproval(Rec);
                        CurrPage.Close();
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
                    Enabled = ((Rec.Status = Rec.Status::Approved) and (Rec.Posted = false));
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
            action("Post")
            {
                ApplicationArea = Basic, Suite;
                Image = PostBatch;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((not Rec.Posted) and (Rec.Status = Rec.Status::Approved));

                trigger OnAction()
                begin
                    Rec.TestField(Rec.Status, Rec.Status::Approved);
                    if not Confirm('You are about to disburse the loan\\Do you wish to continue') then exit;
                    LoansManagement.DisburseLoan(rec);
                end;
            }
            action("Generate Schedule")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                Image = ApplyEntries;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Open) and (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR));

                trigger OnAction()
                begin
                    LoansManagement.GenerateLoanRepaymentSchedule(Rec);
                end;
            }
            action("Suspend Interest")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                Image = ApplyEntries;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = (Rec.Posted and not Rec."Interest Suspended" and (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR));
                trigger OnAction()
                begin
                    LoansManagement.InterestSuspending(Rec."No.");
                end;
            }
            action("UnSuspend Interest")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                Image = RemoveLine;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = (Rec.Posted and Rec."Interest Suspended" and (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR));

                trigger OnAction()
                begin
                    LoansManagement.InterestSuspending(Rec."No.");
                end;
            }
            action("Stop Aging")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                Image = RemoveLine;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = (Rec.Posted and not Rec."Skip Aging" and (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR));
                trigger OnAction()
                begin
                    Rec.Validate("Skip Aging", true);
                    Rec.Modify(true);
                end;
            }
            action("Resume Aging")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                Image = AddAction;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = (Rec.Posted and Rec."Skip Aging" and (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR));

                trigger OnAction()
                begin
                    Rec.Validate("Skip Aging", false);
                    Rec.Modify(true);
                end;
            }
            group(Securities)
            {
                action(Guarantors)
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedCategory = Category11;
                    PromotedIsBig = true;
                    Image = StepOver;
                    RunObject = page "Loan Guarantors";
                    RunPageLink = "Loan No" = field("No.");
                    Visible = (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR);
                }
                action(Collaterals)
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedCategory = Category11;
                    PromotedIsBig = true;
                    Image = StepOver;
                    RunObject = page "Loan Securities";
                    RunPageLink = "Loan No" = field("No."), "Security Type" = const(Collateral);
                    Visible = (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR);

                }
                action("Fixed Deposits")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedCategory = Category11;
                    PromotedIsBig = true;
                    Image = StepOver;
                    RunObject = page "Loan Securities";
                    RunPageLink = "Loan No" = field("No."), "Security Type" = const("Fixed Deposit");
                    Visible = (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR);
                }
            }
            group(Recoveries)
            {
                action(Bridging)
                {
                    ApplicationArea = Basic, Suite;
                    Image = StepOut;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category10;
                    RunObject = page "Loan Recoveries";
                    RunPageLink = "Loan No" = field("No."), "Recovery Type" = const(Loan);
                    Visible = (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR);

                }
                action("Intenal Recoveries")
                {
                    ApplicationArea = Basic, Suite;
                    Image = StepOut;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category10;
                    RunObject = page "Loan Recoveries";
                    RunPageLink = "Loan No" = field("No."), "Recovery Type" = const(Account);
                    Visible = (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR);

                }
                action("External Recoveries")
                {
                    ApplicationArea = Basic, Suite;
                    Image = StepOut;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category10;
                    RunObject = page "Loan Recoveries";
                    RunPageLink = "Loan No" = field("No."), "Recovery Type" = const(External);
                    Visible = (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR);

                }
            }
            action("Payable Advice")
            {
                ApplicationArea = Basic, Suite;
                Image = StepOut;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = page "Loans Payable Advice";
                RunPageLink = "Loan No" = field("No.");
                Visible = (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR);

            }
            action("Member Balances")
            {
                ApplicationArea = Basic, Suite;
                Image = ActivateDiscounts;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = page "Appraisal Account Balances";
                RunPageLink = "Loan No" = field("No.");
            }
            action("Earnings Payslip Information")
            {
                ApplicationArea = Basic, Suite;
                Image = AccountingPeriods;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = page "Loanees Payroll Transactions";
                RunPageLink = "Source No." = field("No."), Type = const(Income);
                Visible = (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR);

            }
            action("Deductions Payslip Information")
            {
                ApplicationArea = Basic, Suite;
                Image = Payables;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = page "Loanees Payroll Transactions";
                RunPageLink = "Source No." = field("No."), Type = const(Deduction);
                Visible = (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR);

            }
            action("Update Debt Collector")
            {
                ApplicationArea = Basic, Suite;
                Image = PostApplication;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and (Rec.Posted) and (not Rec.Closed) and (Rec."Loan Balance" <> 0) and (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR));
                trigger OnAction()
                var
                    UpdateDebtCollector: Report "Update Debt Collector";
                begin
                    UpdateDebtCollector.SetCurrentDetails(Rec."No.", Rec."Debt Collector Name");
                    UpdateDebtCollector.Run;
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
        isOpen := (Rec.Status = Rec.Status::Open);
        IsWindows := GuiAllowed;
    end;

    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        OfficeMgt: Codeunit "Office Management";
        IsOfficeAddin: Boolean;
        LoansManagement: Codeunit "Loans Management";
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. CBS Ext";
        isOpen, IsWindows : Boolean;
}
