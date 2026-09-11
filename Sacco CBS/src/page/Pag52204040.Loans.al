page 52204040 "Loans"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate,Recoveries,Securities';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = Loans;
    SourceTableView = sorting("No.") order(descending);
    CardPageId = Loan;
    ModifyAllowed = false;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Staff No"; Rec."Staff No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Phone No"; Rec."Phone No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Appraised By"; Rec."Appraised By")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("FOSA Account Balance"; Rec."Total Withdrawable Deposits")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("School Fee Savings"; Rec."School Fee Savings")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Member Category"; Rec."Member Category")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Employer Code"; Rec."Employer Code")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Employer Name"; GetEmployerName)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Product Description"; Rec."Product Description")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Interest Repayment Method"; Rec."Interest Repayment Method")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Installments; Rec.Installments)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Rate Type"; Rec."Rate Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Loan Amount"; Rec."Loan Amount")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Requested Amount"; Rec."Requested Amount")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Top Up Amount"; Rec."Bridged Amount")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Fresh Loan"; Rec."Approved Amount" - Rec."Bridged Amount")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Repayment Start Date"; Rec."Repayment Start Date")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Repayment End Date"; Rec."Repayment End Date")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Past Due"; (Rec."Repayment End Date" < WorkDate))
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Last Paid Amount"; LastAmountPaid)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Last Pay Date"; Rec."Last Pay Date")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Loan Balance"; Rec."Loan Balance")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Total Arrears"; Rec."Total Arrears")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Principal Arrears"; Rec."Principal Arrears")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Interest Arrears"; Rec."Interest Arrears")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Defaulted Installments"; Rec."Defaulted Installments")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Defaulted Days"; Rec."Defaulted Days")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Loan Classification"; Rec."Loan Classification")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Restructured; Rec.Restructured)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Interest Paid"; Rec."Interest Paid")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Interest Balance"; Rec."Interest Balance")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Total Penalty Due"; Rec."Total Penalty Due")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Penalty Paid"; Rec."Penalty Paid")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Penalty Balance"; Rec."Penalty Balance")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Interest Suspended"; Rec."Interest Suspended")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("No of Loan Guarantors"; GetNoofLoanGuarantors)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Total Guarantees"; Rec."Total Guarantees")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Debt Collector Type"; Rec."Debt Collector Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Debt Collector Name"; Rec."Debt Collector Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Deposits; Rec.Deposits)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Recovery Mode"; Rec."Recovery Mode")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Sector Code"; Rec."Sector Code")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Sector Name"; Rec."Sector Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Sub Sector Code"; Rec."Sub Sector Code")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Sub Sector Name"; Rec."Sub Sector Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Monthly Principal"; Rec."Monthly Principal")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Monthly Interest"; Rec."Monthly Interest")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Monthly Installment"; Rec."Monthly Installment")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Principal Paid"; Rec."Principal Paid")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Principal Balance"; Rec."Principal Balance")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Net Change-Principal"; Rec."Net Change-Principal")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Sales Representative"; Rec."Sales Representative")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Sales Representative Name"; Rec."Sales Representative Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Principal Repayment"; Rec."Principal Repayment")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Loan Account"; Rec."Loan Account")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Interest Repayment"; Rec."Interest Repayment")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
            }
        }
        area(Factboxes)
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
                Visible = (Rec.Category <> Rec.Category::DEBT) and (Rec.Category <> Rec.Category::HR);
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
            action("Archive UnArchive")
            {
                ApplicationArea = Basic, Suite;
                Image = Archive;
                Promoted = true;
                PromotedCategory = Category9;
                Visible = ((Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::Approved) or (Rec.Status = Rec.Status::Archived));
                trigger OnAction()
                var
                    Loans: Record Loans;
                begin
                    Loans.Reset;
                    CurrPage.SetSelectionFilter(Loans);
                    if Loans.FindSet then begin
                        if Confirm(StrSubstNo('You are about to Archive/Unarchive %1 Loans\\ Do you wish to continue?', Loans.Count)) then begin
                            repeat
                                LoansManagement.LoanArchiving(Loans);
                            until Loans.NEXT = 0;
                        end;
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
            action("Payslip Information")
            {
                ApplicationArea = Basic, Suite;
                Image = AccountingPeriods;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = page "Loanees Payroll Transactions";
                RunPageLink = "Source No." = field("No.");
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
            action("Upload Loans")
            {
                ApplicationArea = Basic, Suite;
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = CanPostUploadedLoans;
                trigger OnAction()
                var
                    Import: XmlPort "Debts & HR Loans";
                begin
                    Clear(Import);
                    Import.Run();
                end;
            }
            action("Post Uploaded Loans")
            {
                ApplicationArea = Basic, Suite;
                Image = PostedVendorBill;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((CanPostUploadedLoans) and (Rec.Status = Rec.Status::Approved));
                trigger OnAction()
                begin
                    LoansManagement.PostUploadedLoans;
                end;
            }
            action("Post Opening Balances")
            {
                ApplicationArea = Basic, Suite;
                Image = PostedVendorBill;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                //Visible = ((not Rec.Posted) and (Rec.Status = Rec.Status::Approved));
                Visible = false;

                trigger OnAction()
                begin
                    LoansManagement.PostLoansOpeningBalances;
                end;
            }

            action("Post Opening Interest Due Balances")
            {
                ApplicationArea = Basic, Suite;
                Image = PostedReturnReceipt;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                // Visible = ((Rec.Posted) and (Rec.Status = Rec.Status::Approved)); 
                Visible = false;

                trigger OnAction()
                begin
                    LoansManagement.PostLoansInterstDueOpeningBalances;
                end;
            }
            action("Regenerate Schedule")
            {
                ApplicationArea = Basic, Suite;
                Image = GeneralLedger;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                //Visible = Rec.Posted;
                Visible = false;

                trigger OnAction()
                var
                    Loans: Record Loans;
                    LoansMgt: Codeunit "Loans Management";
                    Window: Dialog;
                    All, Current : Integer;
                begin
                    Loans.Reset();
                    //CurrPage.SetSelectionFilter(LoanApplication);
                    Loans.SetRange("Product Code", 'L37');
                    Loans.SetFilter("Posting Date", '>01/01/2025');
                    if Loans.FindSet() then begin
                        All := Loans.Count;
                        Current := 0;
                        Window.Open('Checking \#1### \#2##');
                        repeat
                            Window.Update(1, Loans."No.");
                            Window.Update(2, Format(Current) + ' of ' + Format(All));
                            Current += 1;
                            Loans."Interest Repayment Method" := Loans."Interest Repayment Method"::Amortised;
                            Loans.Modify(true);
                            Commit;
                            LoansManagement.GenerateLoanRepaymentSchedule(Loans);
                        until Loans.Next() = 0;
                        Window.Close;
                    end;
                end;
            }
            action("Update Interest")
            {
                ApplicationArea = Basic, Suite;
                Image = CalculateBalanceAccount;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                //Visible = Rec.Posted;
                Visible = false;

                trigger OnAction()
                var
                    Loans: Record Loans;
                    LoansMgt: Codeunit "Loans Management";
                    Window: Dialog;
                    All, Current : Integer;
                begin
                    Loans.Reset();
                    CurrPage.SetSelectionFilter(Loans);
                    if Loans.FindSet() then begin
                        All := Loans.Count;
                        Current := 0;
                        Window.Open('Checking \#1### \#2##');
                        repeat
                            Window.Update(1, Loans."No.");
                            Window.Update(2, Format(Current) + ' of ' + Format(All));
                            Current += 1;
                            //LoansManagement.GenerateLoanRepaymentSchedule(LoanApplication);
                            Loans.Validate(Installments);
                            Loans.Modify(true);
                        until Loans.Next() = 0;
                        Window.Close;
                    end;
                end;
            }
            action("Update Dividend Advance Interest")
            {
                ApplicationArea = Basic, Suite;
                Image = CalculateBalanceAccount;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                //Visible = Rec.Posted;
                Visible = false;

                trigger OnAction()
                var
                    Loans: Record Loans;
                    LoansMgt: Codeunit "Loans Management";
                    GeneralLedgerSetup: Record "General Ledger Setup";
                    Window: Dialog;
                    All, Current : Integer;
                begin
                    GeneralLedgerSetup.Get;
                    Loans.Reset();
                    Loans.SetRange("Product Code", 'L01');
                    Loans.SetFilter("Posting Date", '%1..', GeneralLedgerSetup."Allow Posting From");
                    if Loans.FindSet() then begin
                        All := Loans.Count;
                        Current := 0;
                        Window.Open('Checking \#1### \#2##');
                        repeat
                            Current += 1;
                            Window.Update(1, Loans."No.");
                            Window.Update(2, Format(Current) + ' of ' + Format(All));
                            LoansManagement.PostLoanUpFrontInterest(Loans."No.");
                        until Loans.Next() = 0;
                        Window.Close;
                    end;
                end;
            }
            action("Update Loans")
            {
                ApplicationArea = Basic, Suite;
                Image = CalculateBalanceAccount;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                //Visible = Rec.Posted;
                Visible = false;

                trigger OnAction()
                var
                    Loans: Record Loans;
                    Window: Dialog;
                    All, Current : Integer;
                    GeneralLedgerSetup: Record "General Ledger Setup";
                begin
                    GeneralLedgerSetup.Get;
                    Loans.Reset();
                    Loans.SetRange(Posted, false);
                    Loans.SetRange(Status, Loans.Status::Approved);
                    Loans.SetFilter("Posting Date", '<%1', GeneralLedgerSetup."Opening Balance Posting Date");
                    if Loans.FindSet() then begin
                        All := Loans.Count;
                        Current := 0;
                        Window.Open('Checking \#1### \#2##');
                        repeat
                            Window.Update(1, Loans."No.");
                            Window.Update(2, Format(Current) + ' of ' + Format(All));
                            Current += 1;
                            Loans.Validate(Posted, true);
                            Loans.Modify(true);
                        until Loans.Next() = 0;
                        Window.Close;
                    end;
                end;
            }
            action("Update Loans Recovery Mode")
            {
                ApplicationArea = Basic, Suite;
                Image = CalculateBalanceAccount;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                trigger OnAction()
                var
                    Loans: Record Loans;
                    Window: Dialog;
                    All, Current : Integer;
                    GeneralLedgerSetup: Record "General Ledger Setup";
                    SaccoProducts: Record "Sacco Products";
                    Member: Record Members;
                begin
                    GeneralLedgerSetup.Get;
                    Loans.Reset();
                    Loans.SetFilter("Recovery Mode", '<>%1', Loans."Recovery Mode"::Salary);
                    Loans.SetRange("Product Code", 'L02');
                    if Loans.FindSet() then begin
                        All := Loans.Count;
                        Current := 0;
                        Window.Open('Checking \#1### \#2##');
                        repeat
                            Current += 1;
                            Window.Update(1, Loans."No.");
                            Window.Update(2, Format(Current) + ' of ' + Format(All));
                            Current += 1;
                            SaccoProducts.Get(Loans."Product Code");
                            Member.Get(Loans."Member No.");
                            if (SaccoProducts."Mobile Loan" and (not SaccoProducts."Dividend Based")) then begin
                                if Member.Salaried then
                                    Loans."Recovery Mode" := Loans."Recovery Mode"::Salary
                                else
                                    Loans."Recovery Mode" := Loans."Recovery Mode"::Mpesa;
                            end;
                            If SaccoProducts."Mobile Loan" or SaccoProducts."Dividend Based" then Loans.Category := Loans.Category::FOSA;
                            Loans.Modify(true);
                        until Loans.Next() = 0;
                        Window.Close;
                    end;
                end;
            }
            action("Update Loans Member Category")
            {
                ApplicationArea = Basic, Suite;
                Image = CalculateBalanceAccount;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                trigger OnAction()
                var
                    Loans: Record Loans;
                    Window: Dialog;
                    All, Current : Integer;
                    GeneralLedgerSetup: Record "General Ledger Setup";
                    SaccoProducts: Record "Sacco Products";
                    Member: Record Members;
                begin
                    GeneralLedgerSetup.Get;
                    Loans.Reset();
                    if Loans.FindSet() then begin
                        All := Loans.Count;
                        Current := 0;
                        Window.Open('Checking \#1### \#2###');
                        repeat
                            Current += 1;
                            Window.Update(1, Loans."No.");
                            Window.Update(2, Format(Current) + ' of ' + Format(All));
                            If Member.Get(Loans."Member No.") then begin
                                Loans."Member Category" := Member.Category;
                                Loans.Modify(true);
                            end;
                        until Loans.Next() = 0;
                        Window.Close;
                    end;
                end;
            }
        }
    }
    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        CanPostUploadedLoans: Boolean;
        UserSetup: Record "User Setup";
        OfficeMgt: Codeunit "Office Management";
        IsOfficeAddin: Boolean;
        LoansManagement: Codeunit "Loans Management";
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. CBS Ext";
        GlobalDocumentNo, BatchNo : code[20];
        GlobalDocumentType: option "Loan Batch";
        StyleText: Text;
        LastAmountPaid: Decimal;
        StartDate: Date;
        EndDate: Date;


    trigger OnOpenPage()
    begin
        SetControlAppearance;
        GetLastAmountPaid;
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
        SetStyleText;
        GetLastAmountPaid;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance;
        GetLastAmountPaid;
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
        CanPostUploadedLoans := false;

        If UserSetup.Get(UserId) then begin
            if UserSetup."Is System Admin" or UserSetup."Finance Admin" then
                CanPostUploadedLoans := true;
        end;
    end;

    local procedure SetStyleText()
    begin
        StyleText := '';
        if ((Rec.Posted) and (Rec."Loan Balance" <> 0)) then begin
            case Rec."Loan Classification" of
                Rec."Loan Classification"::Performing:
                    StyleText := 'Favorable';
                Rec."Loan Classification"::Watch:
                    StyleText := 'AttentionAccent';
                Rec."Loan Classification"::Doubtfull:
                    StyleText := 'Attention';
                Rec."Loan Classification"::Substandard:
                    StyleText := 'Ambiguous';
                Rec."Loan Classification"::Loss:
                    StyleText := 'Unfavorable';
            end;
        end;
    end;

    procedure SetParameters(DocumentType: option "Loan Batch"; DocumentNo: Code[20])
    var
    begin
        GlobalDocumentNo := DocumentNo;
        GlobalDocumentType := DocumentType;
    end;

    procedure GetLastAmountPaid()
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        LastAmountPaid := 0;
        Rec.CalcFields("Last Pay Date");
        DetailedVendorLedgEntry.Reset();
        DetailedVendorLedgEntry.SetRange("Member No.", Rec."Member No.");
        DetailedVendorLedgEntry.SetRange("Vendor No.", Rec."Loan Account");
        DetailedVendorLedgEntry.SetRange("Posting Date", Rec."Last Pay Date");
        DetailedVendorLedgEntry.SetFilter("Sacco Transaction Type", '%1|%2', DetailedVendorLedgEntry."Sacco Transaction Type"::"Interest Paid", DetailedVendorLedgEntry."Sacco Transaction Type"::"Principal Paid");
        if DetailedVendorLedgEntry.FindSet then begin
            DetailedVendorLedgEntry.CalcSums(Amount);
            LastAmountPaid := Abs(DetailedVendorLedgEntry.Amount);
        end;
    end;

    procedure GetCurrentMonthPrincipal(): Decimal
    var
        LoanSchedule: Record "Loan Schedule";
    begin
        LoanSchedule.SetRange("Loan No.", Rec."No.");
        LoanSchedule.SetRange("Expected Date", CalcDate('<-CM>', WorkDate), CalcDate('<CM>', WorkDate));
        if LoanSchedule.FindFirst() then exit(LoanSchedule."Principal Repayment");
        exit(0);
    end;

    procedure GetCurrentMonthInterest(): Decimal
    var
        LoanSchedule: Record "Loan Schedule";
    begin
        LoanSchedule.SetRange("Loan No.", Rec."No.");
        LoanSchedule.SetRange("Expected Date", CalcDate('<-CM>', WorkDate), CalcDate('<CM>', WorkDate));
        if LoanSchedule.FindFirst() then exit(LoanSchedule."Interest Repayment");
        exit(0);
    end;

    procedure GetEmployerName(): Text
    var
        Employer: Record Employers;
    begin
        Rec.CalcFields("Employer Code");
        Employer.SetRange(Code, Rec."Employer Code");
        if Employer.FindFirst() then exit(Employer.Name);
    end;

    procedure GetNoofLoanGuarantors(): Integer
    var
        LoanGuarantees: Record "Loan Guarantees";
        Number: Integer;
    begin
        LoanGuarantees.Reset();
        LoanGuarantees.SetRange("Loan No", Rec."No.");
        Number := LoanGuarantees.Count();
        exit(Number);
    end;
}
