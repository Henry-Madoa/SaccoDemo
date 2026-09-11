page 52203906 "Vehicle Booking Request Lines"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    PageType = ListPart;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    SourceTable = "Vehicle Booking Request Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Make"; Rec."Vehicle Make")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Model"; Rec."Vehicle Model")
                {
                    ApplicationArea = All;
                }
                field("Fuel Capacity"; Rec."Fuel Capacity")
                {
                    ApplicationArea = All;
                }
                field("Passenger Capacity"; Rec."Passenger Capacity")
                {
                    ApplicationArea = All;
                }
                field("Last Recorded Mileage (kms)"; Rec."Last Recorded Mileage (kms)")
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
