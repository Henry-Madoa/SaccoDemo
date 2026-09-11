codeunit 52203455 "Appraisal Reminders Manual"
{
    trigger OnRun()
    begin
        if not Confirm('Are you sure you want to send the reminders')then exit;
        CountNoEmployees:=0;
        HumanResourcesSetup.Get;
        AppraisalHeader.Reset;
        //AppraisalHeader.SetRange("Employee User Id", AppraisalHeader."Employee User Id"::"0");
        if AppraisalHeader.FindSet then begin
            repeat if Employee.Get(AppraisalHeader."Employee No")then begin
                    CountNoEmployees+=1;
                    Clear(Recipients);
                    Recipients.Add(Employee."E-Mail");
                    Subject:='Appraisal Reminder';
                    Body:='Hello ' + Employee.FullName + ' <br>This is to remind you that goal setting for staff appraisal starts on ' + Format(AppraisalHeader."Job Title") + '<br>This is a system generated Email, please do not reply to it' + '<br>Regards';
                    CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                end;
            until AppraisalHeader.Next = 0;
        end;
        if CountNoEmployees >= 1 then if CountNoEmployees = 0 then Message('No Emails were sent');
    end;
    var SenderName: Text;
    SenderAddress: Text;
    Recipients: List of[Text];
    Subject: Text;
    Body: Text;
    ReceiverName: Text;
    Employee: Record Employee;
    HumanResourcesSetup: Record "Human Resources Setup";
    UserSetup: Record "User Setup";
    GeneratedEmployeeNoString: Text;
    GeneratedEmployeeNameString: Text;
    CountNoEmployees: Integer;
    CombinedGeneratedString: Text;
    HumanResourceMgmt: Codeunit "Human Resource Management";
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    AppraisalHeader: Record "Appraisal Header";
}
