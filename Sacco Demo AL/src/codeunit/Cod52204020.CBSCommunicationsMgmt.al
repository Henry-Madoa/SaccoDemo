codeunit 52204020 "CBS Communications Mgmt"
{
    var
        CompInfo: Record "Company Information";
        Subject: Text;
        Recipients: List of [Text];
        SMSRecipients: List of [Text];
        Body: Text;
        SMSBody: Text;
        CommunicationMgmt: Codeunit "Communications Mgmt";

    procedure NotificationOnEFTDisbursement(PVHeader: Record "Payment Voucher")
    var
        PVLines: Record "Payment Voucher Lines";
        Member: Record Members;
    begin
        CompInfo.Get;
        PVLines.Reset;
        PVLines.SetRange("No.", PVHeader."No.");
        if PVLines.FindSet then begin
            repeat
                with PVLines do begin
                    Clear(Recipients);
                    Clear(SMSRecipients);
                    Subject := '';
                    Body := '';
                    SMSBody := '';
                    //Member.Get("Member No");
                    if ((Member."E-Mail" <> '') and (Member."Mobile Phone No." <> '')) then begin
                        Recipients.Add(Member."E-Mail");
                        SMSRecipients.Add(Member."Mobile Phone No.");
                        //Send SMS
                        SMSBody += StrSubstNo('Dear %1', UpperCase(Member."Full Name"));
                        SMSBody += StrSubstNo(' KSH %1 has been disbursed to %2, Account No. %3', Format(Amount), "Payee Bank Name", "Payee Account No.");
                        SendSMSNotification(SMSRecipients, SMSBody, 'EFT');
                        //Send Email
                        Subject := 'EFT PAYMENT DISBURSEMENT';
                        Body += '<span style="font-family: Calibri; color: #5B9BD5; font-size: 11pt>';
                        Body += '<span style="font-family: Calibri; color: #5B9BD5; font-size: 11pt>';
                        Body += StrSubstNo('Dear %1', Member."Full Name");
                        Body += '<br></br>';
                        Body += StrSubstNo('KSH %1 has been credited to your %2 Account No. %3.</p>', Format(Amount), "Payee Bank Name", "Payee Account No.");
                        Body += '<br></br>';
                        Body += 'Yours Sincerely,';
                        Body += '<br></br>';
                        Body += '<b>Finance Department<b>';
                        Body += '<br>';
                        Body += CompInfo.Name;
                        CommunicationMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            Until PVLines.Next = 0;
        end;
    end;

    procedure SendSMSNotification(PhoneNumbers: List of [Text]; SMSMessage: Text; SMSSource: Code[20])
    var
        ListIndex: Integer;
        Recipients: Integer;
        PhoneNo: Text;
        NotificationsManagement: Codeunit "Notifications Management";
    begin
        Recipients := PhoneNumbers.Count;
        ListIndex := 1;
        while Recipients >= ListIndex do begin
            PhoneNumbers.Get(ListIndex, PhoneNo);
            NotificationsManagement.SendSms(PhoneNo, SMSMessage, SMSSource);
            ListIndex := ListIndex + 1;
        end;
    end;
}
