codeunit 52203466 "Appraisal Mgmt"
{
    var Employee: Record Employee;
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    Body: Text;
    Subject: Text;
    SenderAdress: Text;
    ReceiverAddress: List of[Text];
    UserSetup: Record "User Setup";
    TempBlob: Codeunit "Temp Blob";
    outStreamReport: OutStream;
    inStreamReport: InStream;
    Recordr: RecordRef;
    Mail: Codeunit "Email Message";
    Email: Codeunit Email;
    procedure SendBackAppraisal(AppraisalHeader: Record "Appraisal Header")
    begin
        Employee.Reset;
        Employee.SetRange("No.", AppraisalHeader."Employee No");
        if Employee.FindFirst then begin
            UserSetup.Reset;
            UserSetup.SetRange("Employee No.", AppraisalHeader."Employee No");
            if UserSetup.FindFirst then begin
                AppraisalHeader.Status:=AppraisalHeader.Status::"Appraisee Level";
                if AppraisalHeader.Modify then begin
                    if UserSetup.Get(UserId)then SenderAdress:=UserSetup."E-Mail";
                    if UserSetup.Get(UserSetup."Line Manager")then ReceiverAddress.Add(UserSetup."E-Mail");
                    Subject:='APPRAISAL';
                    Body:='Dear ' + Format(AppraisalHeader."Supervisor No") + '</br>' + 'Perfomance Management Document has been returned for Review. </br>' + 'Regards ' + Format(UserId);
                    CommunicationsMgmt.SendEmailWithoutAttachement(ReceiverAddress, Subject, Body);
                end;
            end;
        end;
    end;
    procedure SendBackAppraisaToSupervisor(AppraisalHeader: Record "Appraisal Header")
    begin
        Employee.Reset;
        Employee.SetRange("No.", AppraisalHeader."Employee No");
        if Employee.FindFirst then begin
            UserSetup.Reset;
            UserSetup.SetRange("Employee No.", AppraisalHeader."Employee No");
            if UserSetup.FindFirst then begin
                AppraisalHeader.Status:=AppraisalHeader.Status::"Appraiser Level";
                AppraisalHeader."Peer 1 Employee No":=UserSetup."Line Manager";
                if AppraisalHeader.Modify then begin
                    Clear(ReceiverAddress);
                    if UserSetup.Get(UserId)then SenderAdress:=UserSetup."E-Mail";
                    if UserSetup.Get(UserSetup."Line Manager")then ReceiverAddress.Add(UserSetup."E-Mail");
                    Subject:='APPRAISAL';
                    Body:='Dear ' + Format(AppraisalHeader."Supervisor No") + '</br>' + ' Perfomance Management Document has been sent to you for Review. </br>' + 'Regards ' + Format(UserId);
                    CommunicationsMgmt.SendEmailWithoutAttachement(ReceiverAddress, Subject, Body);
                end;
            end
            else
                Error('No user is linked the employee in user setup');
        end;
    end;
    procedure CloseAppraisal(AppraisalHeader: Record "Appraisal Header")
    begin
        Employee.Reset;
        Employee.SetRange("No.", AppraisalHeader."Employee No");
        if Employee.FindFirst then begin
            Employee.TestField("Manager No.");
            //AppraisalHeader."Employee User Id":=AppraisalHeader."Employee User Id"::"3";
            AppraisalHeader."Supervisor No":=Employee."Manager No.";
            AppraisalHeader.Modify;
        end;
    end;
    procedure ApproveAppraisal(AppraisalHeader: Record "Appraisal Header")
    var
        Appraisal: Record "Appraisal Header";
    begin
        Employee.Reset;
        Employee.SetRange("No.", AppraisalHeader."Employee No");
        if Employee.FindFirst then begin
            UserSetup.Reset;
            UserSetup.SetRange("Employee No.", AppraisalHeader."Employee No");
            if UserSetup.FindFirst then begin
                AppraisalHeader.Status:=AppraisalHeader.Status::"Overview Manager Level";
                if AppraisalHeader.Modify then begin
                    Clear(ReceiverAddress);
                    ReceiverAddress.Add(UserSetup."E-Mail");
                    Subject:='APPRAISAL';
                    Body:='Dear ' + Format(AppraisalHeader."Employee Name") + '</br>' + ' Perfomance Appraisal has been Approved. </br>' + 'Regards ' + Format(UserId);
                    Mail.Create(ReceiverAddress, Subject, Body, true);
                    Appraisal.Reset();
                    Appraisal.SetRange("No.", AppraisalHeader."No.");
                    if Appraisal.FindFirst then begin
                        Recordr.GetTable(Appraisal);
                        TempBlob.CreateOutStream(outStreamReport);
                        TempBlob.CreateInStream(inStreamReport);
                        Report.SaveAs(Report::"Appraisal Print Out", Appraisal."No.", ReportFormat::Pdf, outStreamReport, Recordr);
                        Mail.AddAttachment(Appraisal."No." + '.pdf', 'PDF', inStreamReport);
                    end;
                    Email.Send(Mail);
                    CreateTrainingNeed(AppraisalHeader);
                end;
            end;
        end;
    end;
    local procedure CreateTrainingNeed(AppraisalHeader: Record "Appraisal Header")
    var
        AppraisalTrainingRec: Record "Appraisal Training Rec.";
        TrainingNeed: Record "Training Need";
    begin
        with AppraisalHeader do begin
            AppraisalTrainingRec.Reset;
            AppraisalTrainingRec.SetRange("Appraisal Code", "No.");
            AppraisalTrainingRec.SetRange("Employee No.", "Employee No");
            if AppraisalTrainingRec.FindSet then begin
                repeat TrainingNeed.Init;
                    TrainingNeed.Code:=AppraisalTrainingRec."Training Area";
                    TrainingNeed.Description:=AppraisalTrainingRec."Training Description";
                    TrainingNeed."Created By":=UserId;
                    TrainingNeed."Created On":=WorkDate;
                    TrainingNeed."Global Dimension 1 Code":=AppraisalHeader."Global Dimension 1 Code";
                    TrainingNeed."From Appraisal":=true;
                    TrainingNeed."Calendar Code":=AppraisalHeader."Calendar Code";
                    TrainingNeed.Supervisor:="Peer 1 Employee No";
                    TrainingNeed."Training Objective":=AppraisalTrainingRec.Reason;
                    TrainingNeed.Validate("Employee No", "Employee No");
                    if not TrainingNeed.Get(AppraisalTrainingRec."Training Area")then TrainingNeed.Insert;
                until AppraisalTrainingRec.Next = 0;
            end;
        end;
    end;
    procedure SendForAcceptance(AppraisalHeader: Record "Appraisal Header")
    begin
        Employee.Reset;
        Employee.SetRange("No.", AppraisalHeader."Employee No");
        if Employee.FindFirst then begin
            UserSetup.Reset;
            UserSetup.SetRange("Employee No.", AppraisalHeader."Employee No");
            if UserSetup.FindFirst then begin
                AppraisalHeader.Status:=AppraisalHeader.Status::"Agreement Level";
                if AppraisalHeader.Modify then begin
                    Clear(ReceiverAddress);
                    if UserSetup.Get(UserId)then SenderAdress:=UserSetup."E-Mail";
                    if UserSetup.Get(UserSetup."Line Manager")then ReceiverAddress.Add(UserSetup."E-Mail");
                    Subject:='APPRAISAL';
                    Body:='Dear ' + Format(AppraisalHeader."Supervisor No") + '</br>' + 'Perfomance Management Document has been sent to you for score acceptance. </br>' + 'Regards ' + Format(UserId);
                    CommunicationsMgmt.SendEmailWithoutAttachement(ReceiverAddress, Subject, Body);
                end;
            end;
        end;
    end;
    procedure SendBackToSupervisoronDecline(AppraisalHeader: Record "Appraisal Header")
    begin
        Employee.Reset;
        Employee.SetRange("No.", AppraisalHeader."Employee No");
        if Employee.FindFirst then begin
            UserSetup.Reset;
            UserSetup.SetRange("Employee No.", AppraisalHeader."Employee No");
            if UserSetup.FindFirst then begin
                AppraisalHeader.Status:=AppraisalHeader.Status::"Appraiser Level";
                if AppraisalHeader.Modify then begin
                    if UserSetup.Get(UserId)then SenderAdress:=UserSetup."E-Mail";
                    if UserSetup.Get(UserSetup."Line Manager")then ReceiverAddress.Add(UserSetup."E-Mail");
                    Subject:='APPRAISAL';
                    Body:='Dear ' + Format(AppraisalHeader."Supervisor No") + '</br>' + 'Perfomance Management Document has been sent to you review since the employee' + 'declined some of the score you assigned</br>' + 'Regards ' + Format(UserId);
                    CommunicationsMgmt.SendEmailWithoutAttachement(ReceiverAddress, Subject, Body);
                end;
            end;
        end;
    end;
    procedure SendBackToColleagueForReview(AppraisalHeader: Record "Appraisal Header")
    begin
        Employee.Reset;
        Employee.SetRange("No.", AppraisalHeader."Peer 1 Employee Name");
        if Employee.FindFirst then begin
            UserSetup.Reset;
            UserSetup.SetRange("Employee No.", AppraisalHeader."Employee No");
            if UserSetup.FindFirst then begin
                if AppraisalHeader.Modify then begin
                    if UserSetup.Get(UserId)then SenderAdress:=UserSetup."E-Mail";
                    if UserSetup.Get(UserSetup."Line Manager")then ReceiverAddress.Add(UserSetup."E-Mail");
                    Subject:='APPRAISAL';
                    Body:='Dear ' + Format(AppraisalHeader."Supervisor No") + '</br>' + 'Perfomance Management Document has been sent to you review ' + '<br> Please rate your colleague as honest as you can</br>' + 'Regards ' + Format(UserId);
                    CommunicationsMgmt.SendEmailWithoutAttachement(ReceiverAddress, Subject, Body);
                end;
            end;
        end;
    end;
    procedure SendBackToSupervisorAfterReview(AppraisalHeader: Record "Appraisal Header")
    begin
        Employee.Reset;
        Employee.SetRange("No.", AppraisalHeader."Employee No");
        if Employee.FindFirst then begin
            UserSetup.Reset;
            UserSetup.SetRange("Employee No.", AppraisalHeader."Employee No");
            if UserSetup.FindFirst then begin
                AppraisalHeader.Status:=AppraisalHeader.Status::"Appraiser Level";
                if AppraisalHeader.Modify then begin
                    if UserSetup.Get(UserId)then SenderAdress:=UserSetup."E-Mail";
                    if UserSetup.Get(UserSetup."Line Manager")then ReceiverAddress.Add(UserSetup."E-Mail");
                    Subject:='APPRAISAL';
                    Body:='Dear ' + Format(AppraisalHeader."Supervisor No") + '</br>' + 'Perfomance Management Document has been sent to you ' + 'After the employee successfully rated the colleague</br>' + 'Regards ' + Format(UserId);
                    CommunicationsMgmt.SendEmailWithoutAttachement(ReceiverAddress, Subject, Body);
                end;
            end;
        end;
    end;
    procedure Accept(AppraisalHeader: Record "Appraisal Header")
    begin
        Employee.Reset;
        Employee.SetRange("No.", AppraisalHeader."Employee No");
        if Employee.FindFirst then begin
            UserSetup.Reset;
            UserSetup.SetRange("Employee No.", AppraisalHeader."Employee No");
            if UserSetup.FindFirst then begin
                if AppraisalHeader.Modify then begin
                    if UserSetup.Get(UserId)then SenderAdress:=UserSetup."E-Mail";
                    if UserSetup.Get(UserSetup."Line Manager")then ReceiverAddress.Add(UserSetup."E-Mail");
                    Subject:='APPRAISAL';
                    Body:='Dear ' + Format(AppraisalHeader."Supervisor No") + '</br>' + 'Perfomance Management Document has accepted the agreed scores </br>' + 'Regards ' + Format(UserId);
                    CommunicationsMgmt.SendEmailWithoutAttachement(ReceiverAddress, Subject, Body);
                end;
            end;
        end;
    end;
}
