page 52203747 "Appraisal Behaviours"
{
    PageType = List;
    SourceTable = "Appraisal Behaviour";

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
                field("Competence Line No"; Rec."Competence Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal Code"; Rec."Appraisal No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Competence Category"; Rec."Competence Category")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Behaviour Name"; Rec."Behaviour Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Applicable; Rec.Applicable)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Proficiency Level"; Rec."Current Proficiency Level")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Proficiency Level"; Rec."Expected Proficiency Level")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Behaviour Description"; Rec."Behaviour Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Behaviour Results")
            {
                Image = Position;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                RunObject = page "Appraisal Behaviour Rating";
                RunPageLink = "Behaviour Line No"=field("Line No"), "Competence Line No"=field("Competence Line No"), "Appraisal No"=field("Appraisal No"), "Employee No"=field("Employee No");
            }
        }
    }
}
