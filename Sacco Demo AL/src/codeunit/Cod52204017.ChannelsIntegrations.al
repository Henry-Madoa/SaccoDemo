codeunit 52204017 "Channels Integrations"
{
    #region Declarations
    var
        TempResponse: BigText;
        Member: Record Members;
        Vendor: Record Vendor;
        GlobalTransactionType: Enum "Sacco Transaction Type";
        GlobalAccountType: Enum "Gen. Journal Account Type";
        JournalMgt: Codeunit "Journal Management";
        ProductPostingType: Enum "Product Posting Type";
        Recipients: List of [Text];
        Body: Text;
        Subject: Text;
        TempBlob: Codeunit "Temp Blob";
        outStreamReport: OutStream;
        inStreamReport: InStream;
        Recordr: RecordRef;
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
        LoanMgmt: Codeunit "Loans Management";
        GLEntry: Record "G/L Entry";
        NotificationMgmt: Codeunit "Notifications Management";
        CompanyInformation: Record "Company Information";
        MemberManagement: Codeunit "Member Management";
        SaccoSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        Employee: Record Employee;
        Channel_Transactions: Record "Channel Transactions";
        ChannelTransactionSetup: Record "Channel Transaction Setup";
        ChannelTransactionDump: Record "Channel Transaction Dump";
        ArchivedChannelTransactions: Record "Archived Channel Transactions";
        GuidValue: Guid;
    #endregion;

    #region General Methods

    procedure CheckMemberPendingDocument(MemberNo: Code[20]; DocumentType: Option Loan,"Guarantor Substitution","Change Request","Standing Order",Variation) Success: Code[10]
    var
        LoanApplication: Record "Channel Loan Application";
        GuarantorSub: Record "Loan Security Mgmt";
        StandingOrder: Record "Standing Order";
        BCRQ: Record "Member Editing";
        VariationHeader: Record "Checkoff Variation Header";
    begin
        Success := '00';
        case DocumentType of
            DocumentType::loan:
                begin
                    LoanApplication.Reset();
                    LoanApplication.SetRange("Member No.", MemberNo);
                    LoanApplication.SetRange("Portal Status", LoanApplication."Portal Status"::New);
                    LoanApplication.SetRange("Created By", UserId);
                    if LoanApplication.FindFirst() then Success := '01';
                end;
            DocumentType::"Guarantor Substitution":
                begin
                    GuarantorSub.Reset;
                    GuarantorSub.Setrange("Member No", MemberNo);
                    GuarantorSub.Setrange(Processed, false);
                    GuarantorSub.SetRange("Created By", UserId);
                    if GuarantorSub.FindFirst() then Success := '01';
                end;
            DocumentType::"Change Request":
                begin
                    BCRQ.Reset();
                    BCRQ.SetRange(Processed, false);
                    BCRQ.SetRange("Member No.", MemberNo);
                    BCRQ.SetRange("Created By", UserId);
                    if BCRQ.FindFirst() then Success := '01';
                end;
            DocumentType::"Standing Order":
                begin
                    StandingOrder.Reset;
                    StandingOrder.Setrange("Member No", MemberNo);
                    StandingOrder.Setrange(Running, false);
                    StandingOrder.SetRange("Created By", UserId);
                    if StandingOrder.FindFirst() then Success := '01';
                end;
            DocumentType::Variation:
                begin
                    VariationHeader.Reset();
                    VariationHeader.SetRange("Member No", MemberNo);
                    VariationHeader.SetRange(Processed, False);
                    VariationHeader.SetRange("Created By", UserId);
                    if VariationHeader.FindFirst() then Success := '01';
                end;
        end;
        Exit(Success);
    end;

    procedure ValidateIPRSData(var IDNo: Code[20]; var FirstName: Code[100]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        MemberApplication: Record "Member Application";
        HtClient: HttpClient;
        URLCode: TextConst ENU = 'https://test-api.ekenya.co.ke/Ushuru_APP_API/iprs';
        Content: HttpContent;
        Response: HttpResponseMessage;
        ok: Boolean;
        AuthString: Text;
        UserName: Text[250];
        Password: Text[250];
        JToken, JLinesToken, ResultToken : JsonToken;
        JArray: JsonArray;
        JObject, NewJObject : JsonObject;
        JValue: JsonValue;
        i: Integer;
        ResponseText, PayLoad : Text;
        MpesaIntegrations: Codeunit "Integrations Mgmt";
    begin
        PayLoad := '{' + '"phoneNumber":"254704113452"' + ',' + '"idType":"GetDataByIdCard"' + ',' + '"idNumber":"' + IDNo + '"' + ',' + '"deviceId":"2345412341561"' + '}';
        JObject.ReadFrom(MpesaIntegrations.CallService('IPRS', URLCode, 2, PayLoad, '', ''));
        Clear(JToken);
        if JObject.Get('data', JLinesToken) then begin
            NewJObject := JLinesToken.AsObject();
            Clear(ResultToken);
            ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'First_Name');
            MemberApplication."First Name" := ResultToken.AsValue().AsText();
        end;
        if UpperCase(ResultToken.AsValue().AsText()) = FirstName then begin
            ResponseCode := '00';
            ResponseMessage.AddText('{"Message":"The ID Number Name Combination Matches"}');
            exit;
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The ID Number Name Combination Does Not Exist"}');
            exit;
        end;
    end;

    procedure SendMemberSms(var MemberNo: Code[20]; var Message: Text; var Source: Code[20]) Response: Boolean
    var
        PhoneNo: Text;
    begin
        if Member.Get(MemberNo) then begin
            PhoneNo := Member."Mobile Transacting No";
            NotificationMgmt.SendSms(PhoneNo, Message, Source);
            Response := true;
            exit(Response);
        end;
    end;

    internal procedure LogTransactionResponse(TransactionID: Code[20]; RequestID: Code[250]; ResponseCode: Code[20]; ResponseMessage: Text[400])
    var
        ChannelResponses: Record "Mobile Responses";
        EntryNo: Integer;
    begin
        ChannelResponses.Reset();
        if ChannelResponses.FindLast() then
            EntryNo := ChannelResponses."Entry No" + 1
        else
            EntryNo := 1;
        ChannelResponses.Init();
        ChannelResponses."Entry No" := EntryNo;
        ChannelResponses."Request ID" := RequestID;
        ChannelResponses."Transaction Code" := Format(TransactionID);
        ChannelResponses."Response Code" := ResponseCode;
        ChannelResponses."Response Message" := ResponseMessage;
        ChannelResponses."Created At" := CurrentDateTime;
        ChannelResponses.Insert();
    end;

    internal procedure SendSMSOnLoanSubmission(DocumentNo: Code[20])
    var
        OnlineLoanApp: Record "Channel Loan Application";
        SMSSource: Code[20];
        SMSText, SMSNo : Text[200];
        SMSMgt: Codeunit "Notifications Management";
    begin
        SMSSource := 'ONLINE_LOAN_SUBM';
        if OnlineLoanApp.Get(DocumentNo) then begin
            SMSText := 'An Online Loan Application of KES.' + Format(OnlineLoanApp."Applied Amount") + ' has been submitted';
            SMSNo := '0715791378';
            SMSMgt.SendSms(SMSNo, SMSText, SMSSource);
            SMSNo := '0722756788';
            SMSMgt.SendSms(SMSNo, SMSText, SMSSource);
            SMSNo := '0723208283';
            SMSMgt.SendSms(SMSNo, SMSText, SMSSource);
            SMSNo := '0729828573';
            SMSMgt.SendSms(SMSNo, SMSText, SMSSource);
            SMSNo := '0723495027';
            SMSMgt.SendSms(SMSNo, SMSText, SMSSource);
        end;
    end;
    //------------------Eclectics Requests

    procedure CreateTransactionDump(EntryNo: Integer)
    var
        Ok: Boolean;
    begin
        if Channel_Transactions.Get(EntryNo) then begin
            if ChannelTransactionSetup.Get(Channel_Transactions."Transaction Type") then begin
                LogTransactionResponse(Channel_Transactions."Transaction Type", Channel_Transactions."Document No", '00', 'Accepted');
                ChannelTransactionDump.Init();
                ChannelTransactionDump."Entry No" := EntryNo;
                ChannelTransactionDump."Document No" := Channel_Transactions."Document No";
                ChannelTransactionDump."Debit Member Name" := Channel_Transactions."Debit Member Name";
                ChannelTransactionDump."Credit Member Name" := Channel_Transactions."Credit Member Name";
                ChannelTransactionDump."Transaction Type" := Channel_Transactions."Transaction Type";
                ChannelTransactionDump."Transaction Type Name" := ChannelTransactionSetup.Description;
                ChannelTransactionDump."Posting Date" := DT2Date(Channel_Transactions."Created On");
                ChannelTransactionDump."Debit Account" := Channel_Transactions."Dr_Account No";
                ChannelTransactionDump."Debit Member" := Channel_Transactions."Dr_Member No";
                ChannelTransactionDump."Credit Account" := Channel_Transactions."Cr_Account No";
                ChannelTransactionDump."Credit Member" := Channel_Transactions."Cr_Member No";
                ChannelTransactionDump.Amount := Channel_Transactions.Amount;
                if ChannelTransactionSetup."Posting Type" = ChannelTransactionSetup."Posting Type"::Credit then
                    ChannelTransactionDump."Posting Type" := ChannelTransactionDump."Posting Type"::Credit
                else
                    ChannelTransactionDump."Posting Type" := ChannelTransactionDump."Posting Type"::Debit;
                if ChannelTransactionDump.Amount <> 0 then Ok := ChannelTransactionDump.Insert();
            end;
        end;
    end;

    internal procedure ArchiveChannelTransactions(EntryNo: Integer; DocNo: Code[20])
    begin
        if Channel_Transactions.Get(EntryNo, DocNo) then begin
            ArchivedChannelTransactions.Init();
            ArchivedChannelTransactions.TransferFields(Channel_Transactions);
            if not ArchivedChannelTransactions.Skip then begin
                ArchivedChannelTransactions.Posted := true;
                ArchivedChannelTransactions."Posted On" := CurrentDateTime;
            end
            else begin
                ArchivedChannelTransactions.Posted := false;
                ArchivedChannelTransactions."Posted On" := 0DT;
            end;
            ArchivedChannelTransactions.Insert();
            Channel_Transactions.Delete();
        end;
    end;

    internal procedure CheckBelowMaximumAmount(TransactionCode: Code[20]; Amount: Decimal; var ResponseCode: Code[10]; var ResponseMessage: BigText) Success: Boolean
    var
        ChannelTransactionsetup: Record "Channel Transaction Setup";
    begin
        if ChannelTransactionsetup.Get(TransactionCode) then begin
            if ChannelTransactionsetup."Maximum Amount" = 0 then begin
                exit(True);
            end
            else begin
                if Amount > ChannelTransactionsetup."Maximum Amount" then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Transaction Amount Will Exceed the Allowed Maximum Amount"}');
                    exit(False);
                end
                else
                    exit(true);
            end;
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Transaction Type Does Not Exist"}');
            exit(false);
        end;
    end;

    internal procedure HasPendingTransaction(MemberNo: Code[20]; TransactionCode: Code[20]; var ResponseCode: Code[10]; var ResponseMessage: BigText) Success: Boolean
    begin
        Success := false;
        if ChannelTransactionsetup.Get(TransactionCode) then begin
            if ChannelTransactionsetup."Posting Type" = ChannelTransactionsetup."Posting Type"::Credit then
                exit(false)
            else begin
                Channel_Transactions.Reset;
                Channel_Transactions.SetRange("Dr_Member No", MemberNo);
                Channel_Transactions.SetRange("Transaction Type", TransactionCode);
                Channel_Transactions.SetRange(Posted, False);
                Channel_Transactions.SetRange(Reversed, False);
                Channel_Transactions.SetRange(Skip, False);
                if Channel_Transactions.findfirst then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Member has a similar transaction Pending ' + Channel_Transactions."Document No" + '"}');
                    exit(True);
                end;
            end;
        end;
        exit(Success);
    end;

    internal procedure HasPendingPesaLinkTransaction(MemberNo: Code[20]; FosaNumber: Code[20]; var ResponseCode: Code[10]; var ResponseMessage: BigText) Success: Boolean
    var
        PesaLinkTransactions: Record "PesaLink Transactions";
    begin
        Success := false;
        PesaLinkTransactions.Reset;
        PesaLinkTransactions.SetRange("Member No.", MemberNo);
        PesaLinkTransactions.SetRange("FOSA Account Number", FosaNumber);
        PesaLinkTransactions.SetRange("Transaction Direction", PesaLinkTransactions."Transaction Direction"::Outgoing);
        PesaLinkTransactions.SetRange(Status, PesaLinkTransactions.Status::New);
        PesaLinkTransactions.SetRange(Skip, false);
        if PesaLinkTransactions.findfirst then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Member has a similar transaction Pending ' + PesaLinkTransactions."Reference Number" + '"}');
            exit(true);
        end;
        exit(Success);
    end;

    internal procedure CheckMobileBankingRegistration(var MemberNo: Code[20]) Registered: Boolean
    var
        Members: Record Members;
        MobileMembers: Record "Mobile Members";
    begin
        //if Members.Get(MemberNo) then begin
        //    if not (Members.Status IN [Members.Status::Active, Members.Status::"Not Paid Up"]) then
        //         Registered := false
        //     else begin
        //         MobileMembers.Reset();
        //         MobileMembers.SetRange("Member No", MemberNo);
        //         MobileMembers.SetRange("Member Status", MobileMembers."Member Status"::Active);
        //         Registered := MobileMembers.FindFirst();
        //       end;
        // end
        // else
        Registered := true;
        exit(Registered);
    end;

    procedure GetMemberCategories(var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        MemberCategories: Record "Member Categories";
        JCategories: JsonArray;
        JCategory: JsonObject;
        JResponse: JsonObject;
        ResponseText: Text;
    begin
        Clear(ResponseMessage);
        Clear(ResponseCode);

        MemberCategories.Reset();
        if MemberCategories.FindSet() then begin
            ResponseCode := '00';
            repeat
                Clear(JCategory);
                JCategory.Add('Code', MemberCategories.Code);
                JCategory.Add('Description', MemberCategories.Description);
                JCategories.Add(JCategory);
            until MemberCategories.Next() = 0;
        end else
            ResponseCode := '01';

        JResponse.Add('Categories', JCategories);
        JResponse.WriteTo(ResponseText);
        ResponseMessage.AddText(ResponseText);
    end;

    procedure GetMemberNoFromPhoneNo(PhoneNo: code[20]) MemberNo: Code[20]
    var
        Phone1, Phone2, Phone3, Phone4 : Code[20];
    begin
        Member.Reset();
        Member.SetRange("Mobile Transacting No", PhoneNo);
        if Member.FindFirst then
            MemberNo := Member."No."
        else begin
            Phone1 := '';
            Phone2 := '';
            Phone3 := '';
            Phone4 := '';
            if COPYSTR(PhoneNo, 1, 1) = '0' THEN BEGIN
                Phone1 := PhoneNo;
                Phone2 := '254' + COPYSTR(PhoneNo, 2, STRLEN(PhoneNo));
                Phone3 := '+254' + COPYSTR(PhoneNo, 2, STRLEN(PhoneNo));
                Phone4 := COPYSTR(PhoneNo, 2, STRLEN(PhoneNo));
            end;
            if ((COPYSTR(PhoneNo, 1, 1) <> '0') AND (STRLEN(PhoneNo) = 9)) THEN BEGIN
                Phone1 := '0' + PhoneNo;
                Phone2 := '254' + COPYSTR(PhoneNo, 2, STRLEN(PhoneNo));
                Phone3 := '+254' + COPYSTR(PhoneNo, 2, STRLEN(PhoneNo));
                Phone4 := PhoneNo;
            end;
            if COPYSTR(PhoneNo, 1, 3) = '254' THEN BEGIN
                Phone1 := '0' + COPYSTR(PhoneNo, 4, STRLEN(PhoneNo));
                Phone2 := PhoneNo;
                Phone3 := '+' + COPYSTR(PhoneNo, 1, STRLEN(PhoneNo));
                Phone4 := COPYSTR(PhoneNo, 4, STRLEN(PhoneNo));
            end;
            if COPYSTR(PhoneNo, 1, 4) = '+254' THEN BEGIN
                Phone1 := '0' + COPYSTR(PhoneNo, 5, STRLEN(PhoneNo));
                Phone2 := COPYSTR(PhoneNo, 5, STRLEN(PhoneNo));
                Phone3 := PhoneNo;
                Phone4 := COPYSTR(PhoneNo, 5, STRLEN(PhoneNo));
            end;
            MemberNo := '';
            if ((Phone1 = '') AND (Phone2 = '') AND (Phone3 = '') AND (Phone4 = '')) THEN exit(MemberNo);
            Member.RESET;
            Member.SETRANGE("Mobile Transacting No", Phone1);
            if Member.FINDFIRST = FALSE THEN BEGIN
                Member.RESET;
                Member.SETRANGE("Mobile Transacting No", Phone2);
                if Member.FINDFIRST = FALSE THEN BEGIN
                    Member.RESET;
                    Member.SETRANGE("Mobile Transacting No", Phone3);
                    if Member.FINDFIRST = FALSE THEN BEGIN
                        Member.RESET;
                        Member.SETRANGE("Mobile Transacting No", Phone4);
                        if Member.FINDFIRST THEN MemberNo := Member."No.";
                    END
                    ELSE
                        MemberNo := Member."No.";
                END
                ELSE
                    MemberNo := Member."No.";
            END
            ELSE
                MemberNo := Member."No.";
        end;
        if not Member.GET(MemberNo) then MemberNo := '';
        exit(MemberNo);
    end;

    internal procedure FormatSoapParameters(Soapcode: Code[100]) FormatedSoapCode: Code[100]
    begin
        FormatedSoapCode := '';
        FormatedSoapCode := DelChr(Soapcode, '=', '?');
        exit(FormatedSoapCode);
    end;
    //Generate Loan Schedule

    procedure GetTransactingAccountFromPhoneNo(var PhoneNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: Text)
    var
        Vend: Record Vendor;
        JsonObj: JsonObject;
        JsonArr: JsonArray;
    begin
        Clear(ResponseMessage);
        responseCode := '00';
        Member.Reset();
        Member.SetRange("Mobile Transacting No", PhoneNo);
        if Member.FindSet then begin
            Vend.Reset();
            Vend.SetRange("Member No.", Member."No.");
            Vend.SetRange("Product Posting Type", Vend."Product Posting Type"::"Withdrawable Deposit");
            if Vend.FindFirst() then begin
                JsonObj.Add('AccountNo', Vend."No.");
                JsonObj.Add('AccountName', Vend.Name);
                JsonObj.Add('MemberName', Member.FullName);
                JsonArr.Add(JsonObj);
            end;
        end;
        JsonArr.WriteTo(ResponseMessage);
    end;

    #endregion

    #region Member Application

    procedure GenerateMemberApplication(ApplicationNo: code[20]) Base64Pdf: Text
    var
        MemberApplication: Record "Member Application";
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        MemberApplication.Reset();
        MemberApplication.SetRange("No.", ApplicationNo);
        if MemberApplication.FindSet() then begin
            RecRef.GetTable(MemberApplication);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Membership Form", '', ReportFormat::Pdf, outStreamReport, RecRef);
            Base64Pdf := Base64Convert.ToBase64(inStreamReport);
        end;
    end;

    procedure GetMemberImage(var MemberNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Base64Convert: Codeunit "Base64 Convert";
        varInstream: InStream;
    begin
        CLEAR(responseCode);
        CLEAR(responseMessage);
        if Member.GET(MemberNo) THEN BEGIN
            responseCode := '00';
            responseMessage.ADDTEXT('{"Image":"');
            Member.CalcFields("Passport Size Photo");
            Member."Passport Size Photo".CreateInStream(varInstream);
            responseMessage.AddText(Base64Convert.ToBase64(varInstream));
            responseMessage.ADDTEXT('"}');
        END
        ELSE BEGIN
            responseCode := '01';
            responseMessage.ADDTEXT('{"Response":"The Member Does Not Exist"}');
        end;
    end;

    procedure GetMemberSignature(var MemberNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Customer: Record Members;
        Base64Convert: Codeunit "Base64 Convert";
        varInstream: InStream;
    begin
        CLEAR(responseCode);
        CLEAR(responseMessage);
        if Customer.GET(MemberNo) THEN BEGIN
            responseCode := '00';
            responseMessage.ADDTEXT('{"Signature":"');
            Customer.CalcFields(Signature);
            Customer.Signature.CreateInStream(varInstream);
            responseMessage.AddText(Base64Convert.ToBase64(varInstream));
            responseMessage.ADDTEXT('"}');
        END
        ELSE BEGIN
            responseCode := '01';
            responseMessage.ADDTEXT('{"Response":"The Member Does Not Exist"}');
        end;
    end;

    procedure SetMemberKINImage(SourceCode: Code[20]; KinType: Code[20]; KINID: Code[20]; Base64Image: Text; ImageType: Option ProfilePicture,IdentificationDocument; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        NextsOfKin: Record "Member Nominee/Kin";
        Members: Record Members;
        KinType1: Option Child,Spouse,Parent,Nephew,Niece,Uncle,Aunt,Cousin,Other;
        Base64Convert: Codeunit "Base64 Convert";
        varOutStream: OutStream;
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);
        Evaluate(KinType1, KinType);
        if NextsOfKin.Get(SourceCode, KinType1, KINID) then begin
            case ImageType of
                ImageType::IdentificationDocument:
                    begin
                        NextsOfKin."Identification Document".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                        NextsOfKin.CalcFields("Identification Document");
                    end;
                ImageType::ProfilePicture:
                    begin
                        NextsOfKin."Passport Image".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                        NextsOfKin.CalcFields("Passport Image");
                    end;
            end;
            NextsOfKin.Modify();
            ResponseCode := '00';
            ResponseMessage.AddText('{"Message":"Image Set Succecssfully"}');
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The KIN Does' + format(KinType) + ' ' + KINID + ' ' + SourceCode + ' Not Exist"}');
        end;
    end;

    procedure SetMemberImage(ApplicationNo: Code[20]; Base64Image: Text; ImageType: Option MemberPicture,FronID,BackID,Signature)
    var
        MemberApplication: Record "Member Application";
        Members: Record Members;
        Base64Convert: Codeunit "Base64 Convert";
        varOutStream: OutStream;
    begin
        if MemberApplication.Get(ApplicationNo) then begin
            case ImageType of
                ImageType::MemberPicture:
                    begin
                        MemberApplication."Passport Size Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::BackID:
                    begin
                        MemberApplication."Back ID Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::FronID:
                    begin
                        MemberApplication."Front ID Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::Signature:
                    begin
                        MemberApplication.Signature.CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
            end;
            MemberApplication.Modify();
        end;
        if Members.Get(ApplicationNo) then begin
            case ImageType of
                ImageType::MemberPicture:
                    begin
                        Members."Passport Size Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::BackID:
                    begin
                        Members."Back ID Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::FronID:
                    begin
                        Members."Front ID Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::Signature:
                    begin
                        Members.Signature.CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
            end;
            Members.Modify();
        end;
    end;

    procedure SetChangeRequestImage(ApplicationNo: Code[20]; Base64Image: Text[250]; ImageType: Option MemberPicture,FronID,BackID,Signature)
    var
        MemberUpdate: Record "Member Editing";
        Members: Record Members;
        Base64Convert: Codeunit "Base64 Convert";
        varOutStream: OutStream;
    begin
        if MemberUpdate.Get(ApplicationNo) then begin
            case ImageType of
                ImageType::MemberPicture:
                    begin
                        MemberUpdate."Passport Size Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::BackID:
                    begin
                        MemberUpdate."Back ID Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::FronID:
                    begin
                        MemberUpdate."Front ID Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::Signature:
                    begin
                        MemberUpdate.Signature.CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
            end;
            MemberUpdate.Modify();
        end;
        if Members.Get(ApplicationNo) then begin
            case ImageType of
                ImageType::MemberPicture:
                    begin
                        Members."Passport Size Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::BackID:
                    begin
                        Members."Back ID Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::FronID:
                    begin
                        Members."Front ID Photo".CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
                ImageType::Signature:
                    begin
                        Members.Signature.CreateOutStream(varOutStream);
                        Base64Convert.FromBase64(Base64Image, varOutStream);
                    end;
            end;
            Members.Modify();
        end;
    end;

    procedure ExportMemberImages(MemberNo: Code[100]; ImageType: Option MemberPicture,FronID,BackID,Signature) Base64Image: Text
    var
        Members: Record Members;
        Base64Convert: Codeunit "Base64 Convert";
        varInstream: InStream;
    begin
        if Members.Get(MemberNo) then begin
            case ImageType of
                ImageType::MemberPicture:
                    begin
                        Members.CalcFields("Passport Size Photo");
                        Members."Passport Size Photo".CreateInStream(varInstream);
                        exit(Base64Convert.ToBase64(varInstream));
                    end;
                ImageType::BackID:
                    begin
                        Members.CalcFields("Back ID Photo");
                        Members."Back ID Photo".CreateInStream(varInstream);
                        exit(Base64Convert.ToBase64(varInstream));
                    end;
                ImageType::FronID:
                    begin
                        Members.CalcFields("Front ID Photo");
                        Members."Front ID Photo".CreateInStream(varInstream);
                        exit(Base64Convert.ToBase64(varInstream));
                    end;
                ImageType::Signature:
                    begin
                        Members.CalcFields(Signature);
                        Members.Signature.CreateInStream(varInstream);
                        exit(Base64Convert.ToBase64(varInstream));
                    end;
            end;
        end;
        exit(Base64Image);
    end;

    procedure GetMemberProfileByMemberNo(var MemberNo: Code[20]; var ResponseCode: Code[10]; var ResponseMessage: BigText)
    var
        Vendor: array[3] of Record Vendor;
        VendorLedgEntries: Record "Vendor Ledger Entry";
        Loans: Record Loans;
        MemberNomineeKin: Record "Member Nominee/Kin";
        MemberSubscriptions: Record "Member Subscriptions";
        LoanGuarantees: Record "Loan Guarantees";
        Relative: Record Relative;
        SaccoSetup: Record "General Ledger Setup";
        SaccoProduct: Record "Sacco Products";
        LoansManagement: Codeunit "Loans Management";
        RootJson: JsonObject;
        ErrorJson: JsonObject;
        AccountsArray, TransactionsArray, LoansArray, KinArray, NomineesArray, SubscriptionsArray, GuaranteesArray, GuarantorsArray : JsonArray;
        LineJson: JsonObject;
        ResultText: Text;
        BookValue, VendorBalance, AvailableBalance, UnclearedFunds, MinimumBalance : Decimal;
        RemainingCount: Integer;
    begin
        if not CheckMobileBankingRegistration(MemberNo) then begin
            ResponseCode := '01';
            Clear(ErrorJson);
            ErrorJson.Add('Error', 'The Member is Not registered for Mobile Banking');
            ErrorJson.WriteTo(ResultText);
            ResponseMessage.AddText(ResultText);
            exit;
        end;

        Clear(ResponseCode);
        Clear(ResponseMessage);

        if not Member.Get(MemberNo) then begin
            ResponseCode := '01';
            Clear(ErrorJson);
            ErrorJson.Add('Error', 'The Member Does Not Exist ' + MemberNo);
            ErrorJson.WriteTo(ResultText);
            ResponseMessage.AddText(ResultText);
            exit;
        end;

        SaccoSetup.Get();
        ResponseCode := '00';

        // ---- Member summary ----
        Member.CalcFields("Uncleared Funds", "Total Deposits", "Total Shares", "Outstanding Loans", "Self Guarantee", "Running Loans");

        Vendor[1].Reset();
        Vendor[1].SetRange("Member No.", Member."No.");
        Vendor[1].SetRange("Product Posting Type", Vendor[1]."Product Posting Type"::"Withdrawable Deposit");
        Vendor[1].SetRange("Business Account", false);
        Vendor[1].SetRange(Blocked, Vendor[1].Blocked::" ");
        if Vendor[1].FindSet() then
            repeat
                SaccoProduct.Get(Vendor[1]."Product Code");
                Vendor[1].CalcFields(Balance, "Uncleared Funds");
                BookValue += Vendor[1].Balance;
                UnclearedFunds += Vendor[1]."Uncleared Funds";
                MinimumBalance += SaccoProduct."Minimum Balance";
            until Vendor[1].Next() = 0;

        Vendor[2].Reset();
        Vendor[2].SetRange("Member No.", Member."No.");
        Vendor[2].SetRange("Product Posting Type", Vendor[2]."Product Posting Type"::"Withdrawable Deposit");
        Vendor[2].SetRange("Business Account", true);
        Vendor[2].SetRange(Blocked, Vendor[2].Blocked::" ");
        if Vendor[2].FindSet() then;

        AvailableBalance := BookValue - UnclearedFunds - MinimumBalance - GetPendingChannelsTransactions(Member."No.");
        if AvailableBalance < 0 then
            AvailableBalance := 0;

        RootJson.Add('MemberNo', Member."No.");
        RootJson.Add('DateOfRegistration', Format(Member."Date of Registration"));
        RootJson.Add('Status', Format(Member.Status));
        RootJson.Add('KRAPin', Format(Member."KRA PIN"));
        RootJson.Add('PhoneNo', Format(Member."Mobile Transacting No"));
        RootJson.Add('BranchCode', Format(Member."Global Dimension 1 Code"));
        RootJson.Add('DateOfBirth', Format(Member."Date of Birth"));
        RootJson.Add('FullName', Member."Full Name");
        RootJson.Add('NationalIDNo', Member."Identification No.");
        RootJson.Add('Email', Member."E-Mail");
        RootJson.Add('TransactingPhoneNo', Member."Mobile Transacting No");
        RootJson.Add('BookValue', Format(BookValue));
        RootJson.Add('UnclearedFunds', Format(Member."Uncleared Funds"));
        RootJson.Add('AvailableBalance', Format(AvailableBalance));
        RootJson.Add('Deposits', Format(Member."Total Deposits"));
        RootJson.Add('ShareCapital', Format(Member."Total Shares"));
        RootJson.Add('FreeDeposits', Format(LoansManagement.GetNonSelfGuaranteeEligibility(Member."No.")));
        RootJson.Add('QualifiedSelfGuarantee', Format(LoansManagement.GetSelfGuaranteeEligibility(Member."No.")));
        RootJson.Add('OutstandingLoans', Format(Member."Outstanding Loans"));
        RootJson.Add('SelfGuarantee', Format(Member."Self Guarantee"));
        RootJson.Add('RunningLoans', Format(Member."Running Loans"));
        RootJson.Add('CanPromptSTKPush', Format(Vendor[2]."Can Prompt STK Push"));

        // ---- Accounts ----
        Vendor[3].Reset();
        Vendor[3].SetRange("Member No.", Member."No.");
        Vendor[3].SetFilter("Product Posting Type", '<>%1', Vendor[3]."Product Posting Type"::"Loan Account");
        if Vendor[3].FindSet() then
            repeat
                Vendor[3].CalcFields(Balance, "Uncleared Funds");
                SaccoProduct.Get(Vendor[3]."Product Code");
                if Vendor[3]."Product Posting Type" = Vendor[3]."Product Posting Type"::"Withdrawable Deposit" then
                    VendorBalance := Vendor[3].Balance - Vendor[3]."Uncleared Funds" - SaccoProduct."Minimum Balance" - GetPendingChannelsTransactions(Member."No.")
                else
                    VendorBalance := Vendor[3].Balance - Vendor[3]."Uncleared Funds";

                Clear(LineJson);
                LineJson.Add('Code', Vendor[3]."No.");
                LineJson.Add('Description', Vendor[3].Name);
                LineJson.Add('Type', Format(Vendor[3]."Product Posting Type"));
                LineJson.Add('ShareCapital', Format(Vendor[3]."Product Posting Type" = Vendor[3]."Product Posting Type"::"Share Capital Account"));
                LineJson.Add('CashWithdrawAllowed', Format(Vendor[3]."Cash Withdraw Allowed"));
                LineJson.Add('CashDepositAllowed', Format(Vendor[3]."Cash Deposit Allowed"));
                LineJson.Add('CashTransferAllowed', Format(Vendor[3]."Cash Transfer Allowed"));
                LineJson.Add('Status', Format(Vendor[3].Status));
                LineJson.Add('Balance', Format(VendorBalance));
                AccountsArray.Add(LineJson);
            until Vendor[3].Next() = 0;
        RootJson.Add('Accounts', AccountsArray);

        // ---- Latest transactions ----
        RemainingCount := SaccoSetup."Channel Transactins Nos.";
        if RemainingCount <> 0 then begin
            VendorLedgEntries.Reset();
            VendorLedgEntries.SetRange("Member No.", Member."No.");
            VendorLedgEntries.SetAscending("Entry No.", false);
            if VendorLedgEntries.FindSet() then
                repeat
                    VendorLedgEntries.CalcFields(Amount);

                    Clear(LineJson);
                    LineJson.Add('Code', VendorLedgEntries."Vendor No.");
                    LineJson.Add('PostingDate', Format(VendorLedgEntries."Posting Date"));
                    LineJson.Add('DocumentNo', VendorLedgEntries."Document No.");
                    LineJson.Add('Narration', VendorLedgEntries.Description);
                    LineJson.Add('Amount', Format(VendorLedgEntries.Amount));
                    LineJson.Add('TransactingType', Format(VendorLedgEntries."Sacco Transaction Type"));
                    LineJson.Add('ProductPostingType', Format(VendorLedgEntries."Product Posting Type"));
                    LineJson.Add('LoanNo', VendorLedgEntries."Loan No.");
                    TransactionsArray.Add(LineJson);

                    RemainingCount -= 1;
                until (VendorLedgEntries.Next() = 0) or (RemainingCount = 0);
        end;
        RootJson.Add('LatestTransactions', TransactionsArray);

        // ---- Loans ----
        Loans.Reset();
        Loans.SetRange("Member No.", Member."No.");
        if Loans.FindSet() then
            repeat
                Loans.CalcFields("Loan Balance", "Monthly Installment");

                Clear(LineJson);
                LineJson.Add('LoanNo', Loans."No.");
                LineJson.Add('Description', Loans."Product Description");
                LineJson.Add('PrincipalAmount', Format(Loans."Approved Amount", 0, 1));
                LineJson.Add('Installments', Format(Loans.Installments));
                LineJson.Add('MonthlyInstallment', Format(Round(Loans."Monthly Installment", 0.01, '>'), 0, 1));
                LineJson.Add('ApplicationDate', Format(Loans."Posting Date"));
                LineJson.Add('Status', Format(Loans.Status));
                LineJson.Add('ControlAccount', Loans."Loan Account");
                LineJson.Add('Balance', Format(Round(Loans."Loan Balance", 0.01, '>'), 0, 1));
                LoansArray.Add(LineJson);
            until Loans.Next() = 0;
        RootJson.Add('Loans', LoansArray);

        // ---- Next of Kin ----
        MemberNomineeKin.Reset();
        MemberNomineeKin.SetRange("Source Code", Member."No.");
        MemberNomineeKin.SetRange("Document Type", MemberNomineeKin."Document Type"::"Next of Kin");
        if MemberNomineeKin.FindSet() then
            repeat
                if not Relative.Get(MemberNomineeKin."Relative Code") then
                    Clear(Relative);

                Clear(LineJson);
                LineJson.Add('Relationship', Relative.Description);
                LineJson.Add('Identification No.', MemberNomineeKin."Identification No.");
                LineJson.Add('Name', MemberNomineeKin.Name);
                KinArray.Add(LineJson);
            until MemberNomineeKin.Next() = 0;
        RootJson.Add('NextOfKins', KinArray);

        // ---- Nominees ----
        MemberNomineeKin.Reset();
        MemberNomineeKin.SetRange("Source Code", Member."No.");
        MemberNomineeKin.SetRange("Document Type", MemberNomineeKin."Document Type"::Nominee);
        if MemberNomineeKin.FindSet() then
            repeat
                if not Relative.Get(MemberNomineeKin."Relative Code") then
                    Clear(Relative);

                Clear(LineJson);
                LineJson.Add('Relationship', Relative.Description);
                LineJson.Add('Identification No.', MemberNomineeKin."Identification No.");
                LineJson.Add('Name', MemberNomineeKin.Name);
                LineJson.Add('Allocation', Format(MemberNomineeKin.Allocation));
                NomineesArray.Add(LineJson);
            until MemberNomineeKin.Next() = 0;
        RootJson.Add('Nominees', NomineesArray);

        // ---- Subscriptions ----
        MemberSubscriptions.Reset();
        MemberSubscriptions.SetRange("Source Code", Member."No.");
        if MemberSubscriptions.FindSet() then
            repeat
                Clear(LineJson);
                LineJson.Add('Account', MemberSubscriptions."Account Name");
                LineJson.Add('Start Date', Format(MemberSubscriptions."Start Date"));
                LineJson.Add('Amount', Format(MemberSubscriptions.Amount));
                LineJson.Add('Minimum Contribution', Format(MemberSubscriptions."Minimum Contribution"));
                SubscriptionsArray.Add(LineJson);
            until MemberSubscriptions.Next() = 0;
        RootJson.Add('Subscriptions', SubscriptionsArray);

        // ---- Guarantees (loans this member guaranteed for others) ----
        LoanGuarantees.Reset();
        LoanGuarantees.SetRange("Member No.", Member."No.");
        LoanGuarantees.SetRange(Substituted, false);
        if LoanGuarantees.FindSet() then
            repeat
                if Loans.Get(LoanGuarantees."Loan No") then begin
                    Loans.CalcFields("Loan Balance");
                    if Loans."Loan Balance" <> 0 then begin
                        Clear(LineJson);
                        LineJson.Add('MemberNo', Loans."Member No.");
                        LineJson.Add('MemberName', Loans."Member Name");
                        LineJson.Add('LoanProduct', Loans."Product Description");
                        LineJson.Add('LoanNo', Loans."No.");
                        LineJson.Add('Amount', Format(LoanGuarantees."Guaranteed Amount"));
                        GuaranteesArray.Add(LineJson);
                    end;
                end;
            until LoanGuarantees.Next() = 0;
        RootJson.Add('Guarantees', GuaranteesArray);

        // ---- Guarantors (who guaranteed this member's loans) ----
        Loans.Reset();
        Loans.SetRange("Member No.", Member."No.");
        Loans.SetFilter("Loan Balance", '<>%1', 0);
        if Loans.FindSet() then
            repeat
                LoanGuarantees.Reset();
                LoanGuarantees.SetRange("Loan No", Loans."No.");
                LoanGuarantees.SetRange(Substituted, false);
                if LoanGuarantees.FindSet() then
                    repeat
                        Clear(LineJson);
                        LineJson.Add('MemberNo', LoanGuarantees."Member No.");
                        LineJson.Add('MemberName', LoanGuarantees."Member Name");
                        LineJson.Add('LoanProduct', Loans."Product Description");
                        LineJson.Add('LoanNo', Loans."No.");
                        LineJson.Add('Amount', Format(LoanGuarantees."Guaranteed Amount"));
                        GuarantorsArray.Add(LineJson);
                    until LoanGuarantees.Next() = 0;
            until Loans.Next() = 0;
        RootJson.Add('Guarantors', GuarantorsArray);

        RootJson.WriteTo(ResultText);
        ResponseMessage.AddText(ResultText);
    end;

    procedure GetMemberProfileByMemberNo(var MemberNo: Code[20]; var Chargable: Boolean; Var ResponseCode: Code[10]; var ResponseMessage: BigText)
    var
        Vendor, Vendor1 : Record Vendor;
        VendorLegEntries: Record "Vendor Ledger Entry";
        varCount: Integer;
        LastEntry: Integer;
        Loans: Record Loans;
        MemberNomineeKin: Record "Member Nominee/Kin";
        MemberSubscriptions: Record "Member Subscriptions";
        LoanGuarantees: Record "Loan Guarantees";
        Relative: Record Relative;
        SaccoSetup: Record "General Ledger Setup";
        BookValue, VendorBalance, AvailableBalance : Decimal;
        LoansManagement: Codeunit "Loans Management";
        UnclearedFunds: Decimal;
        MinimumBalance: Decimal;
        SaccoProduct: Record "Sacco Products";
    begin
        if CheckMobileBankingRegistration(MemberNo) = false then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Member is Not registered for Mobile Banking"}');
            exit;
        end;
        SaccoSetup.Get;
        Clear(ResponseCode);
        Clear(ResponseMessage);
        Clear(TempResponse);
        if Member.GET(MemberNo) THEN BEGIN
            Member.CalcFields("Uncleared Funds");
            Member.CalcFields("Total Deposits");
            Member.CalcFields("Total Shares");
            Member.CalcFields("Outstanding Loans");
            Member.CalcFields("Self Guarantee");
            Member.CalcFields("Running Loans");
            Vendor.RESET;
            Vendor.SETRANGE("Member No.", Member."No.");
            Vendor.SetRange("Product Posting Type", Vendor."Product Posting Type"::"Withdrawable Deposit");
            Vendor.SetRange("Business Account", false);
            Vendor.SetRange(Blocked, Vendor.Blocked::" ");
            if Vendor.FindSet then begin
                repeat
                    SaccoProduct.Get(Vendor."Product Code");
                    Vendor.CalcFields(Balance, "Uncleared Funds");
                    BookValue += Vendor.Balance;
                    UnclearedFunds += Vendor."Uncleared Funds";
                    MinimumBalance += SaccoProduct."Minimum Balance";
                until Vendor.Next = 0;
            end;
            AvailableBalance := BookValue - UnclearedFunds - MinimumBalance - GetPendingChannelsTransactions(MemberNo);
            if AvailableBalance < 0 then AvailableBalance := 0;
            ResponseMessage.ADDTEXT('{"MemberNo":"' + Member."No." + '","DateOfRegistration":"' + Format(Member."Date of Registration") + '","Status":"' + Format(Member.Status) + '","KRAPin":"' + Format(Member."KRA PIN") + '","PhoneNo":"' + Format(Member."Mobile Transacting No") + '","BranchCode":"' + Format(Member."Global Dimension 1 Code") + '","DateOfBirth":"' + Format(Member."Date of Birth") + '","FullName":"' + Member."Full Name" + '","NationalIDNo":"' + Member."Identification No." + '","Email":"' + Member."E-Mail" + '","TransactingPhoneNo":"' + Member."Mobile Transacting No" + '","BookValue":"' + Format(BookValue) + '","UnclearedFunds":"' + Format(Member."Uncleared Funds") + '","AvailableBalance":"' + Format(AvailableBalance) + '","Deposits":"' + Format(Member."Total Deposits") + '","ShareCapital":"' + Format(Member."Total Shares") + '","FreeDeposits":"' + Format(LoansManagement.GetNonSelfGuaranteeEligibility(Member."No.")) + '","QualifiedSelfGuarantee":"' + Format(LoansManagement.GetSelfGuaranteeEligibility(Member."No.")) + '","OutstandingLoans":"' + Format(Member."Outstanding Loans") + '","SelfGuarantee":"' + Format(Member."Self Guarantee") + '","RunningLoans":"' + Format(Member."Running Loans") + '","Accounts":[');
            Vendor.RESET;
            Vendor.SETRANGE("Member No.", Member."No.");
            Vendor.SetFilter("Product Posting Type", '<>%1', Vendor."Product Posting Type"::"Loan Account");
            if Vendor.FINDSET THEN BEGIN
                ResponseCode := '00';
                REPEAT
                    Vendor.CALCFIELDS(Balance, "Uncleared Funds");
                    SaccoProduct.Get(Vendor."Product Code");
                    if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Withdrawable Deposit" then
                        VendorBalance := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - GetPendingChannelsTransactions(MemberNo)
                    else
                        VendorBalance := Vendor.Balance - Vendor."Uncleared Funds";
                    TempResponse.ADDTEXT('{"Code":"' + Vendor."No." + '","Description":"' + Vendor.Name + '","Type":"' + Format(Vendor."Product Posting Type") + '","ShareCapital":"' + FORMAT(Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Share Capital Account") + '","CashWithdrawAllowed":"' + FORMAT(Vendor."Cash Withdraw Allowed") + '","CashDepositAllowed":"' + FORMAT(Vendor."Cash Deposit Allowed") + '","CashTransferAllowed":"' + FORMAT(Vendor."Cash Transfer Allowed") + '","Status":"' + FORMAT(Vendor.Status) + '","Balance":"' + FORMAT(VendorBalance) + '"}');
                    TempResponse.ADDTEXT(',');
                UNTIL Vendor.NEXT = 0;
                if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            // Latest 10 Transactions
            ResponseMessage.ADDTEXT(']');
            ResponseMessage.ADDTEXT(',"LatestTransactions":[');
            CLEAR(TempResponse);
            varCount := SaccoSetup."Channel Transactins Nos.";
            if varCount <> 0 then begin
                VendorLegEntries.RESET;
                VendorLegEntries.SETRANGE("Member No.", Member."No.");
                VendorLegEntries.SetAscending("Entry No.", false);
                if VendorLegEntries.FINDSET THEN BEGIN
                    REPEAT
                        VendorLegEntries.CalcFields(Amount);
                        TempResponse.ADDTEXT('{"Code":"' + VendorLegEntries."Vendor No." + '","PostingDate":"' + Format(VendorLegEntries."Posting Date") + '","DocumentNo":"' + VendorLegEntries."Document No." + '","Narration":"' + VendorLegEntries.Description + '","Amount":"' + FORMAT(VendorLegEntries.Amount) + '","TransactingType":"' + FORMAT(VendorLegEntries."Sacco Transaction Type") + '","ProductPostingType":"' + FORMAT(VendorLegEntries."Product Posting Type") + '","LoanNo":"' + VendorLegEntries."Loan No." + '"}');
                        TempResponse.ADDTEXT(',');
                        varCount -= 1;
                    UNTIL ((VendorLegEntries.Next = 0) or (varCount = 0));
                    if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
                end;
            end;
            // Loans
            ResponseMessage.ADDTEXT(']');
            ResponseMessage.ADDTEXT(',"Loans":[');
            CLEAR(TempResponse);
            Loans.RESET;
            Loans.SETRANGE("Member No.", Member."No.");
            if Loans.FINDSET THEN BEGIN
                REPEAT
                    Loans.CALCFIELDS("Loan Balance", "Monthly Installment");
                    TempResponse.ADDTEXT('{"LoanNo":"' + Loans."No." + '","Description":"' + Loans."Product Description" + '","PrincipalAmount":"' + FORMAT(Loans."Approved Amount", 0, 1) + '","Installments":"' + FORMAT(Loans.Installments) + '","MonthlyInstallment":"' + FORMAT(ROUND(Loans."Monthly Installment", 0.01, '>'), 0, 1) + '","ApplicationDate":"' + FORMAT(Loans."Posting Date") + '","Status":"' + FORMAT(Loans.Status) + '","ControlAccount":"' + Loans."Loan Account" + '","Balance":"' + FORMAT(ROUND(Loans."Loan Balance", 0.01, '>'), 0, 1) + '"}');
                    TempResponse.ADDTEXT(',');
                UNTIL Loans.NEXT = 0;
                if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            //Next Of Kins
            ResponseMessage.ADDTEXT(']');
            ResponseMessage.ADDTEXT(',"NextOfKins":[');
            CLEAR(TempResponse);
            MemberNomineeKin.RESET;
            MemberNomineeKin.SETRANGE("Source Code", Member."No.");
            MemberNomineeKin.SETRANGE("Document Type", MemberNomineeKin."Document Type"::"Next of Kin");
            if MemberNomineeKin.FINDSET THEN BEGIN
                REPEAT
                    if Relative.Get(MemberNomineeKin."Relative Code") then;
                    TempResponse.ADDTEXT('{"Relationship":"' + Relative.Description + '","Identification No.":"' + MemberNomineeKin."Identification No." + '","Name":"' + MemberNomineeKin.Name + '"}');
                    TempResponse.ADDTEXT(',');
                UNTIL MemberNomineeKin.NEXT = 0;
                if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            //Nominee
            ResponseMessage.ADDTEXT(']');
            ResponseMessage.ADDTEXT(',"Nominees":[');
            CLEAR(TempResponse);
            MemberNomineeKin.RESET;
            MemberNomineeKin.SETRANGE("Source Code", Member."No.");
            MemberNomineeKin.SETRANGE("Document Type", MemberNomineeKin."Document Type"::Nominee);
            if MemberNomineeKin.FINDSET THEN BEGIN
                REPEAT
                    if Relative.Get(MemberNomineeKin."Relative Code") then;
                    TempResponse.ADDTEXT('{"Relationship":"' + Relative.Description + '","Identification No.":"' + MemberNomineeKin."Identification No." + '","Name":"' + MemberNomineeKin.Name + '","Allocation":"' + Format(MemberNomineeKin.Allocation) + '"}');
                    TempResponse.ADDTEXT(',');
                UNTIL MemberNomineeKin.NEXT = 0;
                if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            //Subscriptions
            ResponseMessage.ADDTEXT(']');
            ResponseMessage.ADDTEXT(',"Subscriptions":[');
            CLEAR(TempResponse);
            MemberSubscriptions.RESET;
            MemberSubscriptions.SETRANGE("Source Code", Member."No.");
            if MemberSubscriptions.FINDSET THEN BEGIN
                REPEAT
                    TempResponse.ADDTEXT('{"Account":"' + MemberSubscriptions."Account Name" + '","Start Date":"' + Format(MemberSubscriptions."Start Date") + '","Amount":"' + Format(MemberSubscriptions.Amount) + '","Minimum Contribution":"' + Format(MemberSubscriptions."Minimum Contribution") + '"}');
                    TempResponse.ADDTEXT(',');
                UNTIL MemberSubscriptions.NEXT = 0;
                if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            //Guarantees
            ResponseMessage.ADDTEXT(']');
            ResponseMessage.ADDTEXT(',"Guarantees":[');
            CLEAR(TempResponse);
            LoanGuarantees.RESET;
            LoanGuarantees.SETRANGE("Member No.", Member."No.");
            LoanGuarantees.SETRANGE(Substituted, false);
            if LoanGuarantees.FINDSET THEN BEGIN
                REPEAT
                    if Loans.Get(LoanGuarantees."Loan No") then;
                    Loans.CalcFields("Loan Balance");
                    if Loans."Loan Balance" <> 0 then begin
                        TempResponse.ADDTEXT('{"MemberNo":"' + Loans."Member No." + '","MemberName":"' + Loans."Member Name" + '","LoanProduct":"' + Loans."Product Description" + '", "LoanNo":"' + Loans."No." + '", "Amount":"' + Format(LoanGuarantees."Guaranteed Amount") + '"}');
                        TempResponse.ADDTEXT(',');
                    end;
                UNTIL LoanGuarantees.NEXT = 0;
                if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            //Guarantors
            ResponseMessage.ADDTEXT(']');
            ResponseMessage.ADDTEXT(',"Guarantors":[');
            CLEAR(TempResponse);
            Loans.RESET;
            Loans.SETRANGE("Member No.", Member."No.");
            Loans.SetFilter("Loan Balance", '<>%1', 0);
            if Loans.FINDSET THEN BEGIN
                REPEAT
                    LoanGuarantees.Reset();
                    LoanGuarantees.SetRange("Loan No", Loans."No.");
                    LoanGuarantees.SetRange(Substituted, false);
                    if LoanGuarantees.FindSet then begin
                        repeat
                            TempResponse.ADDTEXT('{"MemberNo":"' + LoanGuarantees."Member No." + '","MemberName":"' + LoanGuarantees."Member Name" + '","LoanProduct":"' + Loans."Product Description" + '", "LoanNo":"' + Loans."No." + '", "Amount":"' + Format(LoanGuarantees."Guaranteed Amount") + '"}');
                            TempResponse.ADDTEXT(',');
                        until LoanGuarantees.Next = 0;
                    end;
                UNTIL Loans.NEXT = 0;
                if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            ResponseMessage.ADDTEXT(']}');
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Member Does Not Exist ' + MemberNo + '"}');
        end;
    end;

    procedure GetMemberAccountDetails(var AccountNo: Code[20]; Var ResponseCode: Code[10]; var ResponseMessage: BigText)
    var
        SaccoSetup: Record "General Ledger Setup";
        VendorLegEntries: Record "Vendor Ledger Entry";
        varCount: Integer;
    begin
        SaccoSetup.Get;
        Clear(ResponseCode);
        Clear(ResponseMessage);
        Clear(TempResponse);
        varCount := SaccoSetup."Channel Transactins Nos.";
        if Vendor.Get(AccountNo) then begin
            Vendor.CALCFIELDS(Balance);
            if Vendor.Balance <> 0 then begin
                TempResponse.ADDTEXT('{"Code":"' + Vendor."No." + '","Description":"' + Vendor.Name + '","Type":"' + Format(Vendor."Product Posting Type") + '","ShareCapital":"' + FORMAT(Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Share Capital Account") + '","CashWithdrawAllowed":"' + FORMAT(Vendor."Cash Withdraw Allowed") + '","CashDepositAllowed":"' + FORMAT(Vendor."Cash Deposit Allowed") + '","CashTransferAllowed":"' + FORMAT(Vendor."Cash Transfer Allowed") + '","Balance":"' + FORMAT(Vendor.Balance, 0, 1) + '","LatestTransactions":[');
                if varCount <> 0 then begin
                    VendorLegEntries.RESET;
                    VendorLegEntries.SETRANGE("Vendor No.", Vendor."No.");
                    VendorLegEntries.SetAscending("Entry No.", false);
                    if VendorLegEntries.FINDSET THEN BEGIN
                        REPEAT
                            VendorLegEntries.CalcFields(Amount);
                            TempResponse.ADDTEXT('{"PostingDate":"' + Format(VendorLegEntries."Posting Date") + '","DocumentNo":"' + VendorLegEntries."Document No." + '","Narration":"' + VendorLegEntries.Description + '","Amount":"' + FORMAT(VendorLegEntries.Amount) + '","TransactingType":"' + FORMAT(VendorLegEntries."Sacco Transaction Type") + '","ProductPostingType":"' + FORMAT(VendorLegEntries."Product Posting Type") + '","LoanNo":"' + VendorLegEntries."Loan No." + '"}');
                            TempResponse.ADDTEXT(',');
                            varCount -= 1;
                        UNTIL ((VendorLegEntries.Next = 0) or (varCount = 0));
                        if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
                    end;
                end;
                ResponseMessage.ADDTEXT(']}');
            end;
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Account Does Not Exist ' + AccountNo + '"}');
        end;
    end;

    procedure GetMemberNoFromIDNo(var IDNo: code[20]) MemberNo: code[20]
    var
        Members: Record Members;
    begin
        MemberNo := '';
        Members.Reset();
        Members.SetRange("Identification No.", IDNo);
        if Members.FindFirst() then
            MemberNo := Members."No."
        else
            Error('The ID No. %1 Does Not Exist', IDNo);
        exit(MemberNo);
    end;

    procedure GenerateAccountStatement(MemberNo: Code[20]; AccountNo: Code[20]; FromDate: Date; ToDate: Date) Base64Pdf: Text
    var
        AccountFilter: Text[100];
        DateFilter: Text;
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        AccountFilter := AccountNo;
        DateFilter := StrSubstNo('%1..%2', Format(FromDate), Format(ToDate));
        Member.Reset();
        Member.SetRange("No.", MemberNo);
        Member.SetFilter("Account Filter", AccountFilter);
        Member.SetFilter("Date Filter", DateFilter);
        if Member.FindSet() then begin
            RecRef.GetTable(Member);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Member Statement", '', ReportFormat::Pdf, outStreamReport, RecRef);
            Base64Pdf := Base64Convert.ToBase64(inStreamReport);
        end;
    end;

    procedure GetMemberGuarantors(MemberNo: Code[20]) Base64Pdf: Text
    var
        Members: Record Members;
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        Members.Reset();
        Members.SetRange("No.", MemberNo);
        if Members.FindSet() then begin
            RecRef.GetTable(Members);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Member Guarantors", '', ReportFormat::Pdf, outStreamReport, RecRef);
            Base64Pdf := Base64Convert.ToBase64(inStreamReport);
        end;
    end;

    procedure GetMemberGuarantees(MemberNo: Code[20]) Base64Pdf: Text
    var
        Members: Record Members;
        MemberGrntrs: Report "Member Guarantees";
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        Members.Reset();
        Members.SetRange("No.", MemberNo);
        if Members.FindSet() then begin
            RecRef.GetTable(Members);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Member Guarantees", '', ReportFormat::Pdf, outStreamReport, RecRef);
            Base64Pdf := Base64Convert.ToBase64(inStreamReport);
        end;
    end;

    procedure GetMandatoryUploadDocuments(EmployerCode: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        LoanDocuments: Record "Appraisal Documents";
    begin
        ResponseCode := '00';
        Clear(TempResponse);
        LoanDocuments.Reset();
        LoanDocuments.SetRange("Employer Code", EmployerCode);
        if LoanDocuments.FindSet() then begin
            ResponseMessage.AddText('{"Documents":[');
            repeat
                TempResponse.AddText('{"Description":"' + LoanDocuments."Document Description" + '"},');
            until LoanDocuments.Next() = 0;
            if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            ResponseMessage.AddText(']}');
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"No Documents Found in ' + LoanDocuments.GetFilters + '"}');
            exit;
        end;
    end;

    procedure GetBanks(var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Banks: Record "External Banks";
        Branches: Record "External Bank Branches";
    Begin
        Banks.Reset();
        if Banks.findset then begin
            ResponseMessage.AddText('{"BankCode":""' + Banks."Bank Code" + '",');
            ResponseMessage.AddText('"BankName":"' + Banks."Bank Name" + '","Branches":[');
            Branches.Reset;
            Branches.SetRange("Bank Code", Banks."Bank Code");
            if Branches.findset then begin
                repeat
                    TempResponse.AddText('{"BranchCode":"' + Branches."Branch Code" + '",');
                    TempResponse.AddText('"BranchName":"' + Branches."Branch Name" + '"},');
                until Branches.Next() = 0;
                if STRLEN(FORMAT(TempResponse)) > 1 then TempResponse.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            ResponseMessage.AddText(']}');
        end;
    end;

    procedure GetMemberGuarantorInformation(var MemberNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Member, Member2, Requestor : Record Members;
        Guarantors: Record "Loan Guarantees";
        LoansMgt: Codeunit "Loans Management";
        Loans: Record Loans;
        MyRequest: Record "Channel Loan Application";
        OnlineGuarantorReq: Record "Channel Guarantor Requests";
        RequestorPhone: Code[20];
        MaximumGuarantee: Decimal;
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);
        if Member.Get(MemberNo) then begin
            if not CheckMobileBankingRegistration(MemberNo) then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"You are not registered for Mobile Banking"}');
                exit;
            end;
            ResponseCode := '00';
            ResponseMessage.AddText('{"MemberName":"');
            ResponseMessage.AddText(Member."Full Name" + '","MyGuarantors":[');
            Clear(TempResponse);
            Loans.Reset();
            Loans.SetRange("Member No.", Member."No.");
            if Loans.FindSet() then begin
                repeat
                    Loans.CalcFields("Loan Balance");
                    if Loans."Loan Balance" > 0 then begin
                        Guarantors.Reset();
                        Guarantors.SetRange("Loan No", Loans."No.");
                        if Guarantors.FindSet() then begin
                            repeat
                                TempResponse.AddText('{');
                                TempResponse.AddText('"LoanNo":"' + Loans."No." + '",');
                                TempResponse.AddText('"GuarantorCode":"' + Guarantors."Member No." + '",');
                                TempResponse.AddText('"GuarantorName":"' + Guarantors."Member Name" + '",');
                                TempResponse.AddText('"GuaranteedAmount":"' + Format(Guarantors."Guaranteed Amount") + '",');
                                TempResponse.AddText('"LoanBalance":"' + Format(Loans."Loan Balance") + '",');
                                TempResponse.AddText('"OutstandingGuarantee":"' + Format(MemberManagement.GetOutstandingGuarantee(Loans."No.", MemberNo)) + '"');
                                TempResponse.AddText('},');
                            until Guarantors.Next() = 0;
                        end;
                    end;
                until Loans.Next = 0;
            end;
            if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            Clear(TempResponse);
            ResponseMessage.AddText('],"MyGuarantees":[');
            Guarantors.Reset();
            Guarantors.SetRange("Member No.", MemberNo);
            if Guarantors.FindSet() then begin
                repeat
                    if Loans.Get(Guarantors."Loan No") then begin
                        Loans.CalcFields("Loan Balance");
                        if Loans."Loan Balance" > 0 then begin
                            TempResponse.AddText('{');
                            TempResponse.AddText('"LoanNo":"' + Loans."No." + '",');
                            TempResponse.AddText('"OwnerNo":"' + Loans."Member No." + '",');
                            TempResponse.AddText('"OwnerName":"' + Loans."Member Name" + '",');
                            TempResponse.AddText('"LoanBalance":"' + format(Loans."Loan Balance") + '",');
                            TempResponse.AddText('"LoanStatus":"' + format(Loans."Loan Classification") + '",');
                            TempResponse.AddText('"GuaranteedAmount":"' + Format(Guarantors."Guaranteed Amount") + '",');
                            TempResponse.AddText('"OutstandingGuarantee":"' + Format(MemberManagement.GetOutstandingGuarantee(Loans."No.", MemberNo)) + '"');
                            TempResponse.AddText('},');
                        end;
                    end;
                until Guarantors.Next() = 0;
            end;
            if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            ResponseMessage.AddText('],"MyRequests":[');
            Clear(TempResponse);
            OnlineGuarantorReq.Reset();
            OnlineGuarantorReq.SetRange(Status, OnlineGuarantorReq.Status::Open);
            OnlineGuarantorReq.SetRange("ID No", Member."Identification No.");
            if OnlineGuarantorReq.FindSet() then begin
                repeat
                    RequestorPhone := '';
                    if Requestor.Get(OnlineGuarantorReq.Applicant) then RequestorPhone := Requestor."Mobile Phone No.";
                    if MyRequest.Get(OnlineGuarantorReq."Loan No") then;
                    MaximumGuarantee := 0;
                    MaximumGuarantee := LoansMgt.GetNonSelfGuaranteeEligibility(Member."No.");
                    TempResponse.AddText('{');
                    TempResponse.AddText('"LoanNo":"' + OnlineGuarantorReq."Loan No" + '",');
                    TempResponse.AddText('"LoanPrincipal":"' + format(OnlineGuarantorReq."Loan Principal") + '",');
                    TempResponse.AddText('"Applicant":"' + OnlineGuarantorReq.Applicant + '",');
                    TempResponse.AddText('"ApplicantName":"' + OnlineGuarantorReq.ApplicantName + '",');
                    TempResponse.AddText('"ApplicantPhoneNumber":"' + RequestorPhone + '",');
                    TempResponse.AddText('"RequestStatus":"' + format(OnlineGuarantorReq.Status) + '",');
                    TempResponse.AddText('"ProductCode":"' + format(MyRequest."Product Code") + '",');
                    TempResponse.AddText('"ProductName":"' + format(MyRequest."Product Description") + '",');
                    TempResponse.AddText('"Type":"' + Format(OnlineGuarantorReq."Request Type") + '",');
                    TempResponse.AddText('"MaximumGuarantee":"' + Format(MaximumGuarantee) + '",');
                    TempResponse.AddText('"RepaymentPeriod":"' + Format(MyRequest.Installments) + '",');
                    TempResponse.AddText('"RequestedAmount":"' + format(OnlineGuarantorReq."Requested Amount") + '"');
                    TempResponse.AddText('},');
                until OnlineGuarantorReq.Next() = 0;
            end;
            if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            ResponseMessage.AddText('],"LoansIHaveWitnessed":[');
            Clear(TempResponse);
            Loans.Reset();
            Loans.SetRange(Witness, Member."No.");
            if Loans.FindSet() then begin
                repeat
                    Loans.CalcFields("Loan Balance");
                    if Loans."Loan Balance" > 0 then begin
                        TempResponse.AddText('{');
                        TempResponse.AddText('"LoanNo":"' + Loans."No." + '",');
                        TempResponse.AddText('"LoanPrincipal":"' + format(Loans."Approved Amount") + '",');
                        TempResponse.AddText('"OwnerNo":"' + Loans."Member No." + '",');
                        TempResponse.AddText('"OwnerName":"' + Loans."Member Name" + '",');
                        TempResponse.AddText('"LoanType":"' + Loans."Product Description" + '",');
                        TempResponse.AddText('"LoanBalance":"' + format(Loans."Loan Balance") + '"');
                        TempResponse.AddText('},');
                    end;
                until Loans.Next() = 0;
            end;
            if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            ResponseMessage.AddText('],"MyWitnesses":[');
            Clear(TempResponse);
            Loans.Reset();
            Loans.SetRange("Member No.", Member."No.");
            if Loans.FindSet() then begin
                repeat
                    Loans.CalcFields("Loan Balance");
                    if Loans."Loan Balance" > 0 then begin
                        if Member2.Get(Loans.Witness) then begin
                            TempResponse.AddText('{');
                            TempResponse.AddText('"LoanNo":"' + Loans."No." + '",');
                            TempResponse.AddText('"LoanPrincipal":"' + format(Loans."Approved Amount") + '",');
                            TempResponse.AddText('"WitnessCode":"' + Loans.Witness + '",');
                            TempResponse.AddText('"WitnessName":"' + Member2."Full Name" + '",');
                            TempResponse.AddText('"LoanType":"' + Loans."Product Description" + '",');
                            TempResponse.AddText('"LoanBalance":"' + format(Loans."Loan Balance") + '"');
                            TempResponse.AddText('},');
                        end;
                    end;
                until Loans.Next() = 0;
            end;
            if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            ResponseMessage.AddText(']');
            ResponseMessage.AddText('}');
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Member Does Not Exist"}');
        end;
    end;

    procedure GetMemberNextOfKins(var MemberNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Members: Record Members;
        NextOfKins: Record "Member Nominee/Kin";
    begin
        Clear(ResponseMessage);
        Clear(ResponseCode);
        if Members.Get(MemberNo) then begin
            if not CheckMobileBankingRegistration(MemberNo) then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"You are not registered for Mobile Banking"}');
                exit;
            end;
            ResponseCode := '00';
            ResponseMessage.AddText('{"FullName":"' + Members."Full Name" + '","NextOfKins":[');
            Clear(TempResponse);
            NextOfKins.Reset();
            NextOfKins.SetRange("Source Code", MemberNo);
            if NextOfKins.FindSet() then begin
                repeat
                    TempResponse.AddText('{');
                    TempResponse.AddText('"KinType":"' + Format(NextOfKins."Relative Code") + '",');
                    TempResponse.AddText('"KinID":"' + NextOfKins."Identification No." + '",');
                    TempResponse.AddText('"Name":"' + NextOfKins.Name + '",');
                    TempResponse.AddText('"Allocation":"' + Format(NextOfKins.Allocation) + '"');
                    TempResponse.AddText('},');
                until NextOfKins.Next() = 0;
            end;
            if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            ResponseMessage.AddText(']}');
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Member Does Not Exist"}');
        end;
    end;

    internal procedure PopulateCRBData(MemberIDNo: Code[20]; MembrPhoneNo: Code[20])
    var
        MemberApplication: Record "Member Application";
        HtClient: HttpClient;
        //URLCode: TextConst EN U = 'https://test-api.ekenya.co.ke/ _APP_API/crb';
        URLCode: TextConst ENU = 'https://mobileapigateway.ekenya.co.ke:8095/Ushuru_APP_API/crb';
        Content: HttpContent;
        Response: HttpResponseMessage;
        ok: Boolean;
        AuthString: Text;
        UserName: Text[250];
        Password: Text[250];
        JToken, JLinesToken, ResultToken : JsonToken;
        JArray: JsonArray;
        JObject, NewJObject : JsonObject;
        JValue: JsonValue;
        i: Integer;
        ResponseText, PayLoad : Text;
        MpesaIntegrations: Codeunit "Integrations Mgmt";
    begin
        PayLoad := '{' + '"phoneNumber": "' + MembrPhoneNo + '",' + '"requestType":"product131",' + '"firstName":"Surname 271481",' + '"surName":"OtherNames 271481",' + '"idNumber":"' + MemberIDNo + '",' + '"deviceId":"23454123345461"' + '}';
        JObject.ReadFrom(MpesaIntegrations.CallService('crb', URLCode, 2, PayLoad, '', ''));
        Clear(JToken);
        if JObject.Get('data', JLinesToken) then begin
            NewJObject := JLinesToken.AsObject();
            ///Mobiloan Accounts                    
            Clear(ResultToken);
            ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'mobiLoanAccounts');
            Message('mobiLoanAccounts %1', ResultToken.AsValue().AsInteger());
            //AverageMobiLoanPrincipal
            Clear(ResultToken);
            ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'avgMobiLoanPrincipalAmount');
            Message('avgMobiLoanPrincipalAmount %1', ResultToken.AsValue().AsDecimal());
            //MaximumMobiLoanPrincipal
            Clear(ResultToken);
            ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'maxMobiLoanPrincipalAmount');
            Message('maxMobiLoanPrincipalAmount %1', ResultToken.AsValue().AsDecimal());
        end;
    end;

    procedure GenerateDividendSlip(MemberNo: Code[20]; Year: Code[20]; DividendOption: Option "Interest On Share Capital","Interest On Deposits"; var ResponseCode: Text; var ResponseMessage: Text) Base64Pdf: Text
    var
        AccountFilter: Text[100];
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        ProductCode: Code[20];
        DividendNo: Code[20];
        SaccoProducts: Record "Sacco Products";
        StartDate: Date;
        EndDate: Date;
        DividendHeader: Record "Dividend Header";
    begin
        Evaluate(StartDate, '0101' + Year);
        EndDate := CalcDate('CY', StartDate);
        DividendHeader.Reset();
        DividendHeader.Setrange("Start Date", StartDate);
        //DividendHeader.Setrange("End Date", EndDate);
        DividendHeader.Setrange("Posting Type", DividendHeader."Posting Type"::Payout);
        DividendHeader.Setrange(Posted, true);
        if DividendHeader.FindLast() then DividendNo := DividendHeader."No.";
        if DividendOption = DividendOption::"Interest On Share Capital" then begin
            SaccoProducts.Reset;
            SaccoProducts.Setrange("Product Posting Type", SaccoProducts."Product Posting Type"::"Share Capital Account");
            if SaccoProducts.FindFirst then ProductCode := SaccoProducts.Code;
        end
        else if DividendOption = DividendOption::"Interest On Deposits" then begin
            SaccoProducts.Reset;
            SaccoProducts.Setrange("Product Posting Type", SaccoProducts."Product Posting Type"::"Non Withdrawable Deposit");
            if SaccoProducts.FindFirst then ProductCode := SaccoProducts.Code;
        end;
        Member.Reset();
        Member.SetRange("No.", MemberNo);
        Member.SetFilter("Product Code Filter", ProductCode);
        Member.SetFilter("Dividend Code Filter", DividendNo);
        if Member.FindSet() then begin
            RecRef.GetTable(Member);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Dividend Slip", '', ReportFormat::Pdf, outStreamReport, RecRef);
            Base64Pdf := Base64Convert.ToBase64(inStreamReport);
            ResponseCode := '00';
            ResponseMessage := 'Dividend Slip Generated Successfully';
        end
        else begin
            ResponseCode := '01';
            ResponseMessage := 'The Member Does Not Exist';
        end;
    end;

    #endregion

    #region Loan Management

    procedure GetLoanBands(MemberNo: Code[20]; LoanCode: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        AppraisalParameters: Record "Loanees Payroll Codes";
        ProductInterestBands: Record "Product Interest Bands";
    begin
        ResponseCode := '00';
        ResponseMessage.AddText('{"ProductInterestBands":[');
        clear(TempResponse);
        ProductInterestBands.Reset();
        ProductInterestBands.SetCurrentKey("Min Installments");
        ProductInterestBands.SetAscending("Min Installments", true);
        ProductInterestBands.SetRange(ProductInterestBands."Source Code", LoanCode);
        ProductInterestBands.SetRange(ProductInterestBands.Active, true);
        if ProductInterestBands.FindSet then begin
            repeat
                TempResponse.AddText('{"Min Installments":"' + Format(ProductInterestBands."Min Installments") + '",');
                TempResponse.AddText('"Max Installments":"' + Format(ProductInterestBands."Max Installments") + '",');
                TempResponse.AddText('"Interest Rate":"' + Format(ProductInterestBands."Interest Rate") + '"},');
            until ProductInterestBands.Next() = 0;
        end;
        if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
        ResponseMessage.AddText(']}');
    end;

    procedure GetLoanCharges(LoanNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Loans: Record Loans;
        ProductCategories: Record "Sacco Product Categories";
        LoansMgt: Codeunit "Loans Management";
        ChargeAmount, NetAmount : Decimal;
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);
        Clear(TempResponse);
        if Loans.Get(LoanNo) then begin
            NetAmount := Loans."Approved Amount";
            ResponseMessage.AddText('{"LoanNo":"' + LoanNo + '",');
            ResponseMessage.AddText('"AppliedAmount":"' + format(Loans."Loan Amount") + '",');
            ResponseMessage.AddText('"ApprovedAmount":"' + format(Loans."Approved Amount") + '",');
            ResponseMessage.AddText('"LoanCharges":[');
            ChargeAmount := 0;
            ChargeAmount := LoansMgt.GetLoanProductChargesAmount(Loans."Product Code", Loans."Approved Amount");
            TempResponse.AddText('{"ChargeName":"' + Loans."Product Description" + '",');
            TempResponse.AddText('"ChargeAmount":"' + format(ChargeAmount) + '"},');
            NetAmount -= ChargeAmount;
            if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            ResponseMessage.AddText('],"NetAmount":"' + format(NetAmount) + '"}');
        end;
    end;

    procedure GenerateCalculatorSchedule(CalcNo: code[20])
    var
        LoansMgt: Codeunit "Loans Management";
        LoanCalculator: Record "Loan Calculator";
    begin
        if LoanCalculator.Get(CalcNo) then LoansMgt.GenerateCalculatorSchedule(LoanCalculator);
    end;

    procedure PopulateSubstitutionLines(DocumentNo: code[20])
    var
        LoansMgt: codeunit "Loans Management";
    begin
        LoansMgt.PopulateGuarantorSubLines(DocumentNo);
    end;

    procedure SubmitPortalLoanApplication(LoanNo: Code[20]; var ResponseCode: code[20])
    var
        OnlineLoanGuarantors: Record "Channel Guarantor Requests";
        LoanApplication: Record "Channel Loan Application";
        LoanAttachments: Record "Document Uploads";
        ChannelIntegration: Codeunit "Channels Integrations";
    begin
        OnlineLoanGuarantors.Reset();
        OnlineLoanGuarantors.SetRange(Status, OnlineLoanGuarantors.Status::Open);
        OnlineLoanGuarantors.SetRange("Loan No", LoanNo);
        if OnlineLoanGuarantors.FindFirst() then error('The %1 %2 has not responded to your request', OnlineLoanGuarantors."Request Type", OnlineLoanGuarantors."Member Name");
        LoanApplication.Get(LoanNo);
        if LoanApplication."Portal Status" <> LoanApplication."Portal Status"::New then Error('The Loan is already submitted');
        LoanApplication.CalcFields("Total Securities", "Total Guarantees", "Total Repayment");
        if (LoanApplication."Total Securities" + LoanApplication."Total Guarantees") < LoanApplication."Applied Amount" then Error('The Loan is unsecured');
        if LoanApplication."Total Repayment" = 0 then Error('Please Generate the Schedule');
        LoanAttachments.reset;
        LoanAttachments.SetRange("Parent No", LoanNo);
        LoanAttachments.SetRange("Parent Type", LoanAttachments."Parent Type"::"Loan Application");
        if LoanAttachments.IsEmpty then Error('Please attach the doucuments');
        LoanApplication."Portal Status" := LoanApplication."Portal Status"::Submitted;
        LoanApplication."Submitted On" := CurrentDateTime;
        LoanApplication.Modify();
        ChannelIntegration.SendSMSOnLoanSubmission(LoanNo);
    end;

    procedure SubmitOnlineGuarantorRequest(LoanNo: code[20])
    var
        Loans: Record Loans;
        OnlineGuarantors: Record "Channel Guarantor Requests";
    begin
        Loans.Get(LoanNo);
        OnlineGuarantors.Reset();
        OnlineGuarantors.SetRange("Loan No", LoanNo);
        OnlineGuarantors.SetRange(Status, OnlineGuarantors.Status::Open);
        if OnlineGuarantors.FindSet() then Error('Not all guarantors have responded to your requests!');
        Loans.TestField("Source Type", Loans."Source Type"::Channels);
        Loans."Portal Status" := Loans."Portal Status"::Submitted;
        Loans.Modify();
    end;

    procedure SubmitOnlineGuarantorSubstitution(DocumentNo: code[20])
    var
        OnlineGuarantors: Record "Channel Guarantor Sub.";
        GuarantorHeader: Record "Loan Security Mgmt Lines";
    begin
        GuarantorHeader.Get(DocumentNo);
        OnlineGuarantors.Reset();
        OnlineGuarantors.SetRange("Document No", DocumentNo);
        OnlineGuarantors.SetRange(Status, OnlineGuarantors.Status::New);
        if OnlineGuarantors.FindSet() then Error('Not all guarantors have responded to your requests!');
    end;

    procedure RespondToGuarantorSubstituion(DocumentNo: Code[20]; InitialGuarantor: Code[20]; MemberNo: Code[20]; var Amount: Decimal; ResponseType: Option Reject,Accept; var ResponseCode: Code[20])
    var
        OnlineRequest: Record "Channel Guarantor Sub.";
        LoanSecurities: Record "Loan Securities";
        GuarantorDetLines: Record "Loan Security Mgmt Det. Lines";
        GuarantorRepLines: Record "Loan Security Mgmt Lines";
        LineNo: integer;
        Members: Record Members;
        MNo: Code[20];
    begin
        Members.Reset();
        Members.SetRange("Identification No.", MemberNo);
        Members.SetRange("Guarantee Blocked", false);
        if Members.FindFirst() then
            MNo := Members."No."
        else
            Error('The Member Does Not Exist.');
        OnlineRequest.Reset();
        OnlineRequest.SetRange("Document No", DocumentNo);
        OnlineRequest.SetRange("Replace With", MemberNo);
        if OnlineRequest.FindSet() then begin
            if ResponseType = ResponseType::Accept then begin
                OnlineRequest.Status := OnlineRequest.Status::Accepted;
                GuarantorRepLines.Reset();
                GuarantorRepLines.SetRange("No.", DocumentNo);
                GuarantorRepLines.SetRange("Security Code", InitialGuarantor);
                if GuarantorRepLines.FindFirst() then begin
                    GuarantorDetLines.Reset();
                    GuarantorDetLines.SetRange("No.", DocumentNo);
                    GuarantorDetLines.SetRange("Line No", GuarantorRepLines."Line No");
                    GuarantorDetLines.SetRange("Security Code", MNo);
                    if GuarantorDetLines.FindSet() then
                        GuarantorDetLines.deleteall;
                    GuarantorDetLines.Init();
                    GuarantorDetLines."No." := DocumentNo;
                    GuarantorDetLines."Line No" := GuarantorRepLines."Line No";
                    GuarantorDetLines.Validate("Security Code", MNo);
                    GuarantorDetLines."Guarantee Amount" := Amount;
                    GuarantorDetLines.Insert(true);
                end;
            end
            else begin
                OnlineRequest.Status := OnlineRequest.Status::Rejected;
                GuarantorRepLines.Reset();
                GuarantorRepLines.SetRange("No.", DocumentNo);
                GuarantorRepLines.SetRange("Security Code", InitialGuarantor);
                if GuarantorRepLines.FindFirst() then begin
                    GuarantorDetLines.Reset();
                    GuarantorDetLines.SetRange("No.", DocumentNo);
                    GuarantorDetLines.SetRange("Line No", GuarantorRepLines."Line No");
                    GuarantorDetLines.SetRange("Security Code", MNo);
                    if GuarantorDetLines.FindSet() then GuarantorDetLines.deleteall;
                end;
            end;
            OnlineRequest."Responded On" := CurrentDateTime;
            OnlineRequest."Accepted Amount" := Amount;
            OnlineRequest.Modify();
            ResponseCode := '00';
        end;
    end;

    procedure OneThirdBasic(LoanNo: Code[20]) OneThird: Decimal
    var
        Loans: Record Loans;
        AppraisalParameters: Record "Loanees Payroll Transactions";
        OtherEarnings, NetIncome, ClearedEffect, BasicPay, HouseAllowance, OtherDeductions : Decimal;
        ParameterSetup: Record "Loanees Payroll Codes";
    begin
        AppraisalParameters.Reset();
        AppraisalParameters.SetRange("Source No.", LoanNo);
        if AppraisalParameters.FindSet() then begin
            repeat
                if AppraisalParameters.Type = AppraisalParameters.Type::Income then
                    NetIncome += AppraisalParameters.Amount
                else
                    NetIncome -= AppraisalParameters.Amount;
                if ParameterSetup.Get(AppraisalParameters.Code) then begin
                    if ParameterSetup."Cleared Effect" then ClearedEffect += AppraisalParameters.Amount;
                    if AppraisalParameters.Type = AppraisalParameters.Type::Deduction then
                        OtherDeductions += AppraisalParameters.Amount
                    else begin
                        if AppraisalParameters."Transaction Type" = AppraisalParameters."Transaction Type"::"Basic Salary" then
                            BasicPay += AppraisalParameters.Amount
                        else if AppraisalParameters."Transaction Type" = AppraisalParameters."Transaction Type"::"House Allownace" then
                            HouseAllowance += AppraisalParameters.Amount
                        else begin
                            if ParameterSetup."Cleared Effect" = false then OtherEarnings += AppraisalParameters.Amount;
                        end;
                    end;
                end;
            until AppraisalParameters.Next() = 0;
        end;
        OneThird := (1 / 3) * BasicPay;
        exit(OneThird);
    end;

    procedure GetAvailableRecovery(LoanNo: Code[20]) Available: Decimal
    var
        Loans: Record Loans;
        AppraisalParameters: Record "Loanees Payroll Transactions";
        OtherEarnings, OneThird, NetIncome, ClearedEffect, BasicPay, HouseAllowance, OtherDeductions : Decimal;
        ParameterSetup: Record "Loanees Payroll Codes";
    begin
        Available := 0;
        AppraisalParameters.Reset();
        AppraisalParameters.SetRange("Source No.", LoanNo);
        if AppraisalParameters.FindSet() then begin
            repeat
                if ParameterSetup.Get(AppraisalParameters.Code) then if AppraisalParameters."Transaction Type" = AppraisalParameters."Transaction Type"::"Basic Salary" then BasicPay += AppraisalParameters.Amount;
            until AppraisalParameters.Next() = 0;
        end;
        Available := AdjustedNet(LoanNo) - (1 / 3 * BasicPay);
        exit(Available);
    end;

    procedure MonthlyRepayment(LoanNo: Code[20]) MonthlyInstallment: Decimal
    var
        LoanApplication: Record "Channel Loan Application";
        AppraisalParameters: Record "Loanees Payroll Transactions";
        LoanProducts: Record "Sacco Products";
        TotalMrepay, PrincipalAmnt, LPrincipal, LInterest, LBalance : Decimal;
    begin
        TotalMrepay := 0;
        LoanApplication.Get(LoanNo);
        PrincipalAmnt := LoanApplication."Applied Amount";
        if LoanApplication."Interest Repayment Method" = LoanApplication."Interest Repayment Method"::Amortised THEN BEGIN
            LoanApplication.TESTFIELD("Installments");
            if LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                TotalMRepay := ROUND((LoanApplication."Interest Rate" / 12 / 100) / (1 - POWER((1 + (LoanApplication."Interest Rate" / 12 / 100)), -(LoanApplication."Installments"))) * (PrincipalAmnt), 0.0001, '>')
            ELSE
                TotalMRepay := ROUND((LoanApplication."Interest Rate" / 100) / (1 - POWER((1 + (LoanApplication."Interest Rate" / 100)), -(LoanApplication."Installments"))) * (PrincipalAmnt), 0.0001, '>');
        end;
        if LoanApplication."Interest Repayment Method" = LoanApplication."Interest Repayment Method"::"Straight Line" THEN BEGIN
            LoanApplication.TESTFIELD("Installments");
            LPrincipal := PrincipalAmnt / LoanApplication."Installments";
            if LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                LInterest := (LoanApplication."Interest Rate" / 12 / 100) * PrincipalAmnt
            ELSE
                LInterest := (LoanApplication."Interest Rate" / 100) * PrincipalAmnt;
            LInterest := LInterest;
            TotalMrepay := LPrincipal + LInterest;
        end;
        if LoanApplication."Interest Repayment Method" = LoanApplication."Interest Repayment Method"::"Reducing Balance" THEN BEGIN
            LoanApplication.TESTFIELD("Installments");
            LPrincipal := PrincipalAmnt / LoanApplication."Installments";
            if LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                LInterest := (LoanApplication."Interest Rate" / 12 / 100) * LBalance
            ELSE
                LInterest := (LoanApplication."Interest Rate" / 100) * LBalance;
            LInterest := LInterest;
            TotalMrepay := LPrincipal + LInterest;
        end;
        exit(TotalMrepay);
    end;

    procedure AdjustedNet(LoanNo: Code[20]) Adjusted: Decimal
    var
        AppraisalParameters: Record "Loanees Payroll Transactions";
        OtherEarnings, OneThird, NetIncome, ClearedEffect, BasicPay, HouseAllowance, OtherDeductions, OtherAllowances : Decimal;
        ParameterSetup: Record "Loanees Payroll Codes";
    begin
        Adjusted := 0;
        AppraisalParameters.Reset();
        AppraisalParameters.SetRange("Source No.", LoanNo);
        if AppraisalParameters.FindSet() then begin
            repeat
                if AppraisalParameters.Type = AppraisalParameters.Type::Income then
                    NetIncome += AppraisalParameters.Amount
                else
                    NetIncome -= AppraisalParameters.Amount;
                if ParameterSetup.Get(AppraisalParameters.Code) then begin
                    if ParameterSetup."Cleared Effect" then ClearedEffect += AppraisalParameters.Amount;
                    if AppraisalParameters.Type = AppraisalParameters.Type::Deduction then
                        OtherDeductions += AppraisalParameters.Amount
                    else begin
                        if AppraisalParameters."Transaction Type" = AppraisalParameters."Transaction Type"::"Basic Salary" then
                            BasicPay += AppraisalParameters.Amount
                        else if AppraisalParameters."Transaction Type" = AppraisalParameters."Transaction Type"::"House Allownace" then
                            HouseAllowance += AppraisalParameters.Amount
                        else begin
                            if ParameterSetup."Cleared Effect" = false then OtherEarnings += AppraisalParameters.Amount;
                        end;
                    end;
                end;
            until AppraisalParameters.Next() = 0;
        end;
        Adjusted := (BasicPay + HouseAllowance - OtherDeductions) + ClearedEffect + ((OtherEarnings) * 30 / 100);
        exit(Adjusted);
    end;

    procedure GetMemberLoans(MemberNo: Code[20]; var LoanNo: Code[20]; var isRunning: Boolean; var ResponseMessage: BigText)
    var
        Loans: Record Loans;
        TempResponse: BigText;
    begin
        Clear(ResponseMessage);
        Clear(TempResponse);
        Member.Get(MemberNo);
        ResponseMessage.AddText('{"Loans":[');
        Loans.Reset();
        Loans.SetRange("Member No.", MemberNo);
        if LoanNo <> '' then Loans.SetFilter("No.", '<>%1', LoanNo);
        if isRunning then
            Loans.SetFilter("Loan Balance", '<>%1', 0)
        else
            Loans.SetFilter("Loan Balance", '=%1', 0);
        if Loans.FindSet() then begin
            repeat
                Loans.CalcFields("Loan Balance");
                TempResponse.ADDTEXT('{"Code":"' + Loans."No." + '","ProductCode":"' + Loans."Product Code" + '","AccountNo":"' + Loans."Loan Account" + '","Description":"' + Loans."Product Description" + '","PrincipalAmount":"' + format(Loans."Approved Amount") + '","CurrentBalance":"' + FORMAT(Loans."Loan Balance") + '"}');
                TempResponse.ADDTEXT(',');
            until Loans.Next() = 0;
            if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
        end;
        ResponseMessage.AddText(']}');
    end;

    procedure SubmitGuarantorSubstitution(DocumentNo: Code[20]; var ResponseCode: Code[20])
    Var
        GuarantorHeader: Record "Loan Security Mgmt";
    begin
        if GuarantorHeader.Get(DocumentNo) then begin
            GuarantorHeader."Portal Status" := GuarantorHeader."Portal Status"::Submitted;
            GuarantorHeader."Submitted On" := CurrentDateTime;
            GuarantorHeader.Modify();
        end;
    end;

    procedure GenerateAppraisalReport(LoanNo: code[20]) Base64Pdf: Text
    var
        LoanApplication: Record "Channel Loan Application";
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        LoanApplication.Reset();
        LoanApplication.SetRange("No.", LoanNo);
        if LoanApplication.FindSet() then begin
            RecRef.GetTable(LoanApplication);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Channel Loan Application", '', ReportFormat::Pdf, outStreamReport, RecRef);
            Base64Pdf := Base64Convert.ToBase64(inStreamReport);
        end;
    end;

    procedure GenerateLoanSchedule(LoanNo: Code[20]) Base64Pdf: Text
    var
        LoanApplication: Record "Channel Loan Application";
        LoansMgt: Codeunit "Loans Management";
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if LoanApplication.Get(LoanNo) then LoansMgt.GenerateOnlineLoanRepaymentSchedule(LoanApplication);
        LoanApplication.Reset();
        LoanApplication.SetRange("No.", LoanNo);
        if LoanApplication.FindSet() then begin
            RecRef.GetTable(LoanApplication);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Channel Repayment Schedule", '', ReportFormat::Pdf, outStreamReport, RecRef);
            Base64Pdf := Base64Convert.ToBase64(inStreamReport);
        end;
    end;

    procedure SendGuarantorNotification(RequestedAmount: Decimal; NationalIDNo: Code[50]; LoanNo: Code[50])
    var
        ObjOnlineGuarantor: Record "Channel Guarantor Requests";
        Members: Record Members;
        SMSSource: Code[20];
        Loans: Record Loans;
        Members2: Record Members;
        SMSText: Text[250];
        SMSNo: Text[250];
        Notifications: Codeunit "Notifications Management";
        Portal: Codeunit "Channels Integrations";
        RespCode: code[50];
    begin
        CompanyInformation.Get;
        ObjOnlineGuarantor.reset;
        ObjOnlineGuarantor.SetRange("Loan No", LoanNo);
        ObjOnlineGuarantor.SetRange("ID No", NationalIDNo);
        if ObjOnlineGuarantor.findset then begin
            SMSSource := 'GUARANTOR-REQ';
            if Members.Get(ObjOnlineGuarantor."Member No") then begin
                if Loans.Get(ObjOnlineGuarantor."Loan No") then begin
                    if Members2.Get(Loans."Member No.") then begin
                        if ObjOnlineGuarantor."Request Type" = ObjOnlineGuarantor."Request Type"::Guarantor then
                            SMSText := 'Dear ' + Members."Full Name" + ', ' + Members2."Full Name" + ' has requested loan Guarantorship of  ' + format(RequestedAmount) + '. Kindly login to the portal to accept or reject the request. ' + CompanyInformation."Home Page" + ' Phone: ' + CompanyInformation."Phone No."
                        else if ObjOnlineGuarantor."Request Type" = ObjOnlineGuarantor."Request Type"::Witness then SMSText := 'Dear ' + Members."Full Name" + ',' + Members2."Full Name" + ' has requested you to witness a loan for them.Please Log In to the App/Members Portal to process the request.';
                        SMSNo := Members."Mobile Phone No.";
                        Notifications.SendSms(SMSNo, SMSText, SMSSource);
                        if Members."No." = Members2."No." then Portal.ProcessGuarantorRequest(ObjOnlineGuarantor."Loan No", Members."Identification No.", 0, ObjOnlineGuarantor.AppliedAmount, 0, RespCode, TempResponse);
                    end;
                end;
            end;
        end;
    end;

    procedure MonthlyRepayment_2(LoanNo: Code[20]) MonthlyInstallment: Decimal
    var
        LoanApplication: Record "Channel Loan Application";
        AppraisalParameters: Record "Loanees Payroll Transactions";
        LoanProducts: Record "Sacco Products";
        TotalMrepay, PrincipalAmnt, LPrincipal, LInterest, LBalance : Decimal;
    begin
        TotalMrepay := 0;
        LoanApplication.Get(LoanNo);
        PrincipalAmnt := LoanApplication."Applied Amount";
        if LoanApplication."Interest Repayment Method" = LoanApplication."Interest Repayment Method"::Amortised THEN BEGIN
            LoanApplication.TESTFIELD("Installments");
            if LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                TotalMRepay := ROUND((LoanApplication."Interest Rate" / 12 / 100) / (1 - POWER((1 + (LoanApplication."Interest Rate" / 12 / 100)), -(LoanApplication."Installments"))) * (PrincipalAmnt), 0.0001, '>')
            ELSE
                TotalMRepay := ROUND((LoanApplication."Interest Rate" / 100) / (1 - POWER((1 + (LoanApplication."Interest Rate" / 100)), -(LoanApplication."Installments"))) * (PrincipalAmnt), 0.0001, '>');
        end;
        if LoanApplication."Interest Repayment Method" = LoanApplication."Interest Repayment Method"::"Straight Line" THEN BEGIN
            LoanApplication.TESTFIELD("Installments");
            LPrincipal := PrincipalAmnt / LoanApplication."Installments";
            if LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                LInterest := (LoanApplication."Interest Rate" / 12 / 100) * PrincipalAmnt
            ELSE
                LInterest := (LoanApplication."Interest Rate" / 100) * PrincipalAmnt;
            LInterest := LInterest;
            TotalMrepay := LPrincipal + LInterest;
        end;
        if LoanApplication."Interest Repayment Method" = LoanApplication."Interest Repayment Method"::"Reducing Balance" THEN BEGIN
            LoanApplication.TESTFIELD("Installments");
            LPrincipal := PrincipalAmnt / LoanApplication."Installments";
            if LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                LInterest := (LoanApplication."Interest Rate" / 12 / 100) * LBalance
            ELSE
                LInterest := (LoanApplication."Interest Rate" / 100) * LBalance;
            LInterest := LInterest;
            TotalMrepay := LPrincipal + LInterest;
        end;
        exit(TotalMrepay);
    end;

    procedure RemoveOnlineRequest(LoanNo: Code[20]; MemberNo: Code[20]; RequestType: Option Guarantor,Witness; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        OnlineGuarantorRequests: Record "Channel Guarantor Requests";
    begin
        OnlineGuarantorRequests.Reset();
        OnlineGuarantorRequests.SetRange("Request Type", RequestType);
        OnlineGuarantorRequests.SetRange("Loan No", LoanNo);
        OnlineGuarantorRequests.SetRange("Member No", MemberNo);
        if OnlineGuarantorRequests.findset then begin
            OnlineGuarantorRequests.DeleteAll();
            ResponseCode := '00';
            ResponseMessage.AddText('{"Message":"Deleted Successfully"}');
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Request Does Not Exist or has been responded to"}');
        end;
    end;

    internal procedure CheckMaximumRunningLoans(ProductCode: Code[20]; MemberNo: Code[20]; var CurrentLoans: Integer; var AllowedLoans: Integer; var BuyOffAmount: Decimal)
    var
        LoanProducts: Record "Sacco Products";
        Loans: Record Loans;
    begin
        BuyOffAmount := 0;
        AllowedLoans := 0;
        CurrentLoans := 0;
        if LoanProducts.Get(ProductCode) then begin
            AllowedLoans := LoanProducts."Max. Running Loans";
            if AllowedLoans > 1 then begin
                Loans.Reset();
                Loans.SetFilter("Loan Balance", '>0');
                Loans.SetRange("Member No.", MemberNo);
                Loans.SetRange("Product Code", ProductCode);
                if Loans.FindSet() then begin
                    CurrentLoans := Loans.Count;
                end;
            end
            else begin
                Loans.Reset();
                Loans.SetFilter("Loan Balance", '>0');
                Loans.SetRange("Member No.", MemberNo);
                Loans.SetRange("Product Code", ProductCode);
                if Loans.FindSet() then begin
                    Loans.calcFields("Loan Balance");
                    BuyOffAmount := Loans."Loan Balance";
                    CurrentLoans := Loans.Count;
                end;
            end;
        end;
    end;


    procedure SubmitLoanApplication(LoanNo: Code[20]; MemberNo: Code[20]; ProductCode: Code[20]; AppliedAmount: Decimal; Installemnts: Integer; var LoanPurpose: Text; var GrossIncome: Decimal; var TotalDeductions: Decimal; ModeOfPayment: Enum "Recovery Modes"; var SourceType: Option MAPP,USSD; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        SaccoSetup: Record "General Ledger Setup";
        NoSeries: Codeunit NoSeriesManagement;
        FOSAAccount: Code[20];
        LProduct: Record "Sacco Products";
        ChannelLoanApplication: Record "Channel Loan Application";
        LoansMgt: Codeunit "Loans Management";
        CurrentLoans, AllowedLoans : Integer;
        BuyOffAamount, var_Qualified_Loan_Amount, var_Minimum_Can_Apply : Decimal;
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);

        CheckQualifiedLoanAmount(MemberNo, ProductCode, Installemnts, var_Qualified_Loan_Amount, var_Minimum_Can_Apply, responseCode, ResponseMessage);
        if ResponseCode = '00' then begin
            if AppliedAmount > var_Qualified_Loan_Amount then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Loan Has Exceeded The Maximum Qualified Amount"}');
                exit;
            end;

            if AppliedAmount < var_Minimum_Can_Apply then begin
                ResponseCode := '01';
                ResponseMessage.AddText(StrSubstNo('{"Error":"You can only apply atleast %1"}', Format(var_Minimum_Can_Apply)));
                exit;
            end;
            if ChannelLoanApplication.Get(LoanNo) then begin
                ChannelLoanApplication."Application Date" := WorkDate;
                ChannelLoanApplication.Validate("Member No.", MemberNo);
                ChannelLoanApplication.Validate("Product Code", ProductCode);
                ChannelLoanApplication."Posting Date" := WorkDate;
                ChannelLoanApplication."Repayment Start Date" := LoansMgt.GetRepaymentChannelStartDate(ChannelLoanApplication);
                ChannelLoanApplication.Validate(Installments, Installemnts);
                ChannelLoanApplication.Validate("Applied Amount", AppliedAmount);
                ChannelLoanApplication."Approved Amount" := ChannelLoanApplication."Applied Amount";
                ChannelLoanApplication."Source Type" := ChannelLoanApplication."Source Type"::Channels;
                ChannelLoanApplication."Mode of Disbursement" := ChannelLoanApplication."Mode of Disbursement"::"FOSA (Full)";
                FOSAAccount := MemberManagement.GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
                ChannelLoanApplication."Disbursement Account" := FOSAAccount;
                ChannelLoanApplication."Portal Status" := ChannelLoanApplication."Portal Status"::Submitted;
                ChannelLoanApplication.Modify;
                Commit;
                LoansMgt.GenerateOnlineLoanRepaymentSchedule(ChannelLoanApplication);
                ResponseCode := '00';
                ResponseMessage.AddText('{"Message":"Loan Updated Successfully","LoanNo":"' + LoanNo + '"}');
            end
            else begin
                ChannelLoanApplication.Reset();
                ChannelLoanApplication.SetRange("Member No.", MemberNo);
                ChannelLoanApplication.SetRange("Portal Status", ChannelLoanApplication."Portal Status"::New);
                if ChannelLoanApplication.FindFirst() then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"You have a pending loan application"}');
                    exit;
                end;
                LProduct.Get(ProductCode);
                SaccoSetup.Get();
                LoanNo := NoSeries.GetNextNo(SaccoSetup."Online Loan Nos.", Today, true);
                ChannelLoanApplication.Init();
                ChannelLoanApplication."No." := LoanNo;
                ChannelLoanApplication."Application Date" := WorkDate;
                ChannelLoanApplication.Validate("Member No.", MemberNo);
                ChannelLoanApplication.Validate("Product Code", ProductCode);
                ChannelLoanApplication."Posting Date" := WorkDate;
                ChannelLoanApplication."Repayment Start Date" := LoansMgt.GetRepaymentChannelStartDate(ChannelLoanApplication);
                ChannelLoanApplication.Validate(Installments, Installemnts);
                ChannelLoanApplication.Validate("Applied Amount", AppliedAmount);
                ChannelLoanApplication."Approved Amount" := ChannelLoanApplication."Applied Amount";
                ChannelLoanApplication."Source Type" := ChannelLoanApplication."Source Type"::Channels;
                ChannelLoanApplication."Mode of Disbursement" := ChannelLoanApplication."Mode of Disbursement"::"FOSA (Full)";
                FOSAAccount := MemberManagement.GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
                ChannelLoanApplication."Disbursement Account" := FOSAAccount;
                ChannelLoanApplication."Portal Status" := ChannelLoanApplication."Portal Status"::New;
                ChannelLoanApplication.Insert();
                LoansMgt.GenerateOnlineLoanRepaymentSchedule(ChannelLoanApplication);
                ResponseCode := '00';
                ResponseMessage.AddText('{"Message":"Loan Created Successfully","LoanNo":"' + LoanNo + '"}');
            end;
        end;
    end;

    procedure GetLoanApplications(MemberNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Members: Record Members;
        OnlineLoanApplication: Record "Channel Loan Application";
        EconomicSectors: Record "Economic Sectors";
        SubSectors: Record "Economic Subsectors";
        SubSubSectors: Record "Economic Sub-subsector";
        LoanParameters: Record "Loanees Payroll Transactions";
        LoanSchedule: Record "Loan Schedule";
        ChannelGuarantorRequests: array[2] of Record "Channel Guarantor Requests";
        BridgedLoans: Record "Loan Recoveries";
        Loans: Record Loans;
        DocumentUploads: Record "Document Uploads";
        LoansMgt: Codeunit "Loans Management";
        JResponse: JsonObject;
        JLoans: JsonArray;
        JLoan: JsonObject;
        JPayslipInfo: JsonArray;
        JPayslip: JsonObject;
        JSchedule: JsonArray;
        JScheduleLine: JsonObject;
        JRequests: JsonArray;
        JRequest: JsonObject;
        JBridgedLoans: JsonArray;
        JBridgedLoan: JsonObject;
        JDocUploads: JsonArray;
        JDocUpload: JsonObject;
        JSalaryAppraisals: JsonArray;
        JSalaryAppraisal: JsonObject;
        BridgedPrincipal, AmountGuranteed : Decimal;
        ResponseText: Text;
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);

        if not Members.Get(MemberNo) then begin
            ResponseCode := '01';
            JResponse.Add('Error', 'The Member Does Not Exist');
            JResponse.WriteTo(ResponseText);
            ResponseMessage.AddText(ResponseText);
            exit;
        end;

        ResponseCode := '00';
        JResponse.Add('MemberNo', Members."No.");
        JResponse.Add('MemberName', Members."Full Name");

        OnlineLoanApplication.Reset();
        OnlineLoanApplication.SetRange("Member No.", Members."No.");
        OnlineLoanApplication.SetFilter(Installments, '>0');
        if OnlineLoanApplication.FindSet() then
            repeat
                OnlineLoanApplication.CalcFields("Monthly Installment");
                Clear(JLoan);
                if EconomicSectors.Get(OnlineLoanApplication."Sector Code") then;
                if SubSectors.Get(OnlineLoanApplication."Sector Code", OnlineLoanApplication."Sub Sector Code") then;
                if SubSubSectors.Get(OnlineLoanApplication."Sector Code", OnlineLoanApplication."Sub Sector Code", OnlineLoanApplication."Sub-Susector Code") then;


                ChannelGuarantorRequests[1].Reset();
                ChannelGuarantorRequests[1].SetRange("Loan No", OnlineLoanApplication."No.");
                ChannelGuarantorRequests[1].SetRange("Request Type", ChannelGuarantorRequests[1]."Request Type"::Guarantor);
                if ChannelGuarantorRequests[1].FindSet() then begin
                    ChannelGuarantorRequests[1].CalcSums("Amount Accepted");
                    AmountGuranteed := ChannelGuarantorRequests[1]."Amount Accepted";
                end;
                JLoan.Add('LoanNo', OnlineLoanApplication."No.");
                JLoan.Add('ProductCode', OnlineLoanApplication."Product Code");
                JLoan.Add('MemberNumber', OnlineLoanApplication."Member No.");
                JLoan.Add('ProductName', OnlineLoanApplication."Product Description");
                JLoan.Add('AppliedAmount', Format(OnlineLoanApplication."Applied Amount"));
                JLoan.Add('AmountGuranteed', Format(AmountGuranteed));
                JLoan.Add('MonthlyInstallment', Format(OnlineLoanApplication."Monthly Installment"));
                JLoan.Add('MonthlyContribution', Format(OnlineLoanApplication."New Monthly Installment"));
                JLoan.Add('SectorCode', OnlineLoanApplication."Sector Code");
                JLoan.Add('SectorName', EconomicSectors."Sector Name");
                JLoan.Add('SubSectorCode', SubSectors."Sub Sector Code");
                JLoan.Add('SubSecotrName', SubSectors."Sub Sector Name");
                JLoan.Add('SubSubSectorCode', SubSubSectors."Sub-Subsector Code");
                JLoan.Add('SubSubSectorName', SubSubSectors."Sub-Subsector Description");
                JLoan.Add('Status', Format(OnlineLoanApplication.Status));
                // Payslip information
                Clear(JPayslipInfo);
                LoanParameters.Reset();
                LoanParameters.SetRange("Source No.", OnlineLoanApplication."No.");
                if LoanParameters.FindSet() then
                    repeat
                        Clear(JPayslip);
                        JPayslip.Add('ParameterCode', LoanParameters.Code);
                        JPayslip.Add('ParameterDescription', LoanParameters.Name);
                        JPayslip.Add('ParameterValue', Format(LoanParameters.Amount));
                        JPayslipInfo.Add(JPayslip);
                    until LoanParameters.Next() = 0;
                JLoan.Add('PayslipInformation', JPayslipInfo);

                // Loan schedule
                OnlineLoanApplication.CalcFields("Principal Repayment");
                if OnlineLoanApplication."Principal Repayment" = 0 then
                    LoansMgt.GenerateOnlineLoanRepaymentSchedule(OnlineLoanApplication);

                Clear(JSchedule);
                LoanSchedule.Reset();
                LoanSchedule.SetRange("Loan No.", OnlineLoanApplication."No.");
                if LoanSchedule.FindSet() then
                    repeat
                        Clear(JScheduleLine);
                        JScheduleLine.Add('Installment', LoanSchedule."Document No.");
                        JScheduleLine.Add('ExpectedDate', Format(LoanSchedule."Expected Date"));
                        JScheduleLine.Add('PrincipalAmount', Format(LoanSchedule."Principal Repayment"));
                        JScheduleLine.Add('InterestAmount', Format(LoanSchedule."Interest Repayment"));
                        JScheduleLine.Add('InstallmentAmount', Format(LoanSchedule."Monthly Repayment"));
                        JScheduleLine.Add('RunningBalance', Format(LoanSchedule."Running Balance"));
                        JSchedule.Add(JScheduleLine);
                    until LoanSchedule.Next() = 0;
                JLoan.Add('LoanSchedule', JSchedule);

                // Guarantor requests
                Clear(JRequests);
                ChannelGuarantorRequests[2].Reset();
                ChannelGuarantorRequests[2].SetRange("Loan No", OnlineLoanApplication."No.");
                if ChannelGuarantorRequests[2].FindSet() then
                    repeat
                        Clear(JRequest);
                        JRequest.Add('RequestType', Format(ChannelGuarantorRequests[2]."Request Type"));
                        JRequest.Add('MemberNo', Format(ChannelGuarantorRequests[2]."Member No"));
                        JRequest.Add('MemberName', Format(ChannelGuarantorRequests[2]."Member Name"));
                        JRequest.Add('MemberIDNo', Format(ChannelGuarantorRequests[2]."ID No"));
                        JRequest.Add('RequestedAmount', Format(ChannelGuarantorRequests[2]."Requested Amount"));
                        JRequest.Add('AcceptedAmount', Format(ChannelGuarantorRequests[2]."Amount Accepted"));
                        JRequest.Add('Status', Format(ChannelGuarantorRequests[2].Status));
                        JRequests.Add(JRequest);
                    until ChannelGuarantorRequests[2].Next() = 0;
                JLoan.Add('Requests', JRequests);

                // Bridged loans
                Clear(JBridgedLoans);
                BridgedLoans.Reset();
                BridgedLoans.SetRange("Loan No", OnlineLoanApplication."No.");
                if BridgedLoans.FindSet() then
                    repeat
                        BridgedPrincipal := 0;
                        if Loans.Get(BridgedLoans."Recovery Code") then begin
                            BridgedPrincipal := Loans."Approved Amount";
                            Clear(JBridgedLoan);
                            JBridgedLoan.Add('LoanNo', Format(BridgedLoans."Recovery Code"));
                            JBridgedLoan.Add('ProductName', Format(BridgedLoans."Recovery Description"));
                            JBridgedLoan.Add('BridgedPrincipal', Format(BridgedPrincipal));
                            JBridgedLoan.Add('BridgedAmount', Format(BridgedLoans.Amount));
                            JBridgedLoans.Add(JBridgedLoan);
                        end;
                    until BridgedLoans.Next() = 0;
                JLoan.Add('BridgedLoans', JBridgedLoans);

                // Salary appraisal — see note below on adapting this helper
                Clear(JSalaryAppraisal);
                JSalaryAppraisal.Add('AvailableRecovery', Format(GetAvailableRecovery(OnlineLoanApplication."No.")));
                JSalaryAppraisal.Add('AdjustedNet', Format(AdjustedNet(OnlineLoanApplication."No.")));
                JSalaryAppraisal.Add('OneThirdBasic', Format(OneThirdBasic(OnlineLoanApplication."No.")));
                JSalaryAppraisal.Add('EstimatedRepayment', Format(MonthlyRepayment(OnlineLoanApplication."No.")));
                JSalaryAppraisals.Add(JSalaryAppraisal);
                JLoan.Add('SalaryAppraisal', JSalaryAppraisals);

                // Document uploads
                Clear(JDocUploads);
                DocumentUploads.Reset();
                DocumentUploads.SetRange("Parent Type", DocumentUploads."Parent Type"::"Loan Application");
                DocumentUploads.SetRange("Parent No", OnlineLoanApplication."No.");
                if DocumentUploads.FindSet() then
                    repeat
                        Clear(JDocUpload);
                        JDocUpload.Add('DocumentType', DocumentUploads."Document Type");
                        JDocUpload.Add('DocumentName', DocumentUploads."Document No");
                        JDocUpload.Add('DocumentURL', DocumentUploads.URL);
                        JDocUploads.Add(JDocUpload);
                    until DocumentUploads.Next() = 0;
                JLoan.Add('DocumentUploads', JDocUploads);

                JLoans.Add(JLoan);
            until OnlineLoanApplication.Next() = 0;

        JResponse.Add('Loans', JLoans);
        JResponse.WriteTo(ResponseText);
        ResponseMessage.AddText(ResponseText);
    end;

    procedure SubmitBridgingLoans(LoanNo: Code[20]; BridgingLoanNo: Code[20]; RequestType: Option "Add Bridging","Delete Bridging"; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        LoanRecoveries: Record "Loan Recoveries";
        OnlineLoanApplication: Record "Channel Loan Application";
        Loans: Record Loans;
        BridgedAmount: Decimal;
        LoansMgt: Codeunit "Loans Management";
    begin
        if RequestType = RequestType::"Add Bridging" then begin
            BridgedAmount := 0;
            if OnlineLoanApplication.Get(LoanNo) then begin
                LoanRecoveries.Reset();
                LoanRecoveries.SetRange("Loan No", LoanNo);
                LoanRecoveries.SetRange("Recovery Type", LoanRecoveries."Recovery Type"::Loan);
                LoanRecoveries.SetRange("Recovery Code", BridgingLoanNo);
                if LoanRecoveries.FindSet() then LoanRecoveries.DeleteAll();
                LoanRecoveries.Reset();
                LoanRecoveries.SetRange("Loan No", LoanNo);
                if LoanRecoveries.FindSet() then begin
                    LoanRecoveries.CalcSums(Amount);
                    BridgedAmount := LoanRecoveries.Amount;
                end;
                if Loans.Get(BridgingLoanNo) then begin
                    Loans.CalcFields("Loan Balance");
                    if (Loans."Loan Balance" + BridgedAmount) > OnlineLoanApplication."Applied Amount" then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"The Bridging Loan is more than the applied amount"}');
                        exit;
                    end;
                    if Loans."Loan Balance" <= 0 then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"The Bridging Loan is cleared"}');
                        exit;
                    end
                    else begin
                        LoanRecoveries.Init();
                        LoanRecoveries."Loan No" := LoanNo;
                        LoanRecoveries."Recovery Type" := LoanRecoveries."Recovery Type"::Loan;
                        LoanRecoveries.Validate("Recovery Code", BridgingLoanNo);
                        LoanRecoveries."Recovery Description" := Loans."Product Description";
                        LoanRecoveries."Current Balance" := Loans."Loan Balance";
                        LoanRecoveries."Prorated Interest" := LoansMgt.GetProratedInterest(Loans."No.", Loans."Application Date");
                        LoanRecoveries.Validate(Amount, (LoanRecoveries."Current Balance" + LoanRecoveries."Prorated Interest"));
                        LoanRecoveries.Validate(Amount, Loans."Loan Balance");
                        LoanRecoveries.Validate("Commission Amount");
                        LoanRecoveries.Insert();
                        ResponseCode := '00';
                        ResponseMessage.AddText('{"Message":"Bridging Loan Added Successfully"}');
                        exit;
                    end;
                end
                else begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Bridging Loan Does Not Exist"}');
                    exit;
                end;
            end
            else begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Loan Application Does Not Exist"}');
                exit;
            end;
        end
        else begin
            if OnlineLoanApplication.Get(LoanNo) then begin
                if Loans.Get(BridgingLoanNo) then begin
                    if OnlineLoanApplication."Product Code" = Loans."Product Code" then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"You Cannot have two loans of the same product"}');
                        exit;
                    end;
                    LoanRecoveries.Reset();
                    LoanRecoveries.SetRange("Loan No", LoanNo);
                    LoanRecoveries.SetRange("Recovery Type", LoanRecoveries."Recovery Type"::Loan);
                    LoanRecoveries.SetRange("Recovery Code", BridgingLoanNo);
                    if LoanRecoveries.FindSet() then LoanRecoveries.DeleteAll();
                    ResponseCode := '00';
                    ResponseMessage.AddText('{"Message":"Loan Bridging Removed Successfully"}');
                    exit;
                end;
            end;
        end;
    end;

    internal procedure GetSalaryAppraisalResponse(LoanNo: Code[20]; var Tresp: BigText)
    var
        AvailableRecovery, AdjustedNet, EstimatedRepayment, OneThirdBasic : Decimal;
        PortalMgt: Codeunit "Channels Integrations";
    begin
        AvailableRecovery := PortalMgt.GetAvailableRecovery(LoanNo);
        AdjustedNet := PortalMgt.AdjustedNet(LoanNo);
        OneThirdBasic := PortalMgt.OneThirdBasic(LoanNo);
        EstimatedRepayment := PortalMgt.MonthlyRepayment(LoanNo);
        Tresp.AddText('"AvailableRecovery":"' + format(AvailableRecovery) + '",');
        Tresp.AddText('"AdjustedNet":"' + format(AdjustedNet) + '",');
        Tresp.AddText('"OneThirdBasic":"' + format(OneThirdBasic) + '",');
        Tresp.AddText('"EstimatedRepayment":"' + format(EstimatedRepayment) + '"');
    end;

    procedure SubmitLoanAppraisalParameter(LoanNo: Code[20]; ParameterCode: Code[20]; ParameterValue: Decimal; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        LoanAppraisalParameters: Record "Loanees Payroll Transactions";
        OnlineLoanApplication: Record "Channel Loan Application";
        AppraisalParameters: Record "Loanees Payroll Codes";
    begin
        clear(ResponseCode);
        clear(ResponseMessage);
        if AppraisalParameters.Get(ParameterCode) then begin
            if OnlineLoanApplication.Get(LoanNo) then begin
                if LoanAppraisalParameters.Get(LoanNo, ParameterCode) then begin
                    LoanAppraisalParameters.Validate(Amount, ParameterValue);
                    LoanAppraisalParameters.Modify();
                end
                else begin
                    LoanAppraisalParameters.Init();
                    LoanAppraisalParameters."Source No." := LoanNo;
                    LoanAppraisalParameters.Validate(Code, ParameterCode);
                    LoanAppraisalParameters.Validate(Amount, ParameterValue);
                    LoanAppraisalParameters.Insert();
                end;
                ResponseCode := '00';
                ResponseMessage.AddText('{');
                GetSalaryAppraisalResponse(OnlineLoanApplication."No.", ResponseMessage);
                ResponseMessage.AddText('}');
            end
            else begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Loan Application does not Exist"}');
                exit;
            end;
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Appraisal parameter does not Exist"}');
            exit;
        end;
    end;

    procedure ProcessGuarantorRequest(LoanNo: Code[20]; MemberNo: Code[20]; ResponseType: Option Accepted,Reject; Amount: Decimal; RequestType: Option Guarantor,Witness; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        OnlineGuarantors: Record "Channel Guarantor Requests";
        SMSMgt: Codeunit "Notifications Management";
        SMSText, SMSNo : Text[250];
        LoanApplication: Record "Channel Loan Application";
        LoanGuarantees: Record "Loan Guarantees";
        MaximumGuarantee: Decimal;
        LoansMgt: Codeunit "Loans Management";
        SMSSource: Code[20];
    begin
        Clear(responseCode);
        Clear(ResponseMessage);
        SMSSource := 'GRNT_WITN_RESP';
        MaximumGuarantee := 0;
        if Member.Get(MemberNo) then begin
            MaximumGuarantee := 0;
            MaximumGuarantee := LoansMgt.GetNonSelfGuaranteeEligibility(Member."No.");
            if RequestType = RequestType::Guarantor then begin
                if Amount > MaximumGuarantee then begin
                    responseCode := '01';
                    ResponseMessage.AddText('{"Error":"You Can Only Guarantee Upto' + Format(MaximumGuarantee) + '"}');
                    exit;
                end;
            end;
        end
        else begin
            responseCode := '01';
            ResponseMessage.AddText('{"Error":"The Member No Does Not Exist"}');
            exit;
        end;
        OnlineGuarantors.Reset();
        OnlineGuarantors.SetRange("Member No", MemberNo);
        OnlineGuarantors.SetRange("Loan No", LoanNo);
        if RequestType = RequestType::Guarantor then
            OnlineGuarantors.SetRange("Request Type", OnlineGuarantors."Request Type"::Guarantor)
        else
            OnlineGuarantors.SetRange("Request Type", OnlineGuarantors."Request Type"::Witness);
        if OnlineGuarantors.FindSet() then begin
            if ResponseType = ResponseType::Accepted then begin
                OnlineGuarantors.Status := OnlineGuarantors.Status::Approved;
                if RequestType = RequestType::Witness then begin
                    if LoanApplication.Get(LoanNo) then begin
                        LoanApplication.Validate(Witness, MemberNo);
                        LoanApplication.Modify();
                    end;
                end
                else begin
                    OnlineGuarantors."Amount Accepted" := Amount;
                    LoanGuarantees.Reset();
                    LoanGuarantees.SetRange("Loan No", LoanNo);
                    LoanGuarantees.SetRange("Member No.", MemberNo);
                    if LoanGuarantees.FindSet() then LoanGuarantees.DeleteAll();
                    if LoanApplication.Get(LoanNo) then begin
                        LoanGuarantees.Init();
                        LoanGuarantees."Loan No" := LoanNo;
                        LoanGuarantees.Validate("Member No.", MemberNo);
                        LoanGuarantees."Guaranteed Amount" := Amount;
                        LoanGuarantees."Loan Owner" := LoanApplication."Member No.";
                        LoanGuarantees.Insert(true);
                    end;
                end;
            end
            else
                OnlineGuarantors.Status := OnlineGuarantors.Status::Rejected;
            OnlineGuarantors."Amount Accepted" := Amount;
            OnlineGuarantors."Responded On" := CurrentDateTime;
            OnlineGuarantors.Modify();
            responseCode := '00';
            if Member.Get(OnlineGuarantors.Applicant) then begin
                if OnlineGuarantors."Request Type" = OnlineGuarantors."Request Type"::Guarantor then
                    SMSText := 'Dear ' + Member."Full Name" + ', ' + OnlineGuarantors."Member Name" + ' has accepted your guarantee request'
                else
                    SMSText := 'Dear ' + Member."Full Name" + ', ' + OnlineGuarantors."Member Name" + ' has accepted your loan witness request';
                SMSNo := Member."Mobile Phone No.";
                SMSMgt.SendSms(SMSNo, SMSText, SMSSource);
            end;
            ResponseMessage.AddText('{"Response":"Processed Successfully"}');
        end
        else begin
            responseCode := '01';
            ResponseMessage.AddText('{"Error":"The Guarantor Request Cannot Be Processed"}');
        end;
    end;

    procedure GetAppraisalPayslipParameters(var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        AppraisalParameters: Record "Loanees Payroll Codes";
    begin
        ResponseCode := '00';
        ResponseMessage.AddText('{"AppraisalParaeters":[');
        clear(TempResponse);
        AppraisalParameters.Reset();
        if AppraisalParameters.FindSet() then begin
            repeat
                TempResponse.AddText('{"ParameterCode":"' + AppraisalParameters.Code + '",');
                TempResponse.AddText('"Description":"' + AppraisalParameters.Name + '"},');
            until AppraisalParameters.Next() = 0;
        end;
        if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
        ResponseMessage.AddText(']}');
    end;

    procedure SubmitGuarantorRequest(LoanNo: Code[20]; MemberNo: Code[20]; RequestedAmount: Decimal; Action: Option New,Remove; var ResponseCode: Code[10]; var ResponseMessage: BigText)
    var
        OnlineGuarantorReq, OnlineGuarantorReq1 : Record "Channel Guarantor Requests";
        OnlineLoanApplication: Record "Channel Loan Application";
        TRespCode: Code[20];
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);
        if MemberNo = '' then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide the member you wish to request"}');
            exit;
        end;
        if Member.Get(MemberNo) = false then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide a valid member you wish to request"}');
            exit;
        end;
        if OnlineLoanApplication.Get(LoanNo) then begin
            if Action = Action::Remove then begin
                OnlineGuarantorReq.Reset();
                OnlineGuarantorReq.SetRange("Request Type", OnlineGuarantorReq."Request Type"::Guarantor);
                OnlineGuarantorReq.SetRange("Loan No", LoanNo);
                OnlineGuarantorReq.SetRange("Member No", MemberNo);
                if OnlineGuarantorReq.FindSet() then begin
                    OnlineGuarantorReq.DeleteAll();
                    ResponseCode := '00';
                    ResponseMessage.AddText('{"Message":"Guarantor Request Removed Successfully"}');
                    exit;
                end
                else begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Guarantor Request Does Not Exist or has been responded to"}');
                    exit;
                end;
            end else if Action = Action::New then begin

                OnlineGuarantorReq1.Reset();
                OnlineGuarantorReq1.SetRange("Member No", MemberNo);
                OnlineGuarantorReq1.SetRange("Loan No", LoanNo);
                OnlineGuarantorReq1.SetRange("Request Type", OnlineGuarantorReq1."Request Type"::Witness);
                if OnlineGuarantorReq1.FindFirst() then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Member is already requested to be a witness"}');
                    exit;
                end;

                OnlineGuarantorReq1.Reset();
                OnlineGuarantorReq1.SetRange("Member No", MemberNo);
                OnlineGuarantorReq1.SetRange("Loan No", LoanNo);
                OnlineGuarantorReq1.SetRange("Request Type", OnlineGuarantorReq1."Request Type"::Guarantor);
                if OnlineGuarantorReq1.IsEmpty then begin
                    if Member.Get(MemberNo) then begin
                        OnlineGuarantorReq.Init();
                        OnlineGuarantorReq."Loan No" := LoanNo;
                        OnlineGuarantorReq."ID No" := Member."Identification No.";
                        OnlineGuarantorReq."Member No" := MemberNo;
                        OnlineGuarantorReq."Member Name" := Member."Full Name";
                        OnlineGuarantorReq."Request Type" := OnlineGuarantorReq."Request Type"::Guarantor;
                        OnlineGuarantorReq."Loan Principal" := OnlineLoanApplication."Applied Amount";
                        OnlineGuarantorReq.PhoneNo := Member."Mobile Phone No.";
                        OnlineGuarantorReq.Applicant := OnlineLoanApplication."Member No.";
                        OnlineGuarantorReq.ApplicantName := OnlineLoanApplication."Member Name";
                        OnlineGuarantorReq."Application Date" := WorkDate;
                        OnlineGuarantorReq."Requested Amount" := RequestedAmount;
                        OnlineGuarantorReq."Product Name" := OnlineLoanApplication."Product Description";
                        OnlineGuarantorReq."Loan Type" := OnlineLoanApplication."Product Code";
                        OnlineGuarantorReq."Created On" := CurrentDateTime;
                        OnlineGuarantorReq.Insert();
                    end
                    else begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"The Member Does Not Exist"}');
                        exit;
                    end;
                end;
                if MemberNo = OnlineLoanApplication."Member No." then begin
                    ProcessGuarantorRequest(LoanNo, Member."Identification No.", 0, RequestedAmount, 0, TRespCode, TempResponse);
                end;
                ResponseCode := '00';
                ResponseMessage.AddText('{"Message":"Guarantor Requested Successfully"}');
            end;
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Loan Application ' + LoanNo + ' does not exist"}');
            exit;
        end;
    end;

    procedure SubmitWitnessRequest(LoanNo: Code[20]; MemberNo: Code[20]; var ResponseCode: Code[10]; var ResponseMessage: BigText)
    var
        OnlineGuarantorReq, OnlineGuarantorReq1 : Record "Channel Guarantor Requests";
        OnlineLoanApplication: Record "Channel Loan Application";
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);
        if MemberNo = '' then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide the member you wish to request"}');
            exit;
        end;
        if Member.Get(MemberNo) = false then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide a valid member you wish to request"}');
            exit;
        end;
        if OnlineLoanApplication.Get(LoanNo) then begin
            OnlineGuarantorReq1.Reset();
            OnlineGuarantorReq1.SetRange("Member No", MemberNo);
            OnlineGuarantorReq1.SetRange("Loan No", LoanNo);
            OnlineGuarantorReq1.SetRange("Request Type", OnlineGuarantorReq1."Request Type"::Guarantor);
            if OnlineGuarantorReq1.FindFirst() then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Member is already requested to be a Guarantor"}');
                exit;
            end;
            if MemberNo = OnlineLoanApplication."Member No." then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"You Cannot self-Witness"}');
                exit;
            end;
            OnlineGuarantorReq.Reset();
            OnlineGuarantorReq.SetRange("Loan No", LoanNo);
            if OnlineGuarantorReq.FindSet() then OnlineGuarantorReq.DeleteAll();
            OnlineGuarantorReq1.Reset();
            OnlineGuarantorReq1.SetRange("Member No", MemberNo);
            OnlineGuarantorReq1.SetRange("Loan No", LoanNo);
            OnlineGuarantorReq1.SetRange("Request Type", OnlineGuarantorReq1."Request Type"::Witness);
            if OnlineGuarantorReq1.IsEmpty then begin
                if Member.Get(MemberNo) then begin
                    OnlineGuarantorReq.Init();
                    OnlineGuarantorReq."Loan No" := LoanNo;
                    OnlineGuarantorReq."Member No" := MemberNo;
                    OnlineGuarantorReq."ID No" := Member."Identification No.";
                    OnlineGuarantorReq."Member Name" := Member."Full Name";
                    OnlineGuarantorReq."Request Type" := OnlineGuarantorReq."Request Type"::Witness;
                    OnlineGuarantorReq."Loan Principal" := OnlineLoanApplication."Applied Amount";
                    OnlineGuarantorReq.PhoneNo := Member."Mobile Phone No.";
                    OnlineGuarantorReq.Applicant := OnlineLoanApplication."Member No.";
                    OnlineGuarantorReq.ApplicantName := OnlineLoanApplication."Member Name";
                    OnlineGuarantorReq."Application Date" := WorkDate;
                    OnlineGuarantorReq."Product Name" := OnlineLoanApplication."Product Description";
                    OnlineGuarantorReq."Loan Type" := OnlineLoanApplication."Product Code";
                    OnlineGuarantorReq."Created On" := CurrentDateTime;
                    OnlineGuarantorReq.Insert();
                end
                else begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Member Does Not Exist"}');
                    exit;
                end;
            end;
            ResponseCode := '00';
            ResponseMessage.AddText('{"Message":"Witness Requested Successfully"}');
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Loan Application ' + LoanNo + ' does not exist"}');
            exit;
        end;
    end;

    procedure GetEconomicSectors(var ResponseCode: Code[10]; var ResponseMessage: BigText)
    var
        EconomicSectors: Record "Economic Sectors";
        EconomicSubSectors: Record "Economic Subsectors";
        EconomicSubSubSectors: Record "Economic Sub-subsector";
        TempResp1, TempResp2 : Bigtext;
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);
        ResponseMessage.AddText('{"EconomicSectors":[');
        EconomicSectors.Reset();
        if EconomicSectors.FindSet() then begin
            Clear(TempResponse);
            repeat
                TempResponse.AddText('{"Code":"' + EconomicSectors."Sector Code" + '",');
                TempResponse.AddText('"Name":"' + EconomicSectors."Sector Name" + '",');
                TempResponse.AddText('"SubSectors":[');
                EconomicSubSectors.Reset();
                EconomicSubSectors.SetRange("Sector Code", EconomicSectors."Sector Code");
                if EconomicSubSectors.FindSet() then begin
                    clear(TempResp1);
                    repeat
                        TempResp1.AddText('{"SubSectorCode":"' + EconomicSubSectors."Sub Sector Code" + '",');
                        TempResp1.AddText('"SubSectorName":"' + EconomicSubSectors."Sub Sector Name" + '",');
                        TempResp1.AddText('"SubSubSectors":[');
                        EconomicSubSubSectors.Reset();
                        EconomicSubSubSectors.SetRange("Sector Code", EconomicSectors."Sector Code");
                        EconomicSubSubSectors.SetRange("Sub Sector Code", EconomicSubSectors."Sub Sector Code");
                        if EconomicSubSubSectors.FindSet() then begin
                            repeat
                                TempResp2.AddText('{"SubSubSectorCode":"' + EconomicSubSubSectors."Sub-Subsector Code" + '",');
                                TempResp2.AddText('"SubSubSectorName":"' + EconomicSubSubSectors."Sub-Subsector Description" + '"},');
                            until EconomicSubSubSectors.Next() = 0;
                            if STRLEN(FORMAT(TempResp2)) > 1 then TempResp1.ADDTEXT(COPYSTR(FORMAT(TempResp2), 1, STRLEN(FORMAT(TempResp2)) - 1));
                        end;
                        TempResp1.AddText(']},');
                    until EconomicSubSectors.Next() = 0;
                    if STRLEN(FORMAT(TempResp1)) > 1 then TempResponse.ADDTEXT(COPYSTR(FORMAT(TempResp1), 1, STRLEN(FORMAT(TempResp1)) - 1));
                end;
                TempResponse.AddText(']},');
            until EconomicSectors.Next() = 0;
            if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
        end;
        ResponseMessage.AddText(']}');
        ResponseCode := '00';
    end;

    procedure GetLoanSchedule(LoanNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        LoanSchedule: Record "Loan Schedule";
        i: Integer;
        RunningBalance, Principal : Decimal;
        LoanApplication: Record "Channel Loan Application";
        LoansMgt: Codeunit "Loans Management";
    begin
        i := 1;
        Clear(ResponseCode);
        Clear(ResponseMessage);
        if LoanApplication.Get(LoanNo) then begin
            ResponseCode := '00';
            Principal := LoanApplication."Applied Amount";
            RunningBalance := Principal;
            ResponseMessage.AddText('{"LoanNo":"' + LoanNo + '","AppliedPrincipalAmount":"' + Format(Principal) + '","Schedule":[');
            LoanSchedule.Reset();
            LoanSchedule.SetRange("Loan No.", LoanApplication."No.");
            if LoanSchedule.FindSet() then begin
                repeat
                    TempResponse.AddText('{');
                    TempResponse.AddText('"InstallmentNo":"' + format(i) + '",');
                    TempResponse.AddText('"ExpectedDate":"' + LoanSchedule."Document No." + '",');
                    TempResponse.AddText('"PrincipalAmount":"' + format(LoanSchedule."Principal Repayment") + '",');
                    TempResponse.AddText('"InterestAmount":"' + format(LoanSchedule."Interest Repayment") + '",');
                    TempResponse.AddText('"RunningBalance":"' + format(LoanSchedule."Running Balance") + '"},');
                    i += 1;
                until LoanSchedule.Next() = 0;
            end
            else begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Loan Schedule Has not been created"}');
                exit;
            end;
            if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            ResponseMessage.AddText(']}');
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Loan Schedule Has not been created"}');
            exit;
        end;
    end;

    internal procedure LoanNetPayable(LoanNo: Code[20]) NetAmount: Decimal
    var
        Loans: Record Loans;
        DetailedLedger: Record "Detailed Vendor Ledg. Entry";
        LoanProduct: Record "Sacco Products";
        IntRate, ProcessingFee : Decimal;
        LoanRecoveries: Record "Loan Recoveries";
        ODAmount: Decimal;
    begin
        NetAmount := 0;
        ODAmount := 0;
        if Loans.Get(LoanNo) then begin
            Loans.Calcfields("Interest Repayment");
            LoanProduct.Get(Loans."Product Code");
            //Initialize Net Amount
            NetAmount := Loans."Approved Amount";
            //Recover Upfront Interest
            if LoanProduct."Charge UpFront Interest" Then NetAmount -= Loans."Interest Repayment";
            //Les Posting Charges
            NetAmount -= LoanMgmt.GetLoanProductChargesAmount(LoanProduct.Code, Loans."Approved Amount");
            ProcessingFee := 0;
            IntRate := GetInterestRate(Loans."Product Code", Loans.Installments, ProcessingFee);
            //Les Processing Fee
            NetAmount -= (ProcessingFee * 0.01 * Loans."Approved Amount");
            //Less Recoveries
            LoanRecoveries.Reset;
            LoanRecoveries.SetRange("Loan No", Loans."No.");
            if LoanRecoveries.FindSet then Begin
                LoanRecoveries.CalcSums(Amount, "Commission Amount");
                NetAmount -= (LoanRecoveries.Amount + LoanRecoveries."Commission Amount");
            end;
            //Less Overdraft
            if Vendor.Get(Loans."Disbursement Account") then begin
                Vendor.CalcFields(Balance);
                if Vendor.Balance < 0 then ODAmount := abs(Vendor.Balance);
            end;
            NetAmount -= ODAmount;
            if NetAmount < 0 Then NetAmount := 0;
            Loans."Mobile Loan Net" := NetAmount;
            Loans.Modify;
        end;
        Exit(NetAmount);
    end;

    procedure CompleteOnlineLoanApplication(LoanNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        OnlineLoanGuarantors: Record "Channel Guarantor Requests";
        LoanApplication: Record "Channel Loan Application";
    begin
        Clear(ResponseMessage);
        Clear(ResponseCode);
        OnlineLoanGuarantors.Reset();
        OnlineLoanGuarantors.SetRange(Status, OnlineLoanGuarantors.Status::Open);
        OnlineLoanGuarantors.SetRange("Loan No", LoanNo);
        if OnlineLoanGuarantors.FindFirst() then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The ' + format(OnlineLoanGuarantors."Request Type") + ' ' + OnlineLoanGuarantors."Member Name" + ' has not responded to your request"}');
            exit;
        end;
        LoanApplication.Get(LoanNo);
        if LoanApplication."Portal Status" <> LoanApplication."Portal Status"::New then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Loan Is Already Submitted"}');
            exit;
        end;
        LoanApplication.CalcFields("Total Securities", "Total Guarantees", "Total Repayment");
        if (LoanApplication."Total Securities" + LoanApplication."Total Guarantees") < LoanApplication."Applied Amount" then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Loan is unsecured"}');
            exit;
        end;
        if LoanApplication."Total Repayment" = 0 then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Generate the Schedule"}');
            exit;
        end;
        LoanApplication."Portal Status" := LoanApplication."Portal Status"::Submitted;
        LoanApplication."Submitted On" := CurrentDateTime;
        LoanApplication.Modify();
        ResponseCode := '00';
        ResponseMessage.AddText('{"Message":"Loan Submitted"}');
        exit;
    end;

    procedure UploadLoanDocument(LoanNo: Code[20]; FilePath: Text; FileName: Text; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        DocumentUploads: Record "Document Uploads";
        OnlineLoanApplication: Record "Channel Loan Application";
        EntryNo: Integer;
    begin
        if not OnlineLoanApplication.Get(LoanNo) then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Loan Does Not Exist"}');
            exit;
        end;
        DocumentUploads.Reset();
        if DocumentUploads.FindLast() then
            EntryNo := DocumentUploads."Entry No" + 1
        else
            EntryNo := 1;
        DocumentUploads.Reset();
        DocumentUploads.SetRange("Parent Type", DocumentUploads."Parent Type"::"Loan Application");
        DocumentUploads.SetRange("Parent No", LoanNo);
        DocumentUploads.SetRange("Document No", FileName);
        if DocumentUploads.FindSet() then DocumentUploads.DeleteAll();
        DocumentUploads.Init();
        DocumentUploads."Entry No" := EntryNo;
        DocumentUploads."Parent Type" := DocumentUploads."Parent Type"::"Loan Application";
        DocumentUploads."Parent No" := LoanNo;
        DocumentUploads."Document No" := FileName;
        DocumentUploads."Document Type" := FileName;
        DocumentUploads."Added By" := UserId;
        DocumentUploads."Added On" := CurrentDateTime;
        DocumentUploads.URL := FilePath;
        DocumentUploads.Insert();
        ResponseCode := '00';
        ResponseMessage.AddText('{"Message":"Document Uploaded Successfully"}');
    end;

    procedure PostMobileLoanApplication(var CUSTOMER_NO: Code[20]; var LOAN_PRODUCTCODE: Code[20]; var CHANNEL_REFERENCE: Code[20]; var REQUEST_TYPE: Code[20]; var TRANSACTION_AMOUNT: Decimal; var NARRATION: Code[100]; var REPAYMENTPERIOD: Integer; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Loans, ExistingLoan : Record Loans;
        SMSManagement: Codeunit "Notifications Management";
        LoanNo, MemberNumber, FOSAAccount, LoanAccount : Code[20];
        GeneralSetup: Record "General Ledger Setup";
        NoSeries: Codeunit NoSeriesManagement;
        LoansMgt: Codeunit "Loans Management";
        SMSPhoneNo, SMSText : Text;
        LoanProducts: Record "Sacco Products";
        CurrentLoans, AllowedLoans : Integer;
        var_Qualified_Loan_Amount, var_Minimum_Can_Apply, BuyoffAmount, CooperateCharge, OutstandingLoan : Decimal;
        SMSSource: Code[20];
        Eloan: Record "E-Loan Application";
        CurrentBalance: Decimal;
    begin
        Clear(ResponseMessage);
        Clear(ResponseCode);
        SMSSource := 'MOBI_LOAN';
        if LoanProducts.Get(LOAN_PRODUCTCODE) then begin
            if TRANSACTION_AMOUNT > LoanProducts."Maximum Loan Amount" then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Loan Has Exceeded The Maximum Amount"}');
                exit;
            end;
            CheckQualifiedLoanAmount(CUSTOMER_NO, LOAN_PRODUCTCODE, REPAYMENTPERIOD, var_Qualified_Loan_Amount, var_Minimum_Can_Apply, responseCode, ResponseMessage);
            if responseCode = '00' then begin
                if TRANSACTION_AMOUNT > var_Qualified_Loan_Amount then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Loan Has Exceeded The Maximum Qualified Amount"}');
                    exit;
                end;

                if TRANSACTION_AMOUNT < var_Minimum_Can_Apply then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText(StrSubstNo('{"Error":"You can only apply atleast %1"}', Format(var_Minimum_Can_Apply)));
                    exit;
                end;

                if REPAYMENTPERIOD <= 0 then REPAYMENTPERIOD := 1;
                if REPAYMENTPERIOD > LoanProducts."Maximum Installments" then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The repayment period has exceeded the Maximum allowed Installments"}');
                    exit;
                end;
                if LoanProducts."Max. Running Loans" <= 1 then begin
                    OutstandingLoan := 0;
                    ExistingLoan.Reset;
                    ExistingLoan.SetRange("Member No.", MemberNumber);
                    ExistingLoan.SetFilter("Loan Balance", '>0');
                    ExistingLoan.Setrange("Product Code", LOAN_PRODUCTCODE);
                    if ExistingLoan.FindSet() then Begin
                        repeat
                            ExistingLoan.CalcFields("Loan Balance");
                            OutstandingLoan += ExistingLoan."Loan Balance";
                        until ExistingLoan.Next = 0;
                    end;
                    if OutstandingLoan < 0 then OutstandingLoan := 0;
                    if OutstandingLoan >= TRANSACTION_AMOUNT then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"You Have an Existing Loan. Apply amount higher than ' + format(OutstandingLoan) + '"}');
                        exit;
                    end;
                end;
            end;
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Loan Product Does Not Exist"}');
            exit;
        end;
        if Member.Get(CUSTOMER_NO) then begin
            CheckMaximumRunningLoans(LOAN_PRODUCTCODE, CUSTOMER_NO, CurrentLoans, AllowedLoans, BuyOffAmount);
            if AllowedLoans = 1 then begin
                if ((BuyOffAmount > TRANSACTION_AMOUNT) AND (CurrentLoans <> 0)) then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"You Can only apply more than KSh.' + format(BuyOffAmount) + '"}');
                    exit;
                end;
            end
            else begin
                if (CurrentLoans + 1) > AllowedLoans then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"You Can only have ' + format(AllowedLoans) + ' Running Loans of this Product"}');
                    exit;
                end;
            end;
            MemberNumber := Member."No.";
            FOSAAccount := MemberManagement.GetMemberAccount(MemberNumber, ProductPostingType::"Withdrawable Deposit");
            if FOSAAccount = '' then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Member Does Not have a FOSA Account"}');
                exit;
            end;
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Member Does Not Exist"}');
            exit;
        end;
        Loans.Reset;
        Loans.Setrange("Member No.", MemberNumber);
        Loans.Setrange("Product Code", LOAN_PRODUCTCODE);
        Loans.Setrange(Status, Loans.Status::Approved);
        Loans.Setrange(Posted, false);
        if Loans.FindFirst then begin
            ResponseCode := '01';
            ResponseMessage.AddText(StrSubstNo('{"Error":"You have a submited Loan No. %1 which is not posted yet. Kindly reach out for support if the loan is not posted after a while.}', Loans."No."));
            exit;
        end;

        GeneralSetup.Get();
        LoanNo := NoSeries.GetNextNo(GeneralSetup."Loan Nos.", Today, true);
        if Vendor.Get(FOSAAccount) then begin
            Vendor.CalcFields(Balance);
            CurrentBalance := Vendor.Balance;
        end;
        Loans.Init();
        Loans."No." := LoanNo;
        Loans.Validate("Member No.", MemberNumber);
        Loans."Application Date" := WorkDate;
        Loans."Posting Date" := WorkDate;
        Loans.Validate("Product Code", LOAN_PRODUCTCODE);
        Loans."Repayment Start Date" := LoansMgt.GetRepaymentStartDate(Loans);
        Loans.Validate(Installments, REPAYMENTPERIOD);
        Loans.Validate("Loan Amount", TRANSACTION_AMOUNT);
        Loans."Approved Amount" := Loans."Loan Amount";
        Loans."Source Type" := Loans."Source Type"::Channels;
        Loans."Mode of Disbursement" := Loans."Mode of Disbursement"::"FOSA (Full)";
        Loans."Disbursement Account" := FOSAAccount;
        Loans."Loan Account" := LoanAccount;
        Loans."Sales Representative" := 'MOBILE';
        Loans."Sector Code" := GeneralSetup."Sector Code";
        Loans."Sub Sector Code" := GeneralSetup."Sub Sector Code";
        Loans."Sub-Subsector Code" := GeneralSetup."Sub-Subsector Code";
        Loans.Status := Loans.Status::Approved;
        Loans.Insert();

        Eloan.Init();
        Eloan."Loan No" := Loans."No.";
        Eloan."Member No" := Loans."Member No.";
        Eloan."Member Name" := Loans."Member Name";
        Eloan."Application Date" := Loans."Application Date";
        Eloan.Posted := true;
        Eloan."Product Code" := Loans."Product Code";
        Eloan."Product Name" := Loans."Product Description";
        Eloan."Applied Amount" := Loans."Approved Amount";
        LoansMgt.GenerateLoanRepaymentSchedule(Loans);
        LoansMgt.DisburseLoan(Loans);
        SaccoSetup.Get;
        if ((SaccoSetup."Mobile Withdrawal Alert Limit" > 0) and (Loans."Approved Amount" > SaccoSetup."Mobile Withdrawal Alert Limit")) then begin
            UserSetup.Reset();
            UserSetup.SetRange("Mobile Limit Notifications", true);
            if UserSetup.FindSet then begin
                repeat
                    if Employee.Get(UserSetup."Employee No.") then begin
                        Member.Get(Loans."Member No.");
                        SMSPhoneNo := Employee."Phone No.";
                        SMSText := StrSubstNo('ALERT. Dear %1, %2 have applied Loan %3, Product %4 hitting limit violation by %5. Urgently review and take necessary action.', Employee."First Name", Member."First Name", Loans."No.", Loans."Product Description", Loans."Approved Amount");
                        SMSManagement.SendSms(SMSPhoneNo, SMSText, SMSSource);
                    end;
                until UserSetup.Next = 0;
            end;
        end;
        Eloan.Insert();
        CooperateCharge := 0;
        if CurrentBalance > 0 then
            CooperateCharge := JournalMgt.GetChargesAmount(LoanProducts.Category, Loans."Approved Amount");
        ResponseCode := '00';
        ResponseMessage.AddText('{"Message":"Loan Application Received Successfully","LoanNumber":"' + LoanNo + '","DueDate":"' + Format(Loans."Repayment End Date") + '","NetPayable":"' + Format(Round(LoanNetPayable(Loans."No."), 1, '<'), 0, 1) + '","MpesaCooperateCharge":"' + Format(CooperateCharge) + '"}');
    end;

    procedure GetMobileTransactionTypes(var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        ChannelTransactions: Record "Channel Transaction Setup";
    begin
        Clear(ResponseMessage);
        Clear(TempResponse);
        responseCode := '00';
        ResponseMessage.AddText('{"TransactionTypes":[');
        ChannelTransactions.Reset();
        if ChannelTransactions.findset then begin
            repeat
                TempResponse.AddText('{');
                TempResponse.AddText('"TransactionCode":"' + ChannelTransactions.Code + '",');
                TempResponse.AddText('"TransactionName":"' + ChannelTransactions.Description + '",');
                TempResponse.AddText('"ChargeCode":"' + ChannelTransactions."Charge Code" + '", ');
                TempResponse.AddText('"MinimumAmount":"' + format(ChannelTransactions."Minimum Amount") + '",');
                TempResponse.AddText('"MaximumAmount":"' + format(ChannelTransactions."Maximum Amount") + '"');
                TempResponse.AddText('},');
            until ChannelTransactions.Next() = 0;
        end;
        if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
        ResponseMessage.AddText(']}');
    end;

    internal procedure MobileLoanBlocked(MemberNo: Code[20]; ProductCode: Code[20]) Blocked: Boolean
    var
        MobileBlock: Record "Channel Loan Blocking";
    begin
        MobileBlock.Reset();
        MobileBlock.SetRange("Member No", MemberNo);
        MobileBlock.SetRange("Product Code", ProductCode);
        if MobileBlock.IsEmpty then
            exit(false)
        else
            exit(true);
    end;

    procedure GetLoanProducts(var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        SaccoProducts: Record "Sacco Products";
    begin
        Clear(ResponseMessage);
        Clear(TempResponse);
        responseCode := '00';
        ResponseMessage.AddText('{"LoanProducts": [');
        SaccoProducts.Reset();
        SaccoProducts.SetRange("Product Posting Type", SaccoProducts."Product Posting Type"::"Loan Account");
        SaccoProducts.SetRange("View Online", true);
        if SaccoProducts.FindSet then begin
            repeat
                TempResponse.AddText('{');
                TempResponse.AddText('"Code":"' + SaccoProducts.Code + '", ');
                TempResponse.AddText('"Description":"' + SaccoProducts.Description + '", ');
                TempResponse.AddText('"MinimumAmount":"' + Format(SaccoProducts."Minimum Loan Amount") + '", ');
                TempResponse.AddText('"MaximumAmount":"' + Format(SaccoProducts."Maximum Loan Amount") + '", ');
                TempResponse.AddText('"Minimum Installments":"' + Format(SaccoProducts."Minimum Installments") + '", ');
                TempResponse.AddText('"Maximum Installments":"' + Format(SaccoProducts."Maximum Installments") + '", ');
                TempResponse.AddText('"Requires Installments":"' + Format(SaccoProducts."Maximum Installments" <> 1) + '", ');
                TempResponse.AddText('"InterestRate":"' + Format(SaccoProducts."Interest Rate") + '", ');
                TempResponse.AddText('"RateType":"' + Format(SaccoProducts."Rate Type") + '", ');
                TempResponse.AddText('"ChargeUpFrontInterest":"' + Format(SaccoProducts."Charge UpFront Interest") + '", ');
                TempResponse.AddText('"MaxRunningLoans":"' + Format(SaccoProducts."Max. Running Loans") + '", ');
                TempResponse.AddText('"MobileAppraisalType":"' + Format(SaccoProducts."Mobile Appraisal Type") + '", ');
                TempResponse.AddText('"MobileLoan":"' + Format(SaccoProducts."Mobile Loan") + '",');
                TempResponse.AddText('"ViewOnline":"' + Format(SaccoProducts."View Online") + '"');
                TempResponse.AddText('},');
            until SaccoProducts.Next() = 0;
        end;
        if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
        ResponseMessage.AddText(']}');
    end;

    procedure GetLoanProduct(var MemberNo: Code[20]; var ProductCode: Code[20]; var ResponseMessage: Text)
    var
        SaccoProducts: Record "Sacco Products";
        InterestBands: Record "Product Interest Bands";
        LoanProductObj: JsonObject;
        IntrestBandsObj: JsonObject;
        LoanProductArr: JsonArray;
        IntrestBandsArr: JsonArray;
        Loans: Record Loans;
        LoanCount: Integer;
        LoanBal: Decimal;
    begin
        Clear(ResponseMessage);
        if SaccoProducts.Get(ProductCode) then begin
            Loans.Reset();
            Loans.SetRange("Member No.", MemberNo);
            Loans.SetRange("Product Code", ProductCode);
            Loans.SetFilter("Loan Balance", '<>%1', 0);
            if Loans.FindSet() then begin
                repeat
                    Loans.CalcFields("Loan Balance");
                    LoanCount += 1;
                    LoanBal += Loans."Loan Balance";
                until Loans.Next = 0;
            end;
            LoanProductObj.Add('Code', SaccoProducts.Code);
            LoanProductObj.Add('Description', SaccoProducts.Description);
            LoanProductObj.Add('MinimumAmount', SaccoProducts."Minimum Loan Amount");
            LoanProductObj.Add('MaximumAmount', SaccoProducts."Maximum Loan Amount");
            LoanProductObj.Add('Minimum Installments', SaccoProducts."Minimum Installments");
            LoanProductObj.Add('Maximum Installments', SaccoProducts."Maximum Installments");
            LoanProductObj.Add('InterestRate', SaccoProducts."Interest Rate");
            LoanProductObj.Add('RateType', SaccoProducts."Rate Type");
            LoanProductObj.Add('ChargeUpFrontInterest', SaccoProducts."Charge UpFront Interest");
            LoanProductObj.Add('MaxRunningLoans', SaccoProducts."Max. Running Loans");
            LoanProductObj.Add('MobileAppraisalType', SaccoProducts."Mobile Appraisal Type");
            LoanProductObj.Add('RunningLoans', LoanCount);
            LoanProductObj.Add('RunningBalance', LoanBal);
            LoanProductArr.Add(LoanProductObj);
            InterestBands.Reset();
            InterestBands.SetRange("Source Code", SaccoProducts.Code);
            InterestBands.SetRange(Active, true);
            if InterestBands.FindSet() then begin
                IntrestBandsObj.Add('InstallmentFrom', '');
                IntrestBandsObj.Add('InstallmentTo', '');
                IntrestBandsObj.Add('InterestRate', '');
                repeat
                    IntrestBandsObj.Replace('InstallmentFrom', InterestBands."Min Installments");
                    IntrestBandsObj.Replace('InstallmentTo', InterestBands."Max Installments");
                    IntrestBandsObj.Replace('InterestRate', InterestBands."Interest Rate");
                    IntrestBandsArr.Add(IntrestBandsObj);
                until InterestBands.Next() = 0;
            end;
            LoanProductArr.Add(IntrestBandsArr);
        end;
        LoanProductArr.WriteTo(ResponseMessage);
    end;

    procedure GetMobiLoanAppraisal(var CUSTOMER_NO: Code[20]; var CHANNEL_REFERENCE: Code[20]; var REQUEST_TYPE: Code[20]; var NARRATION: code[50]; var NUMBER_OF_MONTHS: integer; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        monthlyPrincipalRepayment, InterestDueOnLoan, QualifiedAmount, MaxMonthluRepayment, MaxMonthlhyRepayment : Decimal;
        maxMonthlyRepayment, AvailableSalary, EligibleAmount, MinSalary, BaseAmount, LowestAmount, NetAmount, NetPay, MonthlyContribution, DepositEligibility, Eligibility, Deposits : Decimal;
        SalaryCount, CurrentLoans, AllowedLoans : Integer;
        VendorLedger: Record "Vendor Ledger Entry";
        Sdate, Edate, TempSdate, EndDate : Date;
        Loans: Record Loans;
        LoanProducts1, LoanProduct, LProducts : Record "Sacco Products";
        LoansManagement: Codeunit "Loans Management";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        PayrollPeriodTransaction: Record "Payroll Period Transaction";
        MemberMgmt: Codeunit "Member Management";
        DateFilter, SalaryDateFilter : Text[250];
        LoanNo, ProductCode, MemberNo, PrevDocNo, CurrentDocNo : Code[20];
        CheckOffLines, CheckOffLines2 : Record "Checkoff Lines";
        MinimumYouCanApply, LoanBalance, MaxAmount, Limit, BuyOffAmount, ProcessingFee : Decimal;
        LinkedProducts: Record "Loan Product Linking";
        Multiplier: Decimal;
        MemberNo_var: Code[20];
        canTopup: Boolean;
    begin
        Deposits := 0;
        LoanBalance := 0;
        MonthlyContribution := 0;
        NetPay := 0;
        EligibleAmount := 0;
        Eligibility := 0;
        DepositEligibility := 0;
        MaxAmount := 0;
        Limit := 0;
        clear(ResponseCode);
        Clear(ResponseMessage);
        Clear(MemberNo_var);
        if LoanProduct.Get(REQUEST_TYPE) = false then begin
            responseCode := '01';
            ResponseMessage.AddText('{"Error":"The Loan Product ' + REQUEST_TYPE + ' does not exist","QualifiedAmount":"0"}');
            exit;
        end else begin

            if Member.Get(CUSTOMER_NO) then
                MemberNo_var := Member."No."
            else if Member.Get(GetMemberNoFromPhoneNo(CUSTOMER_NO)) then MemberNo_var := Member."No.";

            if Member.Get(MemberNo_var) then begin
                CheckMaximumRunningLoans(LoanProduct.Code, Member."No.", CurrentLoans, AllowedLoans, BuyOffAmount);
                if ((LoanProduct."Max. Running Loans" > 1) and (not LoanProduct."Dividend Based")) then begin
                    if (CurrentLoans + 1) > AllowedLoans then begin
                        responseCode := '01';
                        ResponseMessage.addText('{"Error":"You Can Only have a Maximum of ' + format(AllowedLoans) + '","QualifiedAmount":"0"}');
                        exit;
                    end;
                end;
                LinkedProducts.Reset();
                LinkedProducts.SetRange("Source Code", LoanProduct.Code);
                if LinkedProducts.FindSet() then begin
                    repeat
                        Loans.Reset();
                        Loans.SetRange("Product Code", LinkedProducts."Linked Product Code");
                        Loans.SetRange("Member No.", Member."No.");
                        Loans.SetFilter("Loan Balance", '>0');
                        if Loans.FindFirst() then begin
                            responseCode := '01';
                            ResponseMessage.addText('{"Error":"You have a similar product running","QualifiedAmount":"0"}');
                            exit;
                        end;
                    until LinkedProducts.Next() = 0;
                end;
                if LoanProduct."Mobile Loan" then begin
                    Loans.Reset();
                    Loans.SetRange("Member No.", Member."No.");
                    Loans.SetFilter("Loan Classification", '<>%1', Loans."Loan Classification"::Performing);
                    if Loans.FindFirst() then begin
                        responseCode := '01';
                        ResponseMessage.addText('{"Error":"You have a Non Performing Loan","QualifiedAmount":"0"}');
                        exit;
                    end;
                end;

                if not CheckMobileBankingRegistration(CUSTOMER_NO) then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"You are not registered for Mobile Banking","QualifiedAmount":"0"}');
                    exit;
                end;
                if MobileLoanBlocked(Member."No.", LoanProduct.Code) then begin
                    responseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Member is blocked to Access Mobile Loans","QualifiedAmount":"0"}');
                    exit;
                end;
                if Member."Date of Registration" = 0D then begin
                    responseCode := '01';
                    ResponseMessage.AddText('{"Error":"You Must have been an active Member for the last 3 Months","QualifiedAmount":"0"}');
                    exit;
                end;

                if CheckMobileBankingRegistration(Member."No.") = false then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Member is Not registered for Mobile Banking"}');
                    exit;
                end;

                if NUMBER_OF_MONTHS <> 0 then begin
                    if NUMBER_OF_MONTHS > LoanProduct."Maximum Installments" then begin
                        responseCode := '01';
                        ResponseMessage.AddText('{"Error":"The Repayment Period Cannot Exceed ' + Format(LoanProduct."Maximum Installments") + ' Months","QualifiedAmount":"0"}');
                        exit;
                    end;
                end;

                Member.CalcFields("Total Deposits", "Outstanding Loans", "Total Shares");
                if Member."Total Shares" < 2000 then begin
                    responseCode := '01';
                    ResponseMessage.AddText('{"Error":"You Must have at least 2,000 Shares Balance","QualifiedAmount":"0"}');
                    exit;
                end;

                Deposits := Member."Total Deposits";

                if LoanProduct."Mobile Loan" then begin
                    case LoanProduct."Mobile Appraisal Type" of
                        LoanProduct."Mobile Appraisal Type"::"Deposit Multiplier":
                            begin
                                Limit := 0;
                                DepositEligibility := 0;
                                MaxAmount := 0;

                                EndDate := WorkDate;
                                SDate := CalcDate('-2M', CALCDATE('<-CM>', EndDate));
                                DateFilter := StrSubstNo('%1..%2', SDate, EndDate);
                                SalaryDateFilter := StrSubstNo('%1..%2', CalcDate('-2M', CALCDATE('<-CM>', CalcDate('<-CM>', WorkDate))), CalcDate('<-CM>', WorkDate));
                                if Member.Category = 'STAFF' then begin
                                    PayrollPeriodTransaction.Reset;
                                    PayrollPeriodTransaction.SetRange("Employee Code", MemberMgmt.GetEmployeeNo(Member."No."));
                                    PayrollPeriodTransaction.SetFilter("Payroll Period", SalaryDateFilter);
                                    PayrollPeriodTransaction.SetRange("Transaction Code", 'NPAY');
                                    if PayrollPeriodTransaction.FindSet() then begin
                                        repeat
                                            NetPay += PayrollPeriodTransaction.Amount;
                                        until PayrollPeriodTransaction.Next = 0;
                                        Eligibility := Round((NetPay / 3) * 0.5) * NUMBER_OF_MONTHS;
                                    end;
                                end
                                else
                                    if not Member.Salaried then begin
                                        DetailedVendorLedgEntry.Reset();
                                        DetailedVendorLedgEntry.SetRange("Product Posting Type", DetailedVendorLedgEntry."Product Posting Type"::"Non Withdrawable Deposit");
                                        DetailedVendorLedgEntry.Setfilter("Sacco Transaction Type", '<>%1', DetailedVendorLedgEntry."Sacco Transaction Type"::"End Month Salary");
                                        DetailedVendorLedgEntry.SetRange("Member No.", Member."No.");
                                        DetailedVendorLedgEntry.Setfilter("Posting Date", Datefilter);
                                        DetailedVendorLedgEntry.Setfilter("Document No.", '<>OPENBAL');
                                        DetailedVendorLedgEntry.SetCurrentKey("Entry No.");
                                        DetailedVendorLedgEntry.SetAscending("Entry No.", false);
                                        if DetailedVendorLedgEntry.FindSet then begin
                                            DetailedVendorLedgEntry.CalcSums("Credit Amount");
                                            MonthlyContribution := DetailedVendorLedgEntry."Credit Amount";
                                            Eligibility := ((MonthlyContribution / 3) * 2) * NUMBER_OF_MONTHS;
                                        end;
                                    end
                                    else begin
                                        CheckOffLines.Reset();
                                        CheckOffLines.SetRange("Member No", Member."No.");
                                        CheckOffLines.SetFilter("Net Amount", '<>%1', 0);
                                        CheckOffLines.SetFilter("Posting Date", SalaryDateFilter);
                                        CheckOffLines.SetRange("Upload Type", CheckOffLines."Upload Type"::Salary);
                                        CheckOffLines.SetRange("Income Type", CheckOffLines."Income Type"::Salary);
                                        CheckOffLines.SetRange(Posted, true);
                                        if CheckOffLines.FindSet() then begin
                                            repeat
                                                CheckOffLines.CalcFields("Net Amount");
                                                MonthlyContribution += CheckOffLines."Net Amount";
                                            until CheckOffLines.Next = 0;
                                            Eligibility := ((MonthlyContribution / 3) * 0.5) * NUMBER_OF_MONTHS;
                                        end;
                                    end;

                                if Member."Mobi Loan Limit" <> 0 then
                                    Eligibility := Member."Mobi Loan Limit" * NUMBER_OF_MONTHS;

                                if Eligibility < 0 then
                                    Eligibility := 0;

                                Deposits := Member."Total Deposits";
                                DepositEligibility := (Deposits * LoanProduct."Loan Multiplier");
                                if DepositEligibility < 0 then
                                    DepositEligibility := 0;

                                MaxAmount := LoanProduct."Maximum Loan Amount";
                                Limit := MaxAmount;

                                if Eligibility > DepositEligibility then
                                    Eligibility := DepositEligibility;

                                if Eligibility > Limit then
                                    Eligibility := limit;

                                EligibleAmount := Eligibility;

                                if ((not Member.Salaried) and (NUMBER_OF_MONTHS > 3)) then
                                    EligibleAmount := 0;
                            end;
                        LoanProduct."Mobile Appraisal Type"::"Percent of Net Salary", LoanProduct."Mobile Appraisal Type"::"Percent Of Lowest Salary":
                            begin
                                ProductCode := LoanProduct.Code;
                                BaseAmount := 0;
                                EndDate := WorkDate;
                                SDate := CalcDate('-3M', EndDate);
                                SDate := DMY2Date(1, Date2DMY(SDate, 2), Date2DMY(SDate, 3));
                                SalaryCount := 0;
                                DateFilter := Format(SDate) + '..' + Format(EndDate);
                                if LProducts.Get(ProductCode) then begin
                                end;
                            end;
                        LoanProduct."Mobile Appraisal Type"::"Dividend Percentage":
                            begin
                                if Member."Prior Year Dividend" = 0 then
                                    BaseAmount := 0
                                else
                                    BaseAmount := Member."Prior Year Dividend" - LoansManagement.GetPriorDividendAmount(Member."No.");
                                LoanBalance := LoansManagement.GetPriorDividendAmount(Member."No.");
                                Eligibility := BaseAmount;
                                EligibleAmount := Eligibility;
                            end;
                        LoanProduct."Mobile Appraisal Type"::"Defined Amount":
                            begin
                                if Member."Mobi Loan Limit" = 0 then
                                    BaseAmount := 0
                                else
                                    BaseAmount := Member."Mobi Loan Limit";

                                Limit := 0;
                                MaxAmount := LoanProduct."Maximum Loan Amount";
                                Limit := MaxAmount;
                                Eligibility := BaseAmount;
                                if Eligibility < 0 then
                                    Eligibility := 0;

                                if Eligibility > Limit then
                                    Eligibility := limit;

                                EligibleAmount := Eligibility;
                            end;
                    end;
                end else begin
                    Deposits := Member."Total Deposits";
                    DepositEligibility := (Deposits * LoanProduct."Loan Multiplier");
                    if DepositEligibility < 0 then
                        DepositEligibility := 0;

                    MaxAmount := LoanProduct."Maximum Loan Amount";
                    Limit := MaxAmount;

                    Eligibility := DepositEligibility;

                    if Eligibility > Limit then
                        Eligibility := limit;

                    EligibleAmount := Eligibility;
                end;
                LoanBalance := 0;

                Loans.Reset();
                Loans.SetRange("Product Code", LoanProduct.Code);
                Loans.SetRange("Member No.", Member."No.");
                Loans.SetFilter("Loan Balance", '>0');
                if Loans.FindSet() then begin
                    repeat
                        Loans.CalcFields("Loan Balance");
                        LoanBalance += Loans."Loan Balance";
                    until Loans.Next() = 0;
                end;

                QualifiedAmount := EligibleAmount;

                if (not LoanProduct."Dividend Based") and ((QualifiedAmount > Deposits) and (LoanProduct."Salary Based" = false)) then
                    QualifiedAmount := Deposits;

                //Check Deposits 
                if Loanproduct."Mobile Loan" then begin
                    if QualifiedAmount > LoanProduct."Maximum Loan Amount" then
                        QualifiedAmount := LoanProduct."Maximum Loan Amount";
                end;
                if LoanProduct."Dividend Based" then begin
                    if QualifiedAmount >= LoanProduct."Maximum Loan Amount" then
                        QualifiedAmount := LoanProduct."Maximum Loan Amount" - LoanBalance;
                    MinimumYouCanApply := LoanProduct."Minimum Loan Amount";
                end
                else begin
                    if LoanBalance < LoanProduct."Minimum Loan Amount" then
                        MinimumYouCanApply := LoanProduct."Minimum Loan Amount"
                    else
                        MinimumYouCanApply := LoanBalance;
                end;
                if ((LoanBalance <> 0) and ((QualifiedAmount - LoanBalance) > 100)) then
                    canTopup := true
                else
                    canTopup := false;

                responseCode := '00';
                ResponseMessage.AddText('{' + '"QualifiedAmount":"' + format(QualifiedAmount) + '",' + '"CanTopup":"' + format(canTopup) + '","MinimumQualificationAmount":"' + format(MinimumYouCanApply) + '"}');
            end;
        end;
    end;

    procedure CheckQualifiedLoanAmount(var CustomerNo: Code[20]; var REQUEST_TYPE: Code[20]; var NUMBER_OF_MONTHS: integer; var var_Qualified_Loan_Amount: Decimal; var var_Minimum_Can_Apply: Decimal; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        monthlyPrincipalRepayment, InterestDueOnLoan, QualifiedAmount, MaxMonthluRepayment, MaxMonthlhyRepayment : Decimal;
        maxMonthlyRepayment, AvailableSalary, EligibleAmount, MinSalary, BaseAmount, LowestAmount, NetAmount, Eligibility, Deposits : Decimal;
        SalaryCount, CurrentLoans, AllowedLoans : Integer;
        VendorLedger: Record "Vendor Ledger Entry";
        Sdate, Edate, TempSdate, EndDate : Date;
        Loans: Record Loans;
        LoanProducts1, LoanProducts, LProducts : Record "Sacco Products";
        LoansManagement: Codeunit "Loans Management";
        DetailedLedger: Record "Detailed Vendor Ledg. Entry";
        DateFilter: Text[250];
        LoanNo, ProductCode, MemberNo, PrevDocNo, CurrentDocNo : Code[20];
        CheckOffLines, CheckOffLines2 : Record "Checkoff Lines";
        MinimumYouCanApply, MpoaBalance, MaxAmount, Limit, BuyOffAmount, ProcessingFee : Decimal;
        LinkedProducts: Record "Loan Product Linking";
        Multiplier: Decimal;
        MemberNo_var: Code[20];
        canTopup: Boolean;
    begin
        MpoaBalance := 0;
        MaxAmount := 0;
        Limit := 0;
        clear(ResponseCode);
        Clear(ResponseMessage);
        Clear(MemberNo_var);
        if LoanProducts.Get(REQUEST_TYPE) = false then begin
            responseCode := '01';
            ResponseMessage.AddText('{"Error":"The Loan Product ' + REQUEST_TYPE + ' does not exist","QualifiedAmount":"0"}');
            exit;
        end;
        LoanProducts.Get(REQUEST_TYPE);
        if Member.Get(CustomerNo) then
            MemberNo_var := Member."No."
        else if Member.Get(GetMemberNoFromPhoneNo(CustomerNo)) then MemberNo_var := Member."No.";
        if Member.Get(MemberNo_var) then begin
            CheckMaximumRunningLoans(LoanProducts.Code, Member."No.", CurrentLoans, AllowedLoans, BuyOffAmount);
            if ((LoanProducts."Max. Running Loans" > 1) and (not LoanProducts."Dividend Based")) then begin
                if (CurrentLoans + 1) > AllowedLoans then begin
                    responseCode := '01';
                    ResponseMessage.addText('{"Error":"You Can Only have a Maximum of ' + format(AllowedLoans) + '","QualifiedAmount":"0"}');
                    exit;
                end;
            end;
            LinkedProducts.Reset();
            LinkedProducts.SetRange("Source Code", LoanProducts.Code);
            if LinkedProducts.FindSet() then begin
                repeat
                    Loans.Reset();
                    Loans.SetRange("Product Code", LinkedProducts."Linked Product Code");
                    Loans.SetRange("Member No.", Member."No.");
                    Loans.SetFilter("Loan Balance", '>0');
                    if Loans.FindFirst() then begin
                        responseCode := '01';
                        ResponseMessage.addText('{"Error":"You have a similar product running","QualifiedAmount":"0"}');
                        exit;
                    end;
                until LinkedProducts.Next() = 0;
            end;
            if not CheckMobileBankingRegistration(CustomerNo) then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"You are not registered for Mobile Banking"}');
                exit;
            end;
            if MobileLoanBlocked(Member."No.", LoanProducts.Code) then begin
                responseCode := '01';
                ResponseMessage.AddText('{"Error":"The Member is blocked to Access Mobile Loans","QualifiedAmount":"0"}');
                exit;
            end;
            if Member."Date of Registration" = 0D then begin
                responseCode := '01';
                ResponseMessage.AddText('{"Error":"You Must have been an active Member for the last 3 Months","QualifiedAmount":"0"}');
                exit;
            end;
            Member.CalcFields("Total Deposits", "Outstanding Loans", "Total Shares");
            if Member."Total Shares" < 2000 then begin
                responseCode := '01';
                ResponseMessage.AddText('{"Error":"You Must have at least 2,000 Shares Balance","QualifiedAmount":"0"}');
                exit;
            end;
            Deposits := Member."Total Deposits";
            case LoanProducts."Mobile Appraisal Type" of
                LoanProducts."Mobile Appraisal Type"::"Deposit Multiplier":
                    begin
                        Limit := 0;
                        MaxAmount := LoanProducts."Maximum Loan Amount";
                        Limit := MaxAmount;
                        Deposits := Member."Total Deposits";
                        Eligibility := (Deposits * LoanProducts."Loan Multiplier");
                        if Eligibility < 0 then Eligibility := 0;
                        MpoaBalance := 0;
                        Loans.Reset();
                        Loans.SetRange("Product Code", LoanProducts.Code);
                        Loans.SetRange("Member No.", Member."No.");
                        Loans.SetFilter("Loan Balance", '>0');
                        if Loans.FindSet() then begin
                            repeat
                                Loans.CalcFields("Loan Balance");
                                MpoaBalance += Loans."Loan Balance";
                            until Loans.Next() = 0;
                        end;
                        if Eligibility > Limit then Eligibility := limit;
                        EligibleAmount := Eligibility;
                    end;
                LoanProducts."Mobile Appraisal Type"::"Percent of Net Salary", LoanProducts."Mobile Appraisal Type"::"Percent Of Lowest Salary":
                    begin
                        ProductCode := LoanProducts.Code;
                        BaseAmount := 0;
                        EndDate := WorkDate;
                        SDate := CalcDate('-3M', EndDate);
                        SDate := DMY2Date(1, Date2DMY(SDate, 2), Date2DMY(SDate, 3));
                        SalaryCount := 0;
                        DateFilter := Format(SDate) + '..' + Format(EndDate);
                        if LProducts.Get(ProductCode) then begin
                        end;
                    end;
                LoanProducts."Mobile Appraisal Type"::"Dividend Percentage":
                    begin
                        if Member."Prior Year Dividend" = 0 then
                            BaseAmount := 0
                        else
                            BaseAmount := Member."Prior Year Dividend" - LoansManagement.GetPriorDividendAmount(Member."No.");
                        MpoaBalance := LoansManagement.GetPriorDividendAmount(Member."No.");
                        Eligibility := BaseAmount;
                        EligibleAmount := Eligibility;
                    end;
                LoanProducts."Mobile Appraisal Type"::"Defined Amount":
                    begin
                        if Member."Mobi Loan Limit" = 0 then
                            BaseAmount := 0
                        else
                            BaseAmount := Member."Mobi Loan Limit";
                        Limit := 0;
                        MaxAmount := LoanProducts."Maximum Loan Amount";
                        Limit := MaxAmount;
                        Eligibility := BaseAmount;
                        if Eligibility < 0 then Eligibility := 0;
                        MpoaBalance := 0;
                        Loans.Reset();
                        Loans.SetRange("Product Code", LoanProducts.Code);
                        Loans.SetRange("Member No.", Member."No.");
                        Loans.SetFilter("Loan Balance", '>0');
                        if Loans.FindSet() then begin
                            repeat
                                Loans.CalcFields("Loan Balance");
                                MpoaBalance += Loans."Loan Balance";
                            until Loans.Next() = 0;
                        end;
                        if Eligibility > Limit then Eligibility := limit;
                        EligibleAmount := Eligibility;
                    end;
            end;
            //Check Mobile Membership
            if CheckMobileBankingRegistration(Member."No.") = false then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Member is Not registered for Mobile Banking"}');
                exit;
            end;
            if NUMBER_OF_MONTHS <> 0 then begin
                if NUMBER_OF_MONTHS > LoanProducts."Maximum Installments" then begin
                    responseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Repayment Period Cannot Exceed ' + Format(LoanProducts."Maximum Installments") + ' Months","QualifiedAmount":"0"}');
                    exit;
                end;
            end;
            QualifiedAmount := EligibleAmount;
            if (not LoanProducts."Dividend Based") and ((QualifiedAmount > Deposits) and (LoanProducts."Salary Based" = false)) then QualifiedAmount := Deposits;
            //Check Deposits 
            if QualifiedAmount > LoanProducts."Maximum Loan Amount" then QualifiedAmount := LoanProducts."Maximum Loan Amount";
            if LoanProducts."Dividend Based" then begin
                if QualifiedAmount >= LoanProducts."Maximum Loan Amount" then QualifiedAmount := LoanProducts."Maximum Loan Amount" - MpoaBalance;
                MinimumYouCanApply := LoanProducts."Minimum Loan Amount";
            end
            else begin
                if MpoaBalance < LoanProducts."Minimum Loan Amount" then
                    MinimumYouCanApply := LoanProducts."Minimum Loan Amount"
                else
                    MinimumYouCanApply := MpoaBalance;
            end;
            if ((MpoaBalance <> 0) and ((QualifiedAmount - MpoaBalance) > 100)) then
                canTopup := true
            else
                canTopup := false;
            responseCode := '00';
            var_Qualified_Loan_Amount := QualifiedAmount;
            var_Minimum_Can_Apply := MinimumYouCanApply;
        end;
    end;

    procedure GetLoanStatement(var CUSTOMER_NO: Code[20]; var LOAN_PRODUCT_CODE: Code[20]; var CHANNEL_REFERENCE: Code[20]; var REQUEST_TYPE: Code[20]; var TRANSACTION_AMOUNT: Decimal; var NARRATION: Code[200]; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        DateFilter: Text[250];
        Member: array[2] of Record Members;
        AccountFilter: Text[250];
        MemberNo: Code[20];
        Loans: Record Loans;
    begin
        Loans.Reset();
        Loans.SetRange("Member No.", CUSTOMER_NO);
        Loans.SetRange("No.", LOAN_PRODUCT_CODE);
        if Loans.FindSet() then begin
            AccountFilter := Loans."No.";
            MemberNo := CUSTOMER_NO;
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.ADDTEXT('{"Response":"The Loan ' + LOAN_PRODUCT_CODE + ' does not exist"}');
            EXIT;
        end;
        CLEAR(ResponseCode);
        CLEAR(ResponseMessage);
        Member[1].RESET;
        Member[1].SETRANGE("No.", MemberNo);
        Member[1].SetFilter("Loan Filter", AccountFilter);
        if Member[1].FINDSET THEN BEGIN
            Clear(Body);
            Clear(Subject);
            Clear(Recipients);
            Recipients.Add(Member[1]."E-Mail");
            Subject := 'Account Statement ' + DateFilter + ' ' + LOAN_PRODUCT_CODE;
            Body += ('Dear ' + Member[1]."Full Name" + '<br></br>Please find attached your Statement');
            Mail.Create(Recipients, Subject, Body, true);
            Member[2].Reset();
            Member[2].SetRange("No.", Member[1]."No.");
            if Member[2].FindFirst then begin
                Recordr.GetTable(Member[2]);
                TempBlob.CreateOutStream(outStreamReport);
                TempBlob.CreateInStream(inStreamReport);
                Report.SaveAs(Report::"Member Statement", CUSTOMER_NO + LOAN_PRODUCT_CODE, ReportFormat::Pdf, outStreamReport, Recordr);
                Mail.AddAttachment(CUSTOMER_NO + LOAN_PRODUCT_CODE + '.pdf', 'PDF', inStreamReport);
            end;
            //Email.Send(Mail);
            ResponseCode := '00';
            ResponseMessage.ADDTEXT('{"Response":"The Statement has been Mailed"}');
        END
        ELSE BEGIN
            ResponseCode := '01';
            ResponseMessage.ADDTEXT('{"Response":"The Account ' + MemberNo + ' does not exist"}');
            EXIT;
        end;
    end;

    internal procedure GetInterestRate(LoanProduct: Code[20]; Installments: Integer; var ProcessingFee: Decimal) Rate: decimal
    var
        LoanProducts: Record "Sacco Products";
        InterestBands: Record "Product Interest Bands";
    begin
        InterestBands.reset;
        InterestBands.SetRange(Active, true);
        InterestBands.SetRange("Source Code", LoanProduct);
        InterestBands.SetFilter("Min Installments", '<=%1', Installments);
        InterestBands.SetFilter("Max Installments", '>=%1', Installments);
        if InterestBands.FindFirst() then begin
            Rate := InterestBands."Interest Rate";
            ProcessingFee := InterestBands."Processing Fee";
        end;
        exit(Rate);
    end;

    local procedure GetBridgingCommission(Loans: Record Loans) BridgingCommission: Decimal
    var
        LoanProduct: Record "Sacco Products";
    begin
        Loans.CalcFields("Loan Balance");
        if LoanProduct.Get(Loans."Product Code") then begin
            exit(Loans."Loan Balance" * LoanProduct."Bridging Commision %" * 0.01)
        end
        else
            exit(0);
    end;

    internal procedure FnGenerateLoanSchedule(ObjLoansMgt: Record Loans)
    var
        ObjLnMgt: Codeunit "Loans Management";
    begin
        ObjLnMgt.GenerateLoanRepaymentSchedule(ObjLoansMgt);
    end;

    procedure LoanCalculatorSchedule(DocNo: Code[20])
    var
        LoanCalculator: Record "Loan Calculator";
        LoansManagement: Codeunit "Loans Management";
    begin
        if LoanCalculator.Get(DocNo) then LoansManagement.GenerateCalculatorSchedule(LoanCalculator);
    end;

    [Scope('Cloud')]

    #endregion

    #region Channel Management

    procedure GetPaybillKeywords(var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        PaybillKeyWords: Record "Paybill Keywords";
    begin
        Clear(ResponseMessage);
        Clear(TempResponse);
        ResponseCode := '00';
        ResponseMessage.ADDTEXT('{"Categories":[');
        PaybillKeyWords.Reset();
        if PaybillKeyWords.FindSet() then begin
            repeat
                TempResponse.ADDTEXT('{"Code":"' + PaybillKeyWords."Kewyword Code" + '","PostToAccountType":"' + Format(PaybillKeyWords."Product Code") + '","PostingType":"' + Format(PaybillKeyWords."Product Posting Type") + '","Description":"' + PaybillKeyWords.Description + '"}');
                TempResponse.ADDTEXT(',');
            until PaybillKeyWords.Next() = 0;
        end;
        if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
        ResponseMessage.ADDTEXT(']}');
    end;

    procedure GetChannelTransactionTypes(var ResponseCode: Code[20]; var ResponseMessage: Text)
    var
        ChannelTransactionSetup: Record "Channel Transaction Setup";
        LoanProductObj: JsonObject;
        Obj: JsonObject;
        Arr: JsonArray;
    begin
        ChannelTransactionSetup.Reset();
        if ChannelTransactionSetup.FindSet() then begin
            Obj.Add('Code', '');
            Obj.Add('Description', '');
            Obj.Add('ChargeCode', '');
            Obj.Add('ChargeDescription', '');
            repeat
                Obj.Replace('Code', ChannelTransactionSetup.Code);
                Obj.Replace('Description', ChannelTransactionSetup.Description);
                Obj.Replace('ChargeCode', ChannelTransactionSetup."Charge Code");
                Obj.Replace('ChargeDescription', ChannelTransactionSetup."Charge Description");
                Arr.Add(Obj);
            until ChannelTransactionSetup.Next() = 0;
            ResponseCode := '00';
            Arr.WriteTo(ResponseMessage);
        end;
    end;

    procedure GetTransactionChargeCodes(var ResponseCode: Code[20]; var ResponseMessage: Text)
    var
        TransactionCharges: Record "Transaction Charges";
        LoanProductObj: JsonObject;
        Obj: JsonObject;
        Arr: JsonArray;
    begin
        TransactionCharges.Reset();
        TransactionCharges.SetFilter("Posting Transaction Type", '<>%1&<>%2', TransactionCharges."Posting Transaction Type"::"Checkoff Pay", TransactionCharges."Posting Transaction Type"::"End Month Salary");
        if TransactionCharges.FindSet() then begin
            Obj.Add('Code', '');
            Obj.Add('Description', '');
            repeat
                Obj.Replace('Code', TransactionCharges.Code);
                Obj.Replace('Description', TransactionCharges.Description);
                Arr.Add(Obj);
            until TransactionCharges.Next() = 0;
            ResponseCode := '00';
            Arr.WriteTo(ResponseMessage);
        end;
    end;

    procedure LookUpTransactionCharges(var ChargeCode: Code[20]; var TransactionAmount: Decimal; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        TransactionCharges: Record "Transaction Charges";
        JournalMgt: Codeunit "Journal Management";
        ChargeAmount: Decimal;
    begin
        if TransactionCharges.Get(ChargeCode) then begin
            ChargeAmount := JournalMgt.GetChargesAmount(ChargeCode, TransactionAmount);
            ResponseCode := '00';
            ResponseMessage.AddText('{"ChargeAmount":"' + format(ChargeAmount) + '"}');
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Charge Code Does Not Exist"}');
            exit;
        end;
    end;

    procedure CustomerLookup(var PHONE_NUMBER: Code[20]; var CHANNEL_REFERENCE: Code[20]; var REQUEST_TYPE: Code[20]; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        MemberNo: Code[20];
        TempResponse: BigText;
        BookValue, AvailableBalance, UnclearedFunds, MinimumBalance : Decimal;
        LoansManagement: Codeunit "Loans Management";
        SaccoProduct: Record "Sacco Products";
    begin
        Clear(TempResponse);
        clear(responseCode);
        clear(ResponseMessage);
        if Member.Get(GetMemberNoFromPhoneNo(PHONE_NUMBER)) then begin
            MemberNo := Member."No.";
        end
        else begin
            Member.Reset();
            Member.SetRange("Identification No.", PHONE_NUMBER);
            if Member.FindFirst() then
                MemberNo := Member."No."
            else begin
                responseCode := '01';
                ResponseMessage.AddText('{"Error":"The Member Does Not Exist"}');
                exit;
            end;
        end;
        Member.Get(MemberNo);
        if not CheckMobileBankingRegistration(MemberNo) then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"You are not registered for Mobile Banking"}');
            exit;
        end;
        responseCode := '00';
        Vendor.RESET;
        Vendor.SETRANGE("Member No.", Member."No.");
        Vendor.SetRange("Product Posting Type", Vendor."Product Posting Type"::"Withdrawable Deposit");
        Vendor.SetRange("Business Account", false);
        Vendor.SetRange(Blocked, Vendor.Blocked::" ");
        if Vendor.FindSet then begin
            repeat
                SaccoProduct.Get(Vendor."Product Code");
                Vendor.CalcFields(Balance, "Uncleared Funds");
                BookValue += Vendor.Balance;
                UnclearedFunds += Vendor."Uncleared Funds";
                MinimumBalance += SaccoProduct."Minimum Balance";
            until Vendor.Next = 0;
        end;
        AvailableBalance := BookValue - UnclearedFunds - MinimumBalance - GetPendingChannelsTransactions(MemberNo);
        if AvailableBalance < 0 then AvailableBalance := 0;
        ResponseMessage.ADDTEXT('{"MemberNo":"' + Member."No." + '","DateOfRegistration":"' + Format(Member."Date of Registration") + '","Status":"' + Format(Member.Status) + '","KRAPin":"' + Format(Member."KRA PIN") + '","PhoneNo":"' + Format(Member."Mobile Transacting No") + '","BranchCode":"' + Format(Member."Global Dimension 1 Code") + '","DateOfBirth":"' + Format(Member."Date of Birth") + '","FullName":"' + Member."Full Name" + '","NationalIDNo":"' + Member."Identification No." + '","Email":"' + Member."E-Mail" + '","TransactingPhoneNo":"' + Member."Mobile Transacting No" + '","BookValue":"' + Format(BookValue) + '","UnclearedFunds":"' + Format(Member."Uncleared Funds") + '","AvailableBalance":"' + Format(AvailableBalance) + '","Deposits":"' + Format(Member."Total Deposits") + '","ShareCapital":"' + Format(Member."Total Shares") + '","FreeDeposits":"' + Format(LoansManagement.GetNonSelfGuaranteeEligibility(Member."No.")) + '","QualifiedSelfGuarantee":"' + Format(LoansManagement.GetSelfGuaranteeEligibility(Member."No.")) + '","OutstandingLoans":"' + Format(Member."Outstanding Loans") + '","SelfGuarantee":"' + Format(Member."Self Guarantee") + '","RunningLoans":"' + Format(Member."Running Loans") + '"' + '}');
    end;

    procedure AccountValidation(var accountNo: Code[20]; var responseCode: Code[20]; var ResponseMessage: Text)
    var
        JsonObj: JsonObject;
        JsonArr: JsonArray;
    begin
        clear(responseCode);
        clear(ResponseMessage);
        if Vendor.Get(accountNo) then begin
            responseCode := '00';
            JsonObj.Add('AccountNo', Vendor."No.");
            JsonObj.Add('AccountName', Vendor.Name);
            JsonObj.Add('Type', Format(Vendor."Product Posting Type"));
            JsonObj.Add('ShareCapital', Format(Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Share Capital Account"));
            JsonObj.Add('CashWithdrawAllowed', Format(Vendor."Cash Withdraw Allowed"));
            JsonObj.Add('CashDepositAllowed', Format(Vendor."Cash Deposit Allowed"));
            JsonObj.Add('CashTransferAllowed', Format(Vendor."Cash Transfer Allowed"));
            JsonObj.Add('Status', Format(Vendor.Status));
            JsonObj.Add('Balance', Format(Vendor.Balance));
            JsonArr.Add(JsonObj);
        end
        else begin
            responseCode := '01';
            JsonObj.Add('Error', 'The Member Does Not Exist');
            JsonArr.Add(JsonObj);
        end;
        JsonArr.WriteTo(ResponseMessage);
    end;

    procedure CustomerLookupForDeposits(var PHONE_NUMBER: Code[20]; var CHANNEL_REFERENCE: Code[20]; var REQUEST_TYPE: Code[20]; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        MemberNo: Code[20];
        TempResponse: BigText;
    begin
        Clear(TempResponse);
        clear(responseCode);
        clear(ResponseMessage);
        if Member.Get(GetMemberNoFromPhoneNo(PHONE_NUMBER)) then begin
            MemberNo := Member."No.";
        end
        else begin
            Member.Reset();
            Member.SetRange("Identification No.", PHONE_NUMBER);
            if Member.FindFirst() then
                MemberNo := Member."No."
            else begin
                responseCode := '01';
                ResponseMessage.AddText('{"Error":"The Member Does Not Exist"}');
                exit;
            end;
        end;
        Member.Get(MemberNo);
        responseCode := '00';
        ResponseMessage.AddText('{' + '"FIRST_NAME":"' + Member."First Name" + '",' + '"SECOND_NAME":"' + Member."Middle Name" + '",' + '"LAST_NAME":"' + Member."Last Name" + '",' + '"IDENTIFICATION_NUMBER":"' + Member."Identification No." + '",' + '"IDENTIFICATION_TYPE":"National ID",' + '"GENDER":"' + Format(Member.Gender) + '",' + '"EMAIL_ADDRESS":"' + Member."E-Mail" + '",' + '"PHYSICAL_ADDRESS":"' + Member.Address + '",' + '"DATE_OF_BIRTH":"' + format(Member."Date of Birth") + '",' + '"CUSTOMER_NO":"' + MemberNo + '",' + '"MOBILETRANSACTION_NO":"' + MEMBER."Mobile Transacting No" + '"' + '}');
    end;

    procedure AccountsLookup(var identifier: Code[20]; var isLoan: Boolean; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        MemberNo: Code[20];
        Member: array[4] of Record Members;
        TempResponse: BigText;
        SaccoProducts: Record "Sacco Products";
    begin
        Clear(TempResponse);
        clear(responseCode);
        clear(ResponseMessage);
        MemberNo := '';
        if Member[1].Get(identifier) then MemberNo := Member[1]."No.";
        if MemberNo = '' then
            if Member[2].Get(GetMemberNoFromPhoneNo(identifier)) then MemberNo := Member[2]."No.";
        if MemberNo = '' then begin
            Member[3].Reset();
            Member[3].SetRange("Identification No.", identifier);
            if Member[3].FindFirst() then
                MemberNo := Member[3]."No."
            else begin
                responseCode := '01';
                ResponseMessage.AddText('{"Error":"The Member Does Not Exist"}');
                exit;
            end;
        end;
        if Member[4].Get(MemberNo) then begin
            if not CheckMobileBankingRegistration(MemberNo) then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"You are not registered for Mobile Banking"}');
                exit;
            end;
            responseCode := '00';
            ResponseMessage.AddText('{' + '"FIRST_NAME":"' + Member[4]."First Name" + '",' + '"SECOND_NAME":"' + Member[4]."Middle Name" + '","Accounts":[');
            Vendor.RESET;
            Vendor.SETRANGE("Member No.", Member[4]."No.");
            Vendor.SetCurrentKey("Print Sequence");
            Vendor.SetAscending("Print Sequence", true);
            if isLoan then
                Vendor.SetFilter("Product Posting Type", '=%1', Vendor."Product Posting Type"::"Loan Account")
            else
                Vendor.SetFilter("Product Posting Type", '<>%1', Vendor."Product Posting Type"::"Loan Account");
            if Vendor.FINDSET THEN BEGIN
                REPEAT
                    Vendor.CALCFIELDS(Balance);
                    TempResponse.ADDTEXT('{"Code":"' + Vendor."No." + '","Description":"' + Vendor.Name + '","Type":"' + Format(Vendor."Product Posting Type") + '","ShareCapital":"' + FORMAT(Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Share Capital Account") + '","CashWithdrawAllowed":"' + FORMAT(Vendor."Cash Withdraw Allowed") + '","CashDepositAllowed":"' + FORMAT(Vendor."Cash Deposit Allowed") + '","CashTransferAllowed":"' + FORMAT(Vendor."Cash Transfer Allowed") + '","Status":"' + FORMAT(Vendor.Status) + '","Balance":"' + FORMAT(Vendor.Balance, 0, 1) + '"}');
                    TempResponse.ADDTEXT(',');
                UNTIL Vendor.NEXT = 0;
                if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            ResponseMessage.AddText(']}');
        end
        else begin
            responseCode := '01';
            ResponseMessage.AddText('{"Error":"The Member Does Not Exist"}');
            exit;
        end;
    end;

    procedure GetMemberFOSAAccount(var MemberNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        TempResponse: BigText;
        BookBalance, AvailableBalance : Decimal;
        Charges, BalanceBefore : Decimal;
        SaccoProduct: Record "Sacco Products";
    begin
        Clear(TempResponse);
        clear(ResponseCode);
        clear(ResponseMessage);
        Vendor.Reset();
        Vendor.SetRange("Member No.", MemberNo);
        Vendor.SetRange("Product Posting Type", Vendor."Product Posting Type"::"Withdrawable Deposit");
        Vendor.SetRange("Business Account", false);
        Vendor.SetRange(Blocked, Vendor.Blocked::" ");
        if Vendor.FindFirst then begin
            SaccoProduct.Get(Vendor."Product Code");
            BookBalance := 0;
            AvailableBalance := 0;
            Vendor.CalcFields(Balance, "Uncleared Funds");
            BookBalance := Vendor.Balance;
            AvailableBalance := BookBalance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - GetPendingChannelsTransactions(Vendor."Member No.");
            if AvailableBalance < 0 then AvailableBalance := 0;
            ResponseCode := '00';
            ResponseMessage.AddText('{"AccountNo":"' + Vendor."No." + '","AccountBalance":"' + Format(BookBalance) + '","ActualBalance":"' + Format(AvailableBalance) + '"}');
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Account Does Not Exist"}');
            exit;
        end;
    end;

    procedure BalanceInquiry(var ACCOUNT_NUMBER: Code[20]; var CHANNEL_REFERENCE: Code[20]; var REQUEST_TYPE: Code[20]; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        MemberNo: Code[20];
        TempResponse: BigText;
        BookBalance, AvailableBalance : Decimal;
        Charges, BalanceBefore : Decimal;
        SaccoProduct: Record "Sacco Products";
    begin
        Clear(TempResponse);
        clear(responseCode);
        clear(ResponseMessage);
        if Vendor.Get(ACCOUNT_NUMBER) then begin
            BookBalance := 0;
            AvailableBalance := 0;
            responseCode := '00';
            Vendor.CALCFIELDS(Balance, "Uncleared Funds");
            if (BalanceBefore - Charges) < 0 then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"Insufficient Funds"}');
                exit;
            end;
            BookBalance := Vendor.Balance;
            SaccoProduct.Get(Vendor."Product Code");
            if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Withdrawable Deposit" then
                AvailableBalance := BookBalance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - GetPendingChannelsTransactions(Vendor."Member No.")
            else
                AvailableBalance := BookBalance - Vendor."Uncleared Funds";
            if AvailableBalance < 0 then AvailableBalance := 0;
            ResponseMessage.AddText('{"AccountNo":"' + Vendor."No." + '","AccountBalance":"' + Format(BookBalance) + '","ActualBalance":"' + Format(AvailableBalance) + '"}');
        end
        else begin
            responseCode := '01';
            ResponseMessage.AddText('{"Error":"The Account Does Not Exist"}');
            exit;
        end;
    end;

    procedure MemberAccountsBalanceInquiry(var MemberNo: Code[20]; var Chargable: Boolean; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        TempResponse: BigText;
        Charges, AvailableBalance, BalanceBefore, VendorBalance : Decimal;
        SaccoProduct: Record "Sacco Products";
        Vend: Record Vendor;
    begin
        Clear(TempResponse);
        clear(responseCode);
        clear(ResponseMessage);
        SaccoSetup.Get;
        ChannelTransactionSetup.Get(SaccoSetup."Balance Inquiry Charge");
        Charges := JournalMgt.GetChargesAmount(ChannelTransactionSetup."Charge Code", 1);
        if Vend.Get(MemberManagement.GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit")) then begin
            AvailableBalance := 0;
            responseCode := '00';
            Vend.CALCFIELDS(Balance, "Uncleared Funds");
            SaccoProduct.Get(Vend."Product Code");
            AvailableBalance := Vend.Balance - Vend."Uncleared Funds" - SaccoProduct."Minimum Balance" - GetPendingChannelsTransactions(MemberNo);
            if (AvailableBalance - Charges) < 0 then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"Insufficient Funds"}');
                exit;
            end;

            Vendor.Reset;
            Vendor.Setrange("Member No.", MemberNo);
            Vendor.SetFilter("Product Posting Type", '<>%1', Vendor."Product Posting Type"::"Loan Account");
            if Vendor.FindSet THEN BEGIN
                ResponseCode := '00';
                ResponseMessage.ADDTEXT('{"Accounts":[');
                REPEAT
                    Vendor.CALCFIELDS(Balance, "Uncleared Funds");
                    SaccoProduct.Get(Vendor."Product Code");
                    if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Withdrawable Deposit" then
                        VendorBalance := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - GetPendingChannelsTransactions(MemberNo)
                    else
                        VendorBalance := Vendor.Balance - Vendor."Uncleared Funds";

                    TempResponse.ADDTEXT('{"Code":"' + Vendor."No." + '","Description":"' + Vendor.Name + '","Type":"' + Format(Vendor."Product Posting Type") + '","ShareCapital":"' + FORMAT(Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Share Capital Account") + '","CashWithdrawAllowed":"' + FORMAT(Vendor."Cash Withdraw Allowed") + '","CashDepositAllowed":"' + FORMAT(Vendor."Cash Deposit Allowed") + '","CashTransferAllowed":"' + FORMAT(Vendor."Cash Transfer Allowed") + '","Status":"' + FORMAT(Vendor.Status) + '","Balance":"' + FORMAT(VendorBalance) + '"}');
                    TempResponse.ADDTEXT(',');

                UNTIL Vendor.NEXT = 0;
                if STRLEN(FORMAT(TempResponse)) > 1 then
                    ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
                ResponseMessage.ADDTEXT(']}');
            end;
            SaccoSetup.Get;
            if ((SaccoSetup."Balance Inquiry Charge" <> '') and Chargable) then begin
                Channel_Transactions.Init;
                Channel_Transactions."Entry No" := Channel_Transactions.GetLastEntryNo;
                Channel_Transactions."Transaction Type" := SaccoSetup."Balance Inquiry Charge";
                GuidValue := CreateGuid();
                Channel_Transactions."Document No" := CopyStr(DelChr(Format(GuidValue), '=', '-{}'), 1, 15);
                Channel_Transactions."Payment Refrence Code" := CopyStr(DelChr(Format(GuidValue), '=', '-{}'), 1, 15);
                Channel_Transactions."Account Reference" := MemberNo;
                Channel_Transactions."Dr_Account No" := MemberManagement.GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
                Channel_Transactions."Dr_Member No" := MemberNo;
                Channel_Transactions."Cr_Account No" := '';
                Channel_Transactions."Cr_Member No" := '';
                Channel_Transactions.Amount := 0;
                Channel_Transactions.Narration := 'Balance Inquiry';
                Channel_Transactions."Created By" := UserId;
                Channel_Transactions.Confirmed := true;
                Channel_Transactions."Created On" := CurrentDateTime;
                Channel_Transactions."Transaction Name" := 'Balance Inquiry';
                Channel_Transactions.Insert;
                CreateTransactionDump(Channel_Transactions."Entry No");
            end;
        end
        else begin
            responseCode := '01';
            ResponseMessage.AddText('{"Error":"The Account Does Not Exist"}');
            exit;
        end;
    end;

    procedure MiniStatement(var ACCOUNT_NUMBER: Code[20]; var noOfTransactions: Integer; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        MemberNo, DrCr : Code[20];
        TempResponse: BigText;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        i: integer;
        OpeningBalance, RunningBalance : Decimal;
        DetailedLedger: Record "Detailed Vendor Ledg. Entry";
        LastDate: Date;
    begin
        Clear(TempResponse);
        clear(responseCode);
        clear(ResponseMessage);
        Vendor.RESET;
        Vendor.SETRANGE("No.", ACCOUNT_NUMBER);
        if Vendor.FIND('-') THEN BEGIN
            Vendor.CALCFIELDS(Balance);
            LastDate := 0D;
            VendorLedgerEntry.RESET;
            VendorLedgerEntry.SETRANGE(Reversed, FALSE);
            VendorLedgerEntry.SETRANGE("Vendor No.", Vendor."No.");
            VendorLedgerEntry.SetCurrentKey("Posting Date", "Transaction Time");
            VendorLedgerEntry.SetAscending("Posting Date", false);
            VendorLedgerEntry.SetAscending("Transaction Time", false);
            if VendorLedgerEntry.FINDSET THEN BEGIN
                REPEAT
                    LastDate := VendorLedgerEntry."Posting Date";
                UNTIL (VendorLedgerEntry.NEXT = 0) OR (i = noOfTransactions);
            end;
            if LastDate <> 0D then begin
                LastDate := CalcDate('-1D', LastDate);
                DetailedLedger.Reset();
                DetailedLedger.SetFilter("Posting Date", '..%1', LastDate);
                DetailedLedger.SetRange("Vendor No.", Vendor."No.");
                if DetailedLedger.FindSet() then begin
                    DetailedLedger.CalcSums(Amount);
                    OpeningBalance := DetailedLedger.Amount;
                end;
            end
            else
                OpeningBalance := 0;
            RunningBalance := 0;
            RunningBalance := OpeningBalance;
            responseCode := '00';
            ResponseMessage.ADDTEXT('{"AccountName":"' + Vendor.Name + '", "Balance":"' + Format(Vendor.Balance) + '", "Transactions":[');
            VendorLedgerEntry.RESET;
            VendorLedgerEntry.SETRANGE(Reversed, FALSE);
            VendorLedgerEntry.SETRANGE("Vendor No.", Vendor."No.");
            VendorLedgerEntry.SetCurrentKey("Posting Date", "Transaction Time");
            VendorLedgerEntry.SetAscending("Posting Date", false);
            VendorLedgerEntry.SetAscending("Transaction Time", false);
            if VendorLedgerEntry.FINDSET THEN BEGIN
                i := 1;
                REPEAT
                    DrCr := '';
                    VendorLedgerEntry.CALCFIELDS(Amount);
                    if VendorLedgerEntry.Amount > 0 then
                        DrCr := 'DR'
                    else
                        DrCr := 'CR';
                    RunningBalance += VendorLedgerEntry.Amount;
                    TempResponse.ADDTEXT('{"transactionID":"' + FORMAT(VendorLedgerEntry."Document No.") + '",');
                    TempResponse.ADDTEXT('"DrCr":"' + DrCr + '",');
                    TempResponse.ADDTEXT('"Description":"' + VendorLedgerEntry.Description + '",');
                    TempResponse.ADDTEXT('"postingDate":"' + FORMAT(VendorLedgerEntry."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>') + '",');
                    TempResponse.ADDTEXT('"postingTime":"' + FORMAT(VendorLedgerEntry."Transaction Time", 0, '<Hours24,2>:<Minutes,2>:<Seconds,2>') + '",');
                    TempResponse.ADDTEXT('"amount":"' + FORMAT(ABS(VendorLedgerEntry.Amount), 0, 1) + '",');
                    TempResponse.ADDTEXT('"RunningBalance":"' + FORMAT((RunningBalance), 0, 1) + '"}');
                    TempResponse.ADDTEXT(',');
                    i += 1;
                UNTIL (VendorLedgerEntry.NEXT = 0) OR (i = noOfTransactions);
                if STRLEN(FORMAT(TempResponse)) > 1 THEN ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            ResponseMessage.ADDTEXT(']}');
        END
        ELSE BEGIN
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Account Does Not Exist"}');
            Exit;
        end;
    end;

    procedure MiniStatement(var ACCOUNT_NUMBER: Code[20]; FromDate: Date; ToDate: Date; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        MemberNo, DrCr : Code[20];
        TempResponse: BigText;
        DateFilter: Text;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        i: integer;
        OpeningBalance, RunningBalance : Decimal;
        DetailedLedger: Record "Detailed Vendor Ledg. Entry";
        LastDate: Date;
    begin
        Clear(TempResponse);
        clear(responseCode);
        clear(ResponseMessage);
        DateFilter := StrSubstNo('%1..%2', Format(FromDate), Format(ToDate));
        Vendor.RESET;
        Vendor.SETRANGE("No.", ACCOUNT_NUMBER);
        if Vendor.FIND('-') THEN BEGIN
            Vendor.CALCFIELDS(Balance);
            LastDate := 0D;
            VendorLedgerEntry.RESET;
            VendorLedgerEntry.SETRANGE(Reversed, FALSE);
            VendorLedgerEntry.SETRANGE("Vendor No.", Vendor."No.");
            VendorLedgerEntry.SetFilter("Posting Date", DateFilter);
            VendorLedgerEntry.SetCurrentKey("Posting Date", "Transaction Time");
            VendorLedgerEntry.SetAscending("Posting Date", false);
            VendorLedgerEntry.SetAscending("Transaction Time", false);
            if VendorLedgerEntry.FINDSET THEN BEGIN
                REPEAT
                    LastDate := VendorLedgerEntry."Posting Date";
                UNTIL VendorLedgerEntry.NEXT = 0;
            end;
            if LastDate <> 0D then begin
                LastDate := CalcDate('-1D', LastDate);
                DetailedLedger.Reset();
                DetailedLedger.SetFilter("Posting Date", '..%1', LastDate);
                DetailedLedger.SetRange("Vendor No.", Vendor."No.");
                if DetailedLedger.FindSet() then begin
                    DetailedLedger.CalcSums(Amount);
                    OpeningBalance := DetailedLedger.Amount;
                end;
            end
            else
                OpeningBalance := 0;
            RunningBalance := 0;
            RunningBalance := OpeningBalance;
            responseCode := '00';
            ResponseMessage.ADDTEXT('{"AccountName":"' + Vendor.Name + '", "Balance":"' + Format(Vendor.Balance) + '", "Transactions":[');
            VendorLedgerEntry.RESET;
            VendorLedgerEntry.SETRANGE(Reversed, FALSE);
            VendorLedgerEntry.SETRANGE("Vendor No.", Vendor."No.");
            VendorLedgerEntry.SetFilter("Posting Date", DateFilter);
            VendorLedgerEntry.SetCurrentKey("Posting Date", "Transaction Time");
            VendorLedgerEntry.SetAscending("Posting Date", false);
            VendorLedgerEntry.SetAscending("Transaction Time", false);
            if VendorLedgerEntry.FINDSET THEN BEGIN
                i := 1;
                REPEAT
                    DrCr := '';
                    VendorLedgerEntry.CALCFIELDS(Amount);
                    if VendorLedgerEntry.Amount > 0 then
                        DrCr := 'D'
                    else
                        DrCr := 'C';
                    RunningBalance += VendorLedgerEntry.Amount;
                    TempResponse.ADDTEXT('{"transactionID":"' + FORMAT(VendorLedgerEntry."Document No.") + '",');
                    TempResponse.ADDTEXT('"DrCr":"' + DrCr + '",');
                    TempResponse.ADDTEXT('"Description":"' + VendorLedgerEntry.Description + '",');
                    TempResponse.ADDTEXT('"postingDate":"' + FORMAT(VendorLedgerEntry."Posting Date") + '",');
                    TempResponse.ADDTEXT('"postingTime":"' + FORMAT(VendorLedgerEntry."Transaction Time") + '",');
                    TempResponse.ADDTEXT('"amount":"' + FORMAT(ABS(VendorLedgerEntry.Amount), 0, 1) + '",');
                    TempResponse.ADDTEXT('"RunningBalance":"' + FORMAT((RunningBalance), 0, 1) + '"}');
                    TempResponse.ADDTEXT(',');
                    i += 1;
                UNTIL VendorLedgerEntry.NEXT = 0;
                if STRLEN(FORMAT(TempResponse)) > 1 THEN ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            ResponseMessage.ADDTEXT(']}');
        END
        ELSE BEGIN
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Account Does Not Exist"}');
            Exit;
        end;
    end;

    procedure MiniStatementChargable(var ACCOUNT_NUMBER: Code[20]; var noOfTransactions: Integer; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        MemberNo, DrCr : Code[20];
        TempResponse: BigText;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        i: integer;
        OpeningBalance, RunningBalance : Decimal;
        DetailedLedger: Record "Detailed Vendor Ledg. Entry";
        LastDate: Date;
    begin
        Clear(TempResponse);
        clear(responseCode);
        clear(ResponseMessage);
        Vendor.RESET;
        Vendor.SETRANGE("No.", ACCOUNT_NUMBER);
        if Vendor.FIND('-') THEN BEGIN
            Vendor.CALCFIELDS(Balance);
            LastDate := 0D;
            VendorLedgerEntry.RESET;
            VendorLedgerEntry.SETRANGE(Reversed, FALSE);
            VendorLedgerEntry.SETRANGE("Vendor No.", Vendor."No.");
            VendorLedgerEntry.SetCurrentKey("Posting Date", "Transaction Time");
            VendorLedgerEntry.SetAscending("Posting Date", false);
            VendorLedgerEntry.SetAscending("Transaction Time", false);
            if VendorLedgerEntry.FINDSET THEN BEGIN
                REPEAT
                    LastDate := VendorLedgerEntry."Posting Date";
                UNTIL (VendorLedgerEntry.NEXT = 0) OR (i = noOfTransactions);
            end;
            if LastDate <> 0D then begin
                LastDate := CalcDate('-1D', LastDate);
                DetailedLedger.Reset();
                DetailedLedger.SetFilter("Posting Date", '..%1', LastDate);
                DetailedLedger.SetRange("Vendor No.", Vendor."No.");
                if DetailedLedger.FindSet() then begin
                    DetailedLedger.CalcSums(Amount);
                    OpeningBalance := DetailedLedger.Amount;
                end;
            end
            else
                OpeningBalance := 0;
            RunningBalance := 0;
            RunningBalance := OpeningBalance;
            responseCode := '00';
            ResponseMessage.ADDTEXT('{"AccountName":"' + Vendor.Name + '", "Balance":"' + Format(Vendor.Balance) + '", "Transactions":[');
            VendorLedgerEntry.RESET;
            VendorLedgerEntry.SETRANGE(Reversed, FALSE);
            VendorLedgerEntry.SETRANGE("Vendor No.", Vendor."No.");
            VendorLedgerEntry.SetCurrentKey("Posting Date", "Transaction Time");
            VendorLedgerEntry.SetAscending("Posting Date", false);
            VendorLedgerEntry.SetAscending("Transaction Time", false);
            if VendorLedgerEntry.FINDSET THEN BEGIN
                i := 1;
                REPEAT
                    DrCr := '';
                    VendorLedgerEntry.CALCFIELDS(Amount);
                    if VendorLedgerEntry.Amount > 0 then
                        DrCr := 'DR'
                    else
                        DrCr := 'CR';
                    RunningBalance += VendorLedgerEntry.Amount;
                    TempResponse.ADDTEXT('{"transactionID":"' + FORMAT(VendorLedgerEntry."Document No.") + '",');
                    TempResponse.ADDTEXT('"DrCr":"' + DrCr + '",');
                    TempResponse.ADDTEXT('"Description":"' + VendorLedgerEntry.Description + '",');
                    TempResponse.ADDTEXT('"postingDate":"' + FORMAT(VendorLedgerEntry."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>') + '",');
                    TempResponse.ADDTEXT('"postingTime":"' + FORMAT(VendorLedgerEntry."Transaction Time", 0, '<Hours24,2>:<Minutes,2>:<Seconds,2>') + '",');
                    TempResponse.ADDTEXT('"amount":"' + FORMAT(ABS(VendorLedgerEntry.Amount), 0, 1) + '",');
                    TempResponse.ADDTEXT('"RunningBalance":"' + FORMAT((RunningBalance), 0, 1) + '"}');
                    TempResponse.ADDTEXT(',');
                    i += 1;
                UNTIL (VendorLedgerEntry.NEXT = 0) OR (i = noOfTransactions);
                if STRLEN(FORMAT(TempResponse)) > 1 THEN ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            ResponseMessage.ADDTEXT(']}');
            SaccoSetup.Get;
            if SaccoSetup."Mini Statement Charge" <> '' then begin
                Channel_Transactions.Init;
                Channel_Transactions."Entry No" := Channel_Transactions.GetLastEntryNo;
                Channel_Transactions."Transaction Type" := SaccoSetup."Mini Statement Charge";
                GuidValue := CreateGuid();
                Channel_Transactions."Document No" := CopyStr(DelChr(Format(GuidValue), '=', '-{}'), 1, 15);
                Channel_Transactions."Payment Refrence Code" := CopyStr(DelChr(Format(GuidValue), '=', '-{}'), 1, 15);
                Channel_Transactions."Account Reference" := Vendor."Member No.";
                Channel_Transactions."Dr_Account No" := MemberManagement.GetMemberAccount(Vendor."Member No.", ProductPostingType::"Withdrawable Deposit");
                Channel_Transactions."Dr_Member No" := Vendor."Member No.";
                Channel_Transactions."Cr_Account No" := '';
                Channel_Transactions."Cr_Member No" := '';
                Channel_Transactions.Amount := 0;
                Channel_Transactions.Narration := 'Mini Statement Request';
                Channel_Transactions."Created By" := UserId;
                Channel_Transactions.Confirmed := true;
                Channel_Transactions."Created On" := CurrentDateTime;
                Channel_Transactions."Confirmation Time" := CurrentDateTime;
                Channel_Transactions."Transaction Name" := 'Mini Statement Request';
                Channel_Transactions.Insert;
                CreateTransactionDump(Channel_Transactions."Entry No");
            end;
        END
        ELSE BEGIN
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Account Does Not Exist"}');
            Exit;
        end;
    end;

    procedure EmailFullStatement(var ACCOUNT_NUMBER: Code[20]; var StartDate: Date; var EndDate: Date; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        DateFilter: Text[250];
        Recipients: List of [Text];
        Member: array[2] of Record Members;
        AccountFilter: Text[250];
        MemberNo: Code[20];
        BalanceBefore, Charges : Decimal;
        EntryNo: Integer;
    begin
        DateFilter := '';
        CLEAR(ResponseCode);
        CLEAR(ResponseMessage);
        if (StartDate = 0D) or (EndDate = 0D) then begin
            responseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide Start and End Dates"}');
            exit;
        end;
        DateFilter := Format(StartDate) + '..' + Format(EndDate);
        if Vendor.Get(ACCOUNT_NUMBER) then begin
            AccountFilter := Vendor."No.";
            MemberNo := Vendor."Member No.";
        end
        else begin
            if Member[1].Get(ACCOUNT_NUMBER) then begin
                AccountFilter := '';
                MemberNo := Member[1]."No.";
            end
            else begin
                ResponseCode := '01';
                ResponseMessage.ADDTEXT('{"Response":"The Account ' + ACCOUNT_NUMBER + ' does not exist"}');
                EXIT;
            end;
        end;
        if ChannelTransactionSetup.Get('911') then Charges := JournalMgt.GetChargesAmount(ChannelTransactionSetup."Charge Code", 0);
        if (BalanceBefore - Charges) < 0 then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Insufficient Funds"}');
            exit;
        end;
        Member[1].RESET;
        Member[1].SETRANGE("No.", MemberNo);
        Member[1].SetFilter("Account Filter", AccountFilter);
        Member[1].SetFilter("Date Filter", DateFilter);
        if Member[1].FINDSET THEN BEGIN
            Clear(Body);
            Clear(Subject);
            Clear(Recipients);
            Recipients.Add(Member[1]."E-Mail");
            Subject := 'Account Statement ' + DateFilter + ' ' + ACCOUNT_NUMBER;
            Body += ('Dear ' + Member[1]."Full Name" + '<br></br> Please find the attached Statement as at ' + DateFilter);
            Mail.Create(Recipients, Subject, Body, true);
            Recordr.GetTable(Member[1]);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Member Statement", ACCOUNT_NUMBER, ReportFormat::Pdf, outStreamReport, Recordr);
            Mail.AddAttachment(ACCOUNT_NUMBER + '.pdf', 'PDF', inStreamReport);
            //Email.Send(Mail);
            ResponseCode := '00';
            ResponseMessage.ADDTEXT('{"Response":"The Statement has been Mailed"}');
        END
        ELSE BEGIN
            ResponseCode := '01';
            ResponseMessage.ADDTEXT('{"Response":"The Account ' + ACCOUNT_NUMBER + ' does not exist"}');
            EXIT;
        end;
    end;

    procedure EmailFullStatement(var ACCOUNT_NUMBER: Code[20]; var StartDate: Date; var EndDate: Date; var Chargable: Boolean; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        DateFilter: Text[250];
        Recipients: List of [Text];
        Member: array[2] of Record Members;
        AccountFilter: Text[250];
        MemberNo: Code[20];
        BalanceBefore, Charges : Decimal;
        EntryNo: Integer;
    begin
        DateFilter := '';
        CLEAR(ResponseCode);
        CLEAR(ResponseMessage);
        if (StartDate = 0D) or (EndDate = 0D) then begin
            responseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide Start and End Dates"}');
            exit;
        end;
        DateFilter := Format(StartDate) + '..' + Format(EndDate);
        if Vendor.Get(ACCOUNT_NUMBER) then begin
            AccountFilter := Vendor."No.";
            MemberNo := Vendor."Member No.";
        end
        else begin
            if Member[1].Get(ACCOUNT_NUMBER) then begin
                AccountFilter := '';
                MemberNo := Member[1]."No.";
            end
            else begin
                ResponseCode := '01';
                ResponseMessage.ADDTEXT('{"Response":"The Account ' + ACCOUNT_NUMBER + ' does not exist"}');
                EXIT;
            end;
        end;
        if ChannelTransactionSetup.Get('911') then Charges := JournalMgt.GetChargesAmount(ChannelTransactionSetup."Charge Code", 0);
        if (BalanceBefore - Charges) < 0 then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Insufficient Funds"}');
            exit;
        end;
        Member[1].RESET;
        Member[1].SETRANGE("No.", MemberNo);
        Member[1].SetFilter("Account Filter", AccountFilter);
        Member[1].SetFilter("Date Filter", DateFilter);
        if Member[1].FINDSET THEN BEGIN
            Clear(Body);
            Clear(Subject);
            Clear(Recipients);
            Recipients.Add(Member[1]."E-Mail");
            Subject := 'Account Statement ' + DateFilter + ' ' + ACCOUNT_NUMBER;
            Body += ('Dear ' + Member[1]."Full Name" + '<br></br> Please find the attached Statement as at ' + DateFilter);
            Mail.Create(Recipients, Subject, Body, true);
            Recordr.GetTable(Member[1]);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Member Statement", ACCOUNT_NUMBER, ReportFormat::Pdf, outStreamReport, Recordr);
            Mail.AddAttachment(ACCOUNT_NUMBER + '.pdf', 'PDF', inStreamReport);
            //Email.Send(Mail);
            ResponseCode := '00';
            ResponseMessage.ADDTEXT('{"Response":"The Statement has been Mailed"}');
            SaccoSetup.Get;
            if ((SaccoSetup."Full Statement Charge" <> '') and Chargable) then begin
                Channel_Transactions.Init;
                Channel_Transactions."Entry No" := Channel_Transactions.GetLastEntryNo;
                Channel_Transactions."Transaction Type" := SaccoSetup."Full Statement Charge";
                Channel_Transactions."Document No" := Format(CurrentDateTime);
                Channel_Transactions."Dr_Account No" := MemberManagement.GetMemberAccount(Member[1]."No.", ProductPostingType::"Withdrawable Deposit");
                Channel_Transactions."Dr_Member No" := Member[1]."No.";
                Channel_Transactions."Cr_Account No" := '';
                Channel_Transactions."Cr_Member No" := '';
                Channel_Transactions.Amount := 0;
                Channel_Transactions.Narration := 'Full Statement Request ' + DateFilter;
                Channel_Transactions."Created By" := UserId;
                Channel_Transactions."Created On" := CurrentDateTime;
                Channel_Transactions."Transaction Name" := 'Full Statement Request';
                Channel_Transactions.Insert;
                CreateTransactionDump(Channel_Transactions."Entry No");
            end;
        END
        ELSE BEGIN
            ResponseCode := '01';
            ResponseMessage.ADDTEXT('{"Response":"The Account ' + ACCOUNT_NUMBER + ' does not exist"}');
            EXIT;
        end;
    end;

    procedure GetFullStatement(var ACCOUNT_NUMBER: Code[20]; var StartDate: Date; var EndDate: Date; var responseCode: Code[20]; var ResponseMessage: BigText) Base64Pdf: Text;
    var
        DateFilter: Text[250];
        Recipients: List of [Text];
        Member: array[2] of Record Members;
        AccountFilter: Text[250];
        MemberNo: Code[20];
        BalanceBefore, Charges : Decimal;
        EntryNo: Integer;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        DateFilter := '';
        CLEAR(ResponseCode);
        CLEAR(ResponseMessage);
        if (StartDate = 0D) or (EndDate = 0D) then begin
            responseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide Start and End Dates"}');
            exit;
        end;
        DateFilter := Format(StartDate) + '..' + Format(EndDate);
        if Vendor.Get(ACCOUNT_NUMBER) then begin
            AccountFilter := Vendor."No.";
            MemberNo := Vendor."Member No.";
        end
        else begin
            if Member[1].Get(ACCOUNT_NUMBER) then begin
                AccountFilter := '';
                MemberNo := Member[1]."No.";
            end
            else begin
                ResponseCode := '01';
                ResponseMessage.ADDTEXT('{"Response":"The Account ' + ACCOUNT_NUMBER + ' does not exist"}');
                EXIT;
            end;
        end;
        if ChannelTransactionSetup.Get('911') then Charges := JournalMgt.GetChargesAmount(ChannelTransactionSetup."Charge Code", 0);
        if (BalanceBefore - Charges) < 0 then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Insufficient Funds"}');
            exit;
        end;
        Member[1].RESET;
        Member[1].SETRANGE("No.", MemberNo);
        Member[1].SetFilter("Account Filter", AccountFilter);
        Member[1].SetFilter("Date Filter", DateFilter);
        if Member[1].FINDSET THEN BEGIN
            Recordr.GetTable(Member[1]);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Member Statement", ACCOUNT_NUMBER, ReportFormat::Pdf, outStreamReport, Recordr);
            Base64Pdf := Base64Convert.ToBase64(inStreamReport);
            ResponseCode := '00';
            ResponseMessage.ADDTEXT('{"Response":"The Statement has been generated."}');
        END
        ELSE BEGIN
            ResponseCode := '01';
            ResponseMessage.ADDTEXT('{"Response":"The Account ' + ACCOUNT_NUMBER + ' does not exist"}');
            EXIT;
        end;
    end;

    procedure InterAccountTransfer(Var DEBIT_ACCOUNT_NUMBER: Code[20]; var CREDIT_ACCOUNT_NUMBER: Code[20]; var CHANNEL_REFERENCE: Code[20]; var transactionTypeCode: Code[20]; var TRANSACTION_AMOUNT: Decimal; var NARRATION: Text[50]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        EntryNo: integer;
        isLoan: Boolean;
        Loans: Record Loans;
        CrMember, DrMember, CrAccount, DrAccount : Code[20];
        BalanceBefore, BalanceAfter, Charges : decimal;
        TransactionTypes: Record "Channel Transaction Setup";
        JournalMgt: Codeunit "Journal Management";
    begin
        isLoan := false;
        Channel_Transactions.Reset();
        if Channel_Transactions.FindLast() then
            EntryNo := Channel_Transactions."Entry No" + 1
        else
            EntryNo := 1;

        Channel_Transactions.Reset();
        Channel_Transactions.SetRange("Document No", CHANNEL_REFERENCE);
        if Channel_Transactions.FindFirst() then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Transaction already exists"}');
            LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
            exit;
        end;
        Channel_Transactions.Reset();
        Channel_Transactions.SetRange("Transaction Type", transactionTypeCode);
        Channel_Transactions.SetRange("Dr_Account No", DEBIT_ACCOUNT_NUMBER);
        if Channel_Transactions.FindFirst() then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"There is unposted transaction, Kindly wait before making anaother request."}');
            LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
            exit;
        end;

        BalanceBefore := 0;
        BalanceAfter := 0;
        Charges := 0;
        if Vendor.Get(DEBIT_ACCOUNT_NUMBER) then begin
            Vendor.CalcFields(Balance, "Uncleared Funds");
            BalanceBefore := Vendor.Balance - Vendor."Uncleared Funds";
            DrMember := Vendor."Member No.";
            DrAccount := Vendor."No.";
            if Vendor."Cash Transfer Allowed" = false then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Debit Account Does Not Allow Cash Transfers"}');
                LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                exit;
            end;
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Debit Account Does Not Exist"}');
            LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
            exit;
        end;
        if Vendor.Get(CREDIT_ACCOUNT_NUMBER) then begin
            CrMember := Vendor."Member No.";
            CrAccount := Vendor."No.";
        end
        else begin
            if Loans.Get(CREDIT_ACCOUNT_NUMBER) then begin
                CrMember := Loans."Member No.";
                CrAccount := Loans."No.";
                isLoan := true;
            end
            else begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Credit Account Does Not Exist"}');
                LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                exit;
            end;
        end;
        if TRANSACTION_AMOUNT <= 0 then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide Transaction Amount"}');
            LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
            exit;
        end;
        if CheckBelowMaximumAmount(transactionTypeCode, TRANSACTION_AMOUNT, ResponseCode, ResponseMessage) = false then begin
            LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
            exit
        end;
        if TransactionTypes.Get(transactionTypeCode) then Charges := JournalMgt.GetChargesAmount(TransactionTypes."Charge Code", TRANSACTION_AMOUNT);

        if (BalanceBefore - TRANSACTION_AMOUNT - Charges) < 0 then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Insufficient Funds"}');
            LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
            exit;
        end;
        if HasPendingTransaction(DrMember, transactionTypeCode, ResponseCode, ResponseMessage) then begin
            LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
            exit;
        end;

        BalanceAfter := BalanceBefore - Charges - TRANSACTION_AMOUNT;
        Channel_Transactions.INIT;
        Channel_Transactions."Entry No" := EntryNo;
        Channel_Transactions."Transaction Type" := transactionTypeCode;
        Channel_Transactions."Document No" := CHANNEL_REFERENCE;
        Channel_Transactions."Dr_Account No" := DrAccount;
        Channel_Transactions."Dr_Member No" := DrMember;
        Channel_Transactions."Cr_Account No" := CrAccount;
        Channel_Transactions."Cr_Member No" := CrMember;
        Channel_Transactions.Amount := TRANSACTION_AMOUNT;
        Channel_Transactions.Narration := NARRATION;
        Channel_Transactions."Created By" := UserId;
        Channel_Transactions."Created On" := CurrentDateTime;
        Channel_Transactions."Transaction Name" := 'Inter Account Transfer';
        Channel_Transactions."Payment Refrence Code" := Channel_Transactions."Document No";
        Channel_Transactions.Confirmed := true;
        Channel_Transactions."Confirmation Time" := CurrentDateTime;
        Channel_Transactions.INSERT;
        CreateTransactionDump(Channel_Transactions."Entry No");
        ResponseCode := '00';
        ResponseMessage.AddText('{"Message":"Transaction Received","BeginningBalance":"' + Format(BalanceBefore) + '","Charges":"' + Format(Charges) + '","BalanceAfter":"' + Format(BalanceAfter) + '"}');
    end;

    procedure ChannelTransactions(var ACCOUNT_NUMBER: Code[20]; var CHANNEL_REFERENCE: Code[20]; var TRANSACTION_AMOUNT: Decimal; var BILL_IDENTIFIER: Code[20]; phoneNo: Text; customerName: Text; var transactionTypeCode: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        varMemberAccountNo, varPaybillAccountRef : Code[20];
        GLEntry: Record "G/L Entry";
        CrMember, DrMember, CrAccount, DrAccount : Code[20];
        BalanceBefore, BalanceAfter, Charges, AvailableBalance : Decimal;
        JournalMgt: Codeunit "Journal Management";
        ChannelsIntegrations: Codeunit "Channels Integrations";
        Loans: Record Loans;
        SaccoProduct: Record "Sacco Products";
        PaybillTransactionTypes: Enum "Paybill Transaction Types";
    begin
        BalanceBefore := 0;
        BalanceAfter := 0;
        Charges := 0;
        if TRANSACTION_AMOUNT <= 0 then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide Transaction Amount"}');
            LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
            exit;
        end;
        if not ChannelTransactionSetup.Get(transactionTypeCode) then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Transaction Type Code do not exist ' + transactionTypeCode + '"}');
            LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
            exit;
        end
        else begin
            Channel_Transactions.Reset();
            Channel_Transactions.SetRange("Document No", CHANNEL_REFERENCE);
            if Channel_Transactions.FindFirst() then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Transaction already exists ' + CHANNEL_REFERENCE + '"}');
                LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                exit;
            end;
            GLEntry.Reset();
            GLEntry.SetRange("Document No.", CHANNEL_REFERENCE);
            if GLEntry.FindFirst() then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error": "The Transaction already exists ' + CHANNEL_REFERENCE + '"}');
                LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                exit;
            end;
            Charges := JournalMgt.GetChargesAmount(ChannelTransactionSetup."Charge Code", TRANSACTION_AMOUNT);
            if ChannelTransactionSetup."Posting Type" = ChannelTransactionSetup."Posting Type"::Credit then begin
                GetMemberDepositAccount(ACCOUNT_NUMBER, varMemberAccountNo, varPaybillAccountRef, PaybillTransactionTypes);
                if Vendor.Get(varMemberAccountNo) then begin
                    if (Vendor."Cash Deposit Allowed" and (Vendor."Product Posting Type" <> Vendor."Product Posting Type"::"Loan Account")) then begin
                        Vendor.CalcFields(Balance);
                        BalanceBefore := Vendor.Balance;
                        CrMember := Vendor."Member No.";
                        CrAccount := Vendor."No.";
                    end;
                    if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Loan Account" then begin
                        Loans.Reset();
                        Loans.SetRange("Member No.", Vendor."Member No.");
                        Loans.SetRange("Loan Account", Vendor."No.");
                        if Loans.FindFirst then begin
                            Loans.CalcFields("Loan Balance");
                            BalanceBefore := Loans."Loan Balance";
                            CrMember := Loans."Member No.";
                            CrAccount := Vendor."No.";
                            BalanceAfter := BalanceBefore + Charges - TRANSACTION_AMOUNT;
                        end;
                    end;
                end;
            end
            else if ChannelTransactionSetup."Posting Type" = ChannelTransactionSetup."Posting Type"::Debit then begin
                if Vendor.Get(ACCOUNT_NUMBER) then begin
                    Vendor.CalcFields(Balance, "Uncleared Funds");
                    SaccoProduct.Get(Vendor."Product Code");
                    AvailableBalance := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor."Member No.") - Charges;

                    if AvailableBalance < TRANSACTION_AMOUNT then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"You cannot Overdraw Account!"}');
                        LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                        exit;
                    end;

                    if Vendor.Blocked <> Vendor.Blocked::" " then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"The Account is Blocked!"}');
                        LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                        exit;
                    end
                    else if not Vendor."Cash Withdraw Allowed" then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"The Account Does Not Allow Cash Withdrawals!"}');
                        LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                        exit;
                    end
                    else begin
                        SaccoProduct.Get(Vendor."Product Code");
                        Vendor.CalcFields(Balance, "Uncleared Funds");
                        BalanceBefore := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - GetPendingChannelsTransactions(Vendor."Member No.");
                        DrMember := Vendor."Member No.";
                        DrAccount := ACCOUNT_NUMBER;
                        BalanceAfter := BalanceBefore - Charges - TRANSACTION_AMOUNT;
                        if phoneNo <> '' then begin
                            if DrMember <> GetMemberNoFromPhoneNo(phoneNo) then begin
                                ResponseCode := '01';
                                ResponseMessage.AddText('{"Error":"The Phone Number provided do not match with the Account Provided"}');
                                LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                                exit;
                            end;
                        end;
                        if BalanceAfter < 0 then begin
                            ResponseCode := '01';
                            ResponseMessage.AddText('{"Error":"Insufficient Funds"}');
                            LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                            exit;
                        end;
                        if HasPendingTransaction(DrMember, transactionTypeCode, ResponseCode, ResponseMessage) then begin
                            LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                            exit;
                        end;
                    end;
                end
                else begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Debit Account Does Not Exist"}');
                    LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                    exit;
                end;
            end;
            if CheckBelowMaximumAmount(transactionTypeCode, TRANSACTION_AMOUNT, ResponseCode, ResponseMessage) = false then begin
                LogTransactionResponse(transactionTypeCode, CHANNEL_REFERENCE, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                exit;
            end;
            Channel_Transactions.INIT;
            Channel_Transactions."Entry No" := Channel_Transactions.GetLastEntryNo;
            Channel_Transactions."Account Reference" := ACCOUNT_NUMBER;
            Channel_Transactions."Transaction Type" := transactionTypeCode;
            if ChannelTransactionSetup."Posting Type" = ChannelTransactionSetup."Posting Type"::Credit then begin
                Channel_Transactions.Confirmed := true;
                Channel_Transactions.Phone := phoneNo;
                Channel_Transactions.Name := customerName;
                Channel_Transactions."Payment Refrence Code" := CHANNEL_REFERENCE;
                Channel_Transactions."Confirmation Time" := CurrentDateTime;
            end;
            Channel_Transactions."Document No" := CHANNEL_REFERENCE;
            Channel_Transactions."Dr_Account No" := DrAccount;
            Channel_Transactions."Dr_Member No" := DrMember;
            Channel_Transactions."Cr_Account No" := CrAccount;
            Channel_Transactions."Cr_Member No" := CrMember;
            Channel_Transactions.Amount := TRANSACTION_AMOUNT;
            Channel_Transactions."Created By" := UserId;
            Channel_Transactions."Created On" := CurrentDateTime;
            Channel_Transactions."Utility Code" := varPaybillAccountRef;
            Channel_Transactions."Transaction Name" := ChannelTransactionSetup.Description + BILL_IDENTIFIER;
            Channel_Transactions."Paybill Transaction Type" := PaybillTransactionTypes;
            Channel_Transactions.INSERT;
            CreateTransactionDump(Channel_Transactions."Entry No");
            ResponseCode := '00';
            ResponseMessage.AddText('{"Message":"Transaction Received","EntryNo":"' + Format(Channel_Transactions."Entry No") + '","BeginningBalance":"' + Format(BalanceBefore) + '","Charges":"' + Format(Charges) + '","BalanceAfter":"' + Format(BalanceAfter) + '"}');
        end;
    end;

    procedure ChannelTransactionConfirmation(var ChannelReference: Code[20]; var PaymentReference: Code[20]; var ReceipientPhoneNo: Code[20]; var ReceipientName: Text[100]; var Confirmed: Boolean; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    begin
        Channel_Transactions.Reset();
        Channel_Transactions.SetRange("Document No", ChannelReference);
        Channel_Transactions.SetRange(Reversed, false);
        Channel_Transactions.SetRange(Confirmed, false);
        Channel_Transactions.SetRange("Document No", ChannelReference);
        if not Channel_Transactions.FindFirst then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide a valid Channel Reference"}');
            exit;
        end
        else begin
            if Confirmed then begin
                if PaymentReference = '' then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"Please Provide Payment Reference"}');
                    exit;
                end;
                Channel_Transactions."Payment Refrence Code" := PaymentReference;
                Channel_Transactions.Phone := ReceipientPhoneNo;
                Channel_Transactions.Name := ReceipientName;
                Channel_Transactions.Confirmed := true;
                Channel_Transactions.Reversed := false;
            end
            else begin
                Channel_Transactions."Payment Refrence Code" := '';
                Channel_Transactions.Phone := '';
                Channel_Transactions.Name := '';
                Channel_Transactions.Confirmed := false;
                Channel_Transactions.Reversed := true;
            end;

            Channel_Transactions."Confirmation Time" := CurrentDateTime;
            Channel_Transactions.Modify(true);
            ResponseCode := '00';
            ResponseMessage.AddText('{"Message":"Confirmation done Successfully"}');
        end;
    end;

    procedure TransactionReversal(Var ORIGINAL_TRANSACTION_REF: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        GLEntry: Record "G/L Entry";
        ReversalEntry: Record "Reversal Entry";
        Loans: Record Loans;
    begin
        CLEAR(responseCode);
        CLEAR(responseMessage);
        GLEntry.RESET;
        GLEntry.SETRANGE(Reversed, FALSE);
        GLEntry.SETRANGE("Document No.", ORIGINAL_TRANSACTION_REF);
        if GLEntry.FINDSET THEN BEGIN
            REPEAT
                ReversalEntry.SetHideDialog(TRUE);
                ReversalEntry.SetHideWarningDialogs;
                ReversalEntry.ReverseTransaction(GLEntry."Transaction No.");
            UNTIL GLEntry.NEXT = 0;
            responseCode := '01';
            responseMessage.ADDTEXT('{"Response":"Successfully Reversed ' + ORIGINAL_TRANSACTION_REF + '"}');
        END
        ELSE BEGIN
            GLEntry.RESET;
            GLEntry.SETRANGE(Reversed, FALSE);
            GLEntry.SETRANGE("External Document No.", ORIGINAL_TRANSACTION_REF);
            if GLEntry.FINDSET THEN BEGIN
                REPEAT
                    ReversalEntry.SetHideDialog(TRUE);
                    ReversalEntry.SetHideWarningDialogs;
                    ReversalEntry.ReverseTransaction(GLEntry."Transaction No.");
                UNTIL GLEntry.NEXT = 0;
                responseCode := '00';
                responseMessage.ADDTEXT('Successfully Reversed ' + ORIGINAL_TRANSACTION_REF);
            END
            ELSE BEGIN
                responseCode := '01';
                responseMessage.ADDTEXT('{"Response":"Document No not found for Reversal"}');
            end;
            Loans.RESET;
            Loans.SetRange("Cheque No.", ORIGINAL_TRANSACTION_REF);
            if Loans.FINDSET THEN BEGIN
                Loans.Status := Loans.Status::Reversed;
                Loans.MODIFY;
            end;
        end;
    end;

    internal procedure GetLoanNo(CreditAccount: Code[20]) LoanNo: Code[20]
    var
        Loans: Record Loans;
    begin
        if Loans.Get(CreditAccount) then begin
            LoanNo := Loans."No.";
        end
        else begin
            if Vendor.Get(CreditAccount) then begin
                Loans.Reset();
                Loans.SetRange("Loan Account", Vendor."No.");
                Loans.SetRange("Member No.", Vendor."Member No.");
                Loans.SetFilter("Loan Balance", '>0');
                if Loans.FindFirst() then LoanNo := Loans."No.";
            end
            else
                exit('NAN');
        end;
        exit(LoanNo);
    end;

    internal procedure PostChannelTransactions()
    var
        RefundAmount: Decimal;
        RefundAccount: Code[20];
        PostingDescription: Text[100];
        LoanNo, Dim1, Dim2, JournalBatch, JournalTemplate, DocumentNo, DebitAccount, AccountNo : Code[20];
        LineNo: Integer;
        PostingDate: Date;
        PostingAmount, LoanBalance, PenaltyBalance, InterestBalance, PrincipalBalance, PenaltyPaid, InterestPaid, PrincipalPaid, BaseAmount, UnAllocatedAmount : Decimal;
        Loans: Record Loans;
        MembersMgt: Codeunit "Member Management";
        JobExecEntries: Record "Job Execution Entries";
        All: Integer;
        SaccoSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        Employee: Record Employee;
        SMSManagement: Codeunit "Notifications Management";
        SMSSource: Code[20];
        SMSPhoneNo: Text;
        SMSText: Text;
        Vendor_Check: Record Vendor;
        Dr_Member: Record Members;
        Cr_Member: Record Members;
    begin
        SaccoSetup.Get();
        Channel_Transactions.Reset();
        Channel_Transactions.SetRange(Posted, true);
        if Channel_Transactions.FindSet() then begin
            repeat
                ArchiveChannelTransactions(Channel_Transactions."Entry No", Channel_Transactions."Document No");
            until Channel_Transactions.Next() = 0;
        end;
        Channel_Transactions.Reset();
        Channel_Transactions.SetRange(Reversed, true);
        if Channel_Transactions.FindSet() then begin
            repeat
                ArchiveChannelTransactions(Channel_Transactions."Entry No", Channel_Transactions."Document No");
            until Channel_Transactions.Next() = 0;
        end;
        Channel_Transactions.Reset();
        Channel_Transactions.SetRange(Skip, true);
        if Channel_Transactions.FindSet() then begin
            repeat
                ArchiveChannelTransactions(Channel_Transactions."Entry No", Channel_Transactions."Document No");
            until Channel_Transactions.Next() = 0;
        end;
        Channel_Transactions.Reset();
        Channel_Transactions.SetRange(Posted, false);
        Channel_Transactions.SetRange(Confirmed, true);
        Channel_Transactions.SetRange(Reversed, false);
        Channel_Transactions.SetCurrentKey("Transaction Type");
        Channel_Transactions.SetCurrentKey("Entry No", "Transaction Type");
        Channel_Transactions.SetAscending("Transaction Type", true);
        if Channel_Transactions.FindSet() then begin
            All := Channel_Transactions.Count;
            repeat
                JournalBatch := 'ITL-MOBI';
                JournalTemplate := 'GENERAL';
                LineNo := JournalMgt.PrepareJournal(JournalTemplate, JournalBatch);
                DocumentNo := Channel_Transactions."Payment Refrence Code";
                if DocumentNo = '' then DocumentNo := Channel_Transactions."Document No";
                PostingDate := DT2Date(Channel_Transactions."Created On");
                if PostingDate = 0D then PostingDate := Channel_Transactions."Posting Date";
                if PostingDate = 0D then exit;
                if ChannelTransactionSetup.Get(Channel_Transactions."Transaction Type") then begin
                    if ((CheckPostOk(DocumentNo)) and (CheckAccountStatus(Channel_Transactions."Entry No", Channel_Transactions."Document No"))) then begin
                        if ChannelTransactionSetup."Posting Type" = ChannelTransactionSetup."Posting Type"::Credit then begin
                            PostingDescription := Channel_Transactions.Narration;
                            if PostingDescription = '' then
                                PostingDescription := CopyStr(StrSubstNo('%1 %2 : %3 #%4', ChannelTransactionSetup.Description, Channel_Transactions.Phone, Channel_Transactions.Name, Channel_Transactions."Utility Code"), 1, 50);
                            if (Vendor.Get(Channel_Transactions."Cr_Account No") and (Channel_Transactions."Cr_Member No" <> '')) then begin
                                if Vendor.Blocked = Vendor.Blocked::" " then begin
                                    if Vendor."Product Posting Type" <> Vendor."Product Posting Type"::"Loan Account" then begin
                                        //Debit Balancing Account                                    
                                        LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::"Bank Account", ChannelTransactionSetup."Balancing Account No", PostingDate, PostingDescription, Channel_Transactions.Amount, Dim1, Dim2, Channel_Transactions."Cr_Member No", DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, 'MOBI', 'MOBI', Channel_Transactions."Cr_Member No", '', 0, '', JournalTemplate, JournalBatch);
                                        LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, Channel_Transactions."Cr_Account No", PostingDate, PostingDescription, -1 * Channel_Transactions.Amount, Dim1, Dim2, Channel_Transactions."Cr_Member No", DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, 'MOBI', 'MOBI', Channel_Transactions."Cr_Member No", '', 0, '', JournalTemplate, JournalBatch);
                                        if ChannelTransactionSetup."Charge Code" <> '' then begin
                                            PostingDescription := ChannelTransactionSetup."Charge Description";
                                            LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, Channel_Transactions."Cr_Account No", PostingDate, PostingDescription, JournalMgt.GetChargesAmount(ChannelTransactionSetup."Charge Code", Channel_Transactions.Amount), Dim1, Dim2, Channel_Transactions."Cr_Member No", DocumentNo, GlobalTransactionType::Charge, LineNo, 'MOBI', 'MOBI', Channel_Transactions."Cr_Member No", '', 0, '', JournalTemplate, JournalBatch);
                                            LineNo := JournalMgt.AddCharges(ChannelTransactionSetup."Charge Code", '', Channel_Transactions.Amount, LineNo, DocumentNo, Channel_Transactions."Cr_Member No", 'MOBI', 'MOBI', Channel_Transactions."Cr_Member No", JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, false);
                                        end;
                                    end
                                    else if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Loan Account" then begin
                                        DebitAccount := ChannelTransactionSetup."Balancing Account No";
                                        LoanNo := '';
                                        LoanNo := GetLoanNo(Channel_Transactions."Cr_Account No");
                                        if Loans.Get(LoanNo) then begin
                                            if SaccoSetup."Daily Interest Accrual" then
                                                LoanMgmt.PostLoanInterest(PostingDate, '', 0, Loans."Member No.", Loans."No.");
                                            Loans.CalcFields("Loan Balance", "Penalty Balance", "Interest Balance", "Principal Balance");
                                            LoanBalance := Loans."Loan Balance" - Channel_Transactions.Amount;

                                            BaseAmount := 0;
                                            PenaltyBalance := 0;
                                            PenaltyPaid := 0;
                                            InterestBalance := 0;
                                            InterestPaid := 0;
                                            PrincipalBalance := 0;
                                            PrincipalPaid := 0;

                                            BaseAmount := Channel_Transactions.Amount;
                                            PenaltyBalance := Loans."Penalty Balance";
                                            InterestBalance := Loans."Interest Balance";
                                            Principalbalance := Loans."Principal Balance";

                                            if BaseAmount > PenaltyBalance then begin
                                                PenaltyPaid := PenaltyBalance;
                                                BaseAmount -= PenaltyPaid;
                                            end
                                            else begin
                                                PenaltyPaid := BaseAmount;
                                                BaseAmount := 0;
                                            end;

                                            if BaseAmount > InterestBalance then begin
                                                InterestPaid := InterestBalance;
                                                BaseAmount -= InterestPaid;
                                            end
                                            else begin
                                                InterestPaid := BaseAmount;
                                                BaseAmount := 0;
                                            end;

                                            if BaseAmount > PrincipalBalance then begin
                                                PrincipalPaid := PrincipalBalance;
                                                BaseAmount -= PrincipalPaid;
                                            end
                                            else begin
                                                PrincipalPaid := BaseAmount;
                                                BaseAmount := 0;
                                            end;
                                            if BaseAmount <> 0 then
                                                UnAllocatedAmount := BaseAmount;


                                            //Penalty Paid
                                            AccountNo := Loans."Loan Account";
                                            PostingAmount := PenaltyPaid;
                                            PostingDescription := 'Penalty Paid';
                                            LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Penalty Paid", LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", '', 0, '', JournalTemplate, JournalBatch);

                                            //Interest Paid
                                            AccountNo := Loans."Loan Account";
                                            PostingAmount := InterestPaid;
                                            PostingDescription := 'Interest Paid';
                                            LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", '', 0, '', JournalTemplate, JournalBatch);

                                            //Principal Paid
                                            AccountNo := Loans."Loan Account";
                                            PostingAmount := PrincipalPaid;
                                            PostingDescription := 'Principal Paid';
                                            LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", '', 0, '', JournalTemplate, JournalBatch);
                                            PostingDescription := ChannelTransactionSetup.Description;
                                            if UnallocatedAmount <> 0 then begin
                                                //Post Unallocated Amount
                                                AccountNo := Loans."Loan Account";
                                                PostingAmount := UnAllocatedAmount;
                                                PostingDescription := 'School Fee Transfer';
                                                LineNo := JournalMgt.CreateUnallocationJournalLine(GlobalAccountType::Vendor, '', PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Acc. Transfer", LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", JournalTemplate, JournalBatch);
                                            end;
                                            //Debit Bank
                                            AccountNo := DebitAccount;
                                            PostingAmount := Channel_Transactions.Amount;
                                            PostingDescription := 'Loan Repayment';
                                            LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::General, LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", '', 0, '', JournalTemplate, JournalBatch);
                                        end;
                                    end;
                                end;
                            end;
                        end
                        else if ChannelTransactionSetup."Posting Type" = ChannelTransactionSetup."Posting Type"::Debit then begin
                            PostingDescription := Channel_Transactions.Narration;
                            if PostingDescription = '' then
                                PostingDescription := CopyStr(StrSubstNo('%1 %2', ChannelTransactionSetup.Description, DocumentNo), 1, 50);

                            //Debit Balancing Account   
                            if ((Channel_Transactions."Cr_Account No" <> '') and (Channel_Transactions."Cr_Account No" <> '')) then begin
                                if (Vendor.Get(Channel_Transactions."Cr_Account No") and (Channel_Transactions."Cr_Member No" <> '')) then begin
                                    if Vendor.Blocked = Vendor.Blocked::" " then begin
                                        if Vendor."Product Posting Type" <> Vendor."Product Posting Type"::"Loan Account" then begin
                                            LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, Channel_Transactions."Cr_Account No", PostingDate, PostingDescription, -1 * Channel_Transactions.Amount, Dim1, Dim2, Channel_Transactions."Cr_Member No", DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, 'MOBI', 'MOBI', Channel_Transactions."Cr_Member No", '', 0, '', JournalTemplate, JournalBatch);
                                        end
                                        else if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Loan Account" then begin
                                            LoanNo := '';
                                            LoanNo := GetLoanNo(Channel_Transactions."Cr_Account No");
                                            if Loans.Get(LoanNo) then begin
                                                if SaccoSetup."Daily Interest Accrual" then
                                                    LoanMgmt.PostLoanInterest(PostingDate, '', 0, Loans."Member No.", Loans."No.");
                                                Loans.CalcFields("Principal Balance", "Interest Balance", "Loan Balance");
                                                LoanBalance := Loans."Loan Balance" - Channel_Transactions.Amount;
                                                BaseAmount := 0;
                                                InterestPaid := 0;
                                                PrincipalPaid := 0;
                                                InterestBalance := 0;
                                                UnAllocatedAmount := 0;
                                                BaseAmount := Channel_Transactions.Amount;
                                                InterestBalance := Loans."Interest Balance";
                                                PrincipalBalance := Loans."Principal Balance";
                                                if InterestBalance < 0 then InterestBalance := 0;
                                                if PrincipalBalance < 0 then PrincipalBalance := 0;
                                                if InterestBalance < BaseAmount then begin
                                                    InterestPaid := InterestBalance;
                                                    BaseAmount -= InterestPaid;
                                                end
                                                else begin
                                                    InterestPaid := BaseAmount;
                                                    BaseAmount := 0;
                                                end;
                                                if PrincipalBalance > BaseAmount then begin
                                                    PrincipalPaid := BaseAmount;
                                                    BaseAmount := 0;
                                                end
                                                else begin
                                                    PrincipalPaid := PrincipalBalance;
                                                    BaseAmount -= PrincipalPaid;
                                                end;
                                                if BaseAmount <> 0 then UnAllocatedAmount := BaseAmount;
                                                PostingDescription := 'Interest Paid';
                                                LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * InterestPaid, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", '', 0, '', JournalTemplate, JournalBatch);
                                                PostingDescription := 'Principal Paid';
                                                LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * PrincipalPaid, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", '', 0, '', JournalTemplate, JournalBatch);
                                                PostingDescription := ChannelTransactionSetup.Description;
                                                if UnallocatedAmount <> 0 then begin
                                                    //Post Unallocated Amount
                                                    PostingDescription := 'School Fee Transfer';
                                                    LineNo := JournalMgt.CreateUnallocationJournalLine(GlobalAccountType::Vendor, '', PostingDate, PostingDescription, UnAllocatedAmount, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Acc. Transfer", LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", JournalTemplate, JournalBatch);
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end
                            else
                                LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::"Bank Account", ChannelTransactionSetup."Balancing Account No", PostingDate, PostingDescription, -1 * Channel_Transactions.Amount, Dim1, Dim2, Channel_Transactions."Cr_Member No", DocumentNo, GlobalTransactionType::"Cash Withdrawal", LineNo, 'MOBI', 'MOBI', Channel_Transactions."Cr_Member No", '', 0, '', JournalTemplate, JournalBatch);
                            if ((Channel_Transactions."Dr_Account No" <> '') and (Channel_Transactions."Dr_Account No" <> '')) then
                                LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, Channel_Transactions."Dr_Account No", PostingDate, PostingDescription, Channel_Transactions.Amount, Dim1, Dim2, Channel_Transactions."Dr_Member No", DocumentNo, GlobalTransactionType::"Cash Withdrawal", LineNo, 'MOBI', 'MOBI', Channel_Transactions."Dr_Member No", '', 0, '', JournalTemplate, JournalBatch);
                            if ChannelTransactionSetup."Charge Code" <> '' then begin
                                PostingDescription := ChannelTransactionSetup."Charge Description";
                                LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, Channel_Transactions."Dr_Account No", PostingDate, PostingDescription, JournalMgt.GetChargesAmount(ChannelTransactionSetup."Charge Code", Channel_Transactions.Amount), Dim1, Dim2, Channel_Transactions."Dr_Member No", DocumentNo, GlobalTransactionType::Charge, LineNo, 'MOBI', 'MOBI', Channel_Transactions."Dr_Member No", '', 0, '', JournalTemplate, JournalBatch);
                                LineNo := JournalMgt.AddCharges(ChannelTransactionSetup."Charge Code", '', Channel_Transactions.Amount, LineNo, DocumentNo, Channel_Transactions."Dr_Member No", 'MOBI', 'MOBI', Channel_Transactions."Dr_Account No", JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, false);
                            end;
                        end;
                        //if isBalancing(JournalTemplate, JournalBatch) then begin
                        JournalMgt.CompletePosting(JournalTemplate, JournalBatch);
                        GLEntry.Reset();
                        GLEntry.SetRange("Document No.", DocumentNo);
                        GLEntry.SetRange("Document Date", PostingDate);
                        if GLEntry.FindFirst() then begin
                            SMSSource := 'CHANNELS';
                            if ChannelTransactionSetup."Posting Type" = ChannelTransactionSetup."Posting Type"::Debit then begin
                                if Member.Get(Channel_Transactions."Cr_Member No") then begin
                                    Dr_Member.Get(Channel_Transactions."Dr_Member No");
                                    SMSPhoneNo := Member."Mobile Phone No.";
                                    if Vendor_Check.Get(Channel_Transactions."Cr_Account No") then begin
                                        if Vendor_Check."Product Posting Type" <> Vendor_Check."Product Posting Type"::"Loan Account" then
                                            SMSText := StrSubstNo('Dear %1, Your %2 Account have received KES %3 on %4 from %5. Ref No. %6', Member."First Name", Vendor_Check.Name, Format(Channel_Transactions.Amount), Format(WorkDate), Dr_Member."First Name", Format(Channel_Transactions."Payment Refrence Code"))
                                        else
                                            SMSText := StrSubstNo('Dear %1, Your loan repayment of KES %2 from %3 has been processed successfully.Principal: %4 , Interest: %5 , New Balance: KES %6', Member."First Name", Format(Channel_Transactions.Amount), Dr_Member."First Name", PrincipalPaid, InterestPaid, LoanBalance);
                                        SMSManagement.SendSms(SMSPhoneNo, SMSText, SMSSource);
                                    end;
                                end;
                                if Member.Get(Channel_Transactions."Dr_Member No") then begin
                                    if ((Channel_Transactions.Phone <> '') and (Channel_Transactions.Name <> '')) then begin
                                        SMSPhoneNo := Member."Mobile Phone No.";
                                        SMSText := StrSubstNo('Dear %1, You have successfully sent KES %2 via MPesa to %3 Ref No. %4', Member."First Name", Format(Channel_Transactions.Amount), Channel_Transactions.Name, Channel_Transactions."Payment Refrence Code");
                                        SMSManagement.SendSms(SMSPhoneNo, SMSText, SMSSource);
                                        if ((SaccoSetup."Mobile Withdrawal Alert Limit" > 0) and (Channel_Transactions.Amount > SaccoSetup."Mobile Withdrawal Alert Limit")) then begin
                                            UserSetup.Reset();
                                            UserSetup.SetRange("Mobile Limit Notifications", true);
                                            if UserSetup.FindSet then begin
                                                repeat
                                                    if Employee.Get(UserSetup."Employee No.") then begin
                                                        SMSPhoneNo := Employee."Phone No.";
                                                        SMSSource := 'ALERT';
                                                        SMSText := StrSubstNo('ALERT, Dear %1, %2 Transaction %3 hit limit violation by %4. Urgently review and take necessary action', Employee."First Name", Member."First Name", Channel_Transactions."Document No", Format(Channel_Transactions.Amount));
                                                        SMSManagement.SendSms(SMSPhoneNo, SMSText, SMSSource);
                                                    end;
                                                until UserSetup.Next = 0;
                                            end;
                                        end;
                                    end
                                    else begin
                                        if Vendor_Check.Get(Channel_Transactions."Dr_Account No") then begin
                                            if Cr_Member.Get(Channel_Transactions."Cr_Member No") then begin
                                                SMSPhoneNo := Member."Mobile Phone No.";
                                                SMSText := StrSubstNo('Dear %1, You have %2 KES %3 to %4 from your %5 Account on %6. Ref No.: %7', Member."First Name", ChannelTransactionSetup."SMS Notification", Format(Channel_Transactions.Amount), Cr_Member."First Name", Vendor_Check.Name, Format(WorkDate), Format(Channel_Transactions."Payment Refrence Code"));
                                                SMSManagement.SendSms(SMSPhoneNo, SMSText, SMSSource);
                                            end;
                                        end;
                                    end;
                                end;
                            end
                            else if ChannelTransactionSetup."Posting Type" = ChannelTransactionSetup."Posting Type"::Credit then begin
                                if Member.Get(Channel_Transactions."Cr_Member No") then begin
                                    SMSPhoneNo := Member."Mobile Phone No.";
                                    if Vendor_Check.Get(Channel_Transactions."Cr_Account No") then begin
                                        if Vendor_Check."Product Posting Type" <> Vendor_Check."Product Posting Type"::"Loan Account" then begin
                                            if Channel_Transactions."Paybill Transaction Type" = Channel_Transactions."Paybill Transaction Type"::"School Fee" then
                                                SMSText := StrSubstNo('Dear %1, %2 %3 has deposited KES %4 to your %5, Payment Reference %6, For: %7.', Member."First Name", Channel_Transactions.Name, Format(Channel_Transactions.Phone), Format(Channel_Transactions.Amount), Vendor_Check.Name, Format(Channel_Transactions."Payment Refrence Code"), Channel_Transactions."Utility Code")
                                            else if Channel_Transactions."Paybill Transaction Type" = Channel_Transactions."Paybill Transaction Type"::Rent then
                                                SMSText := StrSubstNo('Dear %1, %2 %3 has deposited KES %4 to your %5, Payment Reference %6, For House : %7.', Member."First Name", Channel_Transactions.Name, Format(Channel_Transactions.Phone), Format(Channel_Transactions.Amount), Vendor_Check.Name, Format(Channel_Transactions."Payment Refrence Code"), DelChr(Channel_Transactions."Utility Code", '=', '#'))
                                            else if Channel_Transactions."Paybill Transaction Type" = Channel_Transactions."Paybill Transaction Type"::"General Merchant" then
                                                SMSText := StrSubstNo('Dear %1, %2 has deposited KES %3 to your %4, Payment Reference %5', Member."First Name", Channel_Transactions.Name, Format(Channel_Transactions.Amount), Vendor_Check.Name, Format(Channel_Transactions."Payment Refrence Code"))
                                            else
                                                SMSText := StrSubstNo('Dear %1, %2 has deposited KES %3 to your %4, Payment Reference %5', Member."First Name", Channel_Transactions.Name, Format(Channel_Transactions.Amount), Vendor_Check.Name, Format(Channel_Transactions."Payment Refrence Code"))
                                        end else
                                            SMSText := StrSubstNo('Dear %1, Your loan repayment of KES %2 has been processed successfully.Principal: %3, Interest: %4 , New Balance: KES %5', Member."First Name", Format(Channel_Transactions.Amount), PrincipalPaid, InterestPaid, LoanBalance);
                                    end;
                                    SMSManagement.SendSms(SMSPhoneNo, SMSText, SMSSource);
                                    if Vendor_Check.Get(Channel_Transactions."Cr_Account No") then begin
                                        if Vendor_Check."Business Account" then begin
                                            SMSPhoneNo := Channel_Transactions.Phone;
                                            SMSText := StrSubstNo('Dear %1, %2 Confirmed. KES %3 sent to %4 (%5) on (%6).', Channel_Transactions.Name, Channel_Transactions."Payment Refrence Code", Format(Channel_Transactions.Amount), Vendor_Check."Member Name", Vendor_Check."No.", Format(Channel_Transactions."Confirmation Time"));
                                            SMSManagement.SendSms(SMSPhoneNo, SMSText, SMSSource);
                                        end;
                                    end;
                                end;
                            end;
                        end;
                        Channel_Transactions.Posted := true;
                        Channel_Transactions."Posted On" := CurrentDateTime;
                        Channel_Transactions.Modify();
                        ArchiveChannelTransactions(Channel_Transactions."Entry No", Channel_Transactions."Document No");
                    end
                    else begin
                        Channel_Transactions.Skip := true;
                        Channel_Transactions.Modify();
                    end;
                end;
            until Channel_Transactions.Next() = 0;
        end;

        JobExecEntries.LockTable();
        JobExecEntries.Reset();
        if JobExecEntries.FindLast() then
            LineNo := JobExecEntries."Entry No" + 1
        else
            LineNo := 1;
        JobExecEntries.Init();
        JobExecEntries."Document No" := Format(Today);
        JobExecEntries."Entry No" := LineNo;
        JobExecEntries."Member No" := Loans."Member No.";
        JobExecEntries."Task Type" := JobExecEntries."Task Type"::"Mobile Post";
        JobExecEntries."Run Date" := CurrentDateTime;
        JobExecEntries."Transactions Count" := All;
        JobExecEntries.Insert();
    end;

    internal procedure isBalancing(Jtemplate: Code[20]; JBatch: Code[20]) Balanced: Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        Balanced := false;
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", Jtemplate);
        GenJournalLine.SetRange("Journal Batch Name", JBatch);
        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Vendor);
        GenJournalLine.SetFilter("Account No.", '<>%1', '');
        GenJournalLine.SetFilter("Member No.", '%1', '');
        if GenJournalLine.FindSet() then begin
            //repeat
            if GenJournalLine.FindSet() then exit(false);
            //until GenJournalLine.Next() = 0;
        end;
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", Jtemplate);
        GenJournalLine.SetRange("Journal Batch Name", JBatch);
        GenJournalLine.SetRange("Bal. Account No.", '');
        GenJournalLine.SetFilter("Account No.", '<>%1', '');
        if GenJournalLine.FindSet() then begin
            GenJournalLine.CalcSums(Amount);
            Balanced := (GenJournalLine.Amount = 0);
        end
        else
            Balanced := false;
        exit(Balanced);
    end;

    internal procedure CheckPostOk(DocumentNo: Code[20]) PostOk: Boolean
    var
        GLEntry: Record "G/L Entry";
    begin
        PostOk := false;
        GLEntry.Reset();
        GLEntry.SetRange(Reversed, false);
        GLEntry.SetRange("Document No.", DocumentNo);
        PostOk := GLEntry.IsEmpty;
    end;

    internal procedure CheckAccountStatus(EntryNo: Integer; DocumentNo: Code[20]) PostOk: Boolean
    var
        Vendor: array[2] of Record Vendor;
    begin
        PostOk := false;
        if Channel_Transactions.Get(EntryNo, DocumentNo) then begin
            if Vendor[1].Get(Channel_Transactions."Cr_Account No") then begin
                if Vendor[1].Blocked = Vendor[1].Blocked::" " then
                    PostOk := true
                else
                    PostOk := false;
            end;
            if Vendor[2].Get(Channel_Transactions."Dr_Account No") then begin
                if Vendor[2].Blocked = Vendor[2].Blocked::" " then
                    PostOk := true
                else
                    PostOk := false;
            end;
        end;
    end;

    procedure ProcessReversal(var RequestID: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        GLEntry: Record "G/L Entry";
        ReversalEntry: Record "Reversal Entry";
        Loans: Record Loans;
        OnlineReversals: Record "Channel Reversals";
        ok: Boolean;
    begin
        CLEAR(responseCode);
        CLEAR(responseMessage);
        GLEntry.RESET;
        GLEntry.SETRANGE(Reversed, FALSE);
        GLEntry.SETRANGE("Document No.", requestID);
        if GLEntry.FINDSET THEN BEGIN
            REPEAT
                ReversalEntry.SetHideDialog(TRUE);
                ReversalEntry.SetHideWarningDialogs;
                ReversalEntry.ReverseTransaction(GLEntry."Transaction No.");
            UNTIL GLEntry.NEXT = 0;
            responseCode := '00';
            responseMessage.ADDTEXT('{"Response":"Successfully Reversed ' + requestID + '"}');
        END
        ELSE BEGIN
            GLEntry.RESET;
            GLEntry.SETRANGE(Reversed, FALSE);
            GLEntry.SETRANGE("External Document No.", requestID);
            if GLEntry.FINDSET THEN BEGIN
                REPEAT
                    ReversalEntry.SetHideDialog(TRUE);
                    ReversalEntry.SetHideWarningDialogs;
                    ReversalEntry.ReverseTransaction(GLEntry."Transaction No.");
                UNTIL GLEntry.NEXT = 0;
                responseCode := '00';
                responseMessage.ADDTEXT('Successfully Reversed ' + requestID);
            END
            ELSE BEGIN
                responseCode := '00';
                responseMessage.ADDTEXT('Successfully Reversed ' + requestID);
                OnlineReversals.Init();
                OnlineReversals."Document No" := RequestID;
                OnlineReversals."Created By" := UserId;
                OnlineReversals."Created On" := CurrentDateTime;
                ok := OnlineReversals.Insert();
            end;
            Loans.RESET;
            Loans.SetRange("Cheque No.", RequestID);
            if Loans.FINDSET THEN BEGIN
                Loans.Status := Loans.Status::Reversed;
                Loans.MODIFY;
            end;
        end;
    end;

    procedure GetPendingChannelsTransactions(MemberNo: Code[20]): Decimal
    var
        ATMTransactions: Record "ATM Transactions";
        ICSMobileTransactions: Record "ICS Mobile Transactions";
        ChannelTransactionSetup: Record "Channel Transaction Setup";
        JournalMgt: Codeunit "Journal Management";
        var_amount: Decimal;
        var_charge: Decimal;
    begin
        var_amount := 0;
        Channel_Transactions.Reset();
        Channel_Transactions.SetRange("Dr_Member No", MemberNo);
        Channel_Transactions.SetRange(Posted, false);
        Channel_Transactions.SetRange(Reversed, false);
        Channel_Transactions.SetRange(Skip, false);
        if Channel_Transactions.FindSet then begin
            repeat
                if ChannelTransactionSetup.Get(Channel_Transactions."Transaction Type") then begin
                    if ChannelTransactionSetup."Posting Type" = ChannelTransactionSetup."Posting Type"::Debit then begin
                        if Vendor.Get(Channel_Transactions."Dr_Account No") then begin
                            if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Withdrawable Deposit" then begin
                                var_charge := JournalMgt.GetChargesAmount(ChannelTransactionSetup."Charge Code", Channel_Transactions.Amount);
                                var_amount += var_charge + Channel_Transactions.Amount;
                            end;
                        end;
                    end;
                end;
            until Channel_Transactions.Next = 0;
        end;

        ATMTransactions.Reset();
        ATMTransactions.SetRange("Member No", MemberNo);
        ATMTransactions.SetRange(Posted, false);
        ATMTransactions.SetRange(Reversal, false);
        if ATMTransactions.FindSet then begin
            repeat
                if ChannelTransactionSetup.Get(ATMTransactions."Transaction Type") then begin
                    if ChannelTransactionSetup."Posting Type" = ChannelTransactionSetup."Posting Type"::Debit then begin
                        if Vendor.Get(ATMTransactions."Account No") then begin
                            if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Withdrawable Deposit" then begin
                                var_charge := JournalMgt.GetChargesAmount(ChannelTransactionSetup."Charge Code", ATMTransactions.Amount);
                                var_amount += var_charge + ATMTransactions.Amount;
                            end;
                        end;
                    end;
                end;
            until ATMTransactions.Next = 0;
        end;

        ICSMobileTransactions.Reset();
        ICSMobileTransactions.SetRange("Member No", MemberNo);
        ICSMobileTransactions.SetRange(Posted, false);
        ICSMobileTransactions.SetRange(Source, ICSMobileTransactions.Source::Fosa);
        ICSMobileTransactions.SetFilter(Status, '%1|%2', ICSMobileTransactions.Status::"Pending Posting", ICSMobileTransactions.Status::"Sending Money");
        if ICSMobileTransactions.FindSet then begin
            repeat
                if Vendor.Get(ICSMobileTransactions."Account No.") then begin
                    if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Withdrawable Deposit" then begin
                        var_amount += ICSMobileTransactions.Charge + ICSMobileTransactions.Amount;
                    end;
                end;
            until ICSMobileTransactions.Next = 0;
        end;
        exit(var_amount);
    end;

    procedure GetMemberDepositAccount(var ReferenceCode: Code[20]; var MemberAccountNo: Code[20]; var PaybillAccountRef: Code[20]; var PaybillTransactionTypes: Enum "Paybill Transaction Types")
    var
        PaybillKeywords: Record "Paybill Keywords";
        ReferencePart, ReferenceLastPart, LastPart1, LastPart2, LastPart3, LastPart4, LastPart5 : Code[20];
        Position: Integer;
        Loans: Record Loans;
    begin
        if Loans.Get(ReferenceCode) then
            MemberAccountNo := Loans."Loan Account"
        else
            if Vendor.Get(ReferenceCode) then
                MemberAccountNo := Vendor."No."
            else begin
                Vendor.Reset;
                Vendor.SetRange("Paybill Business Account No.", ReferenceCode);
                if Vendor.FindFirst then
                    MemberAccountNo := Vendor."No."
                else
                    if Member.Get(ReferenceCode) then begin
                        if Vendor.Get(MemberManagement.GetMemberAccount(Member."No.", ProductPostingType::"Withdrawable Deposit")) then
                            MemberAccountNo := Vendor."No.";
                    end
                    else begin
                        Member.Reset();
                        Member.SetRange("Identification No.", ReferenceCode);
                        if Member.FindFirst then begin
                            if Vendor.Get(MemberManagement.GetMemberAccount(Member."No.", ProductPostingType::"Withdrawable Deposit")) then
                                MemberAccountNo := Vendor."No.";
                        end
                        else begin
                            Clear(LastPart1);
                            Clear(LastPart2);
                            Clear(LastPart3);
                            Clear(LastPart4);
                            Clear(LastPart5);
                            Clear(ReferencePart);
                            LastPart1 := CopyStr(DelChr(ReferenceCode, '=', ' '), StrLen(ReferenceCode), 1);
                            if (StrLen(ReferenceCode) - 1) > 0 then
                                LastPart2 := CopyStr(DelChr(ReferenceCode, '=', ' '), StrLen(ReferenceCode) - 1, 2);
                            if (StrLen(ReferenceCode) - 2) > 0 then
                                LastPart3 := CopyStr(DelChr(ReferenceCode, '=', ' '), StrLen(ReferenceCode) - 2, 3);
                            if (StrLen(ReferenceCode) - 3) > 0 then
                                LastPart4 := CopyStr(DelChr(ReferenceCode, '=', ' '), StrLen(ReferenceCode) - 3, 4);
                            if (StrLen(ReferenceCode) - 4) > 0 then
                                LastPart5 := CopyStr(DelChr(ReferenceCode, '=', ' '), StrLen(ReferenceCode) - 4, 5);

                            if PaybillKeywords.Get(LastPart1) then begin
                                PaybillTransactionTypes := PaybillKeywords."Transaction Type";
                                Position := StrPos(ReferenceCode, PaybillKeywords."Kewyword Code");
                                PaybillAccountRef := LastPart1;
                                if Position > 0 then
                                    ReferencePart := DelStr(ReferenceCode, Position, StrLen(PaybillKeywords."Kewyword Code"));
                                if PaybillKeywords."Product Posting Type" = PaybillKeywords."Product Posting Type"::"Loan Account" then begin
                                    Loans.Reset();
                                    Loans.SetRange("Member No.", GetMemberNoByRefNo(ReferencePart));
                                    Loans.SetRange("Product Code", PaybillKeywords."Product Code");
                                    Loans.SetRange(Posted, true);
                                    Loans.SetRange(Status, Loans.Status::Approved);
                                    Loans.SetFilter("Loan Balance", '>0');
                                    if Loans.FindFirst() then begin
                                        MemberAccountNo := Loans."Loan Account";
                                    end;
                                end
                                else begin
                                    Vendor.Reset();
                                    Vendor.SetRange("Member No.", GetMemberNoByRefNo(ReferencePart));
                                    Vendor.SetRange("Product Code", PaybillKeywords."Product Code");
                                    if Vendor.FindFirst() then
                                        MemberAccountNo := Vendor."No."
                                    else
                                        MemberAccountNo := MemberManagement.GetMemberAccount(GetMemberNoByRefNo(ReferencePart), ProductPostingType::"Withdrawable Deposit");
                                    if ((not Vendor.Get(MemberAccountNo)) or (Vendor."Member No." = '')) then
                                        "GetBusinessAccountBy#"(ReferenceCode, MemberAccountNo, PaybillAccountRef, PaybillTransactionTypes);

                                end;
                            end
                            else if PaybillKeywords.Get(LastPart2) then begin
                                PaybillTransactionTypes := PaybillKeywords."Transaction Type";
                                Position := StrPos(ReferenceCode, PaybillKeywords."Kewyword Code");
                                PaybillAccountRef := LastPart2;
                                if Position > 0 then
                                    ReferencePart := DelStr(ReferenceCode, Position, StrLen(PaybillKeywords."Kewyword Code"));
                                if PaybillKeywords."Product Posting Type" = PaybillKeywords."Product Posting Type"::"Loan Account" then begin
                                    Loans.Reset();
                                    Loans.SetRange("Member No.", GetMemberNoByRefNo(ReferencePart));
                                    Loans.SetRange("Product Code", PaybillKeywords."Product Code");
                                    Loans.SetRange(Posted, true);
                                    Loans.SetRange(Status, Loans.Status::Approved);
                                    Loans.SetFilter("Loan Balance", '>0');
                                    if Loans.FindFirst() then begin
                                        MemberAccountNo := Loans."Loan Account";
                                    end;
                                end
                                else begin
                                    Vendor.Reset();
                                    Vendor.SetRange("Member No.", GetMemberNoByRefNo(ReferencePart));
                                    Vendor.SetRange("Product Code", PaybillKeywords."Product Code");
                                    if Vendor.FindFirst() then
                                        MemberAccountNo := Vendor."No."
                                    else
                                        MemberAccountNo := MemberManagement.GetMemberAccount(GetMemberNoByRefNo(ReferencePart), ProductPostingType::"Withdrawable Deposit");
                                    if ((not Vendor.Get(MemberAccountNo)) or (Vendor."Member No." = '')) then
                                        "GetBusinessAccountBy#"(ReferenceCode, MemberAccountNo, PaybillAccountRef, PaybillTransactionTypes);

                                end;
                            end
                            else if PaybillKeywords.Get(LastPart3) then begin
                                PaybillTransactionTypes := PaybillKeywords."Transaction Type";
                                Position := StrPos(ReferenceCode, PaybillKeywords."Kewyword Code");
                                PaybillAccountRef := LastPart3;
                                ReferencePart := DelStr(ReferenceCode, Position, StrLen(PaybillKeywords."Kewyword Code"));
                                if PaybillKeywords."Product Posting Type" = PaybillKeywords."Product Posting Type"::"Loan Account" then begin
                                    Loans.Reset();
                                    Loans.SetRange("Member No.", GetMemberNoByRefNo(ReferencePart));
                                    Loans.SetRange("Product Code", PaybillKeywords."Product Code");
                                    Loans.SetRange(Posted, true);
                                    Loans.SetRange(Status, Loans.Status::Approved);
                                    Loans.SetFilter("Loan Balance", '>0');
                                    if Loans.FindFirst() then begin
                                        MemberAccountNo := Loans."Loan Account";
                                    end;
                                end
                                else begin
                                    Vendor.Reset();
                                    Vendor.SetRange("Member No.", GetMemberNoByRefNo(ReferencePart));
                                    Vendor.SetRange("Product Code", PaybillKeywords."Product Code");
                                    if Vendor.FindFirst() then
                                        MemberAccountNo := Vendor."No."
                                    else
                                        MemberAccountNo := MemberManagement.GetMemberAccount(GetMemberNoByRefNo(ReferencePart), ProductPostingType::"Withdrawable Deposit");
                                    if ((not Vendor.Get(MemberAccountNo)) or (Vendor."Member No." = '')) then
                                        "GetBusinessAccountBy#"(ReferenceCode, MemberAccountNo, PaybillAccountRef, PaybillTransactionTypes);
                                end;
                            end
                            else if PaybillKeywords.Get(LastPart4) then begin
                                PaybillTransactionTypes := PaybillKeywords."Transaction Type";
                                Position := StrPos(ReferenceCode, PaybillKeywords."Kewyword Code");
                                PaybillAccountRef := LastPart4;
                                ReferencePart := DelStr(ReferenceCode, Position, StrLen(PaybillKeywords."Kewyword Code"));
                                if PaybillKeywords."Product Posting Type" = PaybillKeywords."Product Posting Type"::"Loan Account" then begin
                                    Loans.Reset();
                                    Loans.SetRange("Member No.", GetMemberNoByRefNo(ReferencePart));
                                    Loans.SetRange("Product Code", PaybillKeywords."Product Code");
                                    Loans.SetRange(Posted, true);
                                    Loans.SetRange(Status, Loans.Status::Approved);
                                    Loans.SetFilter("Loan Balance", '>0');
                                    if Loans.FindFirst() then begin
                                        MemberAccountNo := Loans."Loan Account";
                                    end;
                                end
                                else begin
                                    Vendor.Reset();
                                    Vendor.SetRange("Member No.", GetMemberNoByRefNo(ReferencePart));
                                    Vendor.SetRange("Product Code", PaybillKeywords."Product Code");
                                    if Vendor.FindFirst() then
                                        MemberAccountNo := Vendor."No."
                                    else
                                        MemberAccountNo := MemberManagement.GetMemberAccount(GetMemberNoByRefNo(ReferencePart), ProductPostingType::"Withdrawable Deposit");

                                    if ((not Vendor.Get(MemberAccountNo)) or (Vendor."Member No." = '')) then
                                        "GetBusinessAccountBy#"(ReferenceCode, MemberAccountNo, PaybillAccountRef, PaybillTransactionTypes);
                                end;
                            end
                            else if PaybillKeywords.Get(LastPart5) then begin
                                PaybillTransactionTypes := PaybillKeywords."Transaction Type";
                                Position := StrPos(ReferenceCode, PaybillKeywords."Kewyword Code");
                                PaybillAccountRef := LastPart5;
                                ReferencePart := DelStr(ReferenceCode, Position, StrLen(PaybillKeywords."Kewyword Code"));
                                if PaybillKeywords."Product Posting Type" = PaybillKeywords."Product Posting Type"::"Loan Account" then begin
                                    Loans.Reset();
                                    Loans.SetRange("Member No.", GetMemberNoByRefNo(ReferencePart));
                                    Loans.SetRange("Product Code", PaybillKeywords."Product Code");
                                    Loans.SetRange(Posted, true);
                                    Loans.SetRange(Status, Loans.Status::Approved);
                                    Loans.SetFilter("Loan Balance", '>0');
                                    if Loans.FindFirst() then begin
                                        MemberAccountNo := Loans."Loan Account";
                                    end;
                                end
                                else begin
                                    Vendor.Reset();
                                    Vendor.SetRange("Member No.", GetMemberNoByRefNo(ReferencePart));
                                    Vendor.SetRange("Product Code", PaybillKeywords."Product Code");
                                    if Vendor.FindFirst() then
                                        MemberAccountNo := Vendor."No."
                                    else
                                        MemberAccountNo := MemberManagement.GetMemberAccount(GetMemberNoByRefNo(ReferencePart), ProductPostingType::"Withdrawable Deposit");
                                    if ((not Vendor.Get(MemberAccountNo)) or (Vendor."Member No." = '')) then
                                        "GetBusinessAccountBy#"(ReferenceCode, MemberAccountNo, PaybillAccountRef, PaybillTransactionTypes);
                                end;
                            end else
                                "GetBusinessAccountBy#"(ReferenceCode, MemberAccountNo, PaybillAccountRef, PaybillTransactionTypes);
                        end;
                    end;
            end;
    end;

    local procedure "GetBusinessAccountBy#"(var ReferenceCode: Code[20]; var MemberAccountNo: Code[20]; var PaybillAccountRef: Code[20]; var PaybillTransactionTypes: Enum "Paybill Transaction Types")
    var
        SchoolFee, ReferencePart, ReferenceLastPart : Code[20];
        Position: Integer;
        PaybillKeywords: Record "Paybill Keywords";
        Loans: Record Loans;
    begin
        SchoolFee := '#';
        Position := StrPos(ReferenceCode, SchoolFee);
        if Position > 0 then begin
            ReferencePart := CopyStr(DelChr(ReferenceCode, '=', ' '), 1, Position - 1);
            ReferenceLastPart := CopyStr(DelChr(ReferenceCode, '=', ' '), Position + 1, (StrLen(DelChr(ReferenceCode, '=', ' ')) - Position));
            PaybillAccountRef := ReferenceLastPart;
            if Vendor.Get(ReferencePart) then
                MemberAccountNo := Vendor."No."
            else begin
                if PaybillKeywords.Get(SchoolFee) then begin
                    if PaybillKeywords."Product Posting Type" = PaybillKeywords."Product Posting Type"::"Loan Account" then begin
                        Loans.Reset();
                        Loans.SetRange("Loan Account", GetMemberNoByRefNo(ReferencePart));
                        Loans.SetRange("Product Code", PaybillKeywords."Product Code");
                        Loans.SetRange(Posted, true);
                        Loans.SetRange(Status, Loans.Status::Approved);
                        Loans.SetFilter("Loan Balance", '>0');
                        if Loans.FindFirst() then
                            MemberAccountNo := Loans."Loan Account";
                    end
                    else begin
                        Vendor.Reset();
                        Vendor.SetRange("Member No.", GetMemberNoByRefNo(ReferencePart));
                        Vendor.SetRange("Product Code", PaybillKeywords."Product Code");
                        if Vendor.FindFirst() then
                            MemberAccountNo := Vendor."No."
                        else
                            MemberAccountNo := MemberManagement.GetMemberAccount(GetMemberNoByRefNo(ReferencePart), ProductPostingType::"Withdrawable Deposit");
                    end;
                    PaybillTransactionTypes := PaybillKeywords."Transaction Type";
                end;
            end;
        end;
    end;

    local procedure GetMemberNoByRefNo(RefCode: Code[20]) MemberNo: Code[20]
    var
        Members: Record Members;
        Vendor: Record Vendor;
    begin
        if Members.Get(RefCode) then
            MemberNo := Members."No."
        else begin
            Members.Reset;
            Members.SetRange("Identification No.", RefCode);
            if Members.FindFirst then
                MemberNo := Members."No."
            else begin
                Vendor.Reset;
                Vendor.SetRange("Paybill Business Account No.", RefCode);
                if Vendor.FindFirst then
                    MemberNo := Vendor."Member No."
            end;
        end;
    end;

    #endregion

    #region Standing Order

    procedure GetStandingOrderTypes(var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        StoTypes: Record "Standing Order Types";
    begin
        ResponseCode := '00';
        Clear(TempResponse);
        Clear(ResponseMessage);
        ResponseMessage.AddText('{"StandingOrderTypes":[');
        StoTypes.Reset();
        if StoTypes.FindSet() then begin
            repeat
                TempResponse.AddText('{"Code":"' + StoTypes.Code + '",');
                TempResponse.AddText('"Description":"' + StoTypes.Description + '"},');
            until StoTypes.Next() = 0;
        end;
        if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
        ResponseMessage.AddText(']}');
    end;

    procedure SubmitStandingOrderRequest(MemberNo: Code[20]; StandingOrderType: Code[20]; AmountType: Option "Fixed Amount",Sweep; Amount: Decimal; StandingOrderClass: Option "Internal STO","External STO","Loan-Principal","Loan-Interest","Loan Principal+Interest"; var SalaryBased: Boolean; var SourceAccountNo: Code[20]; var StartDate: Date; var RunPeriod: Integer; var DestinationMember: Code[20]; DestinationAccount: Code[20]; var ExtBankCode: Code[20]; var ExtBranchCode: Code[20]; var ExtAccountName: Code[100]; var ExtAccountNo: Code[20]; var PolicyNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        SaccoSetup: Record "General Ledger Setup";
        StandingOrder: Record "Standing Order";
        STONumber: Code[20];
        StoTypes: Record "Standing Order Types";
        Loans: Record Loans;
        NoSeries: Codeunit NoSeriesManagement;
        STOPeriod: DateFormula;
    begin
        //Format Soap Parameters
        MemberNo := FormatSoapParameters(MemberNo);
        StandingOrderType := FormatSoapParameters(StandingOrderType);
        SourceAccountNo := FormatSoapParameters(SourceAccountNo);
        DestinationMember := FormatSoapParameters(DestinationMember);
        DestinationAccount := FormatSoapParameters(DestinationAccount);
        ExtBankCode := FormatSoapParameters(ExtBankCode);
        ExtBranchCode := FormatSoapParameters(ExtBranchCode);
        ExtAccountName := FormatSoapParameters(ExtAccountName);
        ExtAccountNo := FormatSoapParameters(ExtAccountNo);
        PolicyNo := FormatSoapParameters(PolicyNo);
        ////
        if (MemberNo = '') or (StandingOrderType = '') or (SourceAccountNo = '') or (StartDate = 0D) or (RunPeriod = 0) then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide the Membe No, Standing Order Type, Source of Funds, Start date and run period"}');
            exit;
        end;
        if StoTypes.Get(StandingOrderType) = false then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Standing Order Type Does Not Exist"}');
            exit;
        end;
        if StandingOrderClass = StandingOrderClass::"External STO" then begin
            if (ExtAccountName = '') or (ExtAccountNo = '') or (ExtBankCode = '') or (ExtBranchCode = '') or (PolicyNo = '') then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"External Standing Orders MUST Define an External Account and policy for EFT Transfers"}');
                exit;
            end
            else begin
                if (DestinationAccount = '') or (DestinationMember = '') then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"Internal Standing Orders MUST Define Destination Member Details"}');
                    exit;
                end;
                if StandingOrderClass <> StandingOrderClass::"Internal STO" then begin
                    Loans.Reset();
                    Loans.SetRange("Member No.", DestinationMember);
                    Loans.SetRange("No.", DestinationAccount);
                    if Loans.IsEmpty then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"The Loan ' + DestinationAccount + ' does NOT exist for member ' + DestinationMember + '"}');
                        exit;
                    end;
                end
                else begin
                    Vendor.Reset();
                    Vendor.SetRange("Member No.", DestinationMember);
                    Vendor.SetRange("No.", DestinationAccount);
                    if Vendor.IsEmpty then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"The Account ' + DestinationAccount + ' does NOT exist for member ' + DestinationMember + '"}');
                        exit;
                    end;
                end;
            end;
        end
        else begin
            ExtAccountName := '';
            ExtAccountNo := '';
            ExtBankCode := '';
            ExtBranchCode := '';
            PolicyNo := '';
        end;
        if (AmountType = AmountType::"Fixed Amount") and (Amount = 0) then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide the standing order Amount"}');
            exit;
        end;
        if AmountType = AmountType::Sweep then Amount := 0;
        Evaluate(STOPeriod, Format(RunPeriod) + 'Y');
        SaccoSetup.Get();
        STONumber := NoSeries.GetNextNo(SaccoSetup."Standing Order Nos", Today, true);
        StandingOrder.Init();
        StandingOrder."No." := STONumber;
        StandingOrder.Validate("Member No", MemberNo);
        StandingOrder.Validate("Account No", SourceAccountNo);
        StandingOrder.Validate("STO Type", StandingOrderType);
        StandingOrder."Standing Order Class" := StandingOrderClass;
        StandingOrder."Amount Type" := AmountType;
        StandingOrder.Amount := Amount;
        if DestinationMember <> '' then StandingOrder.Validate("Destination Member No", DestinationMember);
        if DestinationAccount <> '' then StandingOrder.Validate("Destination Account", DestinationAccount);
        if ExtBankCode <> '' then StandingOrder.Validate("EFT Bank Code", ExtBankCode);
        if ExtBranchCode <> '' then StandingOrder.Validate("EFT Branch Code", ExtBranchCode);
        StandingOrder."EFT Account Name" := ExtAccountName;
        StandingOrder."Policy No." := PolicyNo;
        StandingOrder."EFT Transfer Account No" := ExtAccountNo;
        StandingOrder."Start Date" := StartDate;
        StandingOrder.Validate(Period, STOPeriod);
        StandingOrder.Insert();
        ResponseCode := '00';
        ResponseMessage.addText('{"Message":"Standing Order Created Successfully","StandingOrderNumber":"' + STONumber + '"}');
    end;

    #endregion

    #region ATM Management

    procedure GetATMCard(var identifier: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: Text)
    var
        MemberNo: Code[20];
        Status: Text;
        Vend: Record Vendor;
        JsonObj: JsonObject;
        JsonArr: JsonArray;
    begin
        Clear(ResponseMessage);
        responseCode := '00';
        if Member.Get(identifier) then
            MemberNo := Member."No."
        else if Member.Get(GetMemberNoFromPhoneNo(identifier)) then begin
            MemberNo := Member."No.";
        end
        else begin
            Member.Reset();
            Member.SetRange("Identification No.", identifier);
            if Member.FindFirst() then
                MemberNo := Member."No."
            else begin
                responseCode := '01';
                JsonObj.Add('Error', 'The Member Does Not Exist');
                JsonArr.Add(JsonObj);
                JsonArr.WriteTo(ResponseMessage);
                exit;
            end;
        end;
        if Member.Get(MemberNo) then begin
            Vend.Reset();
            Vend.SetRange("Member No.", Member."No.");
            Vend.SetRange("Product Posting Type", Vend."Product Posting Type"::"Withdrawable Deposit");
            if Vend.FindFirst() then begin
                if Vend."Card No" <> '' then
                    Status := 'Active'
                else
                    Status := 'Inactive';
                JsonObj.Add('AccountNo', Vend."No.");
                JsonObj.Add('AccountName', Vend.Name);
                JsonObj.Add('MemberName', Member.FullName);
                JsonObj.Add('CardNo', Vend."Card No");
                JsonObj.Add('Status', Status);
                JsonArr.Add(JsonObj);
            end;
        end;
        JsonArr.WriteTo(ResponseMessage);
    end;

    procedure BlockATMCard(MemberNo: Code[20]; IDNumber: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        ATMLedger: Record "ATM Ledger";
        EntryNo: Integer;
    begin
        EntryNo := 1;
        Vendor.Reset();
        Vendor.SetFilter("Card No", '<>%1', '');
        Vendor.SetRange("Member No.", MemberNo);
        if Vendor.FindSet() then begin
            repeat
                Vendor."Card No" := '';
                Vendor.Modify(True);
                ATMLedger.Reset();
                if ATMLedger.Findlast then EntryNo := ATMLedger."Entry No" + 1;
            until Vendor.Next() = 0;
        end;
        ResponseCode := '00';
        ResponseMessage.addText('{"Message":"ATM Card Blocked Successfully"}')
    end;

    #endregion

    #region Pesalink

    procedure CheckFosaAccount(var FosaAccountNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        JsonObj: JsonObject;
        JsonText: Text;
        BookBalance: Decimal;
        AvailableBalance: Decimal;
        SaccoProduct: Record "Sacco Products";
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);

        if not Vendor.Get(FosaAccountNo) then begin
            ResponseCode := '01';
            JsonObj.Add('Error', 'The Account Does Not Exist');
            JsonObj.WriteTo(JsonText);
            ResponseMessage.AddText(JsonText);
            exit;
        end;

        if Vendor.Blocked <> Vendor.Blocked::" " then begin
            ResponseCode := '01';
            JsonObj.Add('Error', 'The Account is Blocked');
            JsonObj.WriteTo(JsonText);
            ResponseMessage.AddText(JsonText);
            exit;
        end;

        if not Member.Get(Vendor."Member No.") then begin
            ResponseCode := '01';
            JsonObj.Add('Error', 'Member record does not exist');
            JsonObj.WriteTo(JsonText);
            ResponseMessage.AddText(JsonText);
            exit;
        end;

        if not SaccoProduct.Get(Vendor."Product Code") then begin
            ResponseCode := '01';
            JsonObj.Add('Error', 'Sacco product does not exist');
            JsonObj.WriteTo(JsonText);
            ResponseMessage.AddText(JsonText);
            exit;
        end;

        Vendor.CalcFields(Balance, "Uncleared Funds");

        BookBalance := Vendor.Balance;
        AvailableBalance :=
            BookBalance -
            Vendor."Uncleared Funds" -
            SaccoProduct."Minimum Balance" -
            GetPendingChannelsTransactions(Vendor."Member No.");

        if AvailableBalance < 0 then
            AvailableBalance := 0;

        ResponseCode := '00';
        JsonObj.Add('memberNo', Member."No.");
        JsonObj.Add('memberFosaNo', Vendor."No.");
        JsonObj.Add('memberName', Member.FullName);
        JsonObj.Add('memberPhone', Member."Mobile Transacting No");
        JsonObj.Add('memberId', Member."Identification No.");
        JsonObj.Add('memberAccountBalance', BookBalance);
        JsonObj.Add('memberActualBalance', AvailableBalance);

        JsonObj.WriteTo(JsonText);
        ResponseMessage.AddText(JsonText);
    end;

    internal procedure CheckPesaLinkAccountStatus(RefNo: Code[20]) PostOk: Boolean
    var
        Vendor: Record Vendor;
        PesaLinkTransactions: Record "PesaLink Transactions";
    begin
        PostOk := false;
        if PesaLinkTransactions.Get(RefNo) then begin
            if Vendor.Get(PesaLinkTransactions."FOSA Account Number") then begin
                if Vendor.Blocked = Vendor.Blocked::" " then
                    PostOk := true
                else
                    PostOk := false;
            end;
        end;
    end;

    procedure PesalinkRequest(var transactionReference: Code[20]; var paymentReference: Code[35]; var direction: Enum "Channel Transactions Direction"; var transactionTime: DateTime; var channelCode: Code[20]; var sourceAccountNumber: Code[20]; var sourceBankCode: Code[20]; var amount: Decimal; var currency: Code[20]; var memberNo: Code[20]; var fosaAccountNumber: Code[20]; var destinationAccountNumber: Code[20]; var desBankCode: Code[20]; var narration: Text; var status: Enum "Channel Transactions Status"; var comments: Text; var responseCode: Code[20]; var responseMessage: BigText)
    var
        BalanceBefore, AvailableBalance, BalanceAfter, Charges : Decimal;
        PesaLinkTransactions: Record "PesaLink Transactions";
        SaccoProduct: Record "Sacco Products";
    begin
        SaccoSetup.Get;
        SaccoSetup.TestField("PesaLink Charges");

        BalanceBefore := 0;
        BalanceAfter := 0;
        Charges := 0;

        if amount <= 0 then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide Transaction Amount"}');
            exit;
        end;

        if direction = direction::" " then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide Transaction Direction"}');
            exit;
        end;

        PesaLinkTransactions.Reset();
        PesaLinkTransactions.SetRange("Member No.", memberNo);
        PesaLinkTransactions.SetFilter(Status, '%1|%2', PesaLinkTransactions.Status::New, PesaLinkTransactions.Status::Processing);
        if PesaLinkTransactions.FindFirst() then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Transaction already exists ' + transactionReference + '"}');
            exit;
        end;

        GLEntry.Reset();
        GLEntry.SetRange("Document No.", transactionReference);
        if GLEntry.FindFirst() then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error": "The Transaction already exists ' + transactionReference + '"}');
            exit;
        end;

        Charges := JournalMgt.GetChargesAmount(SaccoSetup."PesaLink Charges", amount);
        if Vendor.Get(fosaAccountNumber) then begin
            if Vendor.Blocked <> Vendor.Blocked::" " then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"The Account is Blocked!"}');
                exit;
            end;

            Vendor.CalcFields(Balance, "Uncleared Funds");
            BalanceBefore := Vendor.Balance;
            SaccoProduct.Get(Vendor."Product Code");
            AvailableBalance := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - GetPendingChannelsTransactions(Vendor."Member No.") - Charges;

            if PesaLinkTransactions."Transaction Direction" = PesaLinkTransactions."Transaction Direction"::Incoming then begin
                BalanceAfter := BalanceBefore - Charges + amount;
                if not Vendor."Cash Deposit Allowed" then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Account Does Not Allow Cash Deposit!"}');
                    exit;
                end;
            end
            else if PesaLinkTransactions."Transaction Direction" = PesaLinkTransactions."Transaction Direction"::Outgoing then begin
                if AvailableBalance < amount then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"You cannot Overdraw Account!"}');
                    exit;
                end
                else if not Vendor."Cash Withdraw Allowed" then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Account Does Not Allow Cash Withdrawals!"}');
                    exit;
                end
                else begin
                    BalanceAfter := BalanceBefore - Charges - amount;
                    if BalanceAfter < 0 then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"Insufficient Funds"}');
                        exit;
                    end;
                    if HasPendingPesaLinkTransaction(memberNo, fosaAccountNumber, ResponseCode, ResponseMessage) then
                        exit;
                end;
            end;
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Debit Account Does Not Exist"}');
            exit;
        end;
        PesaLinkTransactions.Init;
        PesaLinkTransactions."Reference Number" := transactionReference;
        PesaLinkTransactions."Payment Refrence Code" := paymentReference;
        PesaLinkTransactions."Transaction Direction" := direction;
        PesaLinkTransactions."Transaction Time" := transactionTime;
        PesaLinkTransactions."Channel Code" := channelCode;
        PesaLinkTransactions."Source Account Number" := sourceAccountNumber;
        PesaLinkTransactions."Source Bank Code" := sourceBankCode;
        PesaLinkTransactions.Amount := amount;
        PesaLinkTransactions.Narration := narration;
        PesaLinkTransactions.Currency := currency;
        PesaLinkTransactions."Member No." := memberNo;
        PesaLinkTransactions."FOSA Account Number" := fosaAccountNumber;
        PesaLinkTransactions."Destination Account Number" := destinationAccountNumber;
        PesaLinkTransactions."Destination Bank Code" := desBankCode;
        PesaLinkTransactions.Narration := narration;
        PesaLinkTransactions.Status := status;
        PesaLinkTransactions.Comments := comments;
        PesaLinkTransactions.Insert;
        ResponseCode := '00';
        ResponseMessage.AddText('{"Message":"Transaction Received","BeginningBalance":"' + Format(BalanceBefore) + '","Charges":"' + Format(Charges) + '","BalanceAfter":"' + Format(BalanceAfter) + '"}');

    end;

    procedure UpdatePesalinkTransaction(var transactionReference: Code[20]; var paymentReference: Code[35]; var status: Enum "Channel Transactions Status"; var comments: Text; var responseCode: Code[20]; var responseMessage: BigText)
    var
        PesaLinkTransactions: Record "PesaLink Transactions";
    begin
        if not PesaLinkTransactions.Get(transactionReference) then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Please Provide a valid Reference"}');
            exit;
        end
        else begin
            PesaLinkTransactions."Payment Refrence Code" := paymentReference;
            PesaLinkTransactions.Comments := comments;
            PesaLinkTransactions.status := status;
            PesaLinkTransactions.Modify(true);
            ResponseCode := '00';
            ResponseMessage.AddText('{"Message":"Update done Successfully"}');
        end;
    end;

    procedure PostPesalinkTransactions()
    var
        PesaLinkTransactions: Record "PesaLink Transactions";
        JournalBatch, JournalTemplate, DocumentNo, ExternalDocumentNo, Dim1, Dim2, SMSSource : Code[20];
        LineNo: Integer;
        PostingDate: Date;
        PostingDescription, SMSPhoneNo, SMSText : Text;
        PostingAmount: Decimal;
        SMSManagement: Codeunit "Notifications Management";
        AvailableBalance: Decimal;
        SaccoProduct: Record "Sacco Products";
        ChannelsIntegrations: Codeunit "Channels Integrations";
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("PesaLink Settlememt Account");

        PesaLinkTransactions.Reset();
        PesaLinkTransactions.SetRange(Status, PesaLinkTransactions.Status::Posted);
        if PesaLinkTransactions.FindSet() then begin
            repeat
                ArchivePesalinkTransactions(PesaLinkTransactions."Reference Number");
            until PesaLinkTransactions.Next() = 0;
        end;
        PesaLinkTransactions.Reset();
        PesaLinkTransactions.SetRange(Skip, true);
        if PesaLinkTransactions.FindSet() then begin
            repeat
                ArchivePesalinkTransactions(PesaLinkTransactions."Reference Number");
            until PesaLinkTransactions.Next() = 0;
        end;

        PesaLinkTransactions.Reset();
        PesaLinkTransactions.SetRange(Status, PesaLinkTransactions.Status::Complete);
        PesaLinkTransactions.SetRange(Skip, false);
        if PesaLinkTransactions.FindSet then begin
            repeat
                JournalBatch := 'PESALINK';
                JournalTemplate := 'GENERAL';
                LineNo := JournalMgt.PrepareJournal(JournalTemplate, JournalBatch);
                DocumentNo := PesaLinkTransactions."Reference Number";
                ExternalDocumentNo := PesaLinkTransactions."Payment Refrence Code";
                PostingDate := DT2Date(PesaLinkTransactions."Posting Time");

                if PostingDate = 0D then
                    PostingDate := DT2Date(PesaLinkTransactions."Transaction Time");

                if PostingDate = 0D then exit;
                PostingDescription := CopyStr(StrSubstNo('%1 : %2', PesaLinkTransactions."Payment Refrence Code", PesaLinkTransactions.Narration), 1, 100);

                if PesaLinkTransactions."Transaction Direction" = PesaLinkTransactions."Transaction Direction"::Incoming then
                    PostingAmount := PesaLinkTransactions.Amount
                else
                    PostingAmount := -1 * PesaLinkTransactions.Amount;

                if (Vendor.Get(PesaLinkTransactions."FOSA Account Number")) then begin
                    if Vendor.Blocked = Vendor.Blocked::" " then begin
                        //Debit Balancing Account                                    
                        LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::"Bank Account", SaccoSetup."PesaLink Settlememt Account", PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, PesaLinkTransactions."Member No.", DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, 'MOBI', 'MOBI', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, PesaLinkTransactions."FOSA Account Number", PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, PesaLinkTransactions."Member No.", DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, 'MOBI', 'MOBI', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                        if SaccoSetup."PesaLink Charges" <> '' then begin
                            PostingDescription := '';
                            LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, PesaLinkTransactions."FOSA Account Number", PostingDate, PostingDescription, JournalMgt.GetChargesAmount(ChannelTransactionSetup."Charge Code", PesaLinkTransactions.Amount), Dim1, Dim2, PesaLinkTransactions."Member No.", DocumentNo, GlobalTransactionType::Charge, LineNo, 'MOBI', 'MOBI', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                            LineNo := JournalMgt.AddCharges(SaccoSetup."PesaLink Charges", '', PesaLinkTransactions.Amount, LineNo, DocumentNo, PesaLinkTransactions."Member No.", 'MOBI', 'MOBI', PesaLinkTransactions."Member No.", JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, false);
                        end;
                    end;

                    JournalMgt.CompletePosting(JournalTemplate, JournalBatch);
                    GLEntry.Reset();
                    GLEntry.SetRange("Document No.", DocumentNo);
                    GLEntry.SetRange("Document Date", PostingDate);
                    if GLEntry.FindFirst() then begin
                        SMSSource := 'PESALINK';
                        if Member.Get(PesaLinkTransactions."Member No.") then begin
                            Vendor.Get(PesaLinkTransactions."FOSA Account Number");
                            Vendor.CalcFields(Balance, "Uncleared Funds");
                            SaccoProduct.Get(Vendor."Product Code");
                            AvailableBalance := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor."Member No.");
                            if AvailableBalance < 0 then
                                AvailableBalance := 0;
                            SMSPhoneNo := Member."Mobile Phone No.";
                            if PesaLinkTransactions."Transaction Direction" = PesaLinkTransactions."Transaction Direction"::Incoming then
                                SMSText := StrSubstNo('Dear %1, you have received KES %2 into your %3 from Bank %4 Account No. %5 on %6. Ref: %7. Your new Fosa Available Balance is %8.', Member."First Name", PesaLinkTransactions.Amount, 'FOSA Account', PesaLinkTransactions."Source Bank Code", PesaLinkTransactions."Source Account Number", WorkDate, PesaLinkTransactions."Payment Refrence Code", AvailableBalance)
                            else
                                SMSText := StrSubstNo('Dear %1, you have sent KES %2 via Pesalink to Bank %3 Account No. %4 on %5. Ref: %6. Your new Fosa Available Balance is %7.', Member."First Name", PesaLinkTransactions.Amount, PesaLinkTransactions."Destination Bank Code", PesaLinkTransactions."Destination Account Number", WorkDate, PesaLinkTransactions."Payment Refrence Code", AvailableBalance);
                            SMSManagement.SendSms(SMSPhoneNo, SMSText, SMSSource);
                        end;
                    end;
                    PesaLinkTransactions.Status := PesaLinkTransactions.Status::Posted;
                    PesaLinkTransactions.Modify();
                    ArchivePesalinkTransactions(PesaLinkTransactions."Reference Number");
                end
                else begin
                    PesaLinkTransactions.Skip := true;
                    PesaLinkTransactions.Modify();
                end;
            until PesaLinkTransactions.Next = 0;
        end;
    end;

    internal procedure ArchivePesalinkTransactions(RefNo: Code[20])
    var
        PesaLinkTransactions: Record "PesaLink Transactions";
        ArchivedPesaLinkTransactions: Record "Archived PesaLink Transactions";
    begin
        if PesaLinkTransactions.Get(RefNo) then begin
            ArchivedPesaLinkTransactions.Init();
            ArchivedPesaLinkTransactions.TransferFields(PesaLinkTransactions);
            ArchivedPesaLinkTransactions.Insert();
            PesaLinkTransactions.Delete();
        end;
    end;

    #endregion

    #region CoopIntegration

    procedure CoopCBSEventNotifications(var AcctNo: Code[25]; var Amount: Decimal; var BookedBalance: Decimal; var ClearedBalance: Decimal; var Currency: Code[25]; var CustMemoLine1: Code[50]; var CustMemoLine2: code[50]; var CustMemoLine3: Code[50]; var EventType: Code[25]; var ExchangeRate: Decimal; var Narration: Text[150]; var ValueDate: Date; var PostingDate: Date; var PaymentRef: Code[50]; var TransactionDate: DateTime; var TransactionId: Code[25]; var TransactionType: Code[25]; var ResponseCode: Code[25]; var ResponseMessage: BigText)
    var
        EntryNo: Integer;
        CBSNotification: Record "CBS Event Notifications";
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);
        CBSNotification.Reset();
        CBSNotification.SetRange("Transaction Id", TransactionId);
        if CBSNotification.FindFirst then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Transaction already exist"}');
        end;
        CBSNotification.LockTable();
        CBSNotification.Reset();
        if CBSNotification.FindLast() then
            EntryNo := CBSNotification."Entry No" + 1
        else
            EntryNo := 1;
        CBSNotification.Init();
        CBSNotification."Entry No" := EntryNo;
        CBSNotification."Account No." := AcctNo;
        CBSNotification.Amount := Amount;
        CBSNotification."Booked Balance" := BookedBalance;
        CBSNotification."Cleared Balance" := ClearedBalance;
        CBSNotification.Currency := Currency;
        CBSNotification."Cust. Memo Line1" := CustMemoLine1;
        CBSNotification."Cust. Memo Line2" := CustMemoLine2;
        CBSNotification."Cust. Memo Line3" := CustMemoLine3;
        CBSNotification."Event Type" := EventType;
        CBSNotification."Exchange Rate" := ExchangeRate;
        CBSNotification.Narration := Narration;
        CBSNotification."Value Date" := ValueDate;
        CBSNotification."Posting Date" := PostingDate;
        CBSNotification."Payment Ref." := PaymentRef;
        CBSNotification."Transaction Date" := TransactionDate;
        CBSNotification."Transaction Id" := TransactionId;
        CBSNotification."Transaction Type" := TransactionType;
        if CBSNotification.Insert() then begin
            ResponseCode := '00';
            ResponseMessage.AddText('{"Message":"TransactionReceived Successfully"}');
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Transaction Could Not Be Received"}');
        end;
    end;

    #endregion

    #region Base64 Attachments

    procedure UploadMemberImages(RecordId: RecordId; Base64: Text; ImageType: Option Passport,Signature,FrontID,BackID,IdentificationDocument)
    var
        MemberApplication: array[2] of Record "Member Application";
        MemberEditting: array[2] of Record "Member Editing";
        MemberNomineeKin: array[2] of Record "Member Nominee/Kin";
        Base64Convert: Codeunit "Base64 Convert";
        VarOutStream: OutStream;
        RecRef: RecordRef;
    begin
        RecRef := RecordID.GetRecord;
        case RecRef.Number of
            Database::"Member Application":
                begin
                    RecRef.SetTable(MemberApplication[1]);
                    MemberApplication[2].Get(MemberApplication[1]."No.");
                    if ImageType = ImageType::Signature then begin
                        MemberApplication[2].Signature.CreateOutStream(VarOutStream);
                        Base64Convert.FromBase64(Base64, VarOutStream);
                    end
                    else if ImageType = ImageType::Passport then begin
                        MemberApplication[2]."Passport Size Photo".CreateOutStream(VarOutStream);
                        Base64Convert.FromBase64(Base64, VarOutStream);
                    end
                    else if ImageType = ImageType::FrontID then begin
                        MemberApplication[2]."Front ID Photo".CreateOutStream(VarOutStream);
                        Base64Convert.FromBase64(Base64, VarOutStream);
                    end
                    else if ImageType = ImageType::BackID then begin
                        MemberApplication[2]."Back ID Photo".CreateOutStream(VarOutStream);
                        Base64Convert.FromBase64(Base64, VarOutStream);
                    end;
                    MemberApplication[2].Modify;
                end;
            Database::"Member Editing":
                begin
                    RecRef.SetTable(MemberEditting[1]);
                    MemberEditting[2].Get(MemberEditting[1]."No.");
                    if ImageType = ImageType::Signature then begin
                        MemberEditting[2].Signature.CreateOutStream(VarOutStream);
                        Base64Convert.FromBase64(Base64, VarOutStream);
                    end
                    else if ImageType = ImageType::Passport then begin
                        MemberEditting[2]."Passport Size Photo".CreateOutStream(VarOutStream);
                        Base64Convert.FromBase64(Base64, VarOutStream);
                    end
                    else if ImageType = ImageType::FrontID then begin
                        MemberEditting[2]."Front ID Photo".CreateOutStream(VarOutStream);
                        Base64Convert.FromBase64(Base64, VarOutStream);
                    end
                    else if ImageType = ImageType::BackID then begin
                        MemberEditting[2]."Back ID Photo".CreateOutStream(VarOutStream);
                        Base64Convert.FromBase64(Base64, VarOutStream);
                    end;
                    MemberEditting[2].Modify(true);
                end;
            Database::"Member Nominee/Kin":
                begin
                    RecRef.SetTable(MemberNomineeKin[1]);
                    MemberNomineeKin[2].Get(MemberNomineeKin[1]."Source Code", MemberNomineeKin[1]."Relative Code", MemberNomineeKin[1]."Identification No.");
                    if ImageType = ImageType::Passport then begin
                        MemberNomineeKin[2]."Passport Image".CreateOutStream(VarOutStream);
                        Base64Convert.FromBase64(Base64, VarOutStream);
                    end
                    else if ImageType = ImageType::IdentificationDocument then begin
                        MemberNomineeKin[2]."Identification Document".CreateOutStream(VarOutStream);
                        Base64Convert.FromBase64(Base64, VarOutStream);
                    end;
                    MemberNomineeKin[2].Modify(true);
                end;
        end;
    end;

    procedure PortalDocumentAttchment(RecordID: RecordID; Base64: Text; FileName: Text)
    var
        DocAttachment: array[2] of Record "Document Attachment";
        RecRef: RecordRef;
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        varInstream: InStream;
        varOutstream: OutStream;
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        RecRef := RecordID.GetRecord;
        FieldRef := RecRef.Field(1);
        RecNo := FieldRef.Value;
        DocAttachment[1].Reset();
        DocAttachment[1].SetRange("Table ID", RecRef.Number);
        DocAttachment[1].SetRange("No.", RecNo);
        DocAttachment[1].SetRange("File Name", FileName);
        if DocAttachment[1].FindFirst() then DocAttachment[1].Delete(true);
        TempBlob.CreateOutStream(varOutstream);
        TempBlob.CreateInStream(varInstream);
        Base64Convert.FromBase64(Base64, varOutStream);
        DocAttachment[2].InitFieldsFromRecRef(RecRef);
        DocAttachment[2]."Document Type" := DocAttachment[2]."Document Type"::Quote;
        DocAttachment[2].SaveAttachmentFromStream(varInstream, RecRef, StrSubstNo('%1.pdf', FileName));
    end;

    procedure GetDocumentAttachments(RecordID: RecordID; var ResponseMessage: BigText)
    var
        TempResponse: BigText;
        DocAttachment: Record "Document Attachment";
        Base64Convert: Codeunit "Base64 Convert";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        RecNo: Code[20];
        TempBlob: Codeunit "Temp Blob";
        varOutstream: OutStream;
        varInstream: InStream;
        Obj: JsonObject;
        Arr: JsonArray;
    begin
        RecRef := RecordID.GetRecord;
        FieldRef := RecRef.Field(1);
        RecNo := FieldRef.Value;
        Clear(TempResponse);
        Clear(ResponseMessage);
        ResponseMessage.AddText('{ "Attachments": [');
        DocAttachment.Reset();
        DocAttachment.SetRange("Table ID", RecRef.Number);
        DocAttachment.SetRange("No.", RecNo);
        DocAttachment.SetAscending("Line No.", false);
        if DocAttachment.FindSet() then begin
            repeat
                TempBlob.CreateOutStream(varOutstream);
                DocAttachment."Document Reference ID".ExportStream(varOutstream);
                TempBlob.CreateInStream(varInstream);
                TempResponse.AddText('{"Name": "' + DocAttachment."File Name" + '",');
                TempResponse.AddText(' "Attachment": "' + Base64Convert.ToBase64(varInstream) + '" ,');
                TempResponse.AddText(' "Extension": "' + DocAttachment."File Extension" + '"},');
            until DocAttachment.Next() = 0;
        end;
        if STRLEN(FORMAT(TempResponse)) > 1 then ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
        ResponseMessage.AddText(']}');
    end;

    #endregion

    #region Employer Management
    procedure GetEmployerDetails(var EmployerCode: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Employer: Record Employers;
        JsonObj: JsonObject;
        JsonArr: JsonArray;
        ResponseText: Text;
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);
        if Employer.Get(EmployerCode) then begin
            JsonObj.Add('EmployerCode', Employer.Code);
            JsonObj.Add('EmployerName', Employer.Name);
            JsonObj.Add('EmployerAddress', Employer.Address);
            JsonObj.Add('EmployerPhoneNo', Employer."Phone No");
            JsonObj.Add('EmployerEmail', Employer."Email Address");
            JsonArr.Add(JsonObj);

            ResponseCode := '00';
            JsonArr.WriteTo(ResponseText);
            ResponseMessage.AddText(ResponseText);
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Employer Does Not Exist"}');
        end;
    end;

    procedure GetEmployerMembers(var EmployerCode: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Employer: Record Employers;
        Member: Record Members;
        JsonObj: JsonObject;
        JsonArr: JsonArray;
        ResponseText: Text;
        LoansManagement: Codeunit "Loans Management";
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);

        if not Employer.Get(EmployerCode) then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Employer Does Not Exist"}');
            exit;
        end;

        Member.Reset();
        Member.SetRange("Employer Code", Employer.Code);
        if not Member.FindSet() then begin
            ResponseCode := '02';
            ResponseMessage.AddText('{"Error":"No Members Found For This Employer"}');
            exit;
        end;
        repeat
            Clear(JsonObj);
            Member.CalcFields("Uncleared Funds", "Total Deposits", "Total Shares", "Outstanding Loans", "Self Guarantee", "Running Loans");
            JsonObj.Add('MemberNo', Member."No.");
            JsonObj.Add('PayrollNo', Member."Payroll No.");
            JsonObj.Add('DateOfRegistration', Format(Member."Date of Registration"));
            JsonObj.Add('Status', Format(Member.Status));
            JsonObj.Add('KRAPin', Format(Member."KRA PIN"));
            JsonObj.Add('PhoneNo', Format(Member."Mobile Transacting No"));
            JsonObj.Add('BranchCode', Format(Member."Global Dimension 1 Code"));
            JsonObj.Add('DateOfBirth', Format(Member."Date of Birth"));
            JsonObj.Add('FullName', Member."Full Name");
            JsonObj.Add('NationalIDNo', Member."Identification No.");
            JsonObj.Add('Email', Member."E-Mail");
            JsonObj.Add('TransactingPhoneNo', Member."Mobile Transacting No");
            JsonObj.Add('UnclearedFunds', Format(Member."Uncleared Funds"));
            JsonObj.Add('Deposits', Format(Member."Total Deposits"));
            JsonObj.Add('ShareCapital', Format(Member."Total Shares"));
            JsonObj.Add('FreeDeposits', Format(LoansManagement.GetNonSelfGuaranteeEligibility(Member."No.")));
            JsonObj.Add('QualifiedSelfGuarantee', Format(LoansManagement.GetSelfGuaranteeEligibility(Member."No.")));
            JsonObj.Add('OutstandingLoans', Format(Member."Outstanding Loans"));
            JsonObj.Add('SelfGuarantee', Format(Member."Self Guarantee"));
            JsonObj.Add('RunningLoans', Format(Member."Running Loans"));
            JsonArr.Add(JsonObj);
        until Member.Next() = 0;
        ResponseCode := '00';
        JsonArr.WriteTo(ResponseText);
        ResponseMessage.AddText(ResponseText);
    end;

    procedure GenerateVarianceReport(EmployerCode: Code[20]; PayrollCode: Code[20]; FromDate: Date; ToDate: Date) Base64Pdf: Text
    var
        Loans: Record Loans;
        DateFilter: Text;
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        DateFilter := StrSubstNo('%1..%2', Format(FromDate), Format(ToDate));
        Loans.Reset();
        if EmployerCode <> '' then
            Loans.SetRange("Employer Code", EmployerCode);
        if PayrollCode <> '' then
            Loans.SetRange("Staff No", PayrollCode);
        Loans.SetFilter("Date Filter", DateFilter);
        if Loans.FindSet() then begin
            RecRef.GetTable(Loans);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Variance Report", '', ReportFormat::Pdf, outStreamReport, RecRef);
            Base64Pdf := Base64Convert.ToBase64(inStreamReport);
        end;
    end;
    #endregion
}
