page 52203870 "Motor Vehicle Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Motor Vehicle Asset";
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
                field("Vehicle Make"; Rec."Vehicle Make")
                {
                    ApplicationArea = All;
                }
                field("Vehicle Model"; Rec."Vehicle Model")
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
                field("Responsible Employee No"; Rec."Responsible Employee No")
                {
                    ApplicationArea = All;
                }
                field("Responsible Employee Name"; Rec."Responsible Employee Name")
                {
                    ApplicationArea = All;
                }
            }
            group("Purchase Details")
            {
                field("Purchase Date"; Rec."Purchase Date")
                {
                    ApplicationArea = All;
                }
                field("Purchase Price"; Rec."Purchase Price")
                {
                    ApplicationArea = All;
                }
                field("Buy From Vendor"; Rec."Buy From Vendor")
                {
                    ApplicationArea = All;
                }
                field("Buy From Vendor Name"; Rec."Buy From Vendor Name")
                {
                    ApplicationArea = All;
                }
            }
            group("Insurance Details")
            {
                field("Document Code"; Rec."Document Code")
                {
                    ApplicationArea = All;
                }
                field("Insurance Document No."; Rec."Insurance Document No.")
                {
                    ApplicationArea = All;
                }
                field("Insurance Date"; Rec."Insurance Date")
                {
                    ApplicationArea = All;
                }
                field("Insurance Expiry Date"; Rec."Insurance Expiry Date")
                {
                    ApplicationArea = All;
                }
                field("Insurance Cover Type"; Rec."Insurance Cover Type")
                {
                    ApplicationArea = All;
                }
                field("Insurance Vendor"; Rec."Insurance Vendor")
                {
                    ApplicationArea = All;
                }
                field("Insurance Vendor Name"; Rec."Insurance Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Insurance Amount"; Rec."Insurance Amount")
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
            action("Fuel Expense Report")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.FindFirst then begin
                        MotorVehicleLedger.Reset;
                        MotorVehicleLedger.SetRange("Vehicle REG. No", Rec."No.");
                        if MotorVehicleLedger.FindSet then begin
                            REPORT.RunModal(60101, true, false, MotorVehicleLedger);
                        end;
                    end;
                end;
            }
            action("Maintenance Expense Report")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.FindFirst then begin
                        MotorVehicleLedger.Reset;
                        MotorVehicleLedger.SetRange("Vehicle REG. No", Rec."No.");
                        if MotorVehicleLedger.FindSet then begin
                            REPORT.RunModal(60102, true, false, MotorVehicleLedger);
                        end;
                    end;
                end;
            }
            action("Insurance Expense Report")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.FindFirst then begin
                        MotorVehicleLedger.Reset;
                        MotorVehicleLedger.SetRange("Vehicle REG. No", Rec."No.");
                        if MotorVehicleLedger.FindSet then begin
                            REPORT.RunModal(60103, true, false, MotorVehicleLedger);
                        end;
                    end;
                end;
            }
        }
    }
    var MotorVehicleLedger: Record "Motor Vehicle Ledger";
}
