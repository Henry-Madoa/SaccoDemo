page 52203698 "Training Need Card"
{
    PageType = Card;
    SourceTable = "Training Need";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
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
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Specific"; Rec."Employee Specific")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("From Appraisal"; Rec."From Appraisal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal Calender"; Rec."Calendar Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal Period"; Rec."Appraisal Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Supervisor; Rec.Supervisor)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Training Source"; Rec."Training Source")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Objective"; Rec."Training Objective")
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
            action(Import)
            {
                ApplicationArea = Basic, Suite;
                Image = Import;
                PromotedCategory = Process;
                Promoted = true;
                RunObject = xmlport "Training Needs";
            }
        }
    }
}
