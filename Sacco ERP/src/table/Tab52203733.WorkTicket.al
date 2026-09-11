table 52203733 "Work Ticket"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Vehicle REG. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Motor Vehicle Asset"."No.";
        }
        field(3; "Driver Emp. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Motor Vehicle Drivers Data"."Employment No.";

            trigger OnValidate()
            begin
                if MotorVehicleDriversData.Get("Driver Emp. No.")then begin
                    "Driver Name":=MotorVehicleDriversData."First Name" + ' ' + MotorVehicleDriversData."Middle Name" + ' ' + MotorVehicleDriversData."Last Name";
                end;
            end;
        }
        field(4; "Driver Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Destination; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Reason For Travel"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Departure Date"; DateTime)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Departure Date" > CurrentDateTime then Error('The departure date cannot cannot be a future date');
            end;
        }
        field(8; "Departure Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(10; "Mileage at Departure (Kms)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Arrival at Destination Date"; DateTime)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Departure Date");
                if "Arrival at Destination Date" <> 0DT then begin
                    if "Arrival at Destination Date" <= "Departure Date" then Error('The arrival at destination cannot be before or equal to departure date/time');
                end;
            end;
        }
        field(12; "Arrival at Destination Time"; DateTime)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
            // TESTFIELD("Arrival at Destination Date");
            // // TESTFIELD("Departure Time");
            // IF "Arrival at Destination Date" < "Departure Date" THEN BEGIN
            // //  IF "Arrival at Destination Time" < "Departure Time" THEN
            //    ERROR('The arrival at destination time cannot be earlier than departure time');
            //  END;
            end;
        }
        field(13; "Departure From Dest. Date"; DateTime)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Arrival at Destination Date");
                if "Departure From Dest. Date" <> 0DT then begin
                    if "Departure From Dest. Date" <= "Arrival at Destination Date" then Error('The departure from destination cannot be before or equal to arrival at destination date/time');
                end;
            end;
        }
        field(14; "Departure From Dest. Time"; DateTime)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
            // TESTFIELD("Departure From Dest. Date");
            // TESTFIELD("Arrival at Destination Time");
            // IF "Departure From Dest. Date" = "Arrival at Destination Date" THEN BEGIN
            //  IF "Departure From Dest. Time" < "Arrival at Destination Time" THEN
            //    ERROR('The departure from destination time cannot be earlier than the arrival at destination time');
            //  END;
            end;
        }
        field(15; "Arrival Back Date"; DateTime)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Departure From Dest. Date");
                if "Departure From Dest. Date" <> 0DT then begin
                    if "Arrival Back Date" <= "Departure From Dest. Date" then Error('The arrival back date cannot be earlier or equal to the departure from destination date/time');
                end;
                // "Duration of Travel (Days)" := ("Arrival Back Date" - "Departure Date") + 1;
                DaysTravelled:=("Arrival Back Date" - "Departure Date") / 86400000;
                "Duration of Travel (Days)":=Round(DaysTravelled, 2);
            end;
        }
        field(16; "Arrival Back Time"; DateTime)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
            // TESTFIELD("Arrival Back Date");
            // TESTFIELD("Departure Time");
            // IF "Departure From Dest. Time" <> 0T THEN BEGIN
            //  IF "Arrival Back Date" = "Departure From Dest. Date" THEN BEGIN
            //    IF "Arrival Back Time" < "Departure From Dest. Time" THEN
            //      ERROR('The arrival back time cannot be earlier than departure from destination time');
            //  END;
            // END;
            // IF "Arrival Back Date" = "Departure Date" THEN BEGIN
            //  IF "Arrival Back Time" < "Departure Time" THEN
            //    ERROR('The arrival back time cannot be earlier than departure time');
            //  END;
            end;
        }
        field(17; "Mileage at Arrival (Kms)"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Mileage at Departure (Kms)");
                if "Mileage at Arrival (Kms)" < "Mileage at Departure (Kms)" then Error('Mileage at departure cannot be less than mileage at the arrival');
                "Mileage Covered (Kms)":="Mileage at Arrival (Kms)" - "Mileage at Departure (Kms)";
            end;
        }
        field(18; "Mileage Covered (Kms)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Duration of Travel (Days)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(20; Submitted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "WorkTicket Form No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "WorkTicket Form Request"."No." WHERE("Vehicle REG. No."=FIELD("Vehicle REG. No."), Status=CONST(Approved), Completed=CONST(false));

            trigger OnValidate()
            begin
            // WorkTicketFormRequest.RESET;
            // WorkTicketFormRequest.SETRANGE("No.","WorkTicket Form No.");
            // IF WorkTicketFormRequest.FINDFIRST THEN BEGIN
            //  WorkTicketFormRequestLines.RESET;
            //  WorkTicketFormRequestLines.SETRANGE("Document No.",WorkTicketFormRequest."No.");
            //  IF WorkTicketFormRequestLines.FINDSET THEN BEGIN
            //    IF WorkTicketFormRequestLines.COUNT > 2 THEN BEGIN
            //      ERROR('The Work Ticket form has reached the required limit. Kindly apply for a new Work Ticket Form.');
            //      END;
            //    END;
            //  END;
            end;
        }
        field(24; "Authorizing Officer"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Authorizing Officer")then begin
                    "Authorizing Officer Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
                end;
            end;
        }
        field(25; "Authorizing Officer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Place Of Departure"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Fuel Log No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Fuel Requisition"."No." WHERE("Vehicle REG. No."=FIELD("Vehicle REG. No."), Posted=CONST(true));
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            FleetManagementSetup.Get;
            FleetManagementSetup.TestField("Work Ticket Nos");
            NoSeriesManagement.InitSeries(FleetManagementSetup."Work Ticket Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
        "Created On":=Today;
        "Created By":=UserId;
        //ERROR('Destination Date %1, Destination Time %2 ',"Departure From Dest. Date","Departure From Dest. Time");
        // IF IansoftFactory.FnIsWebServiceUser(USERID) THEN BEGIN
        Validate("Arrival Back Date");
        Validate("Mileage at Arrival (Kms)");
    //  END;
    end;
    var FleetManagementSetup: Record "Fleet Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    Employee: Record Employee;
    WorkTicketFormRequest: Record "WorkTicket Form Request";
    WorkTicketFormRequestLines: Record "WorkTicket Form Request Lines";
    MotorVehicleDriversData: Record "Motor Vehicle Drivers Data";
    DaysTravelled: Decimal;
//IansoftFactory: Codeunit IansoftFactory;
}
