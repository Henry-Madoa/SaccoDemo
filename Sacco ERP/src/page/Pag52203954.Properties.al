page 52203954 "Properties"
{
    PageType = List;
    SourceTable = Properties;
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
                field("Property Code"; Rec."Property Code")
                {
                    ApplicationArea = All;
                }
                field("Property Name"; Rec."Property Name")
                {
                    ApplicationArea = All;
                }
                field("Property Manager"; Rec."Property Manager")
                {
                    ApplicationArea = All;
                }
                field("Manager Name"; Rec."Manager Name")
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
                field("Bill Water"; Rec."Bill Water")
                {
                    ApplicationArea = All;
                }
                field("Bill Electricity"; Rec."Bill Electricity")
                {
                    ApplicationArea = All;
                }
                field("Bill Other Amenities"; Rec."Bill Other Amenities")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Rec.Blocked)
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
            action("Open Property Units")
            {
                ApplicationArea = All;
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to open the property unit details?')then exit;
                    PropertyUnits.Reset;
                    PropertyUnits.SetRange("Property Code", Rec."Property Code");
                    PropertyUnits.SetRange("Landlord Code", Rec."Landlord Code");
                    if PropertyUnits.FindSet then begin
                        PAGE.RunModal(PAGE::"Property Units", PropertyUnits);
                    end
                    else
                    begin
                        Message('There are no units under this Property & Landlord');
                    end;
                end;
            }
        }
    }
    var PropertyUnits: Record "Property Units";
}
