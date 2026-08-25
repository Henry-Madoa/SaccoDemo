report 52204051 "Mobi Loans Reminder"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem(Members; Members)
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                DueDate, DueDatePlus7 : Date;
                Loans: Record Loans;
                MemberNo, SMSSource : Code[20];
                SMSMessage, SMSNo : text;
                SMSSend: Codeunit "Notifications Management";
                GlobalTransactionType: Enum "Sacco Transaction Type";
                GlobalAccountType: Enum "Gen. Journal Account Type";
                GlobalTaskType: Option "Loan SMS","Share Transfer","Entrance Fee","Loan Recovery";
                NotificationsMGT: Codeunit "Notifications Management";
                JobExecEntries: Record "Job Execution Entries";
                LineNo: Integer;
                SendReminder: Boolean;
            begin
                SMSSource := 'MOBI_REMINDER';
                Loans.Reset();
                Loans.SetFilter("Loan Balance", '>0');
                Loans.SetRange("Mobile Loan", true);
                Loans.SetFilter("Repayment End Date", '>=%1', Today);
                Loans.SetRange("Member No.", Members."No.");
                if Loans.FindSet() then begin
                    repeat
                        DueDatePlus7 := 0D;
                        DueDatePlus7 := CalcDate('7D', Today);
                        SendReminder := false;
                        SendReminder := Loans."Repayment End Date" <= DueDatePlus7;
                        if SendReminder then begin
                            MemberNo := '';
                            MemberNo := Loans."Member No.";
                            if Members.Get(MemberNo) then begin
                                SMSNo := Members."Mobile Phone No.";
                                SMSMessage := '';
                                Loans.Validate(Installments);
                                SMSMessage := 'Dear ' + Members."First Name" + ' your ' + Loans."Product Description" + ' of KSh. ' + Format(Loans."Approved Amount") + ' issued on ' + format(Loans."Posting Date") + ' will be due on ' + Format(Loans."Repayment End Date");
                                SMSMessage += ' Dial *882# and select Make Payment option to pay the loan';
                                JobExecEntries.Reset();
                                JobExecEntries.SetRange("Document No", Format(Today));
                                JobExecEntries.SetRange("Member No", MemberNo);
                                JobExecEntries.SetRange("Task Type", JobExecEntries."Task Type"::"Loan SMS");
                                if JobExecEntries.IsEmpty then begin
                                    if SendReminder then begin
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
                                        JobExecEntries."Task Type" := JobExecEntries."Task Type"::"Loan SMS";
                                        JobExecEntries."Run Date" := CurrentDateTime;
                                        JobExecEntries.Insert();
                                        Commit();
                                        SMSSend.SendSms(SMSNo, SMSMessage, SMSSource); //Fred Commented to stop sms
                                    end;
                                end;
                            end;
                        end;
                    until Loans.Next() = 0;
                end;
            end;
        }
    }
}
