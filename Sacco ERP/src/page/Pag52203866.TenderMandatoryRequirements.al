page 52203866 "Tender Mandatory Requirements"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Tender Mandatory Requirements";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Mandatory Code"; Rec."Mandatory Code")
                {
                    ApplicationArea = All;
                }
                field("Requirement Description"; Rec."Requirement Description")
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
