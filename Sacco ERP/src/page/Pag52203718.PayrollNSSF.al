page 52203718 "Payroll NSSF Matrix"
{
    PageType = List;
    SourceTable = "Payroll NSSF Matrix";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Tier; Rec.Tier)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Lower Limit"; Rec."Lower Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Upper Limit"; Rec."Upper Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
