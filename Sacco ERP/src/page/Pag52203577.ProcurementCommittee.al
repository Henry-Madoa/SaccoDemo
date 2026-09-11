page 52203577 "Procurement Committee"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Procurement Commitee";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Members"; Rec."Minimum Members")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
