page 52204140 "Channel Loan Application"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate,Recoveries,Securities';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Channel Loan Application";

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
                Editable = Rec.Status = Rec.Status::Open;

                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Witness; Rec.Witness)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Loan Details")
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Applied Amount"; Rec."Applied Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Recovery Mode"; Rec."Recovery Mode")
                {
                    ApplicationArea = Basic, Suite;
                }
                group("Economic Sector")
                {
                    field("Sector Code"; Rec."Sector Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Sub Sector Code"; Rec."Sub Sector Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Sub-Susector Code"; Rec."Sub-Susector Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                field("Product Description"; Rec."Product Description")
                {
                    ApplicationArea = Basic, Suite;
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
                field("Mode of Disbursement"; Rec."Mode of Disbursement")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Disbursement Account"; Rec."Disbursement Account")
                {
                    ApplicationArea = Basic, Suite;
                }
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
            group("Repayment Details")
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("Principal Repayment"; Rec."Principal Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Repayment"; Rec."Interest Repayment")
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
            group("Portal Information")
            {
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
                field(DepositsToDate; DepositsToDate)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(RMFToDate; RMFToDate)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(FactBoxes)
        {
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
                SubPageLink = "Table ID" = CONST(Database::"Channel Loan Application"), "No." = FIELD("No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Manual Submitting")
            {
                Promoted = true;
                Image = Approvals;
                Visible = Rec."Portal Status" = Rec."Portal Status"::New;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Confirm('Do you want to submit the Online Loan Application?') then begin
                        Rec."Portal Status" := Rec."Portal Status"::Submitted;
                        Rec."Submitted On" := CurrentDateTime;
                        Rec.Modify(true);
                        Message('Submitted Successfully');
                        CurrPage.Close();
                    end;
                end;
            }
            action("Send To Loans")
            {
                PromotedCategory = Process;
                Promoted = true;
                Image = AccountingPeriods;
                Visible = Rec."Portal Status" = Rec."Portal Status"::Submitted;
                trigger OnAction()
                begin
                    if Confirm('Do you want to submit the Online Loan Application?') then begin
                        LoansManagement.CreateLoan(Rec."No.");
                        Message('Submitted Successfully');
                        CurrPage.Close();
                    end;
                end;
            }
            action(Guarantors)
            {
                PromotedCategory = Category11;
                ApplicationArea = Basic, Suite;
                Promoted = true;
                Image = StepOver;
                RunObject = page "Channel Guarantor Requests";
                RunPageLink = "Loan No" = field("No.");
            }
            action(Securities)
            {
                PromotedCategory = Category11;
                ApplicationArea = Basic, Suite;
                Promoted = true;
                Image = StepOver;
                RunObject = page "Loan Securities";
                RunPageLink = "Loan No" = field("No."), "Security Type" = const(Collateral);
            }
            action("Print Schedule")
            {
                PromotedCategory = Report;
                ApplicationArea = Basic, Suite;
                Promoted = true;
                Image = Print;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    LoanApplication: Record "Channel Loan Application";
                begin
                    LoansManagement.GenerateOnlineLoanRepaymentSchedule(Rec);
                    Commit();
                    LoanApplication.Reset();
                    LoanApplication.SetRange("No.", Rec."No.");
                    if LoanApplication.FindSet() then Report.Run(Report::"Channel Repayment Schedule", true, false, LoanApplication);
                end;
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
        }
    }
    trigger OnOpenPage()
    begin
        MemberMgt.GetDepositsCurrYear(Rec."Member No.", Rec."Application Date", DepositsToDate, RMFToDate);
    end;

    var
        LoansManagement: Codeunit "Loans Management";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. CBS Ext";
        isOpen: Boolean;
        DepositsToDate, RMFTodate : Decimal;
        MemberMgt: Codeunit "Member Management";
}
