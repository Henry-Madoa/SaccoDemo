page 52203578 "Purchaser Response"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Purchaser Response";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Accept Note"; Rec."Accept Note")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Return Note"; Rec."Return Note")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Reject Note"; Rec."Reject Note")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
