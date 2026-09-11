pageextension 52203460 "Fixed Asset Card" extends "Fixed Asset Card"
{
    layout
    {
        modify("FA Location Code")
        {
            ShowMandatory = true;
        }
        modify("Maintenance Vendor No.")
        {
            ShowMandatory = true;
        }
        addafter("FA Location Code")
        {
            field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Asset Type"; Rec."Asset Type")
            {
                ApplicationArea = All;
            }
        }
        addafter("Serial No.")
        {
            field("Asset Tag"; Rec."Asset Tag")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter(General)
        {
            group("Motor Vehicle")
            {
                Visible = Rec."Asset Type" = Rec."Asset Type"::"Motor Vehicle";

                field("Vehicle Make"; Rec."Vehicle Make")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Model"; Rec."Vehicle Model")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Registration No."; Rec."Vehicle Registration No.")
                {
                    ApplicationArea = All;
                }
                field(Color; Rec.Color)
                {
                    ApplicationArea = All;
                }
                field("Frame No."; Rec."Frame No.")
                {
                    ApplicationArea = All;
                }
                field("Engine No."; Rec."Engine No.")
                {
                    ApplicationArea = All;
                }
                field("Log Book No."; Rec."Log Book No.")
                {
                    ApplicationArea = All;
                }
                field("Year Of Manufacture"; Rec."Year Of Manufacture")
                {
                    ApplicationArea = All;
                }
                field("Load Limit (KGS)"; Rec."Load Limit (KGS)")
                {
                    ApplicationArea = All;
                }
                field("Passenger Capacity"; Rec."Passenger Capacity")
                {
                    ApplicationArea = All;
                }
                field("Fuel Capacity"; Rec."Fuel Capacity")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        FADepreciate: Record "FA Depreciation Book";
    begin
        if (Rec.Acquired = true) and (Rec.Inactive = false) then begin
            FADepreciate.Reset();
            FADepreciate.SetRange("FA No.", Rec."No.");
            if FADepreciate.FindFirst() then if (FADepreciate."Depreciation Starting Date" = 0D) and (FADepreciate."Depreciation Ending Date" = 0D) then Message('Kindly confirm that all fields in the Depreciation Book Tab are captured.');
        end;
    end;
}
