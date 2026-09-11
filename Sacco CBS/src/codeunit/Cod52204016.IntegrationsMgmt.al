codeunit 52204016 "Integrations Mgmt"
{
    procedure CallService(ProjectName: Text; RequestUrl: Text; RequestType: Option Get,Patch,Post,Delete; payload: Text; Username: Text; Password: Text): Text
    var
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        contentHeaders: HttpHeaders;
    begin
        RequestHeaders := Client.DefaultRequestHeaders();
        case RequestType of
            RequestType::Get:
                Client.Get(RequestURL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);
                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');
                    RequestMessage.Content := RequestContent;
                    RequestMessage.SetRequestUri(RequestURL);
                    RequestMessage.Method := 'PATCH';
                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);
                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');
                    contentHeaders.Add('Accept', '*');
                    Client.Post(RequestURL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(RequestURL, ResponseMessage);
        end;
        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;

    procedure GetCRBDataLoad()
    var
        HtClient: HttpClient;
        //URLCode: TextConst ENU='https://test-api.ekenya.co.ke/Ushuru_APP_API/crb';
        URLCode: TextConst ENU = 'https://mobileapigateway.ekenya.co.ke:8095/Ushuru_APP_API/crb';
        Content: HttpContent;
        Response: HttpResponseMessage;
        ok: Boolean;
        AuthString: Text;
        UserName: Text[250];
        Password: Text[250];
        JToken: JsonToken;
        JArray: JsonArray;
        JObject: JsonObject;
        JValue: JsonValue;
        i: Integer;
        PayLoad, ResponseText : Text;
    begin
        PayLoad := '{' + '"phoneNumber":"254704113452"' + ',' + '"requestType":"product131"' + ',' + '"firstName":"Surname"' + ',' + '"surName":"OtherNames"' + ',' + '"idNumber":"5602299"' + ',' + '"deviceId":"23454123345461"' + '}';
        Message(CallService('CRB', URLCode, 2, PayLoad, '', ''));
    end;

    procedure GetIPRSDataLoad()
    var
        HtClient: HttpClient;
        URLCode: TextConst ENU = 'https://mobileapigateway.ekenya.co.ke:8095/Ushuru_APP_API/iprs';
        Content: HttpContent;
        Response: HttpResponseMessage;
        ok: Boolean;
        AuthString: Text;
        UserName: Text[250];
        Password: Text[250];
        JToken: JsonToken;
        JArray: JsonArray;
        JObject: JsonObject;
        JValue: JsonValue;
        i: Integer;
        ResponseText, PayLoad : Text;
    begin
        PayLoad := '{' + '"phoneNumber":"254704113452"' + ',' + '"idType":"GetDataByIdCard"' + ',' + '"idNumber":"31397774"' + ',' + '"deviceId":"2345412341561"' + '}';
        JObject.ReadFrom(CallService('IPRS', URLCode, 2, PayLoad, '', ''));
    end;

    procedure GenerateAccessToken() AccessToken: Text[250]
    var
        HtClient: HttpClient;
        Text001: TextConst ENU = 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';
        Content: HttpContent;
        Response: HttpResponseMessage;
        ok: Boolean;
        AuthString: Text;
        UserName: Text[250];
        Password: Text[250];
        JToken: JsonToken;
        JArray: JsonArray;
        JObject: JsonObject;
        JValue: JsonValue;
        i: Integer;
    begin
        UserName := 'Azs2KejU1ARvIL5JdJsARbV2gDrWmpOB';
        Password := 'hipGvFJbOxri330c';
        AuthString := STRSUBSTNO('%1:%2', UserName, Password);
        AuthString := STRSUBSTNO('Basic %1', AuthString);
        HtClient.DefaultRequestHeaders().Add('Authorization', AuthString);
        HtClient.DefaultRequestHeaders.Add('Accept', 'application/json');
        HtClient.Get(Text001, Response);
        ok := Response.Content.ReadAs(AccessToken);
        OK := JArray.ReadFrom('[' + AccessToken + ']');
        for i := 0 to JArray.count - 1 do begin
            JArray.Get(i, JToken);
            Jobject := JToken.AsObject;
        end;
        JToken := GetJsonToken(JObject, 'access_token');
        AccessToken := JToken.AsValue().AsText();
        Message(AccessToken);
        exit(AccessToken);
    end;

    procedure GetJsonToken(JObject: JsonObject; JKey: Text[250]) JToken: JsonToken
    begin
        if JObject.Get(JKey, JToken) then
            exit(JToken)
        else
            error('Key Not Found ' + JKey);
    end;

    procedure ReadJsonObject(JObject: JsonObject; JItem: Text[100]; KeyID: Text[100]) ItemValue: Text
    var
        ResultToken, JOrderNoToken : JsonToken;
        JOrderDateToken: JsonToken;
        JSellToCustomerNoToken: JsonToken;
        JLinesToken, JToken : JsonToken;
        JLinesArray: JsonArray;
        NewJObject: JsonObject;
    begin
        Clear(JToken);
        if JObject.Get(JItem, JLinesToken) then begin
            NewJObject := JLinesToken.AsObject();
            ResultToken := GetJsonToken(NewJObject, KeyID);
            ItemValue := ResultToken.AsValue().AsText();
        end;
    end;

    local procedure ReadJSonArray(JArray: JsonArray) FirstName: Text[100];
    var
        JArrayTokens: JsonToken;
        Jobject: JsonObject;
        JToken: JsonToken;
    begin
        foreach JArrayTokens in JArray do begin
            Jobject := JArrayTokens.AsObject();
            if Jobject.Get('First_Name', JToken) then FirstName := JToken.AsValue().AsText();
        end;
        Message('First Name %1', FirstName);
        exit(FirstName);
    end;

    procedure GenerateB2CRequest() ResponseText: Text[250]
    var
        HtClient: HttpClient;
        Text001: TextConst ENU = 'https://sandbox.safaricom.co.ke/mpesa/b2c/v1/paymentrequest';
        Content: HttpContent;
        Response: HttpResponseMessage;
        ok: Boolean;
        AuthString: Text;
        UserName: Text[250];
        Password: Text[250];
        JToken: JsonToken;
        JArray: JsonArray;
        JObject: JsonObject;
        JValue: JsonValue;
        i: Integer;
        Body: Text[250];
    begin
        UserName := 'Azs2KejU1ARvIL5JdJsARbV2gDrWmpOB';
        Password := 'hipGvFJbOxri330c';
        AuthString := STRSUBSTNO('%1:%2', UserName, Password);
        AuthString := STRSUBSTNO('Basic %1', AuthString);
        HtClient.DefaultRequestHeaders().Add('Authorization', AuthString);
        HtClient.DefaultRequestHeaders.Add('Accept', 'application/json');
        HtClient.DefaultRequestHeaders.Add('content-type', 'application/json');
        HtClient.DefaultRequestHeaders.Add('authorization', 'Bearer <Access-Token>');
        /*MessageBody.AddText('"{\"InitiatorName\":\" \",\"SecurityCredential\":\" \",\"CommandID\":\" \",\"Amount\":\" \",\"PartyA\":\" \",'
        + '\"PartyB\":\" \",\"Remarks\":\" \",\"QueueTimeOutURL\":\"http://your_timeout_url\",'
        + '\"ResultURL\":\"http://your_result_url\",\"Occasion\":\" \"}"');*/
        Content.Clear();
        Content.WriteFrom(body);
        HtClient.Post(Text001, Content, Response);
        ok := Response.Content.ReadAs(ResponseText);
        OK := JArray.ReadFrom('[' + ResponseText + ']');
        for i := 0 to JArray.count - 1 do begin
            JArray.Get(i, JToken);
            Jobject := JToken.AsObject;
        end;
    end;
}
