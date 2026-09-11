page 52203562 "Committees"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = Committees;

    layout
    {
        area(content)
        {
            repeater(Control4)
            {
                ShowCaption = false;

                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Interview; Rec.Interview)
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
            action(Members)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Members';
                Image = PersonInCharge;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = Page "Committee Members";
                RunPageLink = Committee=FIELD(Code);
            }
        }
    }
}
