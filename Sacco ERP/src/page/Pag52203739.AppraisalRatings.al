page 52203739 "Appraisal Ratings"
{
    PageType = List;
    SourceTable = "Appraisal Ratings";
    SourceTableView = SORTING(Percentage)ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Lower Limit"; Rec."Lower Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Upper Limit"; Rec."Upper Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
