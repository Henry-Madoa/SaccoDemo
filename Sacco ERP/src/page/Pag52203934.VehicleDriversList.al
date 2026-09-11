page 52203934 "Vehicle Drivers List"
{
    ApplicationArea = All;
    CardPageID = "Vehicle Drivers Card";
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    SourceTable = "Motor Vehicle Drivers Data";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employment No."; Rec."Employment No.")
                {
                    ApplicationArea = All;
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = All;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                }
                field("Driving License No."; Rec."Driving License No.")
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
