codeunit 52204011 "Global Event Subscribers"
{
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalTemplate: Code[10];
        JournalBatch: Code[10];
        TransactionType: Enum "Sacco Transaction Type";
        JournalManagement: Codeunit "Journal Management";
        LoanManagement: Codeunit "Loans Management";
        MemberMgmt: Codeunit "Member Management";
        Member: Record Members;
        GLEntry: Record "G/L Entry";
        Recipients: List of [Text];
        Body: Text;
        Subject: Text;
        SMS: Codeunit "Notifications Management";
        SMSPhone, SMSText : Text[250];
        SMSSource: Code[20];
        TempBlob: Codeunit "Temp Blob";
        outStreamReport: OutStream;
        inStreamReport: InStream;
        Recordr: RecordRef;
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
        CommunicationMgmt: Codeunit "Communications Mgmt";
        ProductPostingType: Enum "Product Posting Type";
        ATMTypes: Record "ATM Types";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure GenJnlPostOnBeforeCode(var GenJournalLine: Record "Gen. Journal Line"; var HideDialog: Boolean)
    begin
        HideDialog := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Checkoff Management", 'OnAfterCommitPostCheckoff', '', true, true)]
    local procedure OnAfterPostCheckoff(CheckoffNo: Code[20])
    var
        SMSText, SMSNo : Text[250];
        SMSSource: Code[20];
        CheckoffHeader: Record "Checkoff Header";
        CheckoffLines: Record "Checkoff Lines";
        CheckoffCalculation: Record "Checkoff Calculation";
        Members: Record Members;
        SMSSend: Codeunit "Notifications Management";
        CheckoffMgt: Codeunit "Checkoff Management";
        CompanyInformation: Record "Company Information";
    begin
        SMSSource := 'UPLOAD_PROCESSING';
        CompanyInformation.Get;
        if CheckoffHeader.Get(CheckoffNo) then begin
            CheckoffCalculation.Reset();
            CheckoffCalculation.SetRange("Document No", CheckoffNo);
            if CheckoffCalculation.FindSet() then begin
                repeat
                    CheckoffCalculation."Pay Period" := CalcDate('CM', CheckoffHeader."Posting Date");
                    CheckoffCalculation.Posted := true;
                    CheckoffCalculation.Modify(true);
                until CheckoffCalculation.Next = 0;
            end;
            if CheckoffHeader."Upload Type" <> CheckoffHeader."Upload Type"::Checkoff then begin
                CheckoffLines.Reset();
                CheckoffLines.SetRange("No.", CheckoffHeader."No.");
                CheckoffLines.SetRange(Notified, false);
                if CheckoffLines.FindSet() then begin
                    // repeat
                    //     if Members.Get(CheckoffLines."Member No") then begin
                    //         SMSNo := '';
                    //         SMSText := '';
                    //         SMSNo := Members."Mobile Phone No.";
                    //         CheckoffLines.CalcFields("Amount Earned");
                    //         if CheckoffHeader."Upload Type" = CheckoffHeader."Upload Type"::Checkoff then
                    //             SMSText := 'Dear ' + Members."First Name" + ', Your CheckOff of Kshs. ' + Format(-1 * CheckoffLines."Amount Earned") + ' has been effected successfully ' + Format(CurrentDateTime) + '. ' + CompanyInformation.Name
                    //         else if CheckoffHeader."Upload Type" = CheckoffHeader."Upload Type"::Salary then
                    //             SMSText := 'Dear ' + Members."First Name" + ', your ' + CheckoffMgt.GetDocumentNo(CheckoffHeader."Posting Date") + ' Salary of Ksh. ' + Format(-1 * CheckoffLines."Amount Earned") + ', has been credited to your FOSA A/C No.' + CheckoffLines."Collections Account";
                    //         //SMSSend.SendSms(SMSNo, SMSText, SMSSource);
                    //         CheckoffLines.Notified := true;
                    //         CheckoffLines.Modify();
                    //         Commit();
                    //       end;
                    // until CheckoffLines.Next() = 0;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Checkoff Management", 'OnAfterCommitPostCheckoff', '', true, true)]
    procedure UpdateEmployerPayrollDetails(CheckoffNo: Code[20])
    var
        CheckOff: Record "Checkoff Header";
        EmployerPayrollDetails: Record "Employer Payroll Details";
    begin
        if CheckOff.Get(CheckoffNo) then begin
            EmployerPayrollDetails.Reset();
            EmployerPayrollDetails.SetRange(Processed, false);
            if CheckOff."Upload Type" = Checkoff."Upload Type"::Checkoff then
                EmployerPayrollDetails.SetRange("Upload Type", EmployerPayrollDetails."Upload Type"::Checkoff)
            else if CheckOff."Upload Type" = Checkoff."Upload Type"::Salary then
                EmployerPayrollDetails.SetRange("Upload Type", EmployerPayrollDetails."Upload Type"::Salary);
            EmployerPayrollDetails.SetRange("Employer Code", CheckOff."Employer Code");
            EmployerPayrollDetails.SetRange(Period, CalcDate('<-CM>', CheckOff."Posting Date"));
            if EmployerPayrollDetails.FindSet() then begin
                repeat
                    EmployerPayrollDetails.Processed := true;
                    EmployerPayrollDetails.Modify(true);
                until EmployerPayrollDetails.Next() = 0;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CBS Cash Management", 'OnAfterPostReceipt', '', true, true)]
    local procedure SendReceiptOnEmail(var Receipt: Record "Receipt Header")
    var
        ReceiptHeader: Record "Receipt Lines";
        ReceiptLines: array[2] of Record "Receipt Lines";
        CurrMember, PrevMember : Code[20];
        Member: Record Members;
        MemberAmount: Decimal;
    begin
        CurrMember := '';
        PrevMember := 'PREV';
        SMSSource := 'OTC';
        ReceiptLines[1].Reset();
        ReceiptLines[1].SetRange("No.", Receipt."No.");
        ReceiptLines[1].SetFilter("Member No.", '<>%1', '');
        ReceiptLines[1].SetCurrentKey("Member No.");
        if ReceiptLines[1].FindSet() then begin
            repeat
                Clear(Recipients);
                Clear(Subject);
                Clear(Body);
                CurrMember := ReceiptLines[1]."Member No.";
                if CurrMember <> PrevMember then begin
                    if Member.Get(CurrMember) then begin
                        if Member."E-Mail" <> '' then begin
                            Recipients.Add(Member."E-Mail");
                            Subject := 'Receipt ' + Receipt."No.";
                            ReceiptLines[2].Reset();
                            ReceiptLines[2].CopyFilters(ReceiptLines[1]);
                            ReceiptLines[2].SetRange("Member No.", CurrMember);
                            if ReceiptLines[2].FindSet() then begin
                                ReceiptLines[2].CalcSums(Amount);
                                MemberAmount := 0;
                                MemberAmount := ReceiptLines[2].Amount;
                                Body += 'Dear ' + Member."Full Name";
                                Body += '<br></br>';
                                Body += 'Your Receipt of Ksh. ' + format(MemberAmount) + ' has been received Successfully';
                                if MemberAmount > 0 then begin
                                    Mail.Create(Recipients, Subject, Body, true);
                                    ReceiptHeader.Reset();
                                    ReceiptHeader.SetRange("No.", Receipt."No.");
                                    if ReceiptHeader.FindSet() then begin
                                        Recordr.GetTable(ReceiptHeader);
                                        TempBlob.CreateOutStream(outStreamReport);
                                        TempBlob.CreateInStream(inStreamReport);
                                        Report.SaveAs(Report::"Cash Receipt", ReceiptHeader."No.", ReportFormat::Pdf, outStreamReport, Recordr);
                                        Mail.AddAttachment(ReceiptHeader."No." + '.pdf', 'PDF', inStreamReport);
                                    end;
                                    //Email.Send(Mail);
                                    SMSPhone := Member."Mobile Phone No.";
                                    SMSText := StrSubstNo('Dear %1,Your Receipt of Ksh. %2 has been received Successfully', Member."First Name", MemberAmount);
                                    SMS.SendSms(SMSPhone, SMSText, SMSSource);
                                end;
                            end;
                        end;
                    end;
                end;
                PrevMember := CurrMember;
            until ReceiptLines[1].Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FOSA Management", 'OnAfterPostTellerTransaction', '', true, true)]
    local procedure OnAfterPostTellerTransaction(TellerTransaction: Record "Teller Transactions")
    var
        TTransactions: Record "Teller Transactions";
    begin
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        SMSSource := 'OTC';

        if Member.Get(TellerTransaction."Member No.") then begin
            SMSPhone := Member."Mobile Phone No.";
            if TellerTransaction."Transaction Type" = TellerTransaction."Transaction Type"::"Cash Deposit" then
                SMSText := StrSubstNo('Dear %1, Your Account %2 has been Credited with Ksh. %3', Member."First Name", TellerTransaction."Account No", TellerTransaction.Amount)
            else
                SMSText := StrSubstNo('Dear %1, Your Account %2 has been Debited with Ksh. %3', Member."First Name", TellerTransaction."Account No", TellerTransaction.Amount);
            SMS.SendSms(SMSPhone, SMSText, SMSSource);
            if Member."E-Mail" <> '' then begin
                Recipients.Add(Member."E-Mail");
                Body += 'Dear ' + Member."Full Name";
                Body += '<br></br>';
                if TellerTransaction."Transaction Type" = TellerTransaction."Transaction Type"::"Cash Deposit" then begin
                    Subject := StrSubstNo('Cash Deposit %1', TellerTransaction."No.");
                    Body += StrSubstNo('Your Account %1 have been Credited with Ksh. %2', TellerTransaction."Account No", TellerTransaction.Amount);
                end
                else begin
                    Subject := StrSubstNo('Cash Withdrawal %1', TellerTransaction."No.");
                    Body += StrSubstNo('Your Account %1 have been Debited with Ksh. %2', TellerTransaction."Account No", TellerTransaction.Amount);
                end;
                Mail.Create(Recipients, Subject, Body, true);
                TTransactions.Reset();
                TTransactions.SetRange("No.", TellerTransaction."No.");
                if TTransactions.FindSet() then begin
                    Recordr.GetTable(TTransactions);
                    TempBlob.CreateOutStream(outStreamReport);
                    TempBlob.CreateInStream(inStreamReport);
                    if TTransactions."Transaction Type" = TTransactions."Transaction Type"::"Cash Deposit" then
                        Report.SaveAs(Report::"Cash Deposit Receipt", TTransactions."No.", ReportFormat::Pdf, outStreamReport, Recordr)
                    else
                        Report.SaveAs(Report::"Cash Withdrawal", TTransactions."No.", ReportFormat::Pdf, outStreamReport, Recordr);
                    Mail.AddAttachment(TTransactions."No." + '.pdf', 'PDF', inStreamReport);
                end;
                //Email.Send(Mail);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FOSA Management", 'OnAfterPostTellerTransaction', '', true, true)]
    local procedure PrintTellerReceipt(TellerTransaction: Record "Teller Transactions")
    var
        TTransactions: Record "Teller Transactions";
    begin
        if TellerTransaction."Transaction Type" = TellerTransaction."Transaction Type"::"Cash Deposit" then begin
            TTransactions.reset;
            TTransactions.SetRange("No.", TellerTransaction."No.");
            if TTransactions.findset then
                Report.Run(Report::"Cash Deposit Receipt", false, false, TTransactions);
        end
        else if TellerTransaction."Transaction Type" = TellerTransaction."Transaction Type"::"Cash Withdrawal" then begin
            TTransactions.reset;
            TTransactions.SetRange("No.", TellerTransaction."No.");
            if TTransactions.findset then
                Report.Run(Report::"Cash Withdrawal", false, false, TTransactions);
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FOSA Management", 'OnAfterPostInterAccountTransfer', '', true, true)]
    local procedure OnAfterPostInterAccountTransfer(var InterAccountTransfer: Record "Inter Account Transfer")
    begin
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        SMSSource := 'OTC';
        if Member.Get(InterAccountTransfer."Member No") then begin
            SMSPhone := Member."Mobile Phone No.";
            if InterAccountTransfer."Member No" = InterAccountTransfer."Destination Member" then
                SMSText := StrSubstNo('Dear %1, KES %2 has been transfered from %3 to %4', Member."First Name", InterAccountTransfer.Amount, InterAccountTransfer."Transfer From", InterAccountTransfer."Destination Account")
            else begin
                if InterAccountTransfer."Document Type" = InterAccountTransfer."Document Type"::"Share Capital" then
                    SMSText := StrSubstNo('Dear %1, Your Shares of KES %2 has been transfered to %3', Member."First Name", InterAccountTransfer.Amount, InterAccountTransfer."Destination Name")
                else
                    SMSText := StrSubstNo('Dear %1, KES %2 has been transfered from %3 to %4 Acc. No. %5', Member."First Name", InterAccountTransfer.Amount, InterAccountTransfer."Transfer From", InterAccountTransfer."Destination Name", InterAccountTransfer."Destination Account");
            end;
            SMS.SendSms(SMSPhone, SMSText, SMSSource);
            if Member."E-Mail" <> '' then begin
                Recipients.Add(Member."E-Mail");
                Body += 'Dear ' + Member."First Name";
                Body += '<br></br>';

                Subject := StrSubstNo('Inter Account Transfer %1', InterAccountTransfer."No.");

                if InterAccountTransfer."Member No" = InterAccountTransfer."Destination Member" then
                    Body += StrSubstNo('KES %1 has been transfered from %2 to %3', InterAccountTransfer.Amount, InterAccountTransfer."Transfer From", InterAccountTransfer."Destination Account")
                else begin
                    if InterAccountTransfer."Document Type" = InterAccountTransfer."Document Type"::"Share Capital" then begin
                        Subject := StrSubstNo('Share Capital Transfer %1', InterAccountTransfer."No.");
                        Body += StrSubstNo('Your Shares of KES %1 has been transfered to %2', InterAccountTransfer.Amount, InterAccountTransfer."Transfer From", InterAccountTransfer."Destination Name")
                    end else
                        Body += StrSubstNo('KES %1 has been transfered from %2 to %3 Acc. No. %4', InterAccountTransfer.Amount, InterAccountTransfer."Transfer From", InterAccountTransfer."Destination Name", InterAccountTransfer."Destination Account");
                end;
                Mail.Create(Recipients, Subject, Body, true);
                //Email.Send(Mail);
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Member Management", 'OnAfterCreateMember', '', true, true)]
    local procedure CreateATMApplication(var MemberApplication: Record "Member Application"; Member: Record Members)
    var
        ATMApplication: Record "ATM Application";
        MobileApplication: Record "Mobile Application";
        MemberMgt: Codeunit "Member Management";
    begin
        if MemberApplication.ATM then begin
            ATMApplication.Reset();
            ATMApplication.SetRange("No.", MemberApplication."No.");
            if ATMApplication.FindSet() then ATMApplication.DeleteAll();
            ATMApplication.Init();
            ATMApplication."No." := MemberApplication."No.";
            ATMApplication."Application Date" := WorkDate;
            ATMApplication."Member No" := Member."No.";
            ATMApplication."Member Name" := Member."Full Name";
            if MemberMgt.GetMemberAccount(Member."No.", ProductPostingType::"Withdrawable Deposit") <> '' then ATMApplication.Validate("Account No.", MemberMgt.GetMemberAccount(Member."No.", ProductPostingType::"Withdrawable Deposit"));
            ATMTypes.Reset();
            ATMTypes.SetRange(Type, ATMTypes.Type::Debit);
            if ATMTypes.FindFirst then ATMApplication.Validate("ATM Type", ATMTypes.Code);
            ATMApplication."Created By" := UserId;
            ATMApplication."Created On" := WorkDate;
            ATMApplication."Last Updated By" := UserId;
            ATMApplication."Last Updated On" := WorkDate;
            ATMApplication.Status := ATMApplication.Status::Open;
            ATMApplication.Insert(true);
            MemberMgt.CreateAtmLien(ATMApplication."No.");
        end;
        if MemberApplication.Mobile then begin
            MobileApplication.Reset();
            MobileApplication.SetRange("No.", MemberApplication."No.");
            if MobileApplication.FindSet() then MobileApplication.DeleteAll();
            MobileApplication.Init();
            MobileApplication."No." := MemberApplication."No.";
            MobileApplication.Validate("Member No", Member."No.");
            MobileApplication."Created By" := UserId;
            MobileApplication."Created On" := CurrentDateTime;
            MobileApplication.Status := MobileApplication.Status::Open;
            MobileApplication.Insert;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Channel Guarantor Requests", 'OnAfterInsertEvent', '', true, true)]
    internal procedure SendGuarantorRequestCommunication(RunTrigger: Boolean; var Rec: Record "Channel Guarantor Requests")
    var
        SMSText, SMSNo : Text;
        Notifications: Codeunit "Notifications Management";
        Members, Members2 : Record Members;
        LoanApplication: Record "Channel Loan Application";
        Portal: Codeunit "Channels Integrations";
        RespCode: Code[20];
        TempResponse: BigText;
        GuarantorRequest: Record "Channel Guarantor Requests";
    begin
        GuarantorRequest := Rec;
        if Members.Get(GuarantorRequest."Member No") then begin
            if LoanApplication.Get(GuarantorRequest."Loan No") then begin
                if Members2.Get(LoanApplication."Member No.") then begin
                    if Members."No." = Members2."No." then Portal.ProcessGuarantorRequest(GuarantorRequest."Loan No", Members."Identification No.", 0, GuarantorRequest.AppliedAmount, 0, RespCode, TempResponse);
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Loans Management", 'OnAfterPostLoan', '', true, true)]
    procedure OnAfterPostLoan(var LoanNo: Code[20])
    var
        PhoneNo: Text[250];
        SMS: Text[250];
        Members: Record Members;
        Amnt: Decimal;
        CompanyInformation: Record "Company Information";
        LoanSchedule: Record "Loan Schedule";
        MInstallment: Decimal;
        NotificationsMgt: Codeunit "Notifications Management";
        SMSSource: Code[20];
        LoanProduct: Record "Sacco Products";
        LoanSecurities: Record "Loan Securities";
        CollateralRegister: Record "Collateral Register";
        Loans: array[2] of Record Loans;
    begin
        Loans[1].Get(LoanNo);
        if ((Loans[1].Category <> Loans[1].Category::HR) and (Loans[1].Category <> Loans[1].Category::DEBT)) then begin
            CompanyInformation.Get;
            Members.Get(Loans[1]."Member No.");
            MInstallment := 0;
            Clear(SMSSource);
            Clear(SMS);
            Clear(Recipients);
            Clear(Subject);
            Clear(Body);
            LoanSchedule.Reset();
            LoanSchedule.SetRange("Loan No.", LoanNo);
            if LoanSchedule.FindFirst() then MInstallment := round(LoanSchedule."Monthly Repayment", 1, '>');
            SMSSource := 'LOAN_DISB';
            if Loans[1]."Dividend Based" then
                SMS := StrSubstNo('Dear %1  Your %2 of Ksh. %3 has been posted. Your Loan shall be recovered from the next Dividend Payout.', Members."First Name", Loans[1]."Product Description", Loans[1]."Approved Amount")
            else
                SMS := StrSubstNo('Dear %1  Your %2 of Ksh. %3 has been credited to your FOSA Account. Your Monthly Repayment is KES. %4 Payable from %5.', Members."First Name", Loans[1]."Product Description", Loans[1]."Approved Amount", MInstallment, Loans[1]."Repayment Start Date");

            PhoneNo := Members."Mobile Transacting No";
            if PhoneNo <> '' then NotificationsMgt.SendSms(PhoneNo, SMS, SMSSource);
            Recipients.Add(Members."E-Mail");
            Subject := 'Loan Disbursement -' + LoanNo;
            Body += '<p style="font-family:Times New Roman">';
            Body += StrSubstNo('Dear %1', Members."First Name");
            Body += StrSubstNo('Your %1 of Ksh. %2 has been credited to your FOSA Account. Your Monthly Repayment Ksh. %3 Payable from %4 to %5.', Loans[1]."Product Description", Loans[1]."Approved Amount", MInstallment, Loans[1]."Repayment Start Date", Loans[1]."Repayment Start Date");
            Body += '<br></br>';
            Body += 'Please find the attached Loan Schedule.';
            Body += '<br></br>';
            Body += 'This is a system generated email.';
            Body += '<br></br>';
            Body += 'Thanks & Regards.';
            Body += '<br></br>';
            Body += '.******************.';
            Body += '<br></br>';
            Body += 'For any complains/compliments call.';
            Body += '<br></br>';
            Body += CompanyInformation."Phone No.";
            Body += '<br></br>';
            Body += CompanyInformation."E-Mail";
            Body += '<br></br>';
            Body += CompanyInformation.Name;
            Mail.Create(Recipients, Subject, Body, true);

            Loans[2].Reset();
            Loans[2].SetRange("No.", LoanNo);
            if Loans[2].FindFirst then begin
                Recordr.GetTable(Loans[2]);
                TempBlob.CreateOutStream(outStreamReport);
                TempBlob.CreateInStream(inStreamReport);
                Report.SaveAs(Report::"Loan Repayment Schedule", LoanNo, ReportFormat::Pdf, outStreamReport, Recordr);
                Mail.AddAttachment(Subject + '.pdf', 'PDF', inStreamReport);
            end;
            //Email.Send(Mail);
            LoanSecurities.Reset();
            LoanSecurities.SetRange("Loan No", LoanNo);
            LoanSecurities.SetRange("Security Type", LoanSecurities."Security Type"::Collateral);
            If LoanSecurities.FindSet then begin
                repeat
                    if CollateralRegister.Get(LoanSecurities."Security Code") then begin
                        CollateralRegister.Status := CollateralRegister.Status::"Linked to Loan";
                        CollateralRegister.Modify(true);
                    end;
                until LoanSecurities.Next = 0;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Loans Management", 'OnAfterPostLoanDisbursement', '', true, true)]
    procedure OnAfterPostLoanDisbursement(Var LoanDisbursement: Record "Loan Disbursement")
    var
        PhoneNo: Text[250];
        SMS: Text[250];
        Members: Record Members;
        CompanyInformation: Record "Company Information";
        LoanSchedule: Record "Loan Schedule";
        MInstallment: Decimal;
        NotificationsMgt: Codeunit "Notifications Management";
        SMSSource: Code[20];
        Loans: array[2] of Record Loans;
    begin
        CompanyInformation.Get;
        Members.Get(LoanDisbursement."Member No.");
        MInstallment := 0;
        Clear(SMSSource);
        Clear(SMS);
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        Loans[1].Get(LoanDisbursement."Loan No.");
        LoanSchedule.Reset();
        LoanSchedule.SetRange("Loan No.", Loans[1]."No.");
        if LoanSchedule.FindFirst() then
            MInstallment := round(LoanSchedule."Monthly Repayment", 1, '>');

        SMSSource := 'LOAN_DISB';
        SMS := StrSubstNo('Dear %1  Your %2 of Ksh. %3 has been Disbursed. Your Monthly Installment Ksh. %4 Payable from %5. Thank You.', Loans[1]."Member Name", Loans[1]."Product Description", LoanDisbursement.Amount, MInstallment, Loans[1]."Repayment Start Date");
        PhoneNo := Members."Mobile Phone No.";
        if PhoneNo <> '' then NotificationsMgt.SendSms(PhoneNo, SMS, SMSSource);
        Recipients.Add(Members."E-Mail");
        Subject := 'Loan Disbursement -' + LoanDisbursement."No.";
        Body += '<p style="font-family:Times New Roman">';
        Body += StrSubstNo('Dear %1', Loans[1]."Member Name");
        Body += StrSubstNo('Your %1 of Ksh. %2 has been Disbursed. Your Monthly Installment Ksh. %3 Payable from %4.', Loans[1]."Product Description", LoanDisbursement.Amount, MInstallment, Loans[1]."Repayment Start Date");
        Body += '<br></br>';
        Body += 'Please find the attached Loan Schedule.';
        Body += '<br></br>';
        Body += 'This is a system generated email.';
        Body += '<br></br>';
        Body += 'Thanks & Regards.';
        Body += '<br></br>';
        Body += '.******************.';
        Body += '<br></br>';
        Body += 'For any complains/compliments call.';
        Body += '<br></br>';
        Body += CompanyInformation."Phone No.";
        Body += '<br></br>';
        Body += CompanyInformation."E-Mail";
        Body += '<br></br>';
        Body += CompanyInformation.Name;
        Mail.Create(Recipients, Subject, Body, true);
        Loans[2].Reset();
        Loans[2].SetRange("No.", Loans[1]."No.");
        if Loans[2].FindFirst then begin
            Recordr.GetTable(Loans[2]);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Loan Repayment Schedule", Loans[1]."No.", ReportFormat::Pdf, outStreamReport, Recordr);
            Mail.AddAttachment(Subject + '.pdf', 'PDF', inStreamReport);
        end;
        //Email.Send(Mail);
        Loans[1].CalcFields(Disbursements);
        Loans[1]."Openning Disbursed Balance" := LoanDisbursement."Disbursed Amount" + LoanDisbursement.Amount;
        if Loans[1].Disbursements = Loans[1]."Approved Amount" then
            Loans[1]."Fully Disbursed" := true;
        Loans[1].Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Loans Management", 'OnAfterAcceptCollateral', '', true, true)]
    local procedure OnAfterAcceptCollateral(CollateralApplication: Record "Collateral Application")
    var
        PhoneNo: Text[250];
        SMS: Text[250];
        Members: Record Members;
        Amnt: Decimal;
        CompanyInformation: Record "Company Information";
        LoanSchedule: Record "Loan Schedule";
        MInstallment: Decimal;
        NotificationsMgt: Codeunit "Notifications Management";
        SMSSource: Code[20];
    begin
        SMSSource := 'COLLATERAL_ACC';
        SMS := 'Dear ' + CollateralApplication."Member Name" + ' Your ' + CollateralApplication."Collateral Description" + ' has been successfully Received and will be used to guarantee you a loan to the tune of Ksh.' + Format(CollateralApplication.Guarantee) + '. Thank You';
        if Members.Get(CollateralApplication."Member No") then begin
            if PhoneNo <> '' then begin
                PhoneNo := Members."Mobile Phone No.";
                NotificationsMgt.SendSms(PhoneNo, SMS, SMSSource);
            end
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Member Management", 'OnAfterCreateMember', '', true, true)]
    local procedure SendSMS(var MemberApplication: Record "Member Application"; Member: Record Members)
    VAR
        SMSText: Text[250];
        SMSNo: Text[250];
        NotificationMgt: Codeunit "Notifications Management";
        CompanyInfo: Record "Company Information";
        SMSSource: Code[20];
        ApplicantName: Text;
    begin
        SMSSource := 'MEMBER_ONBOARD';
        CompanyInfo.get;
        if MemberApplication."Is Group/Corporate" then
            ApplicantName := MemberApplication."Group/Corporate Name"
        else
            ApplicantName := MemberApplication."Full Name";
        SMSText := 'Dear ' + ApplicantName + ' Welcome to ' + CompanyInfo.Name + '. Your Member No. is ' + Member."No." + '.Thank you for choosing us';
        SMSNo := MemberApplication."Mobile Phone No.";
        NotificationMgt.SendSms(SMSNo, SMSText, SMSSource);
        MemberApplication."Account Created" := true;
        MemberApplication.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendLoanApplicationForApproval', '', true, true)]
    local procedure SendEmailOnLoanAcceptance(var Loans: Record Loans)
    var
        Member: Record Members;
        CompanyInfo: Record "Company Information";
        SMS: Codeunit "Notifications Management";
        SMSPhone, SMSText : Text[250];
        SMSSource: Code[20];
    begin
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        Clear(SMSPhone);
        Clear(SMSText);
        CompanyInfo.get;
        SMSSource := 'LOAN_PROCESSING';
        if Member.Get(Loans."Member No.") then begin
            SMSPhone := Member."Mobile Phone No.";
            SMSText := 'Dear ' + Member."Full Name" + ' Your ' + Loans."Product Description" + ' application of ' + Format(Loans."Approved Amount") + ' has been received and is being processed.';
            SMS.SendSms(SMSPhone, SMSText, SMSSource);
            Recipients.Add(Member."E-Mail");
            Subject := 'Loan Processing';
            Body += 'Dear ' + Member."Full Name";
            Body += '<br></br>';
            Body += 'Your ' + Loans."Product Description" + ' application of ' + Format(Loans."Approved Amount") + ' has been received and is being processed.';
            CommunicationMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Loans Management", 'OnAfterPostLoanRecovery', '', true, true)]
    local procedure SendEmailOnLoanRecovery(var RecoveryHeader: Record "Loan Recovery Header")
    var
        Member: array[2] of Record Members;
        SMSSource: Code[20];
        CompanyInfo: Record "Company Information";
        SMS: Codeunit "Notifications Management";
        SMSPhone, SMSText : Text[250];
        RecoveryLines: Record "Loan Recovery Lines";
        Loans: Record Loans;
    begin
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        Clear(SMSPhone);
        Clear(SMSText);
        CompanyInfo.get;
        SMSSource := 'LOAN_RECOVEY';
        if Member[1].Get(RecoveryHeader."Member No") then begin
            SMSPhone := Member[1]."Mobile Phone No.";
            Loans.Get(RecoveryHeader."Loan No");
            SMSText := 'Dear ' + Member[1]."Full Name" + 'Your ' + Loans."Product Description" + ' balance of ' + Format(Loans."Loan Balance") + ' has been recovered from your deposits.';
            SMS.SendSms(SMSPhone, SMSText, SMSSource);
            Recipients.Add(Member[1]."E-Mail");
            Subject := 'Loan Recovery';
            Body += 'Dear ' + Member[1]."Full Name";
            Body += '<br></br>';
            Body += 'Your ' + Loans."Product Description" + ' balance of ' + Format(Loans."Loan Balance") + ' has been recovered from your deposits.';
            CommunicationMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
            RecoveryLines.Reset();
            RecoveryLines.SetRange("No.", RecoveryHeader."No.");
            RecoveryLines.SetFilter("Recovery Amount", '>0');
            if RecoveryLines.FindSet() then begin
                repeat
                    Clear(Recipients);
                    Clear(Subject);
                    Clear(Body);
                    Clear(SMSPhone);
                    Clear(SMSText);
                    if Member[2].Get(RecoveryLines."Member No") then begin
                        if RecoveryLines."Recovery Type" = RecoveryLines."Recovery Type"::Deposits then
                            SMSText := 'Dear ' + Member[2]."Full Name" + ' KSh. ' + format(RecoveryLines."Recovery Amount") + ' has been recovered from your deposit to pay ' + Loans."Product Description" + ' guaranteed to ' + Member[2]."Full Name"
                        else
                            SMSText := 'Dear ' + Member[2]."Full Name" + ' KSh. ' + format(RecoveryLines."Recovery Amount") + ' for a loan you had guaranteed ' + Member[2]."Full Name" + '  has been posted in your account.';
                        SMSPhone := Member[2]."Mobile Phone No.";
                        SMS.SendSms(SMSPhone, SMSText, SMSSource);
                        Recipients.Add(Member[2]."E-Mail");
                        Subject := 'Loan Recovery';
                        Body += SMSText;
                        Body += '<br></br>';
                        CommunicationMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                until RecoveryLines.Next() = 0;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Member Management", 'OnAfterProcessMemberUpdate', '', true, true)]
    local procedure SendEmailOnMemberUpdate(var MemberEditing: Record "Member Editing")
    var
        Member: Record Members;
        CompanyInfo: Record "Company Information";
        SMS: Codeunit "Notifications Management";
        SMSPhone, SMSText : Text[250];
        SMSSource: Code[20];
    begin
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        Clear(SMSPhone);
        Clear(SMSText);
        CompanyInfo.get;
        SMSSource := 'CHANGE_REQUEST';
        if Member.Get(MemberEditing."Member No.") then begin
            If Member."E-Mail" <> '' then begin
                SMSPhone := Member."Mobile Phone No.";
                SMSText := 'Dear ' + Member."Full Name" + 'Your information has been updated at ' + CompanyInfo.Name;
                SMS.SendSms(SMSPhone, SMSText, SMSSource);
                Recipients.Add(Member."E-Mail");
                Subject := 'Member Change Request';
                Body += SMSText;
                Body += StrSubstNo('<br></br>If you did not initiate this. Please Contact %1 Imediately', CompanyInfo.Name);
                CommunicationMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', true, true)]
    local procedure SendEmailOnDocumentApproval(RecRef: RecordRef)
    var
        Loans: Record Loans;
        Member: Record Members;
        CompanyInfo: Record "Company Information";
        SMS: Codeunit "Notifications Management";
        SMSPhone, SMSText : Text[250];
        SMSSource: Code[20];
    begin
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        Clear(SMSPhone);
        Clear(SMSText);
        SMSSource := 'LOAN_PROCESSING';
        case RecRef.Number of
            Database::Loans:
                begin
                    RecRef.SetTable(Loans);
                    CompanyInfo.get;
                    if Member.Get(Loans."Member No.") then begin
                        SMSPhone := Member."Mobile Phone No.";
                        SMSText := 'Dear ' + Member."Full Name" + 'Your ' + Loans."Product Description" + ' application of ' + Format(Loans."Approved Amount") + ' has been approved.';
                        SMS.SendSms(SMSPhone, SMSText, SMSSource);
                        Recipients.Add(Member."E-Mail");
                        Subject := 'Loan Processing';
                        Body += 'Dear ' + Member."Full Name";
                        Body += '<br></br>';
                        Body += 'Your ' + Loans."Product Description" + ' application of ' + Format(Loans."Approved Amount") + ' has been approved.';
                        CommunicationMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Investment Mgmt", 'OnPostFD', '', false, false)]
    LOCAL PROCEDURE PostFD(VAR FDHeader: Record "Fixed Deposit Header");
    VAR
        LineNo: Integer;
        FDSchedule1: Record "Fixed Deposit Schedule";
        RetentionAccount: Code[30];
        WTAXAccount: Code[30];
        WVATAccount: Code[30];
        Vsetup: Record "VAT Posting Setup";
        Client: Record Customer;
        FHeader: Record "Fixed Deposit Header";
        DR1: Code[20];
        CR1: Code[20];
        PostingCode: Code[20];
        JournalBatch, JournalTemplate : Code[20];
    BEGIN
        OnBeforePostFD(FDHeader);
        with FDHeader do begin
            JournalBatch := 'Investments';
            JournalTemplate := 'General';
            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
            LineNo := JournalManagement.CreateJournalLine(GenJournalLine."Account Type"::"Bank Account", "Debit Account No.", "Investment Date", "FD Certificate No." + ' ' + FORMAT("Debit Account Name") + ' ' + "Debit Account Name", Amount, "Global Dimension 1 Code", "Global Dimension 2 Code", '', "No.", TransactionType::General, LineNo, '', '', "No.", '', 0, '', JournalTemplate, JournalBatch);
            LineNo := JournalManagement.CreateJournalLine(GenJournalLine."Account Type"::"Bank Account", "Credit Account No", "Investment Date", "FD Certificate No." + ' ' + FORMAT("Debit Account Name") + ' ' + "Credit Account Name", -Amount, "Global Dimension 1 Code", "Global Dimension 2 Code", '', "No.", TransactionType::General, LineNo, '', '', "No.", '', 0, '', JournalTemplate, JournalBatch);
        end;
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", FDHeader."No.");
        GLEntry.SetRange("Document Date", FDHeader."Investment Date");
        if GLEntry.FindFirst() then OnAfterPostFD(FDHeader);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Post Payroll", 'OnCreateGnlJournalLineBalanced', '', false, false)]
    procedure CreateGnlJournalLineBalanced(TemplateName: Text; BatchName: Text; DocumentNo: Code[30]; LineNo: Integer; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[50]; TransactionDate: Date; TransactionDescription: Text; BalancingAccountType: Enum "Gen. Journal Account Type"; BalancingAccountNo: Code[50]; TransactionAmount: Decimal; Dimension1: Code[40]; Dimension2: Code[40]; ExtDocNo: Code[20]; AppliesToDocType: Enum "Gen. Journal Document Type"; AppliesToDocNo: Code[50]; CurrencyCode: Code[20]; CurrencyFactor: Decimal; SourceNo: Code[100]; LoanNo: Code[20]; MemberNo: Code[20]; SaccoTransactionType: Enum "Sacco Transaction Type")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Employee: Record Employee;
        Vendor: Record Vendor;
        FAsset: Record "Fixed Asset";
    begin
        GenJournalLine.Init;
        GenJournalLine."Journal Template Name" := TemplateName;
        GenJournalLine."Journal Batch Name" := BatchName;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."Line No." := LineNo;
        if AccountNo <> '' then begin
            GenJournalLine."Account Type" := AccountType;
            GenJournalLine.Validate("Account No.", AccountNo);
            GenJournalLine.Validate(Amount, TransactionAmount);
        end
        else if BalancingAccountNo <> '' then begin
            GenJournalLine."Account Type" := BalancingAccountType;
            GenJournalLine.Validate("Account No.", BalancingAccountNo);
            GenJournalLine.Validate(Amount, -TransactionAmount);
            GenJournalLine."Product Posting Type" := ProductPostingType;
            GenJournalLine."Member No." := MemberNo;
            GenJournalLine."Loan No." := LoanNo;
            GenJournalLine."Transaction Type" := SaccoTransactionType;
            if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then begin
                if Vendor.Get(GenJournalLine."Account No.") then begin
                    GenJournalLine."Product Posting Type" := Vendor."Product Posting Type";
                    GenJournalLine."Member No." := Vendor."Member No.";
                end;
            end;
        end;
        GenJournalLine."Posting Date" := TransactionDate;
        GenJournalLine.Description := TransactionDescription;
        GenJournalLine."Currency Factor" := CurrencyFactor;
        GenJournalLine."Currency Code" := CurrencyCode;
        GenJournalLine."External Document No." := ExtDocNo;
        GenJournalLine."Shortcut Dimension 1 Code" := Dimension1;
        GenJournalLine."Shortcut Dimension 2 Code" := Dimension2;
        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
        GenJournalLine."Applies-to Doc. Type" := AppliesToDocType;
        GenJournalLine."Applies-to Doc. No." := AppliesToDocNo;
        GenJournalLine."Source No." := SourceNo;
        if Employee.Get(SourceNo) then
            GenJournalLine."Source Type" := GenJournalLine."Source Type"::Employee;
        if GenJournalLine.Amount <> 0 then
            GenJournalLine.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payroll Processing", 'OnPayrollLoanManagement', '', false, false)]
    local procedure OnPayrollLoanManagement()
    var
        PayrollLoanMgmt: Codeunit "Payroll Loan Management";
    begin
        PayrollLoanMgmt.LoanProcessing;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Investment Mgmt", 'OnPostLiquidation', '', false, false)]
    LOCAL PROCEDURE PostLiquidation(VAR FDHeader: Record "Fixed Deposit Header");
    VAR
        LineNo: Integer;
        FDSchedule1: Record "Fixed Deposit Schedule";
        RetentionAccount: Code[30];
        WTAXAccount: Code[30];
        WVATAccount: Code[30];
        Vsetup: Record "VAT Posting Setup";
        Client: Record Customer;
        FHeader: Record "Fixed Deposit Header";
        DR1: Code[20];
        CR1: Code[20];
        PostingCode: Code[20];
    BEGIN
        OnBeforePostLiquidation(FDHeader);
        WITH FDHeader DO BEGIN
            FDHeader.TESTFIELD("Receiving Account No");
            FDHeader.TESTFIELD("Receiving Date");
            CALCFIELDS("Interest Accrued", "Interest Received");
            MESSAGE('%1', "Interest Received");
            IF "Interest Received" = 0 THEN ERROR('You must Received the Interest Before Liquidating for Fixed Deposit No. %1', "No.");
            JournalBatch := 'Investments';
            JournalTemplate := 'General';
            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
            LineNo := JournalManagement.CreateJournalLine(GenJournalLine."Account Type"::"Bank Account", "Receiving Account No", "Receiving Date", 'Principal and Interest For' + ' ' + "FD Certificate No.", (Amount + "Interest Received"), "Global Dimension 1 Code", "Global Dimension 2 Code", '', "No.", TransactionType::General, LineNo, '', '', "No.", '', 0, '', JournalTemplate, JournalBatch);
            LineNo := JournalManagement.CreateJournalLine(GenJournalLine."Account Type"::"Bank Account", "Credit Account No", "Receiving Date", "FD Certificate No." + ' ' + 'Principal Amount Received', -Amount, "Global Dimension 1 Code", "Global Dimension 2 Code", '', "No.", TransactionType::General, LineNo, '', '', "No.", '', 0, '', JournalTemplate, JournalBatch);
            LineNo := JournalManagement.CreateJournalLine(GenJournalLine."Account Type"::"G/L Account", "Credit Account No", "Receiving Date", "FD Certificate No." + ' ' + FORMAT('Interest Received'), -"Interest Received", "Global Dimension 1 Code", "Global Dimension 2 Code", '', "No.", TransactionType::General, LineNo, '', '', "No.", '', 0, '', JournalTemplate, JournalBatch);
        end;
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", FDHeader."No.");
        GLEntry.SetRange("Document Date", FDHeader."Receiving Date");
        if GLEntry.FindFirst() then OnAfterPostLiquidation(FDHeader);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Event Subscribers", 'OnAfterPostLiquidation', '', false, false)]
    LOCAL PROCEDURE MarkAsLiquidated(VAR FDHeader: Record "Fixed Deposit Header");
    VAR
        FDSchedule: Record "Fixed Deposit Schedule";
    BEGIN
        WITH FDHeader DO BEGIN
            FDSchedule.RESET;
            FDSchedule.SETRANGE("Investment No", "No.");
            FDSchedule.SETRANGE(Posted, FALSE);
            IF FDSchedule.FINDSET THEN
                REPEAT
                    FDSchedule.Posted := TRUE;
                    FDSchedule."Posted By" := UserId;
                    FDSchedule."Posted At" := TIME;
                    FDSchedule."Posted On" := TODAY;
                    FDSchedule.MODIFY(TRUE);
                UNTIL FDSchedule.NEXT = 0;
            Liquidated := TRUE;
            Status := Status::Terminated;
            MODIFY;
            MESSAGE('Fixed Deposit No %1 has been Liquidated Successfully', "No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Member Management", 'OnAfterPostATMLinking', '', true, true)]
    local procedure OnAfterPostATMLinking(ATMApplication: Record "ATM Application")
    var
        PhoneNo: Text[250];
        SMS: Text[250];
        NotificationsMgt: Codeunit "Notifications Management";
        SMSSource: Code[20];
    begin
        SMSSource := 'ATM_COLLECTION';
        Member.Get(ATMApplication."Member No");
        SMS := 'Dear ' + Member."First Name" + ',  Your ATM Card is ready for collection. Kindly make arrangements to collect during normal working hours.';
        PhoneNo := Member."Mobile Phone No.";
        NotificationsMgt.SendSms(PhoneNo, SMS, SMSSource);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Loans Management", 'OnAfterPostLoanPenalty', '', true, true)]
    local procedure OnAfterPostLoanPenalty(var Loans: Record Loans; PostingAmount: Decimal)
    var
        PhoneNo: Text[250];
        SMS: Text[250];
        NotificationsMgt: Codeunit "Notifications Management";
        SMSSource: Code[20];
    begin
        SMSSource := 'PENALTY';
        Member.Get(Loans."Member No.");

        SMS := StrSubstNo('Dear %1, your %2 is OVERDUE, a penalty of KES %3 has been charged. Kindly regularize your account to avoid more penalties. Dial *882# and follow prompts to repay.', Member."First Name", Loans."Product Description", PostingAmount);
        PhoneNo := Member."Mobile Phone No.";
        NotificationsMgt.SendSms(PhoneNo, SMS, SMSSource);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payroll Processing", 'OnPayrollLoanManagement', '', false, false)]
    local procedure NationalIDValidation()
    var
        PayrollLoanMgmt: Codeunit "Payroll Loan Management";
    begin
        PayrollLoanMgmt.LoanProcessing;
    end;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnKRAPINValidation', '', false, false)]
    local procedure KRAPINValidation(var KRAPIN: Code[20])
    begin
        MemberMgmt.KRAPinValidation(KRAPIN);
    end;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnValidateMemberNo', '', false, false)]
    local procedure GetFOSAAccount(var Employee: Record Employee; var MemberNo: Code[20])
    begin
        Employee."FOSA Account" := LoanManagement.GetFOSAAccount(MemberNo);
        Employee.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Communications Mgmt", 'OnSendSMSNotification', '', false, false)]
    local procedure SendSMSNotification(var PhoneNo: Text[250]; var SmsMessage: Text[250]; var SMSSource: Code[20])
    var
        NotificationsManagement: Codeunit "Notifications Management";
    begin
        NotificationsManagement.SendSms(PhoneNo, SMSMessage, SMSSource)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Communications Mgmt", 'OnNotificationOnEFTDisbursement', '', false, false)]
    local procedure NotificationOnEFTDisbursement(var PVHeader: Record "Payment Voucher")
    var
        CommunicationMgmt: Codeunit "CBS Communications Mgmt";
    begin
        CommunicationMgmt.NotificationOnEFTDisbursement(PVHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Event Subscribers", 'OnAfterPostFD', '', false, false)]
    LOCAL PROCEDURE MarkFDAsPosted(VAR FDHeader: Record "Fixed Deposit Header");
    VAR
        GLEntry: Record "G/L Entry";
        FDSchedule1: Record "Fixed Deposit Schedule";
    BEGIN
        WITH FDHeader DO BEGIN
            GLEntry.RESET;
            GLEntry.SETRANGE("Document No.", "No.");
            GLEntry.SETRANGE(Reversed, FALSE);
            IF GLEntry.FINDFIRST THEN BEGIN
                Posted := TRUE;
                "Posted By" := UserId;
                "Posted On" := TODAY;
                "Posted at" := TIME;
                MODIFY(TRUE);
            end;
            Status := Status::Running;
            MODIFY;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CBS Cash Management", 'OnAfterPostReceipt', '', true, true)]
    local procedure OnAfterPostReceipt(var Receipt: Record "Receipt Header")
    var
        CheckOffAdvice: Record "Checkoff Advice";
        EntryNo: Integer;
        ReceiptLines: Record "Receipt Lines";
        Vendor: Record Vendor;
        Loan: Record Loans;
    begin
        CheckOffAdvice.Reset();
        if CheckOffAdvice.FindLast() then
            EntryNo := CheckOffAdvice."Entry No" + 1
        else
            EntryNo := 1;
        ReceiptLines.Reset();
        ReceiptLines.SetRange("No.", Receipt."No.");
        if ReceiptLines.FindSet() then begin
            repeat
                CheckOffAdvice.Init();
                CheckOffAdvice."Entry No" := EntryNo;
                EntryNo += 1;
                CheckOffAdvice."Member No" := ReceiptLines."Member No.";
                CheckOffAdvice."Amount Off" := ReceiptLines.Amount;
                CheckOffAdvice."Amount On" := 0;
                CheckOffAdvice."Current Balance" := 0;
                if ReceiptLines."Receipt Type" = ReceiptLines."Receipt Type"::Member then begin
                    If Loan.get(ReceiptLines."Loan No.") then begin
                        Loan.CalcFields("Loan Balance");
                        CheckOffAdvice."Current Balance" := Loan."Loan Balance";
                        CheckOffAdvice."Product Code" := Loan."Product Code";
                        CheckOffAdvice."Product Name" := Loan."Product Description";
                    end;
                    if Vendor.get(ReceiptLines."Account No") then begin
                        if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Non Withdrawable Deposit" then begin
                            Vendor.CalcFields(Balance);
                            CheckOffAdvice."Current Balance" := Vendor.Balance;
                            CheckOffAdvice."Product Code" := Vendor."Product Code";
                            CheckOffAdvice."Product Name" := Vendor.Name;
                        end;
                    end;
                end;
                CheckOffAdvice."Advice Type" := CheckOffAdvice."Advice Type"::Adjustment;
                CheckOffAdvice."Advice Date" := Receipt."Posted Date";
                CheckOffAdvice."Posting Date" := WorkDate;
                CheckOffAdvice.Insert();
            until ReceiptLines.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInitGLEntry', '', true, true)]
    local procedure OnBeforeInitGLEntry(var GenJournalLine: Record "Gen. Journal Line"; var GLAccNo: Code[20]; SystemCreatedEntry: Boolean; Amount: Decimal; AmountAddCurr: Decimal; FADimAlreadyChecked: Boolean; var IsHandled: Boolean; var GLEntry: Record "G/L Entry"; UseAmountAddCurr: Boolean; NextEntryNo: Integer; NextTransactionNo: Integer)
    var
        VendPostingGroup: Record "Vendor Posting Group";
        Vendor: Record Vendor;
    begin
        if GenJournalLine."Account Type" <> GenJournalLine."Account Type"::Vendor then exit;
        if Vendor.Get(GenJournalLine."Account No.") then begin
            if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Loan Account" then begin
                if VendPostingGroup.Get(Vendor."Vendor Posting Group") then begin
                    if GenJournalLine."Transaction Type" in [GenJournalLine."Transaction Type"::"Interest Due", GenJournalLine."Transaction Type"::"Interest Paid", GenJournalLine."Transaction Type"::"Penalty Due", GenJournalLine."Transaction Type"::"Penalty Paid"] then begin
                        VendPostingGroup.TestField("Interest Accrual Account");
                        GLAccNo := VendPostingGroup."Interest Accrual Account";
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnAfterGetAccounts', '', true, true)]
    local procedure OnAfterGetAccounts(var GenJournalLine: Record "Gen. Journal Line"; var AccName: Text[100]; var BalAccName: Text[100])
    var
        Members: Record Members;
        Vendor: Record Vendor;
    begin
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then begin
            if Vendor.Get(GenJournalLine."Account No.") then begin
                If Members.Get(Vendor."Member No.") then AccName := StrSubstNo('%1 - %2', Vendor.Name, Members.FullName);
            end;
        end;
        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Vendor then begin
            if Vendor.Get(GenJournalLine."Bal. Account No.") then begin
                If Members.Get(Vendor."Member No.") then BalAccName := StrSubstNo('%1 - %2', Vendor.Name, Members.FullName);
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    LOCAL PROCEDURE OnBeforePostLiquidation(VAR FDHeader: Record "Fixed Deposit Header");
    BEGIN
    end;

    [IntegrationEvent(false, false)]
    LOCAL PROCEDURE OnAfterPostLiquidation(VAR FDHeader: Record "Fixed Deposit Header");
    BEGIN
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostFD(VAR FDHeader: Record "Fixed Deposit Header");
    BEGIN
    end;

    [IntegrationEvent(false, false)]
    LOCAL PROCEDURE OnAfterPostFD(VAR FDHeader: Record "Fixed Deposit Header");
    BEGIN
    end;

}
