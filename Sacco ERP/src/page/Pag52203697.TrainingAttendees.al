page 52203697 "Training Attendees"
{
    PageType = ListPart;
    SourceTable = "Training Attendees";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                //Editable = "Training Created" = false;
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Cost"; Rec."Training Cost")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnAssistEdit()
                    var
                        EmployeeCosts: Record "Training Employee Costs";
                    begin
                        EmployeeCosts.Reset();
                        EmployeeCosts.SetRange("Attendees Line No.", Rec."Line No");
                        EmployeeCosts.SetRange("Plan Line No.", Rec."Plan Line No.");
                        EmployeeCosts.SetRange("Plan No.", Rec."Plan No.");
                        Page.Run(Page::"Training Employee Costs", EmployeeCosts);
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Costs)
            {
                ApplicationArea = Basic, Suite;
                Image = Cost;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Training Employee Costs";
                RunPageLink = "Attendees Line No."=field("Line No"), "Plan Line No."=field("Plan Line No."), "Plan No."=field("Plan No.");
            }
        }
    }
}
