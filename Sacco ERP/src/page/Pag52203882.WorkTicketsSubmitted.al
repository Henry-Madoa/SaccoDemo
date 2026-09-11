page 52203882 "Work Tickets - Submitted"
{
    ApplicationArea = All;
    CardPageID = "Work Ticket Card";
    PageType = List;
    SourceTable = "Work Ticket";
    SourceTableView = WHERE(Submitted=CONST(true));
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
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }
                field(Destination; Rec.Destination)
                {
                    ApplicationArea = All;
                }
                field("Departure Date"; Rec."Departure Date")
                {
                    ApplicationArea = All;
                }
                field("Arrival Back Date"; Rec."Arrival Back Date")
                {
                    ApplicationArea = All;
                }
                field(Submitted; Rec.Submitted)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
        }
    }
}
