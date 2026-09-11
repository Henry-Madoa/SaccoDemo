page 52203929 "Posted Vehicle Insurance"
{
    ApplicationArea = All;
    CardPageID = "Vehicle Insurance Card";
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    SourceTable = "Vehicle Insurance";
    SourceTableView = WHERE(Expired=CONST(false), Posted=CONST(true));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Insurance No."; Rec."Insurance No.")
                {
                    ApplicationArea = All;
                }
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field("Insurance Company Name"; Rec."Insurance Company Name")
                {
                    ApplicationArea = All;
                }
                field("Type Of Cover"; Rec."Type Of Cover")
                {
                    ApplicationArea = All;
                }
                field("Insurance Date"; Rec."Insurance Date")
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
