page 52203958 "Property Unit"
{
    PageType = Card;
    SourceTable = "Property Units";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."Unit No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("General Description"; Rec."General Description")
                {
                    ApplicationArea = All;
                }
                field("Landlord Code"; Rec."Landlord Code")
                {
                    ApplicationArea = All;
                }
                field("Landlord Name"; Rec."Landlord Name")
                {
                    ApplicationArea = All;
                }
            }
            group(Property)
            {
                field("Property Type"; Rec."Property Type")
                {
                    ApplicationArea = All;
                }
                field("Property Code"; Rec."Property Code")
                {
                    ApplicationArea = All;
                }
                field("Property Name"; Rec."Property Name")
                {
                    ApplicationArea = All;
                }
                field("Floor Space (M2)"; Rec."Floor Space (M2)")
                {
                    ApplicationArea = All;
                }
                field("No. of Rooms"; Rec."No. of Rooms")
                {
                    ApplicationArea = All;
                }
                field("No. of Bedrooms"; Rec."No. of Bedrooms")
                {
                    ApplicationArea = All;
                }
                field("Floor No."; Rec."Floor No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Costs)
            {
                field("Deposit Amount"; Rec."Deposit Amount")
                {
                    ApplicationArea = All;
                }
                field("Rent Amount"; Rec."Rent Amount")
                {
                    ApplicationArea = All;
                }
                field("Water Deposit"; Rec."Water Deposit")
                {
                    ApplicationArea = All;
                }
                field("Electricity Deposit"; Rec."Electricity Deposit")
                {
                    ApplicationArea = All;
                }
                field("Other Deposits"; Rec."Other Deposits")
                {
                    ApplicationArea = All;
                }
                field("Expected Rent Date"; Rec."Expected Rent Date")
                {
                    ApplicationArea = All;
                }
                field("Late Payment Penalty %"; Rec."Late Payment Penalty %")
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
