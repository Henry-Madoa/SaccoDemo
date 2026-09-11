page 52203926 "Vehicle Mileage Tracking"
{
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    SourceTable = "Motor Vehicle Asset";

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
                field("Vehicle Make"; Rec."Vehicle Make")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Model"; Rec."Vehicle Model")
                {
                    ApplicationArea = All;
                }
                field("Mileage at Service (Kms)"; Rec."Mileage at Service (Kms)")
                {
                    ApplicationArea = All;
                }
                field("Current Mileage (Kms)"; Rec."Current Mileage (Kms)")
                {
                    ApplicationArea = All;
                }
                field("Distance From Service (Kms)"; Rec."Distance From Service (Kms)")
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
