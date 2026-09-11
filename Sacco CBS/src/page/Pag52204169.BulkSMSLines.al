page 52204169 "Bulk SMS Lines"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Bulk SMS Lines";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Phone No"; Rec."Phone No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Sent; Rec.Sent)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
