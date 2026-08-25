page 52204185 "Portal Economic Subsectors"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Economic Subsectors";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Sector Code"; Rec."Sector Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sub Sector Code"; Rec."Sub Sector Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sub Sector Name"; Rec."Sub Sector Name")
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
            action("Sub Subsectors")
            {
                ApplicationArea = Basic, Suite;
                Image = StepInto;
                RunObject = page "Economic Sub-Subsectors";
                RunPageLink = "Sector Code"=field("Sector Code"), "Sub Sector Code"=field("Sub Sector Code");
            }
        }
    }
}
