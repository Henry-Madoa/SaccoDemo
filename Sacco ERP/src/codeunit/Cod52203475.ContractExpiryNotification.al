codeunit 52203475 "Contract Expiry Notification"
{
    trigger OnRun()
    begin
        CreateContractEmails;
        Employee.Reset;
        Employee.SetRange("End of Contract Date", CalcDate(HumanResourcesSetup."Contract Exp. Not. Period", Today));
        if Employee.FindSet then begin
            repeat GeneratedEmployeeNoString:='';
                GeneratedEmployeeNameString:='';
                GeneratedEmployeeNoString:=Employee."No.";
                GeneratedEmployeeNameString:=Employee.FullName;
                CountNoEmployees+=1;
                CombinedGeneratedString+=Format(CountNoEmployees) + '. ' + '<b>Employee No. :</b>' + GeneratedEmployeeNoString + '. <b>Name: </b>' + GeneratedEmployeeNameString + '<br>';
            until Employee.Next = 0;
            ;
        end;
        UserSetup.Reset;
        UserSetup.SetRange("HR Admin", true);
        if UserSetup.FindSet then begin
            repeat Employee.Reset;
                Employee.SetRange("No.", UserSetup."Employee No.");
                if Employee.FindFirst then begin
                    ReceiverName:=Employee.FullName;
                    Clear(Recipients);
                    Recipients.Add(UserSetup."E-Mail");
                end;
                Subject:='End of Employee contracts';
                Body:='Hello ' + Employee.FullName + '<br> The Following employee(s) contract are due to expire in <b>' + Format(HumanResourcesSetup."Contract Exp. Not. Period") + '(s)</b> Time<br>' + CombinedGeneratedString + '<br> This is a system generated email please do not reply to it <br> Regards';
                if CombinedGeneratedString <> '' then CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
            until UserSetup.Next = 0;
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
    local procedure CreateContractEmails()
    var
    //EmailEntries: Record "Email Entries";
    begin
    //Clear(Recipients);
    // Employee.Reset;
    // Employee.SetRange(Status, Employee.Status::Active);
    // Employee.SetRange("End of Contract Date", CalcDate(HumanResourcesSetup."Contract Exp. Not. Period", Today));
    // if Employee.FindSet then
    // repeat
    //     EmailEntries.Reset;
    //     if not EmailEntries.FindLast then
    //         EmailEntries."Entry No." := 1
    //     else
    //         EmailEntries."Entry No." := EmailEntries."Entry No." + 1;
    //     EmailEntries.Recipients.Add(Employee."E-Mail");
    //     EmailEntries.Subject := 'End of Employment Contract';
    //     EmailEntries.Body := 'Hi' + Employee.FullName + '<br> Kindly note that your Employment Contract will be ending on <br>' + Format(HumanResourcesSetup."Contract Exp. Not. Period")
    //     + '<br> Kindly follow up with Human Resources <br>';
    //     EmailEntries."Date to Send" := WorkDate;
    //     EmailEntries.Regards := 'br> Kind Regards,COGRI Finance Team<br>';
    //     UserSetup.Reset;
    //     UserSetup.SetRange("Is HR Admin", true);
    //     if UserSetup.FindFirst then
    //         EmailEntries.CC := UserSetup."E-Mail";
    //     EmailEntries.Sent := false;
    //     EmailEntries."Sender Name" := SMTPMailSetup."Send As";
    //     EmailEntries."Sender Address" := SMTPMailSetup."User ID";
    //     EmailEntries.Sent := false;
    //     EmailEntries."Time Sent" := 0T;
    //     EmailEntries."Date Sent" := WorkDate;
    //     EmailEntries."Email Type" := EmailEntries."Email Type"::Notification;
    //     EmailEntries.Insert;
    // until Employee.Next = 0;
    end;
}
