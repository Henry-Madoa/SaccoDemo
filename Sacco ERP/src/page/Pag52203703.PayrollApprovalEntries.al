page 52203703 "Payroll Approval Entries"
{
    PageType = ListPart;
    SourceTable = "Payroll Approval Line Entries";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
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
            action("Earnings & Deductions")
            {
                ApplicationArea = Basic, Suite;
                RunObject = Page "Earning & Deductions Approval";
                RunPageLink = "Employee Code"=FIELD("Employee No."), "Payroll Period"=FIELD("Payroll Period");
            }
            action(Payslip)
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Employee.Reset;
                    Employee.SetRange("No.", Rec."Employee No.");
                    Employee.SetRange(Employee."Period Filter", Rec."Payroll Period");
                    REPORT.Run(REPORT::Payslip, true, false, Employee);
                end;
            }
        }
    }
    var Employee: Record Employee;
}
