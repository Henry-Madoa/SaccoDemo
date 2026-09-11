codeunit 52203485 "Communications Mgmt"
{
    var CompInfo: Record "Company Information";
    Subject: Text;
    Recipients: List of[Text];
    SMSRecipients: List of[Text];
    Body: Text;
    SMSBody: Text;
    Employee: array[3]of Record Employee;
    procedure SendSMSNotification(PhoneNumbers: List of[Text]; SMSMessage: Text; SMSSource: Code[20])
    var
        ListIndex: Integer;
        Recipients: Integer;
        PhoneNo: Text;
    begin
        Recipients:=PhoneNumbers.Count;
        ListIndex:=1;
        while Recipients >= ListIndex do begin
            PhoneNumbers.Get(ListIndex, PhoneNo);
            OnSendSMSNotification(PhoneNo, SMSMessage, SMSSource);
            ListIndex:=ListIndex + 1;
        end;
    end;
    procedure SendEmailWithoutAttachement(Recipients: List of[Text]; Subject: Text; Body: Text)
    var
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
        Count: Integer;
    begin
        Count:=Recipients.Count();
        if((Subject <> '') and (Body <> '') and (Count > 0))then begin
        // Mail.Create(Recipients, Subject, Body, true);
        // Email.Send(Mail);
        end;
    end;
    procedure SendEmailWithAttachement(Recipients: List of[Text]; Subject: Text; Body: Text; AttachmentName: Text; AttachmentType: Option PDF, Excel, Word; inStreamReport: InStream)
    var
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
    begin
        if((Subject <> '') and (Body <> '') and (Recipients.Count <> 0))then begin
            //Mail.Create(Recipients, Subject, Body, true);
            case AttachmentType of AttachmentType::PDF: Mail.AddAttachment(AttachmentName + '.pdf', 'PDF', inStreamReport);
            AttachmentType::Excel: Mail.AddAttachment(AttachmentName + '.xlsx', 'Excel', inStreamReport);
            AttachmentType::Word: Mail.AddAttachment(AttachmentName + '.docx', 'Word', inStreamReport);
            end;
        //Email.Send(Mail);
        end;
    end;
    procedure EmployeeTraininingReminder(TrainingApp: Record "Training Application")
    begin
        with TrainingApp do begin
            Clear(Recipients);
            Subject:='';
            Body:='';
            CompInfo.Get;
            Employee[1].Get("Employee No");
            Subject:='TRAINING REMINDER';
            Body+='Hello, ' + Employee[1].FullName;
            Body+='<br><br>';
            Body+=StrSubstNo('This is to bring to your notice that there is a Training (%1) supposed to start in a Week time.', "No.");
            Body+='<br><br>';
            Body+=StrSubstNo('Start Date: <b>%1</b>, End Date: <b>%2</b>', Format("Start Date"), Format("End Date"));
            Body+='<br><br>';
            Body+='Kindly plan and prepare accordingly.';
            Body+='<br><br>';
            Body+='Thank you.';
            Body+='<br><br>';
            Body+='Yours Sincerely,';
            Body+='<br><br>';
            Body+='<b>Human Resources and Administration<b>';
            Body+='<br>';
            Body+=CompInfo.Name;
            SendEmailWithoutAttachement(Recipients, Subject, Body);
            "Notification Sent":=true;
            Modify(true);
        end;
    end;
    procedure SupervisorLeaveApplicationNotification(LeaveApp: Record "Leave Applications")
    begin
        with LeaveApp do begin
            CompInfo.Get;
            Clear(Recipients);
            Subject:='';
            Body:='';
            CompInfo.Get;
            Employee[1].Get("Employee No");
            Employee[1].TestField("Company E-Mail");
            Employee[1].TestField("Manager No.");
            Employee[2].Get(Employee[1]."Manager No.");
            Subject:='LEAVE APPROVAL NOTIFICATION';
            Body+='Hello, ' + Employee[2].FullName;
            Body+='<br><br>';
            Body+=StrSubstNo('This is to bring to your notice that %1 have submitted Leave Application %2 for Approval', Employee[1].FullName, "No.");
            Body+='<br><br>';
            Body+=StrSubstNo('Start Date: <b>%1</b>, End Date: <b>%2</b>', Format("Start Date"), Format("End Date"));
            Body+='<br><br>';
            Body+='Thank you.';
            Body+='<br><br>';
            Body+='Yours Sincerely,';
            Body+='<br><br>';
            Body+='<b>Human Resources and Administration<b>';
            Body+='<br>';
            Body+=CompInfo.Name;
            SendEmailWithoutAttachement(Recipients, Subject, Body);
        end;
    end;
    procedure NotificationOnImprestDisbursement(RequestHeader: Record "Request Header")
    begin
        with RequestHeader do begin
            CompInfo.Get;
            Clear(Recipients);
            Clear(SMSRecipients);
            Subject:='';
            Body:='';
            SMSBody:='';
            Employee[1].Get("Employee No.");
            Employee[1].TestField("Company E-Mail");
            Employee[1].TestField("Phone No.");
            Recipients.Add(Employee[1]."Company E-Mail");
            SMSRecipients.Add(Employee[1]."Phone No.");
            //Send SMS
            SMSBody+=StrSubstNo('Dear %1', UpperCase(Employee[1].FullName));
            SMSBody+=StrSubstNo(' KSH %1 have been credited to your FOSA Account for %2.', Format("Total Requested Amount"), Description);
            SendSMSNotification(SMSRecipients, SMSBody, 'Imprest');
            //Send Email
            Subject:='IMPREST DISBURSEMENT';
            CalcFields("Total Requested Amount");
            Body+='<span style="font-family: Calibri; color: #5B9BD5; font-size: 11pt>';
            Body+='<span style="font-family: Calibri; color: #5B9BD5; font-size: 11pt>';
            Body+=StrSubstNo('Dear %1', Employee[1].FullName);
            Body+='<br><br>';
            Body+=StrSubstNo('<p>This is to bring to your notice that your Imprest Request No.: %1 have been disbursed and KSH %2 credited to your FOSA Account</p>', "No.", Format("Total Requested Amount"));
            Body+='<br><br>';
            Body+='Yours Sincerely,';
            Body+='<br><br>';
            Body+='<b>Finance Department<b>';
            Body+='<br>';
            Body+=CompInfo.Name;
            SendEmailWithoutAttachement(Recipients, Subject, Body);
        end;
    end;
    procedure NotificationOnPaymentVoucherDisbursement(PVHeader: Record "Payment Voucher")
    var
        PaymentSchedule: Record "Payment Schedule";
    begin
        CompInfo.Get;
        PaymentSchedule.Reset;
        PaymentSchedule.SetRange("PV No.", PVHeader."No.");
        if PaymentSchedule.FindSet then begin
            repeat with PaymentSchedule do begin
                    Clear(Recipients);
                    Clear(SMSRecipients);
                    Subject:='';
                    Body:='';
                    SMSBody:='';
                    Employee[1].Get("Employee No");
                    if((Employee[1]."Company E-Mail" <> '') and (Employee[1]."Phone No." <> ''))then begin
                        Recipients.Add(Employee[1]."Company E-Mail");
                        SMSRecipients.Add(Employee[1]."Phone No.");
                        //Send SMS
                        SMSBody+=StrSubstNo('Dear %1', UpperCase(Employee[1].FullName));
                        SMSBody+=StrSubstNo(' KSH %1 has been credited to your FOSA Account for %2.', Format(Amount), PVHeader.Description);
                        SendSMSNotification(SMSRecipients, SMSBody, 'Allowances');
                        //Send Email
                        if "Payment Type" = "Payment Type"::"Board Allowances" then Subject:='BOARD ALLOWANCE DISBURSEMENT'
                        else if "Payment Type" = "Payment Type"::"Staff Bulk Payment" then Subject:='STAFF ALLOWANCE DISBURSEMENT'
                            else if "Payment Type" = "Payment Type"::"Payroll Settlement" then Subject:='PAYROLL DISBURSEMENT';
                        Body+='<span style="font-family: Calibri; color: #5B9BD5; font-size: 11pt>';
                        Body+='<span style="font-family: Calibri; color: #5B9BD5; font-size: 11pt>';
                        Body+=StrSubstNo('<p>Dear %1', Employee[1].FullName);
                        Body+='<br><br>';
                        Body+=StrSubstNo('KSH %1 has been credited to your FOSA Account for %2.</p>', Format(Amount), PVHeader.Description);
                        Body+='<br><br>';
                        Body+='Yours Sincerely,';
                        Body+='<br><br>';
                        Body+='<b>Finance Department<b>';
                        Body+='<br>';
                        Body+=CompInfo.Name;
                        SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            Until PaymentSchedule.Next = 0;
        end;
    end;
    [IntegrationEvent(false, false)]
    procedure OnSendSMSNotification(var PhoneNo: Text[250]; var SmsMessage: Text[250]; var SMSSource: Code[20])
    begin
    end;
    [IntegrationEvent(false, false)]
    procedure OnNotificationOnEFTDisbursement(var PVHeader: Record "Payment Voucher")
    begin
    end;
}
