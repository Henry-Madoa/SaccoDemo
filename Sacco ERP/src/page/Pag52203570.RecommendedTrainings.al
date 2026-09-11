page 52203570 "Recommended Trainings"
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
