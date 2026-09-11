codeunit 52203487 "User Management Ext"
{
    var GenLedgerSetup: Record "General Ledger Setup";
    procedure IsWebServiceUser(): Boolean begin
        if CurrentClientType = CLIENTTYPE::Web then exit(false)
        else
            exit(true);
    end;
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterInitialization', '', false, false)]
    // local procedure SendNotificationOnLogOn()
    // var
    //     Member: Record Members;
    //     Recipients: List of [Text];
    //     SenderName, SenderID, Subject : Text[100];
    //     Mail: Codeunit "Email Message";
    //     Email: Codeunit Email;
    //     Body, SMSBody : Text;
    //     CompanyInfo: Record "Company Information";
    //     SMS: Codeunit "Notifications Management";
    //     SMSPhone, SMSText : Text[250];
    //     UserSetup: Record "User Setup";
    //     ActiveSession: Record "Active Session";
    //     SMSSource: Code[20];
    // begin
    //     if GenLedgerSetup.Get then begin
    //         if (GenLedgerSetup."Login Email Notification" or GenLedgerSetup."Login SMS Notification") then begin
    //             if CompanyInfo.get then begin
    //                 SMSSource := 'LOG_ON_MGT';
    //                 if UserSetup.Get(UserId) then begin
    //                     if ((UserSetup."Phone No." <> '') and (UserSetup."E-Mail" <> '')) then begin
    //                         SMSPhone := UserSetup."Phone No.";
    //                         SenderName := CompanyInfo.Name;
    //                         Recipients.Add(UserSetup."E-Mail");
    //                         Subject := 'Login Management';
    //                         if SessionId() <> UserSetup."Current Session" then begin
    //                             ActiveSession.Reset();
    //                             ActiveSession.SetRange("Session ID", SessionId());
    //                             if ActiveSession.FindFirst() then begin
    //                                 Body := '';
    //                                 Body += 'Dear ' + UserId;
    //                                 Body += '<BR><BR>';
    //                                 Body += ' You have logged into Dynamics 365 Business Central';
    //                                 Body += '<BR> Log In Time ' + format(ActiveSession."Login Datetime");
    //                                 SMSBody := '';
    //                                 SMSBody += 'Dear ' + UserId;
    //                                 SMSBody += ' You have logged into Dynamics 365 Business Central ';
    //                                 SMSBody += 'Log In Time ' + format(ActiveSession."Login Datetime");
    //                             end;
    //                             if GuiAllowed then begin
    //                                 if GenLedgerSetup."Login Email Notification" then begin
    //                                     Mail.Create(Recipients, Subject, Body, true);
    //                                     Email.Send(Mail);
    //                                 end;
    //                                 SMSText := SMSBody;
    //                                 if GenLedgerSetup."Login SMS Notification" then
    //                                     SMS.SendSms(SMSPhone, SMSText, SMSSource);
    //                                 UserSetup."Current Session" := SessionId();
    //                                 UserSetup.Modify;
    //                             end;
    //                         end;
    //                     end;
    //                 end;
    //             end;
    //         end;
    //     end;
    // end;
    procedure GetUserDimensions(UserCode: Code[100]; var VarDim1: Code[20]; var VarDim2: Code[20])
    var
        UserSetup: Record "User Setup";
        Employee: Record Employee;
    begin
        if UserSetup.Get(UserCode)then begin
            If Employee.Get(UserSetup."Employee No.")then begin
                VarDim1:=Employee."Global Dimension 1 Code";
                VarDim2:=Employee."Global Dimension 2 Code";
            end;
        end;
    end;
}
