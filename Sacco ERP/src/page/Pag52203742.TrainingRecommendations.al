page 52203742 "Training Recommendations"
{
    PageType = ListPart;
    SourceTable = "Appraisal Training Rec.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Training Area"; Rec."Training Area")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Description"; Rec."Training Description")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
