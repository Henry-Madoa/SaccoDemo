codeunit 52203451 "Appraisal Management"
{
    var Employee: Record Employee;
    GlobalFunctions: Codeunit "Human Resource Management";
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    ReviewPeriod: array[2]of Record "Appraisal Review Periods";
    Window: Dialog;
    Names: Text;
    procedure InitialiseAppraisal(AppraisalCalendar: Record "Appraisal Calender")
    var
        Employee: Record Employee;
        AppraisalCode: Code[50];
        Window: Dialog;
        All: Integer;
        Current: Integer;
        HumanResourceMgmt: Codeunit "Human Resource Management";
        EmailEntries: Record "Email Entries";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
    begin
        with AppraisalCalendar do begin
            if Closed then Error('You cannot Intialise Appraisals for a Closed Calendar');
            ReviewPeriod[1].Reset();
            ReviewPeriod[1].SetFilter(Sequence, '=%1', 0);
            if not ReviewPeriod[1].FindFirst then Error('You need to define a Planning review Period with 0 sequence No.')
            else
            begin
                Employee.Reset;
                Employee.SetFilter("Employee Status", '=%1|%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
                Employee.SetFilter("Probation Status", '=%1|%2', Employee."Probation Status"::Confirmed, Employee."Probation Status"::"On Probation");
                Employee.SetFilter("Manager No.", '<>%1', '');
                Employee.SetFilter("Overview Manager", '<>%1', '');
                if Employee.FindSet then begin
                    All:=Employee.Count;
                    Current:=0;
                    Window.Open('Going Through Active Employees \Employee Name #1# \Progress @4@@');
                    repeat Current+=1;
                        Window.Update(1, Employee.FullName);
                        AppraisalCode:='';
                        AppraisalCode:=CreateAppraisalHeader(AppraisalCalendar, ReviewPeriod[1], Employee."No.");
                        if AppraisalCode <> '' then begin
                            CreateAppraisalCompetenceLines(Employee."No.", AppraisalCode);
                            Clear(Recipients);
                            Recipients.Add(Employee."E-Mail");
                            Subject:='Annual Objective Setting';
                            Body:='Hello ' + Format(Employee.FullName) + '<br><br> This is to remind you that the annual appraisal calender has been initialized and its time to set your objectives<br>';
                        // HumanResourceMgmt.CreateEmailEntries(Employee."E-Mail", Subject, Body, Today, 'This is a system generated e-mail', ''
                        //                                     , SenderName, SenderAddress, EmailEntries."Email Type"::Notification);
                        end;
                    until Employee.Next = 0;
                    Window.Close();
                end;
            end;
        end;
    end;
    procedure CloseCalendar(AppraisalCalendar: Record "Appraisal Calender")
    var
        AppraisalHeader: Record "Appraisal Header";
        ReviewPeriodCount: Integer;
    begin
        with AppraisalCalendar do begin
            if Closed then Error('The %1 Calendar have already been closed', Description);
            ReviewPeriod[1].Reset();
            ReviewPeriod[1].SetRange("Calendar Code", "Calendar Code");
            ReviewPeriodCount:=ReviewPeriod[1].Count;
            ReviewPeriod[2].Reset();
            ReviewPeriod[2].SetFilter(Sequence, '=%1', (ReviewPeriodCount - 1));
            if ReviewPeriod[2].FindFirst then if ReviewPeriod[2].Status <> ReviewPeriod[2].Status::Closed then Error(StrSubstNo('You need to close %1 first', ReviewPeriod[2].Description));
            AppraisalHeader.Reset();
            AppraisalHeader.SetRange(Status, AppraisalHeader.Status::Closed);
            AppraisalHeader.SetRange("Calendar Code", "Calendar Code");
            if AppraisalHeader.FindSet()then begin
                repeat GetAppraisalTrainingNeeds(AppraisalHeader);
                until AppraisalHeader.Next = 0;
                Closed:=true;
                "Closed By":=UserId;
                "Closed On":=WorkDate;
                Modify(true);
                Message('Calendar have been closed');
            end;
        end;
    end;
    local procedure GetAppraisalTrainingNeeds(var AppraisalHeader: Record "Appraisal Header")
    var
        AppraisalTrainingNeed: Record "Appraisal Training Needs";
    begin
        AppraisalTrainingNeed.Reset;
        AppraisalTrainingNeed.SetRange("Appraisal No.", AppraisalHeader."No.");
        AppraisalTrainingNeed.SetRange(Recommended, true);
        if AppraisalTrainingNeed.FindSet()then begin
            repeat CreateEmployeeTrainingNeed(AppraisalTrainingNeed, AppraisalHeader);
            until AppraisalTrainingNeed.Next = 0;
        end;
    end;
    local procedure CreateEmployeeTrainingNeed(AppTrainingNeed: Record "Appraisal Training Needs"; AppraisalHeader: Record "Appraisal Header")
    var
        TrainingNeed: Record "Training Need";
    begin
        TrainingNeed.Init;
        TrainingNeed.Validate("Employee No", AppTrainingNeed."Employee No.");
        TrainingNeed.Category:=AppTrainingNeed.Category;
        TrainingNeed."From Appraisal":=true;
        TrainingNeed.Validate("Calendar Code", AppraisalHeader."Calendar Code");
        TrainingNeed."Created By":=UserId;
        TrainingNeed."Created On":=WorkDate;
        TrainingNeed.Supervisor:=AppraisalHeader."Supervisor No";
        TrainingNeed.Description:=AppTrainingNeed."Training Need Description";
        TrainingNeed.Insert(true);
    end;
    local procedure CreateAppraisalHeader(AppraisalCalendar: Record "Appraisal Calender"; ReviewPeriod: Record "Appraisal Review Periods"; EmployeeNo: Code[50]): Code[20]var
        AppraisalHeader: Record "Appraisal Header";
        Employee: Record Employee;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        HRSetUp: Record "Human Resources Setup";
        AppraisalCalendarLines: Record "Appraisal Calender Lines";
        NextAppraisalNo: Code[30];
    begin
        AppraisalHeader.Reset;
        AppraisalHeader.SetRange("Employee No", EmployeeNo);
        AppraisalHeader.SetRange("Appraisal End Date", AppraisalCalendar."Period End Date");
        AppraisalHeader.SetRange("Appraisal Start Date", AppraisalCalendar."Period Start Date");
        if not AppraisalHeader.FindFirst then begin
            if Employee.Get(EmployeeNo)then begin
                HRSetUp.Get;
                AppraisalHeader.Reset;
                NextAppraisalNo:=NoSeriesManagement.GetNextNo(HRSetUp."Appraisal Nos", 0D, true);
                AppraisalHeader."No.":=NextAppraisalNo;
                AppraisalHeader.Validate("Employee No", EmployeeNo);
                AppraisalHeader."Employee Name":=Employee.FullName;
                AppraisalHeader."Employee User Id":=Employee."User ID";
                AppraisalHeader."Calendar Code":=AppraisalCalendar."Calendar Code";
                AppraisalHeader."Review Period":=ReviewPeriod.Code;
                AppraisalHeader.Sequence:=ReviewPeriod.Sequence;
                AppraisalHeader."Appraisal End Date":=AppraisalCalendar."Period End Date";
                AppraisalHeader."Appraisal Start Date":=AppraisalCalendar."Period Start Date";
                AppraisalHeader.Status:=AppraisalHeader.Status::"Appraisee Level";
                AppraisalHeader.Validate("Supervisor No", Employee."Manager No.");
                AppraisalHeader.Validate("Overview Manager", Employee."Overview Manager");
                AppraisalHeader."Level/Grade":=Employee."Job Scale";
                if AppraisalHeader.Insert then exit(NextAppraisalNo);
            end;
        end;
    end;
    local procedure CreateAppraisalTargetLines(EmployeeCode: Code[50]; AppraisalCode: Code[50]; KPICode: Code[50]; MaxWeight: Integer; KRACode: Code[50]; DepartmentalTarget: Decimal)
    var
        EmployeeAppraisalKPIs: Record "Appraisal Activities";
    begin
    /*
            EmployeeAppraisalKPIs.RESET;
            EmployeeAppraisalKPIs."Appraisal Code":=AppraisalCode;
            EmployeeAppraisalKPIs."Employee No.":=EmployeeCode;
            EmployeeAppraisalKPIs."Self Comments":=KRACode;
            EmployeeAppraisalKPIs."KRA Code":=KPICode;
            EmployeeAppraisalKPIs.VALIDATE("KRA Code");
            EmployeeAppraisalKPIs."KPI Description":=MaxWeight;
            EmployeeAppraisalKPIs."Departmental Target":=DepartmentalTarget;
            EmployeeAppraisalKPIs.INSERT;
            */
    end;
    local procedure CheckIfALreadyInitialized()
    begin
    end;
    procedure BuildAppraisalJournal(JournalTemplate: Code[50]; JournalBatch: Code[50]; LineNo: Integer; AppraisalCalendar: Code[20]; EmployeeCode: Code[20]; PostingDate: Date; AppraisalPeriod: Text; DocNo: Code[20]; MaxWeight: Decimal; TargetScore: Decimal; SelfComments: Text; SupervisorComment: Text; SelfAssesedScore: Decimal; JustificationofScore: Text; SupervisorScore: Decimal; AgreedScore: Decimal; SupervisorFinalComments: Text; PeriodStartDate: Date; PeriodEndDate: Date; Dim1: Code[50]; Dim2: Code[50])
    var
        AppraisalJournal: Record "Appraisal Journal Line";
    begin
    /*WITH AppraisalJournal DO
              BEGIN
                "Journal Template Name":=JournalTemplate;
                "Journal Batch Name":=JournalBatch;
                "Line No.":=LineNo;
                "External Document No.":=AppraisalCalendar;
                VALIDATE("Staff No.",EmployeeCode);
                "Posting Date":=PostingDate;
                "Appraisal Period":=AppraisalPeriod;
                Score:=MaxWeight;
                "Document No.":=DocNo;
                "Index Entry":=TargetScore;
                "Posting No. Series":=SelfComments;
                "Self Rating":=SelfAssesedScore;
                "Justification of Score":=JustificationofScore;
                "Appraisal Period Start Date":=PeriodStartDate;
                "Appraisal Period End Date":=PeriodEndDate;
                "Supervisor Final Comments":=SupervisorFinalComments;
                "Shortcut Dimension 1 Code":=Dim1;
                "Shortcut Dimension 2 Code":=Dim2;
                IF "Agreed Rating"<>0 THEN
                  INSERT;
              end;
            */
    end;
    procedure DeleteAppraisalJournalLines(JournalTemplate: Code[20]; JournalBatch: Code[20])
    var
        AppraisalJournalLine: Record "Appraisal Journal Line";
    begin
        AppraisalJournalLine.Reset;
        AppraisalJournalLine.SetRange("Journal Template Name", JournalTemplate);
        AppraisalJournalLine.SetRange("Journal Batch Name", JournalBatch);
        if AppraisalJournalLine.FindSet then AppraisalJournalLine.DeleteAll;
    end;
    procedure PostAppraisalJournalLines(JournalTemplate: Code[20]; JournalBatch: Code[20])
    var
        AppraisalJournalLine: Record "Appraisal Journal Line";
    begin
        AppraisalJournalLine.Reset;
        AppraisalJournalLine.SetRange("Journal Template Name", JournalTemplate);
        AppraisalJournalLine.SetRange("Journal Batch Name", JournalBatch);
    // if AppraisalJournalLine.FindSet then
    //     CODEUNIT.Run(CODEUNIT::Codeunit70002, AppraisalJournalLine);
    end;
    procedure CreateAppraisalJournalBatch(JournalTemplate: Code[20]; JournalBatch: Code[20])
    var
        AppraisalJournalLine: Record "Appraisal Journal Line";
        AppraisalJournalBatch: Record "Appraisal Journal Batch";
    begin
        AppraisalJournalBatch.Reset;
        AppraisalJournalBatch.SetRange("Journal Template Name", JournalTemplate);
        AppraisalJournalBatch.SetRange(Name, JournalBatch);
        if AppraisalJournalBatch.FindFirst then exit
        else
        begin
            with AppraisalJournalBatch do begin
                "Journal Template Name":=JournalTemplate;
                Name:=UserId;
                Description:='Leave Batch For ' + Format(JournalBatch);
                Insert;
            end;
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Appraisal Management", 'OnCloseAppraisalCalenderPeriod', '', false, false)]
    local procedure CloseAppraisalCalenderPeriod(var AppraisalCalendarLines: Record "Appraisal Calender Lines")
    begin
        with AppraisalCalendarLines do begin
            Closed:=true;
            "Closed By":=UserId;
            "Closed On":=WorkDate;
            "Current Period":=false;
            if Modify(true)then Message('%1 Succuessfully closed', "Period Name");
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Appraisal Management", 'OnCloseAppraisalCalender', '', false, false)]
    local procedure CloseAppraisalCalender(var AppraisalCalender: Record "Appraisal Calender")
    begin
        with AppraisalCalender do begin
            Closed:=true;
            "Closed By":=UserId;
            "Closed On":=WorkDate;
            if Modify(true)then Message('%1 Succuessfully closed', Description);
        end;
    end;
    [IntegrationEvent(false, false)]
    procedure OnCloseAppraisalCalenderPeriod(var AppraisalCalendarLines: Record "Appraisal Calender Lines")
    begin
    end;
    [IntegrationEvent(false, false)]
    procedure OnCloseAppraisalCalender(var AppraisalCalender: Record "Appraisal Calender")
    begin
    end;
    local procedure UpdateTrainingNeeds()
    begin
    end;
    //[EventSubscriber(ObjectType::Codeunit, 50209, 'OnAfterInitializeAppraisal', '', false, false)]
    local procedure SendEmailsToEmployees(AppraisalCalendar: Code[50]; AprraisalPeriod: Text)
    var
        AppraisalHeader: Record "Appraisal Header";
        Window: Dialog;
        All: Integer;
        Current: Integer;
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Subject: Text;
        Body: Text;
        ReceiverName: Text;
        Employee: Record Employee;
        HumanResourceMgmt: Codeunit "Human Resource Management";
    begin
        AppraisalHeader.Reset;
        AppraisalHeader.SetRange("Supervisor Title", AprraisalPeriod);
        if AppraisalHeader.FindSet then begin
            All:=AppraisalHeader.Count;
            Current:=0;
            Window.Open('Sending Email to \Employee Name #1# \Progress @4@@');
            Clear(Recipients);
            repeat Current+=1;
                Window.Update(1, AppraisalHeader."Employee Name");
                Sleep(100);
                if Employee.Get(AppraisalHeader."Employee No")then begin
                    Recipients.Add(Employee."E-Mail");
                    Subject:='Appraisal Goal Setting';
                    Body:='Dear ' + Format(Employee.FullName) + '<br> This is to inform you that a goal setting process for human resource appraisal' + 'for the period ' + Format(AprraisalPeriod) + ' has been initiated <br> Log in to Nav ERP and set your goals ' + '<br>This is a system generated Email, Please do not reply to it <br>Regards';
                end;
            until AppraisalHeader.Next = 0;
            Window.Close();
        end;
    end;
    procedure CreateAppraisalCompetenceLines(EmployeeNo: Code[50]; AppraisalNo: Code[50])
    var
        EmployeeAppraisalCompetence: array[3]of Record "Appraisal Competence";
        CompetenceCategories: Record "Competence Categories";
        LineNo: Integer;
        Employee: Record Employee;
        IsManager: Boolean;
        EvaluatedGrade: Integer;
        GrantApprovers: Record "Grant Approvers";
        ok: Boolean;
        IsGrade8: Boolean;
    begin
        IsManager:=false;
        IsGrade8:=false;
        Employee.Get(EmployeeNo);
        ok:=Evaluate(EvaluatedGrade, Employee."Job Scale");
        GrantApprovers.Reset;
        GrantApprovers.SetRange("Emp No", Employee."No.");
        GrantApprovers.SetRange(Level, GrantApprovers.Level::OverView);
        if GrantApprovers.FindFirst then IsManager:=true;
        if EvaluatedGrade >= 8 then IsGrade8:=true;
        CompetenceCategories.Reset;
        if CompetenceCategories.FindSet then begin
            repeat EmployeeAppraisalCompetence[1].Init;
                EmployeeAppraisalCompetence[2].Reset;
                EmployeeAppraisalCompetence[2].SetCurrentKey("Line No");
                EmployeeAppraisalCompetence[2].SetAscending("Line No", true);
                if EmployeeAppraisalCompetence[2].FindLast then LineNo:=EmployeeAppraisalCompetence[2]."Line No" + 1
                else
                    LineNo:=1;
                EmployeeAppraisalCompetence[1]."Line No":=LineNo;
                EmployeeAppraisalCompetence[1]."Appraisal No":=AppraisalNo;
                EmployeeAppraisalCompetence[1]."Employee Code":=EmployeeNo;
                EmployeeAppraisalCompetence[1]."Competence Category":=CompetenceCategories.Category;
                EmployeeAppraisalCompetence[1]."Maximum Weigth":=CompetenceCategories."Maximum Weigth";
                if EmployeeAppraisalCompetence[1].Insert then CreateAppraisalCompetenceBehaviourLines(EmployeeNo, AppraisalNo, LineNo, CompetenceCategories.Category);
            until CompetenceCategories.Next = 0;
        end;
    end;
    procedure CreateAppraisalCompetenceBehaviourLines(EmployeeNo: Code[50]; AppraisalNo: Code[50]; CompetenceLineNo: Integer; CompetenceCategoryCode: Text)
    var
        EmployeeAppraisalCompetence: array[3]of Record "Appraisal Behaviour";
        CompetenceCategories: Record "Competence Behaviour";
        LineNo: Integer;
    begin
        CompetenceCategories.Reset;
        CompetenceCategories.SetRange(Category, CompetenceCategoryCode);
        if CompetenceCategories.FindSet then begin
            repeat EmployeeAppraisalCompetence[1].Init;
                EmployeeAppraisalCompetence[2].Reset;
                EmployeeAppraisalCompetence[2].SetCurrentKey("Line No");
                EmployeeAppraisalCompetence[2].SetAscending("Line No", true);
                if EmployeeAppraisalCompetence[2].FindLast then LineNo:=EmployeeAppraisalCompetence[2]."Line No" + 1
                else
                    LineNo:=1;
                EmployeeAppraisalCompetence[1]."Line No":=LineNo;
                EmployeeAppraisalCompetence[1]."Appraisal No":=AppraisalNo;
                EmployeeAppraisalCompetence[1]."Employee No":=EmployeeNo;
                EmployeeAppraisalCompetence[1]."Competence Line No":=CompetenceLineNo;
                EmployeeAppraisalCompetence[1].Weight:=CompetenceCategories.Weigths;
                EmployeeAppraisalCompetence[1]."Behaviour Name":=CompetenceCategories.Behaviour;
                EmployeeAppraisalCompetence[1]."Behaviour Description":=CompetenceCategories."Behaviour Description";
                EmployeeAppraisalCompetence[1].Insert;
            until CompetenceCategories.Next = 0;
        end;
    end;
    local procedure FindLastLineInCompetenceLines(EmployeeNo: Code[50]; AppraisalNo: Code[50]): Integer var
        EmployeeAppraisalCompetence: Record "Appraisal Competence";
        CompetenceCategories: Record "Competence Categories";
    begin
        EmployeeAppraisalCompetence.Reset;
        EmployeeAppraisalCompetence.SetRange("Appraisal No", AppraisalNo);
        EmployeeAppraisalCompetence.SetRange("Employee Code", EmployeeNo);
        exit(EmployeeAppraisalCompetence.Count);
    end;
    local procedure FindLastLineInCompetenceBehaviourLines(EmployeeNo: Code[50]; AppraisalNo: Code[50]): Integer var
        EmployeeAppraisalCompetence: Record "Appraisal Behaviour";
        CompetenceCategories: Record "Competence Categories";
    begin
        EmployeeAppraisalCompetence.Reset;
        EmployeeAppraisalCompetence.SetRange("Appraisal No", AppraisalNo);
        EmployeeAppraisalCompetence.SetRange("Employee No", EmployeeNo);
        exit(EmployeeAppraisalCompetence.Count);
    end;
    local procedure FindLastLineInKRALines(EmployeeNo: Code[50]; AppraisalNo: Code[50]): Integer var
        EmployeeAppraisalKRA: Record "Appraisal Objectives/KRAs";
        CompetenceCategories: Record "Competence Categories";
    begin
        EmployeeAppraisalKRA.Reset;
        EmployeeAppraisalKRA.SetRange("Appraisal No", AppraisalNo);
        EmployeeAppraisalKRA.SetRange("Employee No", EmployeeNo);
        exit(EmployeeAppraisalKRA.Count);
    end;
    [Scope('Cloud')]
    procedure SendGoalSettingForApproval(AppraisalNo: Code[20]; EmployeeNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text): Boolean var
        AppraisalHeader: Record "Appraisal Header";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
        EmployeeAppraisalKRAs: Record "Appraisal Objectives/KRAs";
        Employee: Record Employee;
        EmployeeAppraisalCompetence: Record "Appraisal Competence";
        EmployeeAppraisalBehaviour: Record "Appraisal Behaviour";
        AreasofFurtherDevelopment: Record "Areas of Further Development";
    begin
        SendEmail:=true;
        if AppraisalHeader.Get(AppraisalNo)then begin
            OnBeforeSendAppraisalToSupervisor(AppraisalHeader, false, false);
            AppraisalHeader.Status:=AppraisalHeader.Status::"Appraiser Level";
            if AppraisalHeader.Modify(true)then begin
                if SendEmail then begin
                    EmployeeAppraisalKRAs.Reset;
                    EmployeeAppraisalKRAs.SetRange("Appraisal No", AppraisalNo);
                    if EmployeeAppraisalKRAs.FindSet then begin
                        repeat EmployeeAppraisalKRAs.CalcFields("Total Weigth");
                            if EmployeeAppraisalKRAs."Total Weigth" <> EmployeeAppraisalKRAs."Maximum Weight" then Error('Total KPI weight should be %1', EmployeeAppraisalKRAs."Maximum Weight");
                        until EmployeeAppraisalKRAs.Next = 0;
                    end;
                    EmployeeAppraisalCompetence.Reset;
                    EmployeeAppraisalCompetence.SetRange("Appraisal No", AppraisalNo);
                    if EmployeeAppraisalCompetence.FindSet then begin
                        repeat EmployeeAppraisalCompetence.CalcFields("Total Weigth");
                            if EmployeeAppraisalCompetence."Total Weigth" <> EmployeeAppraisalCompetence."Maximum Weigth" then Error('Total competence weight should be %1', EmployeeAppraisalCompetence."Maximum Weigth");
                        until EmployeeAppraisalCompetence.Next = 0;
                    end;
                    EmployeeAppraisalBehaviour.Reset;
                    EmployeeAppraisalBehaviour.SetRange("Appraisal No", AppraisalNo);
                    if EmployeeAppraisalBehaviour.FindSet then begin
                        repeat EmployeeAppraisalBehaviour.TestField(Weight);
                        until EmployeeAppraisalBehaviour.Next = 0;
                    end;
                    EmployeeAppraisalKRAs.Reset;
                    EmployeeAppraisalKRAs.SetRange("Appraisal No", AppraisalNo);
                    EmployeeAppraisalKRAs.SetRange("Employee No", EmployeeNo);
                    EmployeeAppraisalKRAs.SetFilter("KRA/Objective", '<>%1', '');
                    if not EmployeeAppraisalKRAs.FindFirst then Error('You cannot submit blank objectives');
                    /*IF AppraisalHeader."Is Long Term" THEN
                  BEGIN
                    AreasofFurtherDevelopment.RESET;
                    AreasofFurtherDevelopment.SETRANGE("Appraisal No.",AppraisalNo);
                    AreasofFurtherDevelopment.SETFILTER(Weakness,'<>%1','');
                    IF NOT AreasofFurtherDevelopment.FINDFIRST THEN
                      ERROR('You have to specify atleast one training need');
                  end;*/
                    if Employee.Get(AppraisalHeader."Employee No")then begin
                        Clear(Recipients);
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:='Goal Setting Approval';
                        Body:='Dear ' + Format(AppraisalHeader."Employee Name") + ' <br><br>' + Format(AppraisalHeader."Supervisor Name") + ' has sent your appraisal goal setting for acceptance. Kindly  use follow the Link below to approve: <a href =' + Format(ApprovalURL) + '> Approval Link</a>' + ' <br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                    if Employee.Get(AppraisalHeader."Supervisor No")then begin
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:='Annual objective Setting Approval';
                        Body:='Dear ' + Format(AppraisalHeader."Supervisor Name") + '<br> You have successfully submited objective setting to ' + Format(AppraisalHeader."Employee Name") + ' for acceptance <br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure SendGoalSettingBackToAppraisee(AppraisalNo: Code[20]; EmployeeNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text; RejectionComments: Text): Boolean var
        AppraisalHeader: Record "Appraisal Header";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
    begin
        SendEmail:=true;
        if AppraisalHeader.Get(AppraisalNo)then begin
            AppraisalHeader.Status:=AppraisalHeader.Status::"Appraisee Level";
            if RejectionComments <> '' then AppraisalHeader."Supervisor Rejection Comments":=RejectionComments;
            if AppraisalHeader.Modify(true)then begin
                if SendEmail then begin
                    if Employee.Get(AppraisalHeader."Supervisor No")then begin
                        Clear(Recipients);
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:='Goal Setting Rejection';
                        Body:='Dear ' + Format(AppraisalHeader."Supervisor Name") + ' <br><br>' + Format(AppraisalHeader."Employee Name") + ' has sent back their appraisal goal setting for correction. Their correction comments are as follows :<br>' + Format(AppraisalHeader."Supervisor Rejection Comments") + '<br></br> Kindly  use follow the Link below to approve: <a href =' + Format(ApprovalURL) + '> Approval Link</a>' + ' <br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure SendGoalSettingToOverview(AppraisalNo: Code[20]; EmployeeNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text): Boolean var
        AppraisalHeader: Record "Appraisal Header";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
    begin
        SendEmail:=true;
        if AppraisalHeader.Get(AppraisalNo)then begin
            AppraisalHeader.Status:=AppraisalHeader.Status::"Overview Manager Level";
            if AppraisalHeader.Modify(true)then begin
                if SendEmail then begin
                    if Employee.Get(AppraisalHeader."Overview Manager")then begin
                        Clear(Recipients);
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:='Goal Setting Approval';
                        Body:='';
                        Body+='Dear ' + Format(AppraisalHeader."Overview Manager Name");
                        Body+='<br><br>';
                        Body+=Format(AppraisalHeader."Employee Name") + ' has sent their appraisal goal setting for further approval.';
                        Body+='<br><br>';
                        Body+='Kindly  use follow the Link below to approve: <a href =' + Format(ApprovalURL) + '> Approval Link</a>';
                        Body+='<br></br>';
                        Body+='This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                    if Employee.Get(AppraisalHeader."Supervisor No")then begin
                        Clear(Recipients);
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:='Goal Setting Approval';
                        Body:='Dear ' + Format(AppraisalHeader."Supervisor Name") + ' <br><br>' + Format(AppraisalHeader."Employee Name") + ' has accepted appraisal goal setting and sent it for further approval.' + '<br></br> Kindly  use follow the Link below to approve: <a href =' + Format(ApprovalURL) + '> Approval Link</a>' + ' <br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure SendGoalSettingBackToLineManager(AppraisalNo: Code[20]; EmployeeNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text; RejectionComments: Text): Boolean var
        AppraisalHeader: Record "Appraisal Header";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
    begin
        SendEmail:=true;
        if AppraisalHeader.Get(AppraisalNo)then begin
            AppraisalHeader.Status:=AppraisalHeader.Status::"Appraiser Level";
            if RejectionComments <> '' then AppraisalHeader."Overview Rejection Comments":=RejectionComments;
            if AppraisalHeader.Modify(true)then begin
                if SendEmail then begin
                    if Employee.Get(AppraisalHeader."Employee No")then begin
                        Clear(Recipients);
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:='Goal Setting Rejection';
                        Body:='Dear ' + Format(AppraisalHeader."Employee Name") + ' <br><br>' + Format(AppraisalHeader."Overview Manager Name") + ' has sent back appraisal goal setting assesment for correction. Their correction comments are as follows :<br>' + Format(AppraisalHeader."Overview Rejection Comments") + '<br></br> Kindly  use follow the Link below to approve: <a href =' + Format(ApprovalURL) + '> Approval Link</a>' + ' <br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure ApproveGoalSetting(AppraisalNo: Code[20]; EmployeeNo: Code[20]; SendEmail: Boolean): Boolean var
        AppraisalHeader: Record "Appraisal Header";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
    begin
        SendEmail:=true;
        if AppraisalHeader.Get(AppraisalNo)then begin
            AppraisalHeader.Status:=AppraisalHeader.Status::Approved;
            if AppraisalHeader.Modify(true)then begin
                if SendEmail then begin
                    if Employee.Get(AppraisalHeader."Employee No")then begin
                        Clear(Recipients);
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:='Annual Objective Setting Approval';
                        Body:='Dear ' + Format(AppraisalHeader."Employee Name") + ' <br><br>' + Format(AppraisalHeader."Overview Manager Name") + ' has approved your appraisal goal setting for period : ' + Format(AppraisalHeader."Calendar Code") + ' <br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure SendAppraisalForApproval(AppraisalNo: Code[20]; EmployeeNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text): Boolean var
        AppraisalHeader: Record "Appraisal Header";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
    begin
        SendEmail:=true;
        if AppraisalHeader.Get(AppraisalNo)then begin
            ReviewPeriod[1].Get(AppraisalHeader."Calendar Code", AppraisalHeader."Review Period");
            OnBeforeSendAppraisalToSupervisor(AppraisalHeader, false, false);
            AppraisalHeader.Status:=AppraisalHeader.Status::"Appraiser Level";
            if AppraisalHeader.Modify(true)then begin
                if SendEmail then begin
                    if Employee.Get(AppraisalHeader."Supervisor No")then begin
                        Clear(Recipients);
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:=StrSubstNo('%1 Approval', ReviewPeriod[1].Description);
                        Body:='Dear ' + Format(AppraisalHeader."Supervisor Name") + ' <br><br>' + Format(AppraisalHeader."Employee Name") + ' has sent their ' + ReviewPeriod[1].Description + ' for approval.<br></br> Kindly use follow the Link below to approve: <a href =' + Format(ApprovalURL) + '> Approval Link</a>' + ' <br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure SendAppraisaBackToAppraisee(AppraisalNo: Code[20]; EmployeeNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text; RejectionComments: Text): Boolean var
        AppraisalHeader: Record "Appraisal Header";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
    begin
        SendEmail:=true;
        if AppraisalHeader.Get(AppraisalNo)then begin
            AppraisalHeader.Status:=AppraisalHeader.Status::"Appraisee Level";
            if RejectionComments <> '' then AppraisalHeader."Supervisor Rejection Comments":=RejectionComments;
            if AppraisalHeader.Modify(true)then begin
                if SendEmail then begin
                    if Employee.Get(AppraisalHeader."Employee No")then begin
                        ReviewPeriod[1].Get(AppraisalHeader."Calendar Code", AppraisalHeader."Review Period");
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:=StrSubstNo('%1 Appraisal Rejection', ReviewPeriod[1].Description);
                        Body:='Dear ' + Format(AppraisalHeader."Employee Name") + ' <br><br>' + Format(AppraisalHeader."Supervisor Name") + ' has sent back your ' + ReviewPeriod[1].Description + ' appraisal for correction. Their correction comments are as follows :<br>' + Format(AppraisalHeader."Supervisor Rejection Comments") + '<br></br> Kindly  use follow the Link below to approve: <a href =' + Format(ApprovalURL) + '> Approval Link</a>' + ' <br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure SendAppraisalToOverViewManager(AppraisalNo: Code[20]; EmployeeNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text): Boolean var
        AppraisalHeader: Record "Appraisal Header";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
    begin
        SendEmail:=true;
        if AppraisalHeader.Get(AppraisalNo)then begin
            OnBeforeSendAppraisalToSupervisor(AppraisalHeader, false, true);
            AppraisalHeader.Status:=AppraisalHeader.Status::"Overview Manager Level";
            if AppraisalHeader.Modify(true)then begin
                if SendEmail then begin
                    if Employee.Get(AppraisalHeader."Overview Manager")then begin
                        Clear(Recipients);
                        Recipients.Add(Employee."Company E-Mail");
                        if ReviewPeriod[1].Get(AppraisalHeader."Review Period", AppraisalHeader."Calendar Code")then;
                        Subject:=StrSubstNo('%1 Appraisal Approval', ReviewPeriod[1].Description);
                        Body:='Dear ' + Format(AppraisalHeader."Overview Manager Name") + ' <br><br>' + Format(AppraisalHeader."Supervisor Name") + ' has sent Mid Year appraisal for ' + Format(AppraisalHeader."Employee Name") + ' for further assesment <br></br> Kindly  use follow the Link below to approve: <a href =' + Format(ApprovalURL) + '> Approval Link</a>' + ' <br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure SendAppraisaBackLineManager(AppraisalNo: Code[20]; EmployeeNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text; RejectionComments: Text): Boolean var
        AppraisalHeader: Record "Appraisal Header";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
    begin
        SendEmail:=true;
        if AppraisalHeader.Get(AppraisalNo)then begin
            AppraisalHeader.Status:=AppraisalHeader.Status::"Appraiser Level";
            if RejectionComments <> '' then AppraisalHeader."Overview Rejection Comments":=RejectionComments;
            if AppraisalHeader.Modify(true)then begin
                if SendEmail then begin
                    if Employee.Get(AppraisalHeader."Supervisor No")then begin
                        Clear(Recipients);
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:='Appraisal Rejection';
                        Body:='Dear ' + Format(AppraisalHeader."Supervisor Name") + ' <br><br>' + Format(AppraisalHeader."Overview Manager Name") + ' has sent back Line Manager appraisal for ' + Format(AppraisalHeader."Employee Name") + ' for further assesment. Their correction comments are as follows :<br>' + Format(AppraisalHeader."Overview Rejection Comments") + '<br></br> Kindly  use follow the Link below to approve: <a href =' + Format(ApprovalURL) + '> Approval Link</a>' + ' <br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure ApproveAppraisal(AppraisalNo: Code[20]; EmployeeNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text): Boolean var
        AppraisalHeader: Record "Appraisal Header";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
        IsFailing: Boolean;
        HumanResourcesSetup: Record "Human Resources Setup";
        RatingInt: Integer;
        PassMarkInt: Integer;
        AppraisalRatings: Record "Appraisal Ratings";
        ReviewCount: Integer;
    begin
        SendEmail:=true;
        if AppraisalHeader.Get(AppraisalNo)then begin
            AppraisalHeader.Status:=AppraisalHeader.Status::Approved;
            if AppraisalHeader.Modify(true)then begin
                if ReviewPeriod[1].Get(AppraisalHeader."Calendar Code", AppraisalHeader."Review Period")then;
                ReviewPeriod[1].TestField(Description);
                if SendEmail then begin
                    if Employee.Get(AppraisalHeader."Employee No")then begin
                        Clear(Recipients);
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:=StrSubstNo('%1 Appraisal Approval', ReviewPeriod[1].Description);
                        HumanResourcesSetup.Get;
                        AppraisalRatings.Reset;
                        AppraisalRatings.SetRange(Code, HumanResourcesSetup."One Point Eligibility");
                        if AppraisalRatings.FindFirst then // PassMarkInt := AppraisalRatings.Code;   
 AppraisalRatings.Reset;
                        //AppraisalRatings.SetRange("Rating Description", AppraisalHeader."Mid Year Overrall rating");
                        if AppraisalRatings.FindFirst then //  RatingInt := AppraisalRatings.Code;                
 if PassMarkInt <= RatingInt then IsFailing:=true
                            else
                                IsFailing:=false;
                        if not IsFailing then Body:='Dear ' + Format(AppraisalHeader."Employee Name") + ' <br><br>' + Format(AppraisalHeader."Overview Manager Name") + ' has approved your ' + ReviewPeriod[1].Description + ' appraisal for period : ' + Format(AppraisalHeader."Calendar Code") + ' <br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards'
                        else
                            Body:='Dear ' + Format(AppraisalHeader."Employee Name") + ' <br><br>' + ' Your rating at ' + ReviewPeriod[1].Description + ' has fallen short of expectation at ' + '. This is below the expected performance standards.' + ' <br><br>This is a caution. Your performance in the noted areas will need more effort in the next 6 months to avoid moving to a PIP.' + ' Work together with  your line manager to ensure that the scores move up to required expectations. ' + ' <br><br>HR Department is available in case of any support you would require in improving your performance.' + ' <br><br>Regards' + ' <br>Human Resources Department';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure SendAppraisalToAgreementLevel(AppraisalNo: Code[20]; EmployeeNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text): Boolean var
        AppraisalHeader: Record "Appraisal Header";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
        AppraisalKPIsRating: Record "Appraisal KPIs Rating";
        AppraisalBehaviourRating: Record "Appraisal Behaviour Rating";
    begin
        SendEmail:=true;
        if AppraisalHeader.Get(AppraisalNo)then begin
            OnBeforeSendAppraisalToSupervisor(AppraisalHeader, false, false);
            AppraisalHeader.Status:=AppraisalHeader.Status::"Agreement Level";
            AppraisalHeader."Appraisee Agreed":=true;
            if ReviewPeriod[1].Get(AppraisalHeader."Calendar Code", AppraisalHeader."Review Period")then;
            ReviewPeriod[1].TestField(Description);
            if AppraisalHeader.Modify(true)then begin
                AppraisalKPIsRating.Reset;
                AppraisalKPIsRating.SetRange("Appraisal No", AppraisalHeader."No.");
                AppraisalKPIsRating.SetRange("Employee No", AppraisalHeader."Employee No");
                AppraisalKPIsRating.SetRange("Review Period", AppraisalHeader."Review Period");
                if AppraisalKPIsRating.FindSet then begin
                    repeat AppraisalKPIsRating.Agree:=true;
                        AppraisalKPIsRating.Modify(true);
                    until AppraisalKPIsRating.Next = 0;
                end;
                AppraisalBehaviourRating.Reset;
                AppraisalBehaviourRating.SetRange("Appraisal No", AppraisalHeader."No.");
                AppraisalBehaviourRating.SetRange("Employee No", AppraisalHeader."Employee No");
                if AppraisalBehaviourRating.FindSet then begin
                    repeat AppraisalBehaviourRating.Agree:=true;
                        AppraisalBehaviourRating.Modify(true);
                    until AppraisalBehaviourRating.Next = 0;
                end;
                if SendEmail then begin
                    if Employee.Get(AppraisalHeader."Employee No")then begin
                        Clear(Recipients);
                        Recipients.Add(Employee."Company E-Mail");
                        Subject:=StrSubstNo('%1 Appraisal Agreement', ReviewPeriod[1].Description);
                        Body:='Dear ' + Format(AppraisalHeader."Employee Name") + ' <br><br>' + Format(AppraisalHeader."Supervisor Name") + ' has sent your' + ReviewPeriod[1].Description + 'appraisal for period : ' + Format(AppraisalHeader."Calendar Code") + ' to agreement level;<br> Please avail yourself as soon as possible to complete this process' + '<br><br>This is a system generated E-mail, do not reply to it<br> Kind Regards';
                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                end;
            end;
        end;
    end;
    local procedure OnBeforeSendAppraisalToSupervisor(var AppraisalHeader: Record "Appraisal Header"; IsToAgreement: Boolean; IsToOverview: Boolean)
    var
        EmployeeAppraisalKRAs: Record "Appraisal Objectives/KRAs";
        AppraisalKPIsRating: Record "Appraisal KPIs Rating";
        EmployeeAppraisalCompetence: Record "Appraisal Competence";
        EmployeeAppraisalBehaviour: Record "Appraisal Behaviour";
        HumanResourcesSetup: Record "Human Resources Setup";
    begin
        if((AppraisalHeader.Sequence = 0) and (AppraisalHeader.Status in[AppraisalHeader.Status::"Appraisee Level"]))then begin
            EmployeeAppraisalKRAs.Reset;
            EmployeeAppraisalKRAs.SetRange("Appraisal No", AppraisalHeader."No.");
            if EmployeeAppraisalKRAs.FindSet then begin
                HumanResourcesSetup.Get;
                EmployeeAppraisalKRAs.CalcSums("Maximum Weight");
                if EmployeeAppraisalKRAs."Maximum Weight" <> HumanResourcesSetup."KRA Percentage" then Error('KRA weights should add upto %1', HumanResourcesSetup."KRA Percentage")
                else if EmployeeAppraisalKRAs."Maximum Weight" = 0 then Error('You have not set your objectives');
            end;
        end;
    end;
    procedure CloseAppraisalReviewPeriod(var AppraisalReviewPeriod: Record "Appraisal Review Periods"; Close: Boolean)
    var
        AppraisalHeader: Record "Appraisal Header";
        ReviewCount: Integer;
        AppraisalUpdated: Integer;
    begin
        ReviewPeriod[1].Reset;
        ReviewPeriod[1].SetRange("Calendar Code", AppraisalReviewPeriod."Calendar Code");
        if ReviewPeriod[1].FindSet then ReviewCount:=ReviewPeriod[1].Count;
        ReviewPeriod[2].Reset;
        ReviewPeriod[2].SetRange("Calendar Code", AppraisalReviewPeriod."Calendar Code");
        ReviewPeriod[2].SetRange(Sequence, (AppraisalReviewPeriod.Sequence + 1));
        if ReviewPeriod[2].FindFirst then;
        if AppraisalReviewPeriod.Sequence + 1 <= ReviewCount - 1 then begin
            AppraisalHeader.Reset;
            AppraisalHeader.SetRange(Status, AppraisalHeader.Status::Approved);
            AppraisalHeader.SetRange("Review Period", AppraisalReviewPeriod.Code);
            AppraisalHeader.SetRange(Sequence, AppraisalReviewPeriod.Sequence);
            if AppraisalHeader.FindSet then begin
                Window.Open('Updating Appraisal for  #####1', Names);
                repeat AppraisalHeader.Validate("Review Period", ReviewPeriod[2].Code);
                    AppraisalHeader.Sequence:=AppraisalHeader.Sequence + 1;
                    AppraisalHeader.Status:=AppraisalHeader.Status::"Appraisee Level";
                    AppraisalHeader.Modify(true);
                    Window.Update(1, AppraisalHeader."Employee Name");
                    AppraisalUpdated:=AppraisalUpdated + 1;
                until AppraisalHeader.Next = 0;
                Window.Close;
            end;
        end;
        if AppraisalReviewPeriod.Sequence = ReviewCount - 1 then begin
            AppraisalHeader.Reset;
            AppraisalHeader.SetRange(Status, AppraisalHeader.Status::Approved);
            AppraisalHeader.SetRange("Review Period", AppraisalReviewPeriod.Code);
            AppraisalHeader.SetRange(Sequence, AppraisalReviewPeriod.Sequence);
            if AppraisalHeader.FindSet then begin
                Window.Open('Closing Appraisal #####1', Names);
                repeat AppraisalHeader.Validate(Status, AppraisalHeader.Status::Closed);
                    AppraisalHeader."Review Period":='';
                    AppraisalHeader.Sequence:=AppraisalHeader.Sequence + 1;
                    AppraisalHeader.Modify(true);
                    Window.Update(1, AppraisalHeader."No.");
                    AppraisalUpdated:=AppraisalUpdated + 1;
                until AppraisalHeader.Next = 0;
                Window.Close;
            end;
        end;
        if AppraisalUpdated <> 0 then begin
            if Close = true then begin
                AppraisalReviewPeriod.Status:=AppraisalReviewPeriod.Status::Closed;
                AppraisalReviewPeriod.Modify(true);
                if AppraisalReviewPeriod.Sequence <> ReviewCount - 1 then begin
                    ReviewPeriod[2].Status:=ReviewPeriod[2].Status::Open;
                    ReviewPeriod[2].Modify(true);
                end;
                Message('%1 have been successfully closed and %2 Appraisals moved to the next Review Period', AppraisalReviewPeriod.Description, Format(AppraisalUpdated));
            end
            else if Close = false then Message('%1 Appraisals for %2 have been successfully Updated', Format(AppraisalUpdated), AppraisalReviewPeriod.Description);
        end
        else
            Message('%1 have nothing to update', AppraisalReviewPeriod.Description);
    end;
}
