codeunit 52203463 "Leave Bal. Reminder"
{
    trigger OnRun()
    begin
        LeaveBalReminder;
    end;
    local procedure LeaveBalReminder()
    begin
        CompInfo.Get;
        LeaveTypes.Reset;
        LeaveTypes.SetRange("Is Annual Leave", true);
        if LeaveTypes.FindFirst then;
        Subject:='LEAVE BAL REMINDER';
        Employee.Reset;
        Employee.SetRange("Employee Status", Employee."Employee Status"::Active);
        Employee.SetFilter("Company E-Mail", '<>%1', '');
        if Employee.FindSet then begin
            repeat LeaveBal:=0;
                LeaveLedgerEntries.Reset;
                LeaveLedgerEntries.SetRange("Employee No.", Employee."No.");
                LeaveLedgerEntries.SetRange("Leave Type", LeaveTypes.Code);
                LeaveLedgerEntries.SetRange(Closed, false);
                LeaveLedgerEntries.CalcSums(Quantity);
                LeaveBal:=LeaveLedgerEntries.Quantity;
                if LeaveBal > LeaveTypes."Leave Balance Notification" then begin
                    Clear(Recipients);
                    Body:='';
                    Recipients.Add(Employee."Company E-Mail");
                    Body+='<span style="font-family: Calibri; color: #5B9BD5; font-size: 11pt>';
                    Body+='<span style="font-family: Calibri; color: #5B9BD5; font-size: 11pt>';
                    Body+='Hello, ' + Employee.FullName;
                    Body+='<br><br>';
                    Body+=StrSubstNo('This is a reminder that your leave balance is at %1, Kindly plan to utilise your Leave days', Format(LeaveBal));
                    Body+='<br><br>';
                    Body+='Thank you.';
                    Body+='<br><br>';
                    Body+='Yours Sincerely,';
                    Body+='<br><br>';
                    Body+='<b>Human Resources and Administration<b>';
                    Body+='<br>';
                    Body+=CompInfo.Name;
                    CommunicationMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                end;
            until Employee.Next = 0;
        end;
    end;
    var CommunicationMgmt: Codeunit "Communications Mgmt";
    CompInfo: Record "Company Information";
    Subject: Text;
    Recipients: List of[Text];
    Body: Text;
    Employee: Record Employee;
    LeaveLedgerEntries: Record "Leave Ledger Entries";
    LeaveTypes: Record "Leave Types";
    LeaveBal: Decimal;
}
