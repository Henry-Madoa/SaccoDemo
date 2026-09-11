codeunit 52204015 "Notifications Management"
{
    procedure SendSms(var PhoneNo: Text[250]; var SmsMessage: Text[250]; var SMSSource: Code[20]);
    var
        HtClient: HttpClient;
        Text001: TextConst ENU = 'https://api.mobilesasa.com/v1/send/message?senderID=AFYA-SACCO';
        Text002: TextConst ENU = '&message=';
        Text003: TextConst ENU = '&phone=';
        Content: HttpContent;
        Response: HttpResponseMessage;
        GeneralLedgerSetup: Record "General Ledger Setup";
        SMSLedger: Record "SMS Ledger";
        EntryNo: Integer;
        AuthString: Text;
        PayLoad: Text;
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        Base64Convert: Codeunit "Base64 Convert";
        ResponseText: Text;
        Client: HttpClient;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        JObject, JsonData : JsonObject;
        JToken: JsonToken;
        JValue: JsonValue;
        RequestUrl: Text;
        Uname: Text;
        Password: Text;
    begin
        if SMSSource <> '' then begin
            if GeneralLedgerSetup.Get then begin
                if GeneralLedgerSetup."Block SMS" = false then begin
                    if CopyStr(PhoneNo, 1, 1) = '0' then
                        PhoneNo := '+254' + CopyStr(PhoneNo, 2);

                    PayLoad := '{' + '"phone":"' + PhoneNo + '"' + ',' + '"message":"' + SmsMessage + '"' + '}';
                    RequestUrl := GeneralLedgerSetup."SMS Url";
                    Uname := 'Nation';
                    Password := 'Nation@69';
                    Client.UseServerCertificateValidation(false);
                    RequestHeaders := Client.DefaultRequestHeaders();
                    RequestContent.WriteFrom(PayLoad);
                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');
                    AddHttpBasicAuthHeader(Uname, Password, Client);
                    Client.Post(RequestURL, RequestContent, ResponseMessage);
                    ResponseMessage.Content().ReadAs(ResponseText);
                    JObject.ReadFrom(ResponseText);
                    if JObject.Get('code', JToken) then ResponseText := JToken.AsValue().AsText();
                end;
                SMSLedger.Reset;
                if SMSLedger.findlast then
                    EntryNo := SMSLedger."Entry No" + 1
                else
                    EntryNo := 1;
                SMSLedger.Init;
                SMSLedger."Entry No" := EntryNo;
                SMSLedger."Phone No" := PhoneNo;
                SMSLedger."SMS Message" := SmsMessage;
                SMSLedger."Created By" := UserId;
                SMSLedger."Sent On" := CurrentDateTime;
                SMSLedger."SMS Source" := SMSSource;
                SMSLedger.Insert;
            end;
        end;
    end;

    procedure AddHttpBasicAuthHeader(UserName: Text[50]; Password: Text[50]; var varHttpClient: HttpClient);
    var
        AuthString, AuthString64 : Text;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        AuthString := STRSUBSTNO('%1:%2', UserName, Password);
        AuthString64 := Base64Convert.ToBase64(AuthString);
        AuthString := STRSUBSTNO('Basic %1', AuthString64);
        varHttpClient.DefaultRequestHeaders().Add('Authorization', AuthString);
    end;
}
