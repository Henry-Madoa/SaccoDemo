page 52204127 "Economic Sector"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Economic Sectors";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Sector Code"; Rec."Sector Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sector Name"; Rec."Sector Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("Subsectors"; "Economic Subsectors")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Sector Code"=field("Sector Code");
            }
        }
    }
}
