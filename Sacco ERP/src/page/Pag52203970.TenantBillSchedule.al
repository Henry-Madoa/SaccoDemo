page 52203970 "Tenant Bill Schedule"
{
    PageType = Card;
    SourceTable = "Tenant Bill Schedule";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Schedule No."; Rec."Schedule No.")
                {
                    ApplicationArea = All;
                }
                field("Schedule Date"; Rec."Schedule Date")
                {
                    ApplicationArea = All;
                }
                field("Tenant No."; Rec."Tenant No.")
                {
                    ApplicationArea = All;
                }
                field("Tenant Name"; Rec."Tenant Name")
                {
                    ApplicationArea = All;
                }
                field("Tenant Address"; Rec."Tenant Address")
                {
                    ApplicationArea = All;
                }
                field("Tenant Phone No."; Rec."Tenant Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Landlord No."; Rec."Landlord No.")
                {
                    ApplicationArea = All;
                }
                field("Landlord Name"; Rec."Landlord Name")
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
            }
            part(Control13; "Tenant Bill Schedule Lines")
            {
                SubPageLink = "Schedule No."=FIELD("Schedule No."), "Schedule Date"=FIELD("Schedule Date"), "Tenant No."=FIELD("Tenant No.");
            }
        }
    }
    actions
    {
    }
}
