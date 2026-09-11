page 52203956 "Property Units"
{
    CardPageID = "Property Unit";
    PageType = List;
    SourceTable = "Property Units";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."Unit No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
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
                field("Landlord Code"; Rec."Landlord Code")
                {
                    ApplicationArea = All;
                }
                field("Landlord Name"; Rec."Landlord Name")
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
