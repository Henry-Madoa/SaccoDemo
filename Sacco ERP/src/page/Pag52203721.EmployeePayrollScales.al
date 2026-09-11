page 52203721 "Employee Payroll Scales"
{
    CardPageID = "Salary Scale Card";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Employee Payroll Scales";
    SourceTableView = SORTING(Sequence)ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Scale; Rec.Scale)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Probation Notice Period"; Rec."Probation Notice Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Allowance Amount"; Rec."Leave Allowance Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Allowance Amount"; Rec."Training Allowance Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Inpatient Ward Entitlement"; Rec."Inpatient Ward Entitlement")
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
            action("Income & Deduction Configuartion")
            {
                ApplicationArea = Basic, Suite;
                Image = Column;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Income/Deduction Configuarion";
                RunPageLink = Scale=FIELD(Scale);
            }
        }
    }
}
