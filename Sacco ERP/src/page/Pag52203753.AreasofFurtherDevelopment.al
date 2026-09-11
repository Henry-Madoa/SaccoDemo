page 52203753 "Areas of Further Development"
{
    PageType = ListPart;
    SourceTable = "Areas of Further Development";

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
                field(Weakness; Rec.Weakness)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Needed"; Rec."Training Needed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Support Needed"; Rec."Support Needed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Status Comment"; Rec."Status Comment")
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
            action("Training Needs")
            {
                ApplicationArea = Basic, Suite;
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Appraisal Training Needs";
                RunPageLink = "Training Needs Line No."=FIELD("Line No."), "Appraisal No."=FIELD("Appraisal No."), "Employee No."=FIELD("Employee No.");
            }
        }
    }
}
