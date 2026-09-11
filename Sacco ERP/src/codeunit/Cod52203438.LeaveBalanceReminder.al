codeunit 52203438 "Leave Balance Reminder"
{
    trigger OnRun()
    begin
        Employee.Reset;
        Employee.SetFilter("Employee Status", '=%1|%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
        if Employee.FindSet then begin
            repeat LeaveTypes.Reset;
                LeaveTypes.SetFilter("Leave Balance Notification", '>%1', 0);
                if LeaveTypes.FindSet then begin
                    repeat LeaveCalender.Reset;
                        LeaveCalender.SetRange("Current Leave Calendar", true);
                        if LeaveCalender.FindFirst then begin
                            LeaveLedgerEntries.Reset;
                            LeaveLedgerEntries.SetRange("Employee No.", Employee."No.");
                            LeaveLedgerEntries.SetRange("Leave Year Code", LeaveCalender."Calendar Code");
                            LeaveLedgerEntries.SetRange("Leave Type", LeaveTypes.Code);
                            if LeaveLedgerEntries.FindSet then begin
                                LeaveLedgerEntries.CalcSums(Quantity);
                                if LeaveLedgerEntries.Quantity > LeaveTypes."Leave Balance Notification" then begin
                                    Clear(Recipients);
                                    Recipients.Add(Employee."E-Mail");
                                    Subject:='Leave Balance Reminder';
                                    Body:='Hello ' + Employee.FullName + ' <br><br>We refer to your leave balance to date, which is ' + FORMAT(LeaveLedgerEntries.Quantity) + ' days  <br><br>' + 'By a copy of this email, you are hereby reminded and advised to liaise with your supervisor to<br>' + 'discuss modalities of utilizing these days to enhance work life balance<br><br>' + 'Regards,<br>HR';
                                    CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                                end;
                            end;
                        end;
                    until LeaveTypes.Next = 0;
                end;
            until Employee.Next = 0;
        end;
    end;
    var Recipients: List of[Text];
    Subject: Text;
    Body: Text;
    Employee: Record Employee;
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    LeaveCalender: Record "Leave Calendar";
    LeaveTypes: Record "Leave Types";
    LeaveLedgerEntries: Record "Leave Ledger Entries";
}
