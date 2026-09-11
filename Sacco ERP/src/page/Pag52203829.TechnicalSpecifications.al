page 52203829 "Technical Specifications"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Technical Specifications";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Requirement Code"; Rec."Requirement Code")
                {
                    ApplicationArea = All;
                }
                field("Requirement Specification"; Rec."Requirement Specification")
                {
                    ApplicationArea = All;
                }
                field("Max Weigth"; Rec."Max Weigth")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
}
