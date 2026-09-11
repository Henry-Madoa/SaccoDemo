page 52203741 "Appraisal Proficiency Level"
{
    PageType = List;
    SourceTable = "Appraisal Proficiency Levels";

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
                field(Level; Rec.Level)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
