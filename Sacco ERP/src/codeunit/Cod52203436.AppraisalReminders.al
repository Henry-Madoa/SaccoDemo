codeunit 52203436 "Appraisal Reminders"
{
    trigger OnRun()
    begin
        HumanResourcesSetup.Get;
        AppraisalHeader.Reset;
        //AppraisalHeader.SetRange("Job Title", CalcDate(HumanResourcesSetup."Appraisal Notification Period", Today));
        if AppraisalHeader.FindSet then begin
            repeat if Employee.Get(AppraisalHeader."Employee No")then begin
                    Clear(Recipients);
                    Recipients.Add(Employee."E-Mail");
                    Subject:='Appraisal Reminder';
                    Body:='Hello ' + Employee.FullName + ' <br>This is to remind you that the Human resource appraisal starts on ' + Format(AppraisalHeader."Job Title") + '<br>This is a system generated Email, please do not reply to it' + '<br>Regards';
                    CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                end;
            until AppraisalHeader.Next = 0;
        end;
    end;
    var SenderName: Text;
    SenderAddress: Text;
    Recipients: List of[Text];
    Subject: Text;
    Body: Text;
    ReceiverName: Text;
    Employee: Record Employee;
    HumanResourcesSetup: Record "Human Resources Setup";
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    UserSetup: Record "User Setup";
    GeneratedEmployeeNoString: Text;
    GeneratedEmployeeNameString: Text;
    CountNoEmployees: Integer;
    CombinedGeneratedString: Text;
    HumanResourceMgmt: Codeunit "Human Resource Management";
    AppraisalHeader: Record "Appraisal Header";
}
