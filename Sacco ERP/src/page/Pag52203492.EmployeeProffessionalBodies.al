page 52203492 "Employee Proffessional Bodies"
{
    PageType = List;
    SourceTable = "Employee Proffesional Bodies";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Body Code"; Rec."Body Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("From Date"; Rec."From Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("To Date"; Rec."To Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Membership Number"; Rec."Membership Number")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
