page 52203748 "Learning Assesment - Competenc"
{
    PageType = ListPart;
    SourceTable = "Development Learning Assesment";

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
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal No"; Rec."Appraisal No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Action"; Rec."Training Action")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Learning Hours"; Rec."Learning Hours")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Status(Mid Year)"; Rec."Status(Mid Year)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Status(End Year)"; Rec."Status(End Year)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
