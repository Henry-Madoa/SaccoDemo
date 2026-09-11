page 52203746 "Appraisal Competence"
{
    PageType = ListPart;
    SourceTable = "Appraisal Competence";

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
                field("Appraisal Code"; Rec."Appraisal No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Code"; Rec."Employee Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Category; Rec."Competence Category")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Weigth"; Rec."Maximum Weigth")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Overall Rating"; Rec."Overall Score")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Weigth"; Rec."Total Weigth")
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
            action("&Behaviours")
            {
                ApplicationArea = Basic, Suite;
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Appraisal Behaviours";
                RunPageLink = "Competence Line No"=FIELD("Line No"), "Employee No"=FIELD("Employee Code"), "Appraisal No"=FIELD("Appraisal No");
            }
        }
    }
}
