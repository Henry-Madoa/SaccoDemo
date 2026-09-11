page 52203715 "Payroll List"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';
    CardPageID = "Payroll Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = Employee;
    SourceTableView = where("Nature Of Employment"=filter(<>Board), "Employee Status"=FILTER(Active|OnLeave|"Pending Final Payment"), "Nature Of Employment"=filter(<>Board));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
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
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Title"; Rec."Job Title")
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
                field("Employee Posting Group"; Rec."Employee Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("National ID"; Rec."National ID")
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
                field("KRA Number"; Rec."KRA Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payroll Scale"; Rec."Job Scale")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Payroll Process")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Process Payroll';
                Image = PayrollStatistics;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Text000: Label '@1@@@@@@@@@@@@@@@@@@@@@';
                begin
                    PayrollPeriods.Reset;
                    PayrollPeriods.SetRange(PayrollPeriods.Closed, false);
                    if PayrollPeriods.Find('-')then begin
                        if PayrollPeriods.Status in[PayrollPeriods.Status::Approved]then Error('You cannot process an approved payroll');
                        if PayrollPeriods.Status in[PayrollPeriods.Status::"Pending Approval"]then Error('Payroll is already under approval');
                        SelectedPeriod:=PayrollPeriods."Start Date";
                    end
                    else
                    begin
                        Error('No Payroll period found');
                    end;
                    PayrollEmployerTransaction.Reset;
                    PayrollEmployerTransaction.SetRange("Payroll Period", SelectedPeriod);
                    if PayrollEmployerTransaction.FindSet then PayrollEmployerTransaction.DeleteAll;
                    PayrollPeriodTrans.Reset;
                    PayrollPeriodTrans.SetRange("Payroll Period", SelectedPeriod);
                    if PayrollPeriodTrans.FindSet then PayrollPeriodTrans.DeleteAll;
                    PayrollChargedGrants.Reset;
                    PayrollChargedGrants.SetRange("Payroll Period", SelectedPeriod);
                    if PayrollChargedGrants.FindSet then PayrollChargedGrants.DeleteAll;
                    PayrollEmployeeP9TaxInfo.Reset;
                    PayrollEmployeeP9TaxInfo.SetRange("Payroll Period", SelectedPeriod);
                    if PayrollEmployeeP9TaxInfo.FindSet then PayrollEmployeeP9TaxInfo.DeleteAll;
                    SalaryAdvanceMgmt.CheckForImprestMarkedForPayroll;
                    SalaryAdvanceMgmt.LeaveAllowancesToBePaid;
                    Employee.Reset;
                    Employee.SetFilter("Nature Of Employment", '<>%1', Employee."Nature Of Employment"::Board);
                    Employee.SetRange("Suspend Pay", false);
                    Employee.SetFilter("Employee Status", '=%1|=%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
                    if Employee.Find('-')then begin
                        ProgressWindow.Open('Processing Salary #1#################################################################');
                        repeat ProgressWindow.Update(1, Employee."No." + ':' + Employee.FullName);
                            if PRSalaryCard.Get(Employee."No.")then begin
                                ProcessPayroll.Processpayroll(Employee."No.", Employee."Employment Date", PRSalaryCard."Basic Pay", PRSalaryCard."Pays PAYE", PRSalaryCard."Pays NSSF", PRSalaryCard."Pays SHIF", SelectedPeriod, SelectedPeriod, '', '', Employee."Date of Leaving", true, Employee."Global Dimension 1 Code", false, false);
                            end;
                        until Employee.Next = 0;
                        ProgressWindow.Close;
                    end;
                    Commit;
                end;
            }
            action("Earnings & Deductions")
            {
                ApplicationArea = Basic, Suite;
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Employee Earning & Deductions";
                RunPageLink = "Employee Code"=FIELD("No.");
            }
            action(Payslip)
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Employee: Record Employee;
                begin
                    Employee.Reset;
                    Employee.SetFilter("No.", Rec."No.");
                    REPORT.Run(Report::Payslip, true, false, Employee);
                end;
            }
            action("Process Current")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Process Current';
                Image = PayrollStatistics;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Text000: Label '@1@@@@@@@@@@@@@@@@@@@@@';
                begin
                    PayrollPeriods.Reset;
                    PayrollPeriods.SetRange(PayrollPeriods.Closed, false);
                    if PayrollPeriods.Find('-')then begin
                        if PayrollPeriods.Status in[PayrollPeriods.Status::Approved]then Error('You cannot process an approved payroll');
                        if PayrollPeriods.Status in[PayrollPeriods.Status::"Pending Approval"]then Error('Payroll is already under approval');
                        SelectedPeriod:=PayrollPeriods."Start Date";
                    end
                    else
                    begin
                        Error('No Payroll period found');
                    end;
                    PayrollPeriodTrans.Reset;
                    PayrollPeriodTrans.SetRange("Payroll Period", SelectedPeriod);
                    PayrollPeriodTrans.SetRange("Employee Code", Rec."No.");
                    if PayrollPeriodTrans.FindSet then PayrollPeriodTrans.DeleteAll;
                    PayrollEmployeeP9TaxInfo.Reset;
                    PayrollEmployeeP9TaxInfo.SetRange("Payroll Period", SelectedPeriod);
                    PayrollEmployeeP9TaxInfo.SetRange("Employee Code", Rec."No.");
                    if PayrollEmployeeP9TaxInfo.FindSet then PayrollEmployeeP9TaxInfo.DeleteAll;
                    PayrollEmployerTransaction.Reset;
                    PayrollEmployerTransaction.SetRange("Payroll Period", SelectedPeriod);
                    PayrollEmployerTransaction.SetRange("Employee Code", Rec."No.");
                    if PayrollEmployerTransaction.FindSet then PayrollEmployerTransaction.DeleteAll;
                    PayrollChargedGrants.Reset;
                    PayrollChargedGrants.SetRange("Payroll Period", SelectedPeriod);
                    PayrollChargedGrants.SetRange("Emp Code", Rec."No.");
                    if PayrollChargedGrants.FindSet then PayrollChargedGrants.DeleteAll;
                    EmployeeDonors.Reset;
                    EmployeeDonors.SetRange("Employee No", Rec."No.");
                    EmployeeDonors.SetRange("Grant Status", EmployeeDonors."Grant Status"::Active);
                    if EmployeeDonors.FindFirst then hasActiveGrant:=true
                    else
                        hasActiveGrant:=false;
                    SalaryAdvanceMgmt.CheckForImprestMarkedForPayroll;
                    SalaryAdvanceMgmt.LeaveAllowancesToBePaid;
                    if PRSalaryCard.Get(Rec."No.")then begin
                        Employee.Reset;
                        Employee.SetFilter("No.", '=%1', Rec."No.");
                        if Employee.Find('-')then begin
                            ProgressWindow.Open('Processing Salary #1#################################################################');
                            repeat ProgressWindow.Update(1, Employee."No." + ':' + Employee.FullName);
                                if PRSalaryCard.Get(Employee."No.")then begin
                                    ProcessPayroll.Processpayroll(Employee."No.", Employee."Employment Date", PRSalaryCard."Basic Pay", PRSalaryCard."Pays PAYE", PRSalaryCard."Pays NSSF", PRSalaryCard."Pays SHIF", SelectedPeriod, SelectedPeriod, '', '', Employee."Date of Leaving", true, Employee."Global Dimension 1 Code", false, false);
                                end;
                            until Employee.Next = 0;
                            ProgressWindow.Close;
                        end;
                        Commit;
                    end;
                end;
            }
            action("Bulk Transaction")
            {
                ApplicationArea = Basic, Suite;
                Image = AddToHome;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = XMLport "Import Bulk Payroll Codes.";
            }
            action(Donors)
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
                Image = Hierarchy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Employee Donors";
                RunPageLink = "Employee No"=FIELD("No.");
            }
            action("Historical Data")
            {
                ApplicationArea = Basic, Suite;
                Image = History;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Payroll period trans list";
                RunPageLink = "Employee Code"=FIELD("No.");
            }
        }
    }
    var PayrollPeriods: Record "Payroll Periods";
    Employee: Record Employee;
    PRSalaryCard: Record "Payroll Salary Card";
    SelectedPeriod: Date;
    ProgressWindow: Dialog;
    ProcessPayroll: Codeunit "Payroll Processing";
    PayrollPeriodTrans: Record "Payroll Period Transaction";
    PayrollEmployeeP9TaxInfo: Record "Payroll Employee P9 Tax Info";
    PayrollEmployerTransaction: Record "Payroll Employer Transaction";
    ContractStartDate: Date;
    ContractEndDate: Date;
    EmployeeContractDetails: Record "Employee Contract Details";
    PayrollChargedGrants: Record "Payroll Charged Grants";
    EmployeeDonors: Record "Employee Donors";
    hasActiveGrant: Boolean;
    HumanResourceMgmt: Codeunit "Human Resource Management";
    SalaryAdvanceMgmt: Codeunit "Payroll Processing";
}
