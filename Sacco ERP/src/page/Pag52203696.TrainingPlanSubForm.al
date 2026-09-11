page 52203696 "Training Plan Sub-Form"
{
    PageType = ListPart;
    SourceTable = "Training Plan Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Training Need"; Rec."Training Need")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Need Description"; Rec."Training Need Description")
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
                field("Training Type"; Rec."Training Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Trainer Code"; Rec."Trainer Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Trainer Name"; Rec."Trainer Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Start Date"; Rec."Expected Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected End Date"; Rec."Expected End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Estimated Cost"; Rec."Estimated Cost")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Actual Cost"; Rec."Actual Cost")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Duration; Rec.Duration)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Trainees"; Rec."Expected Trainees")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("No. of Applications"; Rec."No. of Applications")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Training Venue"; Rec."Training Venue")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Sponsor"; Rec."Training Sponsor")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sponsorship Start Date"; Rec."Sponsorship Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sponsorship End Date"; Rec."Sponsorship End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Target Group"; Rec."Target Group")
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
            action(Attendees)
            {
                ApplicationArea = Basic, Suite;
                Image = Employee;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "Training Attendees";
                RunPageLink = "Plan Line No."=field("Line No."), "Plan No."=field("Plan No.");
            }
        }
    }
}
