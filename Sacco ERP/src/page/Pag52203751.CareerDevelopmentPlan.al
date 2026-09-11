page 52203751 "Career Development Plan"
{
    PageType = ListPart;
    SourceTable = "Career Development Goals";

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
                field("Career Development Goal"; Rec."Career Development Goal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate Start Date"; Rec."Estimate Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Estimate End Date"; Rec."Estimate End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Duration; Rec.Duration)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            group(Strengths)
            {
                action("&Strengths")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Add;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Key Career Dev Strengths";
                    RunPageLink = "Goal Line No."=FIELD("Line No."), "Appraisal No."=FIELD("Appraisal No."), "Employee No."=FIELD("Employee No.");
                }
            }
        }
    }
}
