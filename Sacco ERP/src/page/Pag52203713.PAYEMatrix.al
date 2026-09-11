page 52203713 "PAYE Matrix"
{
    PageType = List;
    SourceTable = "Payroll PAYE";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tier Code"; Rec."Tier Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("PAYE Tier"; Rec."PAYE Tier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Rate; Rec.Rate)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Tax Code"; Rec."Tax Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
