page 52203702 "Payroll Approval Card"
{
    Editable = false;
    PageType = Card;
    SourceTable = "Payroll Periods";
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Period Name"; Rec."Period Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Period Month"; Rec."Period Month")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Period Year"; Rec."Period Year")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control8; "Payroll Approval Entries")
            {
                Editable = false;
                SubPageLink = "Payroll Period"=FIELD("Start Date");
            }
        }
    }
    actions
    {
        area(reporting)
        {
            group(Reports)
            {
                action("Payroll Deductions Report")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52051, true, false, PrPeriodTransaction);
                    end;
                }
                action("Payroll Allowances Report")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52052, true, false, PrPeriodTransaction);
                    end;
                }
                action("NSSF Report")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52053, true, false, Employee);
                    end;
                }
                action("SHIF Report")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52059, true, false, Employee);
                    end;
                }
                action("PAYE Report")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52052, true, false, PrPeriodTransaction);
                    end;
                }
                action("1/3 Rule Report")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52061, true, false, Employee);
                    end;
                }
                action("Gratuity Report")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52063, true, false, Employee);
                    end;
                }
                action("Payroll Grant Summary")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52104, true, false, PayrollChargedGrants);
                    end;
                }
                action("Payroll Summary")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52058, true, false, PrPeriodTransaction);
                    end;
                }
                action("Payroll varCe")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52068, true, false, PrPeriodTransaction);
                    end;
                }
                action("Pension Report")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52065, true, false, Employee);
                    end;
                }
                action("Payroll Costing Report")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52069, true, false, PrPeriodTransaction);
                    end;
                }
                action("NITA Report")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52074, true, false, Employee);
                    end;
                }
                action("Payroll Individual Allowance")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52060, true, false, PrPeriodTransaction);
                    end;
                }
                action("Payroll Individual Deduction")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52054, true, false, PrPeriodTransaction);
                    end;
                }
                action("Payroll Summary Individual")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52057, true, false, PayrollPeriods);
                    end;
                }
                action("Payments held")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52070, true, false, PrPeriodTransaction);
                    end;
                }
                action("Employee Per Grant")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52098, true, false, EmployeeDonors);
                    end;
                }
                action("Company Deductions")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = false;

                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    // PromotedIsBig = false;
                    trigger OnAction()
                    begin
                        REPORT.Run(52099, true, false, PrPeriodTransaction);
                    end;
                }
            }
        }
        area(processing)
        {
            group(Approval)
            {
                action(Approve)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = false;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
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
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = false;
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
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
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
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
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
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance();
    end;
    trigger OnOpenPage()
    begin
        SetControlAppearance();
    end;
    var OpenApprovalEntriesExist: Boolean;
    OpenApprovalEntriesExistForCurrUser: Boolean;
    PrPeriodTransaction: Record "Payroll Period Transaction";
    Employee: Record Employee;
    PayrollPeriods: Record "Payroll Periods";
    EmployeeDonors: Record "Employee Donors";
    PayrollChargedGrants: Record "Payroll Charged Grants";
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
    end;
}
