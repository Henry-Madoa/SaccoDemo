page 52203668 "Contract Change Conditions"
{
    PageType = List;
    SourceTable = "Contract Change Conditions";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Condition; Rec.Condition)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
