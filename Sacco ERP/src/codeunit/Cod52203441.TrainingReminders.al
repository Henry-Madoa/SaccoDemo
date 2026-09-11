codeunit 52203441 "Training Reminders"
{
    trigger OnRun()
    begin
        HumanResourcesSetup.Get;
        TrainingApplication.Reset;
        TrainingApplication.SetRange("Training Start Date", CalcDate(HumanResourcesSetup."Training Notification", Today));
        if TrainingApplication.FindSet then begin
            repeat if Employee.Get(TrainingApplication."Employee No")then begin
                    Clear(Recipients);
                    Recipients.Add(Employee."E-Mail");
                    Subject:='Training Reminder';
                    Body:='Hello ' + Employee.FullName + ' <br>This is to remind you that the training on ' + Format(TrainingApplication."Training Need Description") + ' is starting on ' + Format(TrainingApplication."Training Start Date") + '<br>This is a system generated Email, please do not reply to it' + '<br>Regards';
                    CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                end;
            until TrainingApplication.Next = 0;
        end;
    end;
    var Recipients: List of[Text];
    Subject: Text;
    Body: Text;
    Employee: Record Employee;
    HumanResourcesSetup: Record "Human Resources Setup";
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    TrainingApplication: Record "Training Application";
}
