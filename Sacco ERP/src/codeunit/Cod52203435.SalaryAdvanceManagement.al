codeunit 52203435 "Salary Advance Management"
{
    var HumanResourceMgmt: Codeunit "Human Resource Management";
    GenJournalLine: Record "Gen. Journal Line";
    UserPostingBatches: Record "User Posting Batches";
    [IntegrationEvent(false, false)]
    procedure OnPostImprest(var RequestHeader: Record "Request Header")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnBeforePostImprest(var RequestHeader: Record "Request Header")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnAfterPostImprest(var RequestHeader: Record "Request Header")
    begin
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Salary Advance Management", 'OnPostImprest', '', false, false)]
    local procedure PostImprest(var RequestHeader: Record "Request Header")
    var
        Jtemplate: Code[40];
        JBatch: Code[40];
        LineNo: Integer;
    begin
        OnBeforePostImprest(RequestHeader);
        with RequestHeader do begin
            if UserPostingBatches.Get(UserId)then begin
                UserPostingBatches.TestField("General Jounral");
                UserPostingBatches.TestField("General Journal Batch");
                Jtemplate:=UserPostingBatches."General Jounral";
                JBatch:=UserPostingBatches."General Journal Batch";
            end
            else
            begin
                Message('Please contact your system administrator to create you a posting bacth');
                exit;
            end;
            TestField("Paying Bank Code");
            LineNo:=1;
            HumanResourceMgmt.CreateGnlJournalLineJournal(Jtemplate, JBatch, "No.", LineNo, GenJournalLine."Account Type"::"Bank Account", "Paying Bank Code", "Posted Date", -"Amount Requested", "Global Dimension 1 Code", "Global Dimension 3 Code", "Payment Tx No.(Cheque No.)", Purpose + ' for ' + Format("Employee No.") + ' ' + "Employee Name", "Pay Mode", "Currency Code", GenJournalLine."Applies-to Doc. Type"::" ", '', "Employee No.", "Budget Code", 0, '', '');
            LineNo:=LineNo + 1;
            HumanResourceMgmt.CreateGnlJournalLineJournal(Jtemplate, JBatch, "No.", LineNo, GenJournalLine."Account Type"::Employee, "Employee No.", "Posted Date", "Amount Requested", "Global Dimension 1 Code", "Global Dimension 2 Code", "Payment Tx No.(Cheque No.)", Purpose + ' for ' + Format("Employee No.") + ' ' + "Employee Name", "Pay Mode", "Currency Code", GenJournalLine."Applies-to Doc. Type"::" ", '', "Employee No.", "Budget Code", 0, '', '');
            HumanResourceMgmt.PostGeneralJournalLines(Jtemplate, JBatch);
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Salary Advance Management", 'OnAfterPostImprest', '', false, false)]
    local procedure MarkImprestAsPosted(var RequestHeader: Record "Request Header")
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Reset;
        GLEntry.SetRange("Document No.", RequestHeader."No.");
        if GLEntry.FindFirst then begin
            RequestHeader.Posted:=true;
            RequestHeader."Posted By":=UserId;
            RequestHeader."Posted Date":=WorkDate;
            RequestHeader."To Recover From Payroll":=true;
            RequestHeader.Modify;
        end;
    end;
    procedure MarkItForPayrollRecovery(var RequestHeader: Record "Request Header")
    begin
        OnBeforeMarkItForPayrollRecovery(RequestHeader);
        with RequestHeader do begin
            "To Recover From Payroll":=true;
            if Modify then Message('Successfully Marked');
        end;
        OnAfterMarkItForPayrollRecovery(RequestHeader);
    end;
    [IntegrationEvent(false, false)]
    local procedure OnBeforeMarkItForPayrollRecovery(var RequestHeader: Record "Request Header")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnAfterMarkItForPayrollRecovery(RequestHeader: Record "Request Header")
    begin
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Salary Advance Management", 'OnBeforeMarkItForPayrollRecovery', '', false, false)]
    local procedure SendEmailOnMarkForPayroll(var RequestHeader: Record "Request Header")
    var
        RHeader: Record "Request Header";
        USetup: Record "User Setup";
        Initiator: Text;
        Owner: Text;
        Heading: Text[250];
        EmailBody: Text[250];
        Heading1: Text[250];
        EmailBody1: Text[250];
        Employee: Record Employee;
        EmailEntries: Record "Email Entries";
    begin
        with RequestHeader do begin
            EmailEntries.Reset;
            if not EmailEntries.FindLast then begin
                EmailEntries."Entry No.":=1 end
            else
                EmailEntries."Entry No.":=EmailEntries."Entry No." + 1;
            USetup.Reset;
            USetup.SetFilter("Head of Department", '<>%1', '');
            USetup.SetRange("Head of Department", "Global Dimension 1 Code");
            if USetup.FindFirst then EmailEntries.CC:=USetup."E-Mail";
            USetup.Reset;
            USetup.SetRange("Employee No.", "Employee No.");
            if USetup.FindFirst then EmailEntries.Recipient:=USetup."E-Mail";
            if Employee.Get(USetup."Employee No.")then EmailEntries.Subject:=StrSubstNo('Imprest %1 Payroll Recovery', "No.");
            Heading:=StrSubstNo('Dear %1', Employee.FullName);
            EmailBody:=StrSubstNo('<br><br> Your Imprest No. %1 has been marked to be recovered from payroll', "No.");
            Heading1:=StrSubstNo(Heading, "Employee Name");
            EmailBody1:=StrSubstNo(EmailBody, "No.");
            EmailEntries.Body:=Heading + ' ' + EmailBody;
            EmailEntries.Regards:=StrSubstNo('<br><br> Kind Regards<br><br> COGRI Finance Team');
            EmailEntries."Email Type":=EmailEntries."Email Type"::Imprest;
            EmailEntries."Date to Send":=WorkDate;
            EmailEntries."Date Sent":=0D;
            EmailEntries."Time Sent":=0T;
            EmailEntries.Sent:=false;
            EmailEntries.Insert;
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Salary Advance Management", 'OnBeforePostImprest', '', false, false)]
    procedure AdvanceOverdrawal(var RequestHeader: Record "Request Header")
    begin
        with RequestHeader do begin
            HumanResourceMgmt.CheckOverdrawal("Paying Bank Code", "Amount Requested");
        end;
    end;
}
