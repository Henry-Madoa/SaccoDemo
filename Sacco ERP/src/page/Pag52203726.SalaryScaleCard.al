page 52203726 "Salary Scale Card"
{
    PageType = Card;
    SourceTable = "Employee Payroll Scales";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Scale; Rec.Scale)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("No. of Employees"; Rec."No. of Employees")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Allowance Amount"; Rec."Leave Allowance Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Probation Notice Period"; Rec."Probation Notice Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Inpatient Ward Entitlement"; Rec."Inpatient Ward Entitlement")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Allowance Amount"; Rec."Training Allowance Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Overtime Allowance Amount"; Rec."Overtime Allowance Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
            }
            part(Control6; "Salary Scale Pointers")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = Scale=FIELD(Scale);
            }
        }
    }
}
