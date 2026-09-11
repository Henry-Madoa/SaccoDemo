page 52203873 "Work Ticket Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Work Ticket";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group("General Details")
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field("WorkTicket Form No."; Rec."WorkTicket Form No.")
                {
                    ApplicationArea = All;
                }
                field("Fuel Log No."; Rec."Fuel Log No.")
                {
                    ApplicationArea = All;
                }
                field("Driver Emp. No."; Rec."Driver Emp. No.")
                {
                    ApplicationArea = All;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }
                field("Authorizing Officer"; Rec."Authorizing Officer")
                {
                    ApplicationArea = All;
                }
                field("Authorizing Officer Name"; Rec."Authorizing Officer Name")
                {
                    ApplicationArea = All;
                }
                field("Reason For Travel"; Rec."Reason For Travel")
                {
                    ApplicationArea = All;
                }
            }
            group("Journey Details")
            {
                field("Place Of Departure"; Rec."Place Of Departure")
                {
                    ApplicationArea = All;
                }
                field(Destination; Rec.Destination)
                {
                    ApplicationArea = All;
                }
                field("Departure Date"; Rec."Departure Date")
                {
                    ApplicationArea = All;
                    Caption = 'Departure Date/Time';
                }
                field("Arrival at Destination Date"; Rec."Arrival at Destination Date")
                {
                    ApplicationArea = All;
                    Caption = 'Arrival at Destination Date/Time';
                }
                field("Departure From Dest. Date"; Rec."Departure From Dest. Date")
                {
                    ApplicationArea = All;
                }
                field("Arrival Back Date"; Rec."Arrival Back Date")
                {
                    ApplicationArea = All;
                    Caption = 'Arrival Back Date/Time';
                }
                field("Duration of Travel (Days)"; Rec."Duration of Travel (Days)")
                {
                    ApplicationArea = All;
                }
                field("Mileage at Departure (Kms)"; Rec."Mileage at Departure (Kms)")
                {
                    ApplicationArea = All;
                }
                field("Mileage at Arrival (Kms)"; Rec."Mileage at Arrival (Kms)")
                {
                    ApplicationArea = All;
                }
                field("Mileage Covered (Kms)"; Rec."Mileage Covered (Kms)")
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
            action("Submit Work Ticket")
            {
                Image = SendConfirmation;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Submitted, false);
                    Rec.TestField("Mileage at Departure (Kms)");
                    Rec.TestField("Departure Date");
                    Rec.TestField(Destination);
                    Rec.TestField("Reason For Travel");
                    Rec.TestField("Mileage at Arrival (Kms)");
                    Rec.TestField("Arrival Back Date");
                    Rec.TestField("WorkTicket Form No.");
                    if not Confirm('Are you sure you want to submit the work ticket?')then exit;
                    WorkTicketFormRequest.Reset;
                    WorkTicketFormRequest.SetRange("No.", Rec."WorkTicket Form No.");
                    if WorkTicketFormRequest.FindFirst then begin
                        WorkTicketFormRequestLines.Reset;
                        if WorkTicketFormRequestLines.FindLast then WorkTicketFormRequestLines."Line No.":=WorkTicketFormRequestLines."Line No.";
                        WorkTicketFormRequestLines.Init;
                        WorkTicketFormRequestLines."Document No.":=Rec."WorkTicket Form No.";
                        WorkTicketFormRequestLines."Line No."+=10;
                        WorkTicketFormRequestLines.Date:=Rec."Departure Date";
                        WorkTicketFormRequestLines."Work Ticket No.":=Rec."No.";
                        WorkTicketFormRequestLines."Driver No.":=Rec."Driver Emp. No.";
                        WorkTicketFormRequestLines.Validate("Driver No.");
                        WorkTicketFormRequestLines."Place Of Departure":=Rec."Place Of Departure";
                        WorkTicketFormRequestLines.Destination:=Rec.Destination;
                        WorkTicketFormRequestLines."Reason For Travel":=Rec."Reason For Travel";
                        WorkTicketFormRequestLines."Authorizing Officer":=Rec."Authorizing Officer";
                        WorkTicketFormRequestLines.Validate("Authorizing Officer");
                        WorkTicketFormRequestLines."Fuel Log No.":=Rec."Fuel Log No.";
                        WorkTicketFormRequestLines.Validate("Fuel Log No.");
                        WorkTicketFormRequestLines."Date In":=Rec."Arrival Back Date";
                        WorkTicketFormRequestLines."Time Out":=Rec."Departure Time";
                        WorkTicketFormRequestLines."Time In":=Rec."Arrival Back Time";
                        WorkTicketFormRequestLines."Mileage at Start (kms)":=Rec."Mileage at Departure (Kms)";
                        WorkTicketFormRequestLines."Mileage at End (kms)":=Rec."Mileage at Arrival (Kms)";
                        WorkTicketFormRequestLines."Distance Travelled (kms)":=Rec."Mileage Covered (Kms)";
                        if WorkTicketFormRequestLines.Insert then begin
                            Rec.Submitted:=true;
                            Rec.Modify(true);
                            Message('Work Ticket has been submitted successfully');
                            WorkTicketFormRequestLines.Reset;
                            WorkTicketFormRequestLines.SetRange("Document No.", WorkTicketFormRequest."No.");
                            if WorkTicketFormRequestLines.FindSet then begin
                                FleetManagementSetup.Get;
                                if WorkTicketFormRequestLines.Count = FleetManagementSetup."WorkTicket Form Limit" then begin
                                    WorkTicketFormRequest.Completed:=true;
                                    WorkTicketFormRequest.Modify(true);
                                end;
                            end;
                        end;
                    end;
                    UpdateMileage(Rec);
                    CurrPage.Close;
                end;
            }
        }
    }
    var WorkTicketFormRequest: Record "WorkTicket Form Request";
    WorkTicketFormRequestLines: Record "WorkTicket Form Request Lines";
    FleetManagementSetup: Record "Fleet Management Setup";
    procedure UpdateMileage(var WorkTicket: Record "Work Ticket")
    var
        MotorVehicleAsset: Record "Motor Vehicle Asset";
    begin
        //with WorkTicket do begin
        MotorVehicleAsset.Reset;
        MotorVehicleAsset.SetRange("No.", WorkTicket."Vehicle REG. No.");
        if MotorVehicleAsset.FindFirst then begin
            MotorVehicleAsset."Current Mileage (Kms)":=WorkTicket."Mileage at Arrival (Kms)";
            MotorVehicleAsset.Modify(true);
        end;
    // end;
    end;
}
