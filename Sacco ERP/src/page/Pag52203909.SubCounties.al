page 52203909 "Sub Counties"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Sub Counties";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("County Code"; Rec."County Code")
                {
                    ApplicationArea = All;
                }
                field("Sub County Code"; Rec."Sub County Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sub County Name"; Rec."Sub County Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
