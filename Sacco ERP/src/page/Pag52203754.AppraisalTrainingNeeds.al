page 52203754 "Appraisal Training Needs"
{
    PageType = ListPart;
    SourceTable = "Appraisal Training Needs";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Training Needs Line No."; Rec."Training Needs Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
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
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Category Name"; Rec."Category Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Need Description"; Rec."Training Need Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Recommended; Rec.Recommended)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recommendation Justification"; Rec."Recommendation Justification")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = not Rec.Recommended;
                }
                field("Proposed Trainer"; Rec."Proposed Trainer")
                {
                    Editable = Rec.Recommended;
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
