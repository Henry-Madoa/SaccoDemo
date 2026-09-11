page 52203912 "Vehicle Insurance - Expired"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Vehicle Insurance";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

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
