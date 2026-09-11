codeunit 52203462 "Notify Emp. of Impending Leave"
{
    trigger OnRun()
    begin
        LeavePlan.Reset;
        LeavePlan.SetRange(Status, LeavePlan.Status::Approved);
        if LeavePlan.FindSet then begin
            repeat if CheckIfLeaveCalendarIsCurrent(LeavePlan."Leave Calendar Code") and CheckIfNotificationTemplateIsSet()then RunThroughLeavePlanLines(LeavePlan."No.", LeavePlan."Employee No.");
            until LeavePlan.Next = 0;
        end;
    end;
    var LeavePlan: Record "Leave Plan";
    local procedure CheckIfLeaveCalendarIsCurrent(LeaveCalendarCode: Code[20]): Boolean var
        LeaveCalendar: Record "Leave Calendar";
    begin
        if LeaveCalendar.Get(LeaveCalendarCode)then exit(LeaveCalendar."Current Leave Calendar");
    end;
    local procedure CheckIfNotificationTemplateIsSet(): Boolean var
        NotificationTemplate: Record "Notification Template";
    begin
        NotificationTemplate.Reset;
        NotificationTemplate.SetRange(Source, NotificationTemplate.Source::"Impending leave");
        NotificationTemplate.SetRange("Notification Type", NotificationTemplate."Notification Type"::Email);
        exit(NotificationTemplate.FindFirst);
    end;
    local procedure RunThroughLeavePlanLines(PlanNo: Code[20]; EmployeeNo: Code[30])
    var
        Employee: Record Employee;
        LeavePlanLines: Record "Leave Plan Lines";
        LeaveSetup: Record "Leave Setup";
    begin
        LeaveSetup.Get;
        LeavePlanLines.Reset;
        LeavePlanLines.SetRange("Plan No.", PlanNo);
        LeavePlanLines.SetRange("Employee Code.", EmployeeNo);
        if LeavePlanLines.FindSet then begin
            repeat if CheckIfNotificationIsToBeSent(LeaveSetup."Impending L.App. Not. Period", LeavePlanLines."Start Date")then SendNotificationToEmployee(LeavePlanLines."Employee Code.", LeavePlanLines."Start Date", LeavePlanLines."End Date", LeavePlanLines."Leave Type Description", LeavePlanLines."Days Planned");
            until LeavePlanLines.Next = 0;
        end;
    end;
    local procedure CheckIfNotificationIsToBeSent(DateFormulaToUse: DateFormula; PlanLineDate: Date): Boolean begin
        if CalcDate(DateFormulaToUse, Today) = PlanLineDate then exit(true)
        else
            exit(false);
    end;
    local procedure SendNotificationToEmployee(EmployeeCode: Code[50]; StartDate: Date; EndDate: Date; LeaveType: Text; NoDays: Decimal)
    var
        Employee: Record Employee;
        CommunicationsMgmt: Codeunit "Communications Mgmt";
        NotificationTemplate: Record "Notification Template";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Subject: Text;
        Body: Text;
    begin
        if Employee.Get(EmployeeCode)then begin
            Clear(Recipients);
            Recipients.Add(Employee."E-Mail");
            NotificationTemplate.Reset;
            NotificationTemplate.SetRange("Notification Type", NotificationTemplate."Notification Type"::Email);
            NotificationTemplate.SetRange(Source, NotificationTemplate.Source::"Impending leave");
            if NotificationTemplate.FindFirst then begin
                Subject:=NotificationTemplate.Subject;
            //Body := StrSubstNo(NotificationTemplate.Body, Employee.FullName, NoDays, StartDate, EndDate);
            end;
            CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
        end;
    end;
}
