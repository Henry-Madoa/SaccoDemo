codeunit 52203483 "Fleet Management"
{
    trigger OnRun()
    begin
    end;
    procedure SendNotificationOnBookingSubmission(var VehicleBookingRequest: Record "Vehicle Booking Request")
    var
        FleetManagementSetup: Record "Fleet Management Setup";
        SMTPMail: Codeunit Mail;
        Email: Codeunit Email;
        SenderName: Text;
        SenderAddress: Text;
        Recepient: Text;
        Subject: Text;
        Body: Text;
        Employee: Record Employee;
    begin
        FleetManagementSetup.Get;
        VehicleBookingRequest.Reset;
        VehicleBookingRequest.SetRange("No.", VehicleBookingRequest."No.");
        if VehicleBookingRequest.FindFirst then begin
            Employee.Reset;
            Employee.SetRange("No.", FleetManagementSetup."Fleet Officer");
            if Employee.FindFirst then begin
                Clear(Recepient);
                Clear(Subject);
                Clear(Body);
                Recepient:=Employee."E-Mail";
                Subject:='VEHICLE BOOKING REQUEST.';
                Body:='Dear' + ' ' + Format(Employee."First Name") + ',' + '<br>A vehicle booking request No:' + ' ' + Format(VehicleBookingRequest."No.") + ' ' + 'has been submitted to you by' + ' ' + Format(VehicleBookingRequest."Employee Name") + ' ' + 'for further action.' + '<br> Kindly attend to this matter.' + '<br><br>THIS IS A SYSTEM GENERATED EMAIL. DO NOT REPLY TO IT';
                if(SenderName <> '') and (SenderAddress <> '') and (Recepient <> '') and (Subject <> '') and (Body <> '')then begin
                    SMTPMail.CreateMessage(Recepient, '', '', Subject, Body, true, true);
                //SMTPMail.Send();
                end;
            end;
        end;
    end;
    procedure SendNotificationOnWorkFormRequestSubmission(var WorkTicketFormRequest: Record "WorkTicket Form Request")
    var
        FleetManagementSetup: Record "Fleet Management Setup";
        SMTPMailSetup: Record "Sent Email";
        SMTPMail: Codeunit Mail;
        Email: Codeunit Email;
        SenderName: Text;
        SenderAddress: Text;
        Recepient: Text;
        Subject: Text;
        Body: Text;
        Employee: Record Employee;
    begin
        FleetManagementSetup.Get;
        WorkTicketFormRequest.Reset;
        WorkTicketFormRequest.SetRange("No.", WorkTicketFormRequest."No.");
        if WorkTicketFormRequest.FindFirst then begin
            Employee.Reset;
            Employee.SetRange("No.", FleetManagementSetup."Fleet Officer");
            if Employee.FindFirst then begin
                Clear(Recepient);
                Clear(Subject);
                Clear(Body);
                Recepient:=Employee."E-Mail";
                Subject:='WORK TICKET FORM REQUEST.';
                Body:='Dear' + ' ' + Format(Employee."First Name") + ',' + '<br>A work ticket form request No:' + ' ' + Format(WorkTicketFormRequest."No.") + ' ' + 'has been submitted to you by' + ' ' + Format(WorkTicketFormRequest."Driver Name") + ' ' + 'for further action.' + '<br> Kindly attend to this matter.' + '<br><br>THIS IS A SYSTEM GENERATED EMAIL. DO NOT REPLY TO IT';
                if(SenderName <> '') and (SenderAddress <> '') and (Recepient <> '') and (Subject <> '') and (Body <> '')then begin
                    SMTPMail.CreateMessage(Recepient, '', '', Subject, Body, true, true);
                //SMTPMail.Send()
                end;
            end;
        end;
    end;
    procedure PostVehicleExpenses(var PostingDateParam: Date; var TransactionTypeParam: Option Fuel, Insurance, Maintenance; var DocumentNoParam: Code[20]; var PostDescriptionParam: Text; var AmountParam: Decimal; var AmountLCYParam: Decimal; var VehicleREGNoParam: Code[20])
    var
        MotorVehicleLedger: Record "Motor Vehicle Ledger";
    begin
        //with MotorVehicleLedger do begin
        MotorVehicleLedger.Reset;
        if MotorVehicleLedger.FindLast then MotorVehicleLedger."Entry No":=MotorVehicleLedger."Entry No";
        MotorVehicleLedger.Init;
        MotorVehicleLedger."Entry No"+=1000;
        MotorVehicleLedger."Posting Date":=PostingDateParam;
        MotorVehicleLedger."Transaction Type":=TransactionTypeParam;
        MotorVehicleLedger."Document No.":=DocumentNoParam;
        MotorVehicleLedger."Posting Description":=PostDescriptionParam;
        MotorVehicleLedger.Amount:=AmountParam;
        MotorVehicleLedger."Amount (LCY)":=AmountLCYParam;
        MotorVehicleLedger."Vehicle REG. No":=VehicleREGNoParam;
        MotorVehicleLedger.Insert;
    // end;
    end;
}
