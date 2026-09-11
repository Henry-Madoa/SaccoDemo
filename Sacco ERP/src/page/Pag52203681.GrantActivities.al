page 52203681 "Grant Activities"
{
    PageType = List;
    SourceTable = "Grant Activities";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Grant Activity"; Rec."Grant Activity")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
