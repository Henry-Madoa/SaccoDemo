page 52203907 "Counties"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = Counties;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("County Code"; Rec."County Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
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
            action("Sub Counties")
            {
                ApplicationArea = Basic, Suite;
                Image = CountryRegion;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Ellipsis = true;
                Scope = Repeater;
                RunObject = page "Sub Counties";
                RunPageLink = "County Code"=field("County Code");
            }
        }
    }
}
