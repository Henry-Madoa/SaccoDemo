page 52204131 "Employers"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = Employers;
    CardPageId = Employer;
    Editable = false;
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payroll No. Mandatory"; Rec."Payroll No. Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Checkoff Account"; Rec."Checkoff Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary Account"; Rec."Salary Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Suspense Account"; Rec."Suspense Account")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
