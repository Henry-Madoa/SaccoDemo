page 52203576 "Score Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Score Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Score ID"; Rec."Score ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Score; Rec.Score)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
