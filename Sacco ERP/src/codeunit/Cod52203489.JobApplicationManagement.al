codeunit 52203489 "Job Application Management"
{
    var CompInfo: Record "Company Information";
    JobRequisition: Record "Job Requisition";
    //Job Application
    procedure SubmitJobApplication(ApplicantNo: Code[20]; RequisitionNo: Code[20]): Code[20]var
        JobApplications: array[2]of Record "Job Application";
        HumanResourcesSetup: Record "Human Resources Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        JobApplicantProfiles: Record Applicant;
        ApplicationNo: Code[20];
        ApplicantQualification: Record "Applicants Qualification";
        EmployeeQualification: Record "Employee Qualification";
        ApplicantWorkExperience: Record "Applicant Current Employment";
        Applicant: Record Applicant;
        JobRequisition: Record "Job Requisition";
    begin
        CompInfo.Get;
        ApplicantQualification.RESET;
        ApplicantQualification.SETRANGE("Applicant No.", ApplicantNo);
        IF NOT ApplicantQualification.FINDFIRST THEN ERROR('Incomplete details on Qualifications');
        ApplicantWorkExperience.RESET;
        ApplicantWorkExperience.SETRANGE("Applicant No.", ApplicantNo);
        IF NOT ApplicantWorkExperience.FINDFIRST THEN ERROR('Incomplete deatils on Work Experience');
        IF JobApplicantProfiles.GET(ApplicantNo)THEN BEGIN
            JobApplications[2].Reset();
            JobApplications[2].SetRange("Applicant No.", ApplicantNo);
            JobApplications[2].SetRange("Requisition No.", RequisitionNo);
            if not JobApplications[2].FindFirst then begin
                HumanResourcesSetup.GET;
                HumanResourcesSetup.TESTFIELD("Job Application Nos");
                ApplicationNo:=NoSeriesManagement.GetNextNo(HumanResourcesSetup."Job Application Nos", 0D, TRUE);
                JobApplications[1].INIT;
                JobApplications[1]."No.":=ApplicationNo;
                JobApplications[1].Status:=JobApplications[1].Status::Application;
                JobApplications[1].Validate("Applicant No.", ApplicantNo);
                JobApplications[1].Validate("Requisition No.", RequisitionNo);
                JobApplications[1]."Created By":=UserId;
                IF JobApplications[1].INSERT then JobApplicationNotification(JobApplications[1]);
                if Applicant.Get(ApplicantNo)then begin
                    if JobRequisition.Get(RequisitionNo)then begin
                        Applicant.Validate("Job ID", JobRequisition."Job ID");
                        Applicant."Vacany No.":=JobRequisition."No.";
                        Applicant.Modify(true);
                    end;
                end;
                EXIT(ApplicationNo);
            end
            else
                Error('You have already submitted application for this postion');
        end;
    end;
    //Job Longlisting
    procedure GetLongListedApplicants(JobShortlisting: Record "Job Shortlisting")
    var
        JobApplications: Record "Job Application";
        DidNotPassHighPriorityReq: Boolean;
        DidNotPassMediumPriorityReq: Boolean;
        DidNotPassLowPriorityReq: Boolean;
        HighPriorityReqExist: Boolean;
        MediumPriorityReqExist: Boolean;
        LowPriorityReqExist: Boolean;
        ReqWithAttachementExist: Boolean;
        DidNotProvedAttachements: Boolean;
        QualifiedCount: Integer;
        ApplicantsCount: Integer;
        HRJobs: Record "Company Jobs";
        PassMark: Decimal;
        TotalScore: Decimal;
        JobReqSpecifications: Record "Job Qualifications";
        QualificationCriteria: Record "Job Shortlisting Criteria";
        CheckAge: Boolean;
        CheckGender: Boolean;
        CheckExperience: Boolean;
    begin
        QualifiedCount:=0;
        WITH JobShortlisting DO BEGIN
            CheckAge:=FALSE;
            CheckGender:=FALSE;
            CheckExperience:=FALSE;
            If "Age Limit" <> '' then CheckAge:=true;
            if "Preferred Gender" <> "Preferred Gender"::" " then CheckGender:=true;
            If "Work Experience" <> 0 then CheckExperience:=TRUE;
            PassMark:="Pass Mark";
            JobApplications.RESET;
            JobApplications.SETRANGE("Requisition No.", JobShortlisting."Requisition No.");
            JobApplications.SETFILTER(Status, '%1|%2|%3|%4', JobApplications.Status::Application, JobApplications.Status::Unsuccessful, JobApplications.Status::"Long Listed", JobApplications.Status::Shortlisted);
            IF JobApplications.FINDSET THEN BEGIN
                ApplicantsCount:=JobApplications.Count;
                REPEAT //Experience
 IF CheckExperience and not CheckIfApplicantMeetsExperienceRequirement(JobShortlisting, JobApplications."Applicant No.")then MarkApplicantAsNotQualified(JobApplications, 'Experiece')
                    else //Age
 if CheckAge and not CheckIfApplicantMeetsAgeRequirement(JobShortlisting, JobApplications."Applicant No.")then MarkApplicantAsNotQualified(JobApplications, 'Age')
                        else // Gender
 if CheckGender and not CheckIfApplicantMeetsGenderRequirement(JobShortlisting, JobApplications."Applicant No.")then MarkApplicantAsNotQualified(JobApplications, 'Gender')
                            else //Qualifications
 if(PassMark <> 0) and not CheckIfApplicantMeetsRequirements(JobShortlisting, JobApplications."Applicant No.")then MarkApplicantAsNotQualified(JobApplications, 'Qualifications')
                                else
                                begin
                                    MarkApplicantAsQualified(JobApplications);
                                    QualifiedCount+=1;
                                end;
                UNTIL JobApplications.NEXT = 0;
            END;
        END;
        MESSAGE('Qualified Applicants are %1 \ Unqualified Applicants are %2', QualifiedCount, (ApplicantsCount - QualifiedCount));
    end;
    local procedure CheckIfApplicantMeetsRequirements(JobShortlist: Record "Job Shortlisting"; ApplicantNo: Code[20]): Boolean var
        JobReqSpecifications: Record "Job Qualifications";
        ApplicantQualification: Record "Applicants Qualification";
        JobApplications: Record "Job Application";
        JobRequisition: Record "Job Requisition";
    begin
        JobRequisition.GET(JobShortlist."Requisition No.");
        JobReqSpecifications.RESET;
        JobReqSpecifications.SETRANGE("Job Id", JobRequisition."Job Id");
        IF JobReqSpecifications.FINDSET THEN BEGIN
            REPEAT ApplicantQualification.RESET;
                ApplicantQualification.SETRANGE("Applicant No.", ApplicantNo);
                ApplicantQualification.SETRANGE("Qualification Type", JobReqSpecifications."Qualification Type");
                ApplicantQualification.SETRANGE("Qualification Code", JobReqSpecifications."Qualification Code");
                IF ApplicantQualification.FINDFIRST THEN EXIT(TRUE);
            UNTIL JobReqSpecifications.NEXT = 0;
        END;
        EXIT(FALSE);
    end;
    local procedure MarkApplicantAsQualified(JobApplication: Record "Job Application")
    begin
        WITH JobApplication DO BEGIN
            VALIDATE(Status, JobApplication.Status::"Long Listed");
            Remark:='Qualified for the next Level';
            MODIFY(TRUE);
        END;
    end;
    procedure MarkApplicantAsNotQualified(JobApplication: Record "Job Application"; Reason: Text)
    begin
        WITH JobApplication DO BEGIN
            VALIDATE(Status, JobApplication.Status::Unsuccessful);
            Remark:=StrSubstNo('Disqualified for the next level bacause of %1', UpperCase(Reason));
            MODIFY(TRUE);
        END;
    end;
    local procedure CheckIfApplicantMeetsAgeRequirement(JobShortlisting: Record "Job Shortlisting"; ApplicantNo: Code[20]): Boolean var
        Applicant: Record Applicant;
        ApplicantAge: Integer;
    begin
        // Applicant.GET(ApplicantNo);
        // ApplicantAge := Today - Applicant."Birth Date";
        // if(ApplicantAge,)
        exit(true);
    end;
    local procedure CheckIfApplicantMeetsGenderRequirement(JobShortlisting: Record "Job Shortlisting"; ApplicantNo: Code[20]): Boolean var
        Applicant: Record Applicant;
    begin
        Applicant.Get(ApplicantNo);
        if Applicant.Gender = JobShortlisting."Preferred Gender" then exit(true)
        else
            exit(false);
    end;
    local procedure CheckIfApplicantMeetsExperienceRequirement(JobShortlisting: Record "Job Shortlisting"; ApplicantNo: Code[20]): Boolean begin
        if GetTotalWorkExperience(ApplicantNo) >= JobShortlisting."Work Experience" then exit(true)
        else
            exit(false);
    end;
    local procedure GetTotalWorkExperience(ApplicationNo: Code[20]): Decimal var
        ApplicantWorkExperience: Record "Applicant Current Employment";
        StartDate: Date;
        EndDate: Date;
        Applicant: Record Applicant;
    begin
        ApplicantWorkExperience.RESET;
        ApplicantWorkExperience.SETRANGE("Applicant No.", ApplicationNo);
        ApplicantWorkExperience.SETFILTER("From Date", '<>%1', 0D);
        ApplicantWorkExperience.SETCURRENTKEY("From Date");
        ApplicantWorkExperience.SETASCENDING("From Date", TRUE);
        IF ApplicantWorkExperience.FINDFIRST THEN StartDate:=ApplicantWorkExperience."From Date";
        ApplicantWorkExperience.RESET;
        ApplicantWorkExperience.SETRANGE("Applicant No.", ApplicationNo);
        ApplicantWorkExperience.SETFILTER("To Date", '<>%1', 0D);
        ApplicantWorkExperience.SETCURRENTKEY("To Date");
        ApplicantWorkExperience.SETASCENDING("To Date", TRUE);
        IF ApplicantWorkExperience.FINDLAST THEN EndDate:=ApplicantWorkExperience."To Date";
        ApplicantWorkExperience.RESET;
        ApplicantWorkExperience.SETRANGE("Applicant No.", ApplicationNo);
        ApplicantWorkExperience.SETFILTER("To Date", '=%1', 0D);
        ApplicantWorkExperience.SETRANGE("Currently Employment", TRUE);
        IF ApplicantWorkExperience.FINDFIRST THEN EndDate:=TODAY;
        if Applicant.Get(ApplicationNo)then begin
            Applicant."Years Of Experience":=Round(((EndDate - StartDate) / 365), 1);
            Applicant.Modify(true);
        end;
        EXIT((EndDate - StartDate) / 365);
    end;
    procedure CloseLonglisting(JobShortListing: Record "Job Shortlisting")
    var
        JobApplications: Record "Job Application";
        ShortlistedApplicants: Record "Job Shortlisted Applicants";
    begin
        if not Confirm(StrSubstNo('You are about to Close %1, Do you wish to continue?', JobShortListing."No."), false)then exit
        else
        begin
            JobShortListing.Type:=JobShortListing.Type::"Short List";
            JobShortListing.Modify(true);
            //VOKOTH: Update Corresponding Applications
            ShortlistedApplicants.Reset();
            ShortlistedApplicants.SetRange("No.", JobShortListing."No.");
            If ShortlistedApplicants.FindSet()then begin
                repeat OnAfterShortlist(ShortlistedApplicants, true)until ShortlistedApplicants.Next() = 0;
            end;
        end;
    end;
    procedure ReOpenLonglisting(JobShortListing: Record "Job Shortlisting")
    begin
        if not Confirm(StrSubstNo('You are about to reopen %1, Do you wish to continue?', JobShortListing."No."), false)then exit
        else
        begin
            JobShortListing.Type:=JobShortListing.Type::"Long List";
            JobShortListing.Modify(true);
        end;
    end;
    //ShortListing
    procedure Shortlisting(JobShortListing: Record "Job Shortlisting")
    var
        ShortlistingCliteria: Record "Job Shortlisting Criteria";
        ShortlistingApplicants: Record "Job Shortlisted Applicants";
        JobApplications: Record "Job Application";
        ApplicantQualifications: Record "Applicants Qualification";
    begin
        JobShortListing.TestField("Pass Mark");
        ClearShortlistedApplicants(JobShortListing);
        GenerateShortlistingEntries(JobShortListing);
        ShortlistingCliteria.Reset();
        ShortlistingCliteria.SetRange("No.", JobShortListing."No.");
        ShortlistingCliteria.Setfilter(Score, '<>0', 0);
        If ShortlistingCliteria.FindSet()then begin
            repeat ApplicantQualifications.Reset();
                ApplicantQualifications.SetRange("Qualification Type", ShortlistingCliteria."Qualification Type");
                ApplicantQualifications.SetRange("Qualification Code", ShortlistingCliteria."Qualification Code");
                if ApplicantQualifications.FindSet()then begin
                    repeat if ShortlistingApplicants.Get(JobShortListing."No.", ApplicantQualifications."Applicant No.")then begin
                            ShortlistingApplicants.Score:=ShortlistingApplicants.Score + ShortlistingCliteria.Score;
                            ShortlistingApplicants.Modify(true);
                        end;
                    until ApplicantQualifications.Next = 0;
                end;
            until ShortlistingCliteria.Next() = 0;
        end;
        GetQualifiedShortslists(JobShortListing);
        Message('Shortlisting Completed');
    end;
    local procedure GenerateShortlistingEntries(JobShortListing: Record "Job Shortlisting")
    var
        JobApplications: Record "Job Application";
        ShortlistingApplicants: Record "Job Shortlisted Applicants";
    begin
        JobApplications.Reset();
        JobApplications.SetRange("Requisition No.", JobShortListing."Requisition No.");
        JobApplications.SetFilter(Status, '%1|%2|%3', JobApplications.Status::"Long Listed", JobApplications.Status::Shortlisted, JobApplications.Status::Unsuccessful);
        if JobApplications.FindSet then begin
            ShortlistingApplicants.Init();
            ShortlistingApplicants."No.":=JobShortListing."No.";
            ShortlistingApplicants."Application No.":=JobApplications."No.";
            ShortlistingApplicants.Validate("Applicant No.", JobApplications."Applicant No.");
            ShortlistingApplicants.Validate("Requisition No.", JobApplications."Requisition No.");
            ShortlistingApplicants.Insert(true);
        end;
    end;
    local procedure GetQualifiedShortslists(JobShortListing: Record "Job Shortlisting")
    var
        ShortlistedApplicants: Record "Job Shortlisted Applicants";
    begin
        ShortlistedApplicants.Reset();
        ShortlistedApplicants.SetRange("No.", JobShortListing."No.");
        If ShortlistedApplicants.FindSet()then begin
            repeat If((ShortlistedApplicants.Score) < (JobShortListing."Pass Mark"))then OnAfterShortlist(ShortlistedApplicants, false)
                else
                    OnAfterShortlist(ShortlistedApplicants, true)until ShortlistedApplicants.Next() = 0;
        end;
    end;
    local procedure ClearShortlistedApplicants(JobShortListing: Record "Job Shortlisting")
    var
        ShortlistedApplicants: Record "Job Shortlisted Applicants";
    begin
        ShortlistedApplicants.Reset();
        ShortlistedApplicants.SetRange("No.", JobShortListing."No.");
        ShortlistedApplicants.DeleteAll(true);
    end;
    local procedure OnAfterShortlist(ShortlistedApplicants: Record "Job Shortlisted Applicants"; Qaulified: Boolean)
    var
        JobApplication: Record "Job Application";
    begin
        JobApplication.Reset();
        JobApplication.SetRange("Applicant No.", ShortlistedApplicants."Applicant No.");
        JobApplication.SetRange("Requisition No.", ShortlistedApplicants."Requisition No.");
        JobApplication.SetFilter(Status, '%1|%2|%3', JobApplication.Status::"Long Listed", JobApplication.Status::Shortlisted, JobApplication.Status::Unsuccessful);
        if JobApplication.FindFirst()then begin
            if Qaulified then begin
                JobApplication.Status:=JobApplication.Status::Shortlisted;
                JobApplication.Remark:='Qualified for the next level';
            end
            else
            begin
                JobApplication.Status:=JobApplication.Status::Unsuccessful;
                JobApplication.Remark:='Disqualified for the next level bacause of not attaining SHORTLISTING PASS MARK';
            end;
            JobApplication.Score:=ShortlistedApplicants.Score;
            JobApplication.Modify(true);
        end;
    end;
    procedure CloseShortlisting(JobShortListing: Record "Job Shortlisting")
    var
        ShortlistingApplicants: Record "Job Shortlisted Applicants";
        JobApplication: Record "Job Application";
    begin
        if not Confirm(StrSubstNo('You are about to Close %1, Do you wish to continue?', JobShortListing."No."), false)then exit
        else
        begin
            JobRequisition.Get(JobShortListing."Requisition No.");
            JobRequisition.Shortlisted:=true;
            JobShortListing.Modify(true);
            JobShortListing.Status:=JobShortListing.Status::Closed;
            JobShortListing.Modify(true);
            ShortlistingApplicants.Reset();
            ShortlistingApplicants.SetRange("No.", JobShortListing."No.");
            if ShortlistingApplicants.FindSet()then begin
                repeat JobApplication.Get(ShortlistingApplicants."Application No.");
                    ShortListingRegretNotification(JobShortListing, JobApplication);
                until ShortlistingApplicants.Next() = 0;
            end;
        end;
    end;
    procedure ReOpenShortlisting(JobShortListing: Record "Job Shortlisting")
    begin
        if not Confirm(StrSubstNo('You are about to Reopen %1, Do you wish to continue?', JobShortListing."No."), false)then exit
        else
        begin
            JobShortListing.Status:=JobShortListing.Status::Open;
            JobShortListing.Modify(true);
        end;
    end;
    //Job Advertisement
    procedure JobAdvertisement(JobRequisition: Record "Job Requisition")
    begin
        if Confirm(StrSubstNo('You are about to Advertise %1, Do you wish to continue?', JobRequisition."No."), false) = false then exit
        else
        begin
            JobRequisition."Advertisement Status":=JobRequisition."Advertisement Status"::Open;
            //JobRequisition."Advertisement Registration Date" := CurrentDateTime;
            JobRequisition."Advertisement Date":=Today;
            JobRequisition.Modify(true);
        end;
    end;
    procedure JobRe_Advertisement(JobRequisition: Record "Job Requisition")
    begin
        if Confirm(StrSubstNo('You are about to Re-Advertise %1, Do you wish to continue?', JobRequisition."No."), false) = false then exit
        else
        begin
            JobRequisition."Advertisement Status":=JobRequisition."Advertisement Status"::Open;
            JobRequisition.Modify(true);
        end;
    end;
    procedure CloseJobAdvertisement(JobRequisition: Record "Job Requisition")
    begin
        if Confirm(StrSubstNo('You are about to Close Advertisement %1, Do you wish to continue?', JobRequisition."No."), false) = false then exit
        else
        begin
            JobRequisition."Advertisement Status":=JobRequisition."Advertisement Status"::Closed;
            JobRequisition.Modify(true);
        end;
    end;
    //Interview
    procedure SendInterviewEmailInvitations(JobInterview: Record "Job Interview")
    var
        InterviewApplicants: Record "Job Interview Applicants";
    begin
        if Confirm(StrSubstNo('You are about to invite applicants for Interview, Do you wish to continue?', JobInterview."No."), false)then begin
            if JobInterview.Subsequent then JobInterview.TestField("Subsequent Interview Mail");
            InterviewApplicants.Reset();
            InterviewApplicants.SetRange("No.", JobInterview."No.");
            if InterviewApplicants.FindSet()then begin
                repeat InterviewApplicants.Testfield("Interview Date");
                    InterviewApplicants.Testfield("Interview Time");
                    InterviewApplicants.Testfield("Interview Venue");
                    InterviweeEmailInvitation(InterviewApplicants, JobInterview);
                until InterviewApplicants.Next = 0;
            end
            else
                Error(StrSubstNo('There is no Applicant to invite for this Interview %1'), JobInterview."No.");
            JobInterview.Status:=JobInterview.Status::Open;
            JobInterview.Modify(true);
        end;
    end;
    procedure AssignInterviewers(JobInterview: Record "Job Interview")
    var
        CommitteeMembers: array[3]of Record "Committee Members";
        InterviewApplicant: array[3]of Record "Job Interview Applicants";
        InterviewRating: array[3]of Record "Job Interview Rating";
    begin
        if Confirm(StrSubstNo('You are about to Assign Interviewers for %1, Do you wish to continue?', JobInterview."No."), false)then begin
            JobInterview.TestField(Committee);
            JobInterview.TestField(Status, JobInterview.Status::Created);
            //Check Committee Members
            CommitteeMembers[1].Reset();
            CommitteeMembers[1].SetRange(Committee, JobInterview.Committee);
            if not CommitteeMembers[1].FindFirst then Error('Interview Committee Members must be defined first');
            //Delete Existing Lines
            InterviewApplicant[1].Reset;
            InterviewApplicant[1].SetRange("No.", JobInterview."No.");
            InterviewApplicant[1].DeleteAll;
            //Delete Existing Ratings Lines
            InterviewRating[1].Reset;
            InterviewRating[1].SetRange("No.", JobInterview."No.");
            InterviewRating[1].DeleteAll;
            GenerateInterviewApplicants(JobInterview);
            InterviewApplicant[2].Reset();
            InterviewApplicant[2].SetRange("No.", JobInterview."No.");
            if InterviewApplicant[2].FindSet()then begin
                repeat CommitteeMembers[2].Reset;
                    CommitteeMembers[2].SetRange(Committee, JobInterview.Committee);
                    if CommitteeMembers[2].FindSet then begin
                        repeat InterviewRating[2].Init();
                            InterviewRating[2]."No.":=JobInterview."No.";
                            InterviewRating[2].Validate("Applicant No", InterviewApplicant[2]."Applicant No.");
                            InterviewRating[2].Validate(Interviewer, CommitteeMembers[2].Code);
                            InterviewRating[2].Insert(true);
                        until CommitteeMembers[2].Next = 0;
                    end;
                until InterviewApplicant[2].Next() = 0;
            end;
            CommitteeMembers[3].Reset();
            CommitteeMembers[3].SetRange(Committee, JobInterview.Committee);
            if CommitteeMembers[3].FindSet()then begin
                repeat InterviewerInvitationEmail(JobInterview, CommitteeMembers[3]);
                until CommitteeMembers[3].Next() = 0;
            end;
        end;
    end;
    local procedure GenerateInterviewApplicants(JobInterview: Record "Job Interview")
    var
        JobApplication: Record "Job Application";
        InterviewApplicant: Record "Job Interview Applicants";
    begin
        JobApplication.Reset;
        JobApplication.SetRange("Requisition No.", JobInterview."Requisition No.");
        JobApplication.SetRange(Status, JobApplication.Status::Shortlisted);
        if JobApplication.FindSet()then begin
            repeat //Add Interview Applicants Lines
 InterviewApplicant.Init;
                InterviewApplicant."No.":=JobInterview."No.";
                InterviewApplicant.Validate("Requisition No.", JobApplication."Requisition No.");
                InterviewApplicant.Validate("Application No.", JobApplication."No.");
                InterviewApplicant.Validate("Applicant No.", JobApplication."Applicant No.");
                InterviewApplicant.Insert(true);
            until JobApplication.Next = 0;
        end
        else
            Error(StrSubstNo('There is no Applicant shortlisted for this Requisition %1'), JobInterview."Requisition No.");
    end;
    procedure GetQualifiedInterviwee(JobInterview: Record "Job Interview")
    var
        InterviewApplicants: Record "Job Interview Applicants";
        JobApplications: Record "Job Application";
    begin
        if Confirm(StrSubstNo('You are about to Assign Interviers for %1, Do you wish to continue?', JobInterview."No."), false)then begin
            JobInterview.TestField("Pass Mark");
            CalculateInterviweeScores(JobInterview);
            InterviewApplicants.Reset();
            InterviewApplicants.SetRange("No.", JobInterview."No.");
            If InterviewApplicants.FindSet()then begin
                repeat if InterviewApplicants.Score < JobInterview."Pass Mark" then begin
                        OnAfterInterviewRating(InterviewApplicants, false);
                        InterviewApplicants.Qualified:=false;
                        InterviewApplicants.Modify(true);
                    end
                    else
                    begin
                        OnAfterInterviewRating(InterviewApplicants, true);
                        InterviewApplicants.Qualified:=true;
                        InterviewApplicants.Modify(true);
                    end;
                until InterviewApplicants.Next() = 0;
            end
            else
                Error(StrSubstNo('There is no Applicant to rate for this Interview %1'), JobInterview."No.");
        end;
    end;
    local procedure OnAfterInterviewRating(InterviewApplicants: Record "Job Interview Applicants"; Qualified: Boolean)
    var
        JobApplication: Record "Job Application";
    begin
        JobApplication.Reset();
        JobApplication.SetRange("Applicant No.", InterviewApplicants."Applicant No.");
        JobApplication.SetRange("Requisition No.", InterviewApplicants."Requisition No.");
        JobApplication.SetFilter(Status, '%1|%2|%3', JobApplication.Status::Interview, JobApplication.Status::Shortlisted, JobApplication.Status::Unsuccessful);
        if JobApplication.FindFirst()then begin
            if Qualified then begin
                JobApplication.Status:=JobApplication.Status::Interview;
                JobApplication.Remark:='Qualified for the next level';
            end
            else
            begin
                JobApplication.Status:=JobApplication.Status::Unsuccessful;
                JobApplication.Remark:='Disqualified for the next level bacause for failing to attain INTERVIEW PASS MARK';
            end;
            JobApplication.Score:=InterviewApplicants.Score;
            JobApplication.Modify(true);
        end;
    end;
    local procedure CalculateInterviweeScores(JobInterview: Record "Job Interview")
    var
        InterviewRating: Record "Job Interview Rating";
        InterviewApplicant: Record "Job Interview Applicants";
    begin
        InterviewApplicant.Reset();
        InterviewApplicant.SetRange("No.", JobInterview."No.");
        if InterviewApplicant.FindSet()then begin
            repeat InterviewRating.Reset();
                InterviewRating.SetRange("No.", JobInterview."No.");
                InterviewRating.SetRange("Applicant No", InterviewApplicant."Applicant No.");
                if InterviewRating.FindSet()then begin
                    InterviewRating.CalcSums(Marks);
                    InterviewApplicant.Score:=Round((InterviewRating.Marks / GetNoOfInterviwers(JobInterview)), 1);
                    InterviewApplicant.Modify(true);
                end;
            until InterviewApplicant.Next() = 0;
        end;
    end;
    local procedure GetNoOfInterviwers(JobInterview: Record "Job Interview"): Decimal var
        CommitteeMembers: Record "Committee Members";
    begin
        CommitteeMembers.Reset();
        CommitteeMembers.SetRange(Committee, JobInterview.Committee);
        exit(CommitteeMembers.Count);
    end;
    procedure "Close&CreateNextInterview"(JobInterview: Record "Job Interview")
    var
        HumanResourcesSetup: Record "Human Resources Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        JobInterview_: Record "Job Interview";
    begin
        if Confirm(StrSubstNo('You are about to close %1 and create a Subsequent interview, Do you wish to continue?', JobInterview."No."), false)then begin
            HumanResourcesSetup.GET;
            HumanResourcesSetup.TESTFIELD("Job Application Nos");
            JobInterview_.Init();
            JobInterview_."No.":=NoSeriesManagement.GetNextNo(HumanResourcesSetup."Job Application Nos", 0D, TRUE);
            JobInterview_."Created By":=UserId;
            JobInterview_."Closed Date":=WorkDate;
            JobInterview_.Validate("Shortlisting No.", JobInterview."Shortlisting No.");
            JobInterview_."Previous Interview":=JobInterview."No.";
            JobInterview_.Subsequent:=true;
            JobInterview_.Insert;
            OnBeforeCloseInterview(JobInterview, true);
            OnAfterCloseInterview(JobInterview);
            Page.Run(Page::"Job Interview", JobInterview_);
        end;
    end;
    local procedure OnBeforeCloseInterview(JobInterview: Record "Job Interview"; Subsequent: Boolean)
    var
        JobApplication: Record "Job Application";
        InterviewApplicants: Record "Job Interview Applicants";
        Applicant: Record Applicant;
    begin
        InterviewApplicants.Reset();
        InterviewApplicants.SetRange("No.", JobInterview."No.");
        if InterviewApplicants.FindSet then begin
            repeat JobApplication.Reset();
                JobApplication.SetRange("Applicant No.", InterviewApplicants."Applicant No.");
                if JobApplication.FindFirst()then begin
                    Applicant.Get(JobApplication."Applicant No.");
                    if InterviewApplicants.Qualified then begin
                        // if not Subsequent then begin
                        JobApplication.Status:=JobApplication.Status::"Offer Letter";
                        JobApplication.Remark:='Qualified for the next level';
                        RemunerationResumptionDateDiscussion(JobInterview, JobApplication);
                        Applicant.Validate("Job ID", JobApplication."Job ID");
                        Applicant.Validate("Offer Status", Applicant."Offer Status"::"Offer Made");
                        Applicant.Modify(true);
                    //end;
                    end
                    else
                    begin
                        JobApplication.Status:=JobApplication.Status::Unsuccessful;
                        JobApplication.Remark:='Disqualified for the next level bacause for failing to attain INTERVIEW PASS MARK';
                        InterviewRegretNotification(JobInterview, JobApplication);
                        Applicant.Validate("Offer Status", Applicant."Offer Status"::Failed);
                        Applicant.Modify(true);
                    end;
                    JobApplication.Score:=InterviewApplicants.Score;
                    JobApplication.Modify(true);
                end;
            until InterviewApplicants.Next() = 0;
        end;
    end;
    procedure CloseInterview(JobInterview: Record "Job Interview")
    begin
        if Confirm(StrSubstNo('You are about to Close Interview %1, Do you wish to continue?', JobInterview."No."), false)then begin
            JobInterview.TestField("Discussion Date");
            JobInterview.TestField("Discussion Time");
            OnBeforeCloseInterview(JobInterview, false);
            OnAfterCloseInterview(JobInterview);
        end;
    end;
    local procedure OnAfterCloseInterview(JobInterview: Record "Job Interview")
    var
        Shortlisting: Record "Job Shortlisting";
    begin
        If Shortlisting.Get(JobInterview."Shortlisting No.")then begin
            Shortlisting."Interview Conducted":=true;
            Shortlisting.Modify(true);
        end;
        JobInterview.Status:=JobInterview.Status::Closed;
        JobInterview."Closed By":=UserId;
        JobInterview."Closed Date":=WorkDate;
        JobInterview.Modify(true);
    end;
    procedure JobApplicationNotification(Application: Record "Job Application")
    var
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
        Body: Text;
        Recepients: List of[Text];
        Subject: Text;
        Applicant: Record Applicant;
        JobRequisition: Record "Job Requisition";
    begin
        CompInfo.Get;
        Applicant.Get(Application."Applicant No.");
        JobRequisition.Get(Application."Requisition No.");
        Body:='';
        Clear(Recepients);
        Recepients.Add(Applicant."E-Mail");
        Subject:='Job Application';
        Body+=StrSubstNo('Dear %1', Applicant.FullName);
        Body+='<br><br>';
        Body+=StrSubstNo('Thank you for your application for Industrial Relations Officer, reference number %1', JobRequisition."No.");
        Body+='<br><br>';
        Body+='We are in the process of reviewing with full attention all applications to this vacancy';
        Body+='<br><br>';
        Body+='Provided that your skills correspond with our requirements, a member of our team will contact you via e-mail or telephone. However, Please note that due to the high number of applications received, only shortlisted candidates will be contacted. ';
        Body+='<br><br>';
        Body+=StrSubstNo('In addition, we invite you to regularly search and apply for additional opportunities on our career site. Thank you for your interest in working with %1', CompInfo.Name);
        Body+='<br><br>';
        Body+='<br><br>';
        Body+='Thank you.';
        Body+='<br><br>';
        Body+='Yours Sincerely,';
        Body+='<br><br>';
        Body+='<b>Human Resource</b>';
        Body+='<br>';
        Body+=StrSubstNo('<b>%1</b>', CompInfo.Name);
        Body+='<br>';
        Body+='<br><br>NOTE:  THIS MESSAGE IS SYSTEM RATED.  PLEASE DO NO REPLY TO THIS MESSAGE.';
        Mail.Create(Recepients, Subject, Body, true);
        Email.Send(Mail);
    end;
    procedure ShortListingRegretNotification(JobShortlisting: Record "Job Shortlisting"; JobApplication: Record "Job Application")
    var
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
        Body: Text;
        Applicant: Record Applicant;
        Recepients: List of[Text];
    begin
        Body:='';
        Clear(Recepients);
        CompInfo.Get;
        Applicant.Get(JobApplication."Applicant No.");
        Applicant.TestField("E-Mail");
        Recepients.Add(Applicant."E-Mail");
        Body:='Dear, ' + JobApplication."First Name";
        Body+='<br><br>';
        Body+='We appreciate your interest in the ' + JobShortlisting."Job Title" + ' Position at ' + CompInfo.Name;
        Body+='<br><br>';
        Body+='However, we regret to inform you that your application was unsuccessful, as we have had to make a difficult choice between many candidates for the position.';
        Body+='<br>';
        Body+=StrSubstNo('Reason: (%1)', JobApplication.Remark);
        Body+='<br>';
        Body+='We do appreciate you taking the time to apply for the role and also encourage you to apply for other openings at the company in the future.';
        Body+='Again, thank you so much for your time.';
        Body+='<br><br>';
        Body+='Yours Sincerely,';
        Body+='<br><br>';
        Body+='<b>Human Resources and Administration<b>';
        Body+='<br>';
        Body+=CompInfo.Name;
        Mail.Create(Recepients, 'Regret', Body, true);
        Email.Send(Mail);
    end;
    procedure InterviweeEmailInvitation(InterviewApplicants: Record "Job Interview Applicants"; JobInterview: Record "Job Interview")
    var
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
        Body: Text;
        Applicant: Record Applicant;
        Recepients: List of[Text];
    begin
        Body:='';
        Clear(Recepients);
        CompInfo.Get;
        Applicant.Get(InterviewApplicants."Applicant No.");
        Applicant.TestField("E-Mail");
        Recepients.Add(Applicant."E-Mail");
        Body:='Dear, ' + InterviewApplicants."First Name";
        Body+='<br><br>';
        if JobInterview.Subsequent then begin
            Body+='Thank you for your interest in the ' + InterviewApplicants."Job Title" + ' Position at ' + CompInfo.Name;
            Body+='<br><br>';
            Body+='We are pleased to invite you for an interview:';
        end
        else
            Body+=JobInterview."Subsequent Interview Mail";
        Body+='<br>';
        Body+='<ul>';
        Body+='<li>Venue:' + InterviewApplicants."Interview Venue" + '</li>';
        Body+='<li>Date' + Format(InterviewApplicants."Interview Date") + '</li>';
        Body+='<li>Time:' + Format(InterviewApplicants."Interview Time") + '</li>';
        Body+='<br>';
        Body+='</ul>';
        Body+='<br>';
        Body+='Please carry the following:';
        Body+='<br>';
        Body+='<ul>';
        Body+='<li>Your original ID</li>';
        Body+='<li>A copy of your ID</li>';
        Body+='<li>Your certificates including KCSE</li>';
        Body+='<li>•	A set of copies of your certificates including KCSE</li>';
        Body+='<br>';
        Body+='</ul>';
        Body+='Kindly confirm receipt of this mail and confirm your availability. Please let me know if you require any clarification';
        Body+='<br><br>';
        Body+='Regards';
        Body+='<br><br>';
        Body+='<b>Human Resources and Administration<b>';
        Body+='<br>';
        Body+=CompInfo.Name;
        Mail.Create(Recepients, 'Invitation for Interview', Body, true);
        Email.Send(Mail);
    end;
    procedure InterviewerInvitationEmail(JobInterview: Record "Job Interview"; CommitteeMembers: Record "Committee Members")
    var
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
        Body: Text;
        Employee: Record Employee;
        Recepients: List of[Text];
    begin
        Body:='';
        Clear(Recepients);
        CompInfo.Get;
        Employee.Get(CommitteeMembers.Code);
        Employee.TestField("Company E-Mail");
        Recepients.Add(Employee."Company E-Mail");
        Body:='Hello, ' + Employee."First Name";
        Body+='<br><br>';
        Body+=StrSubstNo('You have been requested to participate in an interview for %1 as an interviewer', JobInterview."Job Title");
        Body+='<br><br>';
        Body+='Kindly acknowledge the receipt of this e-mail and confirm your availability.';
        Body+='<br><br>';
        Body+='For more information kindly contact HR Office.';
        Body+='<br><br>';
        Body+='Thank you.';
        Body+='<br><br>';
        Body+='Yours Sincerely,';
        Body+='<br><br>';
        Body+='<b>Human Resources and Administration<b>';
        Body+='<br>';
        Body+=CompInfo.Name;
        Mail.Create(Recepients, 'Invitation for Interview', Body, true);
        Email.Send(Mail);
    end;
    procedure InterviewRegretNotification(JobInterview: Record "Job Interview"; JobApplication: Record "Job Application")
    var
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
        Body: Text;
        Applicant: Record Applicant;
        Recepients: List of[Text];
        JobInterviewApplicants: Record "Job Interview Applicants";
    begin
        Body:='';
        Clear(Recepients);
        CompInfo.Get;
        Applicant.Get(JobApplication."Applicant No.");
        Applicant.TestField("E-Mail");
        Recepients.Add(Applicant."E-Mail");
        if JobInterviewApplicants.Get(JobInterview."No.", JobApplication."Applicant No.")then;
        Body:='Dear, ' + JobApplication."First Name";
        Body+='<br><br>';
        Body+='The above subject matter refers.';
        Body+='<br>';
        Body+=StrSubstNo('We take this opportunity to thank you for attending our interview on %1 ', Format(JobInterviewApplicants."Interview Date"));
        Body+='We really appreciated the discussions and your competencies were well demonstrated. ';
        Body+='However, another candidate made a better fit for selection for the role and as such, ';
        Body+='I regret to inform you that you that you were unsuccessful. ';
        Body+='That said, we noted your strengths and will retain your documentation for consideration if a suitable position arises in the near future.';
        Body+='<br>';
        Body+='Once again thanks for your interest in working with FKE and we wish you well in your career plans.';
        Body+='<br><br>';
        Body+='Regards,';
        Body+='<br><br>';
        Body+='<b>Human Resources and Administration<b>';
        Body+='<br>';
        Body+=CompInfo.Name;
        Mail.Create(Recepients, 'Regret', Body, true);
        Email.Send(Mail);
    end;
    procedure RemunerationResumptionDateDiscussion(JobInterview: Record "Job Interview"; JobApplication: Record "Job Application")
    var
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
        Body: Text;
        Applicant: Record Applicant;
        Recepients: List of[Text];
    begin
        Body:='';
        Clear(Recepients);
        CompInfo.Get;
        Applicant.Get(JobApplication."Applicant No.");
        Applicant.TestField("E-Mail");
        Recepients.Add(Applicant."E-Mail");
        Body:='Dear, ' + Applicant."First Name";
        Body+='<br><br>';
        Body+='Congraturations, This is to inform you you have passed the interview and you are invited for Remuneration and Resumption Date discussion.';
        Body+='<br><br>';
        Body+='<b>Date: ' + Format(JobInterview."Discussion Date") + '</b>';
        Body+='<br><br>';
        Body+='<b>Time:' + Format(JobInterview."Discussion Time") + '</b>';
        Body+='<br><br>';
        Body+='Kindly acknowledge receipt of this email.';
        Body+='<br><br>';
        Body+='Thank you.';
        Body+='<br><br>';
        Body+='Yours Sincerely,';
        Body+='<br><br>';
        Body+='<b>Human Resources and Administration<b>';
        Body+='<br>';
        Body+=CompInfo.Name;
        Mail.Create(Recepients, 'Remuneration Resumption Date Discussion', Body, true);
        Email.Send(Mail);
    end;
}
