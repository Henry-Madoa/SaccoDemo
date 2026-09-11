page 52203752 "Key Career Dev Strengths"
{
    PageType = List;
    SourceTable = "Key Strengths Career Goals";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal No."; Rec."Appraisal No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Strength; Rec.Strength)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Goal Line No."; Rec."Goal Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
