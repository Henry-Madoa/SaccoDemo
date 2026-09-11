codeunit 52203472 "Training Mgmt"
{
    var HRSetup: Record "Human Resources Setup";
    RequestHeader: Record "Request Header";
    RequestLines: Record "Request Lines";
    PayrollScales: Record "Employee Payroll Scales";
    Employee: Record Employee;
    UserSetup: Record "User Setup";
    ProgressWindow: Dialog;
    TrainingApp: Record "Training Application";
    procedure ConfirmAvailability(TrainingCode: Code[20])
    begin
        TrainingApp.Get(TrainingCode);
        TrainingApp.Status:=TrainingApp.Status::"Awaiting Attendance Confirmation";
        TrainingApp.Modify;
        Message('You have successfully confirmed Training Availability');
    end;
    procedure ConfirmAttendance(TrainingCode: Code[20])
    begin
        TrainingApp.Get(TrainingCode);
        with TrainingApp do begin
            TestField("Training Feedback");
            Validate(Status, TrainingApp.Status::"Awaiting HR Confirmation");
            Modify(true);
            Message('You have successfully confirmed Training Attendance');
        end;
    end;
    procedure HRConfirmAttendance(TrainingCode: Code[20])
    begin
        TrainingApp.Get(TrainingCode);
        HRSetup.Get;
        HRSetup.TestField("Training Expense Code");
        //UserSetup.Get(UserId);
        Employee.Get(TrainingApp."Employee No");
        Employee.TestField("Job Scale");
        if not PayrollScales.Get(Employee."Job Scale")then Error(StrSubstNo('%1 Payroll Scale Setup is required', Employee."Job Scale"))
        else
            PayrollScales.TestField("Training Allowance Amount");
        RequestHeader.Init();
        RequestHeader."Request Type":=RequestHeader."Request Type"::"Staff Claim";
        RequestHeader.Insert(true);
        RequestHeader.Validate("Employee No.", TrainingApp."Employee No");
        RequestHeader.Description:=StrSubstNo('System generated Training allowance claim for Training No. %1 (%2)', TrainingApp."No.", TrainingApp."Training Need Description");
        RequestHeader."Request Type":=RequestHeader."Request Type"::"Staff Claim";
        RequestHeader.Status:=RequestHeader.Status::Open;
        RequestHeader.Modify(true);
        RequestLines.Init();
        RequestLines."Line No":=10000;
        RequestLines.Validate("No.", RequestHeader."No.");
        RequestLines.Validate("Expense Code", HRSetup."Training Expense Code");
        RequestLines.Insert(true);
        RequestLines.Validate("Claim Quantity", Round(((TrainingApp.Period / 1000) / 86400), 1));
        RequestLines.Validate("Claim Unit Cost", PayrollScales."Training Allowance Amount");
        RequestLines.Modify(true);
        with TrainingApp do begin
            Validate(Status, TrainingApp.Status::Attended);
            Modify(true);
            Message(StrSubstNo('You have successfully confirmed %1 Training Attendance', "Employee Name"));
        end;
    end;
    procedure GenerateEmployeeTrainingRequests(TrainingPlan: Record "Training Plan")
    var
        TrainingPlanLines: Record "Training Plan Lines";
        TrainingAttendees: Record "Training Attendees";
    begin
        TrainingPlanLines.Reset();
        TrainingPlanLines.SetRange("Plan No.", TrainingPlan."No.");
        if TrainingPlanLines.FindSet()then begin
            repeat TrainingAttendees.Reset();
                TrainingAttendees.SetRange("Plan No.", TrainingPlanLines."Plan No.");
                TrainingAttendees.SetRange("Plan Line No.", TrainingPlanLines."Line No.");
                TrainingAttendees.SetRange("Training Created", false);
                if TrainingAttendees.FindSet()then begin
                    repeat CreateTrainingApplication(TrainingAttendees, TrainingPlanLines);
                    until TrainingAttendees.Next() = 0;
                end;
            until TrainingPlanLines.Next() = 0;
        end;
        Message('Employee Training Requests have been generated Successfully');
    end;
    [IntegrationEvent(false, false)]
    procedure OnCloseTrainingCalendar(TrainingCalendar: Record "Training Calender")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCloseTrainingCalendar(TrainingCalendar: Record "Training Calender")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnAfterCLoseTrainingCalendar(TrainingCalendar: Record "Training Calender")
    begin
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Training Mgmt", 'OnCloseTrainingCalendar', '', false, false)]
    local procedure CloseCalendar(TrainingCalendar: Record "Training Calender")
    begin
        OnBeforeCloseTrainingCalendar(TrainingCalendar);
        with TrainingCalendar do begin
            Validate(Closed, true);
            "Current Period":=false;
            "Closed On":=WorkDate;
            "Closed By":=UserId;
            Modify(true);
        end;
        OnAfterCLoseTrainingCalendar(TrainingCalendar);
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Training Mgmt", 'OnAfterCLoseTrainingCalendar', '', false, false)]
    local procedure CreateNewPeriod(TrainingCalendar: Record "Training Calender")
    var
        TrainingCalenderVar: Record "Training Calender";
    begin
        TrainingCalenderVar.Init;
        TrainingCalenderVar."Start Date":=CalcDate('1D', TrainingCalendar."End Date");
        TrainingCalenderVar."End Date":=CalcDate('CY', TrainingCalenderVar."Start Date");
        TrainingCalenderVar."Opened by":=UserId;
        TrainingCalenderVar."Opened On":=WorkDate;
        TrainingCalenderVar."Calender Code":=Format(Date2DMY(TrainingCalenderVar."Start Date", 3));
        TrainingCalenderVar."Current Period":=true;
        if TrainingCalenderVar.Insert then Message('%1 has been closed and %2 has been opened', TrainingCalendar."Calender Code", TrainingCalenderVar."Calender Code");
    end;
    local procedure CreateTrainingApplication(TrainingAttendees: Record "Training Attendees"; TrainingPlanLines: Record "Training Plan Lines")
    var
        TrainingApp: Record "Training Application";
        TrainingCalendar: Record "Training Calender";
        CurrentCalender: Code[50];
    begin
        TrainingAttendees.CalcFields("Training Cost");
        TrainingCalendar.Reset;
        TrainingCalendar.SetRange("Current Period", true);
        TrainingCalendar.SetRange(Closed, false);
        if TrainingCalendar.FindFirst then CurrentCalender:=TrainingCalendar."Calender Code";
        TrainingApp.Init();
        TrainingApp."SS Created":=false;
        TrainingApp.Validate("Employee No", TrainingAttendees."Employee No");
        TrainingApp.Validate("Training Need", TrainingPlanLines."Training Need");
        TrainingApp.Validate(Status, TrainingApp.Status::"Awaiting Availability Confirmation");
        TrainingApp."Training Plan Line No":=TrainingPlanLines."Line No.";
        if TrainingPlanLines."Expected Trainees" <= TrainingPlanLines."No. of Applications" then TrainingApp."Exceeds Expected Trainees":=true
        else
            TrainingApp."Exceeds Expected Trainees":=false;
        TrainingApp."Training Need":=TrainingPlanLines."Training Need";
        TrainingApp.Category:=TrainingPlanLines.Category;
        TrainingApp."Training Calender":=CurrentCalender;
        TrainingApp."Start Date":=TrainingCalendar."Start Date";
        TrainingApp."Training Start Date":=TrainingPlanLines."Expected Start Date";
        TrainingApp."End Date":=TrainingCalendar."End Date";
        TrainingApp."Training Need Description":=TrainingPlanLines."Training Need Description";
        TrainingApp.Trainer:=TrainingPlanLines."Trainer Code";
        TrainingApp."Expected Cost":=TrainingAttendees."Training Cost";
        TrainingApp."Plan No.":=TrainingPlanLines."Plan No.";
        TrainingApp."Plan Line No.":=TrainingPlanLines."Line No.";
        TrainingApp.Period:=TrainingPlanLines.Duration;
        TrainingApp.Insert(true);
        TrainingAttendees."Training Created":=true;
        TrainingAttendees.Modify(true);
    end;
}
