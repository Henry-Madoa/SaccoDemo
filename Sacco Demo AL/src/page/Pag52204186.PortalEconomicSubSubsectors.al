page 52204186 "Portal Economic Sub-Subsectors"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Economic Sub-subsector";
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
                field("Sub-Subsector Code"; Rec."Sub-Subsector Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sub-Subsector Description"; Rec."Sub-Subsector Description")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
