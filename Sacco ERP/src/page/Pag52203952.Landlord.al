page 52203952 "Landlord"
{
    PageType = Card;
    SourceTable = Landlords;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                }
                field("PIN No."; Rec."PIN No.")
                {
                    ApplicationArea = All;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
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
            action("View Properties")
            {
                ApplicationArea = All;
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to view the landlord properties?')then exit;
                    Properties.Reset;
                    Properties.SetRange("Landlord Code", Rec."No.");
                    if Properties.FindSet then begin
                        PAGE.RunModal(PAGE::Properties, Properties);
                    end;
                end;
            }
            action("View Tenants")
            {
                ApplicationArea = All;
                Image = ViewDocumentLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to view the landlord tenants?')then exit;
                    TenantBooking.Reset;
                    TenantBooking.SetRange("Landlord Code", Rec."No.");
                    TenantBooking.SetRange("Tenancy Status", TenantBooking."Tenancy Status"::Active);
                    if TenantBooking.FindSet then begin
                        PAGE.RunModal(PAGE::"Tenant Bookings", TenantBooking);
                    end;
                end;
            }
        }
    }
    var Properties: Record Properties;
    TenantBooking: Record "Tenant Booking";
}
