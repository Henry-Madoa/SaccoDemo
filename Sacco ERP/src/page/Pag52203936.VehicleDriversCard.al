page 52203936 "Vehicle Drivers Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Motor Vehicle Drivers Data";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Employment No."; Rec."Employment No.")
                {
                    ApplicationArea = All;
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = All;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                }
                field("ID No."; Rec."ID No.")
                {
                    ApplicationArea = All;
                }
                field("D.O.B"; Rec."D.O.B")
                {
                    ApplicationArea = All;
                }
                field("Driving License No."; Rec."Driving License No.")
                {
                    ApplicationArea = All;
                }
                field("Driving License Issue Date"; Rec."Driving License Issue Date")
                {
                    ApplicationArea = All;
                }
                field("License Use Duration"; Rec."License Use Duration")
                {
                    ApplicationArea = All;
                }
                field("Driving License Expiry Date"; Rec."Driving License Expiry Date")
                {
                    ApplicationArea = All;
                }
                field("Driving License Type"; Rec."Driving License Type")
                {
                    ApplicationArea = All;
                }
                field("Date of Employment"; Rec."Date of Employment")
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
            action("Print Driver Report")
            {
                ApplicationArea = All;
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    MotorVehicleDriversData.Reset;
                    MotorVehicleDriversData.SetRange("Employment No.", Rec."Employment No.");
                    if MotorVehicleDriversData.FindFirst then begin
                        REPORT.RunModal(60108, true, false, MotorVehicleDriversData);
                    end;
                end;
            }
        }
    }
    var MotorVehicleDriversData: Record "Motor Vehicle Drivers Data";
}
