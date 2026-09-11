page 52203744 "Competence Categories"
{
    PageType = List;
    SourceTable = "Competence Categories";

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
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Weigth"; Rec."Maximum Weigth")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
