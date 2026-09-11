page 52203830 "Tender Mandatory Specification"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Mandatory Requirements";

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
                field("Requirement Description"; Rec."Requirement Description")
                {
                    ApplicationArea = All;
                }
                field("Max Weight"; Rec."Max Weight")
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
