page 52203763 "Imprest Purpose"
{
    PageType = List;
    SourceTable = "Imprest Purpose";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Purpose Code"; Rec."Purpose Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Purpose Desscription"; Rec."Purpose Desscription")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
