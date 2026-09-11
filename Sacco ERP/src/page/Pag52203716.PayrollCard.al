page 52203716 "Payroll Card"
{
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = Card;
    SourceTable = Employee;
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = false;

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
                field("Full Name"; Rec.FullName)
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
                field(Disabled; Rec.Disabled)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Describe Disability"; Rec."Describe Disability")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Suspend Pay"; Rec."Suspend Pay")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employment Date"; Rec."Employment Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Leaving"; Rec."Date of Leaving")
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
                field("Global Dimension 6 Code"; Rec."Global Dimension 6 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Posting Group"; Rec."Employee Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Grade"; Rec."Job Scale")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("J-G Steps"; Rec."J-G Steps")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payroll Scale"; Rec."Job Scale")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Nature Of Employment"; Rec."Nature Of Employment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Reason For Pay Suspension"; Rec."Reason For Pay Suspension")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Percentage To Hold"; Rec."Percentage To Hold")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Methods"; Rec."Payment Methods")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bank Branch No."; Rec."Bank Branch No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Control33)
            {
                ShowCaption = false;

                field("Membership No"; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("FOSA Account"; Rec."FOSA Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bank Code"; Rec."Bank Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Flout 1/3 Rule"; Rec."Flout 1/3 Rule")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control18; "Employee Salary Card")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Employee Code"=FIELD("No.");
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(5200), "No."=FIELD("No.");
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Historical Data")
            {
                ApplicationArea = Basic, Suite;
                Image = History;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = Page "Payroll period trans list";
                RunPageLink = "Employee Code"=FIELD("No.");
            }
        }
        area(processing)
        {
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
            action("Process Current")
            {
                ApplicationArea = All;
                Caption = 'Process Current';
                Image = PayrollStatistics;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ProcessPayroll.ProcessIndividualPayroll(Rec);
                end;
            }
        }
        area(Reporting)
        {
            action(Payslip)
            {
                ApplicationArea = All;
                Image = "Report";
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetFilter("No.", Rec."No.");
                    REPORT.Run(Report::Payslip, true, false, Rec);
                end;
            }
            action("MailAllPayslips")
            {
                ApplicationArea = All;
                Caption = 'Mail Payslip';
                Image = SendEmailPDF;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetFilter("No.", Rec."No.");
                    REPORT.Run(Report::"Email Payslips", true, false, Rec);
                end;
            }
        }
    }
    var ProcessPayroll: Codeunit "Payroll Processing";
}
