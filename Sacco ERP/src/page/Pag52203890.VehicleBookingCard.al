page 52203890 "Vehicle Booking Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Vehicle Booking Request";
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
                    Editable = false;
                }
                field("Requisition Date"; Rec."Requisition Date")
                {
                    ApplicationArea = All;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                }
                field(Destination; Rec.Destination)
                {
                    ApplicationArea = All;
                }
                field("Reason For Request"; Rec."Reason For Request")
                {
                    ApplicationArea = All;
                }
                field("Number Of Travellers"; Rec."Number Of Travellers")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(Department; Rec.Department)
                {
                    ApplicationArea = All;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
                field("Expected Return Date"; Rec."Expected Return Date")
                {
                    ApplicationArea = All;
                }
                field(Submitted; Rec.Submitted)
                {
                    ApplicationArea = All;
                }
                field("Capacity of Assigned Vehicles"; Rec."Capacity of Assigned Vehicles")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part("Vehicles Assignment"; "Vehicle Booking Request Lines")
            {
                ApplicationArea = All;
                Caption = 'Vehicles Assignment';
                SubPageLink = "Requisition No."=FIELD("No.");
                Visible = SubPageVisibility;
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Submit Booking Request")
            {
                ApplicationArea = All;
                Image = SendTo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Submitted, false);
                    Rec.TestField(Department);
                    Rec.TestField(Destination);
                    Rec.TestField("Reason For Request");
                    Rec.TestField("Number Of Travellers");
                    if not Confirm('Are you sure you want to submit the booking request?')then exit;
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.FindFirst then begin
                        Rec.Submitted:=true;
                        if Rec.Modify(true)then begin
                            FleetManagement.SendNotificationOnBookingSubmission(Rec);
                            Message('Booking request has been submitted successfully');
                        end;
                    end;
                    CurrPage.Close;
                end;
            }
            action("Send Approval Request")
            {
                ApplicationArea = All;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::New);
                    Rec.TestField(Submitted, true);
                    if not Confirm('Are you sure you want to send the vehicle booking request for approval?')then exit;
                    VehicleBookingRequestLines.Reset;
                    VehicleBookingRequestLines.SetRange("Requisition No.", Rec."No.");
                    if VehicleBookingRequestLines.FindSet then begin
                        VehicleBookingRequestLines.CalcSums("Passenger Capacity");
                        TotalPassengers:=VehicleBookingRequestLines."Passenger Capacity";
                        if Rec."Number Of Travellers" > TotalPassengers then Error('The number of passengers exceed the vehicle capacity');
                    end;
                    Rec.Status:=Rec.Status::Approved;
                    Rec.Modify;
                    // IF ApprovalsMgmt.CheckBookingRequisitionApprovalsWorkflowEnabled(Rec) THEN
                    //  ApprovalsMgmt.OnSendBookingRequisitionForApproval(Rec);
                    CurrPage.Close;
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = All;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    if not Confirm('Are you sure you want to cancel the vehicle booking request?')then exit;
                    Rec.Status:=Rec.Status::New;
                    Rec.Modify;
                    // IF ApprovalsMgmt.CheckBookingRequisitionApprovalsWorkflowEnabled(Rec) THEN
                    //  ApprovalsMgmt.OnCancelBookingRequisitionApprovalRequest(Rec);
                    CurrPage.Close;
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        LineVisibility;
    end;
    var SubPageVisibility: Boolean;
    FleetManagement: Codeunit "Fleet Management";
    VehicleBookingRequestLines: Record "Vehicle Booking Request Lines";
    VehicleBookingRequest: Record "Vehicle Booking Request";
    TotalPassengers: Integer;
    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    procedure LineVisibility(): Boolean begin
        SubPageVisibility:=false;
        case Rec.Submitted of true: begin
            SubPageVisibility:=true;
        end;
        false: begin
            SubPageVisibility:=false;
        end;
        end;
    end;
}
