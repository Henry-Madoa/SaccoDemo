page 52203871 "Fleet Management Setup"
{
    ApplicationArea = All;
    PageType = Card;
    DeleteAllowed = false;
    SourceTable = "Fleet Management Setup";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("WorkTicket Form Limit"; Rec."WorkTicket Form Limit")
                {
                    ApplicationArea = All;
                }
                field("Fleet Officer"; Rec."Fleet Officer")
                {
                    ApplicationArea = All;
                }
                field("Servicing Mileage (Kms)"; Rec."Servicing Mileage (Kms)")
                {
                    ApplicationArea = All;
                }
            }
            group(Numbering)
            {
                field("Insurance Nos"; Rec."Insurance Nos")
                {
                    ApplicationArea = All;
                }
                field("Work Ticket Nos"; Rec."Work Ticket Nos")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Repair Nos"; Rec."Vehicle Repair Nos")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Booking Nos"; Rec."Vehicle Booking Nos")
                {
                    ApplicationArea = All;
                }
                field("Fuel Log Nos"; Rec."Fuel Log Nos")
                {
                    ApplicationArea = All;
                }
                field("Fuel Top-Up Nos"; Rec."Fuel Top-Up Nos")
                {
                    ApplicationArea = All;
                }
                field("WorkTicket Request Nos"; Rec."WorkTicket Request Nos")
                {
                    ApplicationArea = All;
                }
                field("Service Proforma Nos"; Rec."Service Proforma Nos")
                {
                    ApplicationArea = All;
                }
                field("Service Part Nos"; Rec."Service Part Nos")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
    trigger OnOpenPage()
    var
        FleetMgmtSetup: Record "Fleet Management Setup";
    begin
        if FleetMgmtSetup.IsEmpty then begin
            FleetMgmtSetup.Init();
            FleetMgmtSetup.Insert(true);
        end;
    end;
}
