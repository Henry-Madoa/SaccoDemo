page 52203706 "Transaction For Jobs"
{
    PageType = ListPart;
    SourceTable = "Payroll Transaction Jobs";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Job Id"; Rec."Job Id")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Description"; Rec."Job Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
