codeunit 52203476 "Probation Ending Period HOD"
{
    trigger OnRun()
    begin
        HumanResourcesSetup.Get;
        Employee.Reset;
        Employee.SetRange("End of Probation Period", CalcDate(HumanResourcesSetup."Probation Notifications", Today));
        if Employee.FindSet then begin
            repeat GeneratedEmployeeNoString:='';
                GeneratedEmployeeNameString:='';
                GeneratedEmployeeNoString:=Employee."No.";
                GeneratedEmployeeNameString:=Employee.FullName;
                CountNoEmployees+=1;
                CombinedGeneratedString+=Format(CountNoEmployees) + '. ' + '<b>Employee No. :</b>' + GeneratedEmployeeNoString + '. <b>Name: </b>' + GeneratedEmployeeNameString + '<br>';
                UserSetup.Reset;
                UserSetup.SetRange("Head of Department", Employee."Global Dimension 1 Code");
                if UserSetup.FindFirst then HODtoCC+=UserSetup."E-Mail" + ';';
            until Employee.Next = 0;
            ;
        end;
        if CombinedGeneratedString <> '' then begin
            Clear(Recipients);
            UserSetup.Reset;
            UserSetup.SetRange("HR Admin", true);
            if UserSetup.FindSet then begin
                repeat Employee.Reset;
                    Employee.SetRange("No.", UserSetup."Employee No.");
                    if Employee.FindFirst then begin
                        ReceiverName:=Employee.FullName;
                        Recipients.Add(UserSetup."E-Mail");
                        Recipients.Add(HODtoCC);
                    end;
                    Subject:='Probation Period Expiry';
                    Body:='Hello ' + Employee.FullName + '<br> The Following employee(s) probation periods are due to expire in <b>' + Format(HumanResourcesSetup."Probation Notifications") + '(s)</b> Time<br>' + CombinedGeneratedString + '<br> This is a system generated email please do not reply to it <br> Regards';
                    if CombinedGeneratedString <> '' then CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                until UserSetup.Next = 0;
            end;
        end;
    end;
    var Recipients: List of[Text];
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
    HODtoCC: Text;
}
