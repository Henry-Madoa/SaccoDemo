codeunit 52203490 "Onboarding Management"
{
    trigger OnRun()
    begin
    end;
    var Text000: Label 'Are you offering this applicant a Job?';
    Text001: Label 'Did this applicant accept the Job Offer?';
    Text002: Label 'Did this applicant reject the Job Offer?';
    Employee: Record Employee;
    Text003: Label 'Has this applicant reported to work? By Confirming This Staff Card will be created, Do you wish to continue?';
    Applicant: Record Applicant;
    Text004: Label 'The applicant did not show up for work?';
    procedure OfferAccepted(var Applicant: Record Applicant)
    begin
        with Applicant do begin
            if Confirm(Text001, true) = true then begin
                "Offer Status":="Offer Status"::"Accepted Offer";
                Modify;
            end;
        end;
    end;
    procedure OfferRejected(var Applicant: Record Applicant)
    begin
        with Applicant do begin
            if Confirm(Text002, true) = true then begin
                "Offer Status":="Offer Status"::"Rejected Offer";
                Modify;
            end;
        end;
    end;
    procedure ReportedToWork(var Applicant: Record Applicant)
    begin
        with Applicant do begin
            if Confirm(Text003, true) = true then begin
                ConvertToEmployee(Applicant);
                "Offer Status":="Offer Status"::"Reported to Work";
                Modify;
            end;
        end;
    end;
    procedure NoShow(var Applicant: Record Applicant)
    begin
        with Applicant do begin
            if Confirm(Text004, true) = true then begin
                "Offer Status":="Offer Status"::"Rejected Offer";
                Modify;
            end;
        end;
    end;
    procedure ConvertToEmployee(var Applicant: Record Applicant)
    begin
        If Applicant."Applicant Type" = Applicant."Applicant Type"::External then CreateStaffCardForExternalApplicant(Applicant) // else
    //     PromotionHistory.ProcessRoleChange_Second(Applicant."Staff ID", Applicant."Employment Date", 'Recruitment', Applicant."Job Applied For");
    end;
    procedure CreateStaffCardForExternalApplicant(var Applicant: Record Applicant)
    var
        HumanResourcesSetup: Record "Human Resources Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        EmployeeNo: Code[20];
    begin
        HumanResourcesSetup.GET;
        HumanResourcesSetup.TESTFIELD("Employee Nos.");
        EmployeeNo:=NoSeriesManagement.GetNextNo(HumanResourcesSetup."Employee Nos.", 0D, TRUE);
        // Employee.Init();
        // Employee."No." := EmployeeNo;
        // Employee.Insert;
        //Create Employee Card
        Employee.Init();
        Employee."No.":=EmployeeNo;
        Employee."First Name":=Applicant."First Name";
        Employee."Middle Name":=Applicant."Middle Name";
        Employee."Last Name":=Applicant."Last Name";
        Employee.Validate("Search Name");
        Employee.Validate("Job Code", Applicant."Job ID");
        Employee.Initials:=Applicant.Initials;
        Employee.Address:=Applicant."Postal Address";
        Employee."Address 2":=Applicant."Physical Address";
        Employee."Alt. Address Code":=Applicant."Alt. Address Code";
        Employee."Alt. Address End Date":=Applicant."Alt. Address End Date";
        Employee."Alt. Address Start Date":=Applicant."Alt. Address Start Date";
        Employee."Birth Date":=Applicant."Birth Date";
        Employee."Cause of Absence Filter":=Applicant."Cause of Absence Filter";
        Employee."Cause of Inactivity Code":=Applicant."Cause of Inactivity Code";
        Employee.City:=Applicant.City;
        Employee.Comment:=Applicant.Comment;
        Employee."Company E-Mail":=Applicant."Company E-Mail";
        Employee."Country/Region Code":=Applicant."Country/Region Code";
        Employee.County:=Applicant."Home County";
        Employee.Gender:=Applicant.Gender;
        Employee."E-Mail":=Applicant."E-Mail";
        Employee."Global Dimension 1 Code":=Applicant."Global Dimension 1 Code";
        Employee."Global Dimension 2 Code":=Applicant."Global Dimension 2 Code";
        Employee.Image:=Applicant.Image;
        Employee."Job Title":=Applicant."Position Applied For";
        Employee."Phone No.":=Applicant."Alternative Phone No.";
        Employee."Mobile Phone No.":=Applicant."Mobile Phone No.";
        Employee."National ID":=Applicant."ID Number";
        Employee."Passport Number":=Applicant."Passport No.";
        Employee.County:=Applicant."Home County";
        Employee."Global Dimension 1 Code":=Applicant."Global Dimension 1 Code";
        Employee."Global Dimension 2 Code":=Applicant."Global Dimension 2 Code";
        Employee."SHIF No.":=Applicant."SHIF No";
        Employee."Marital Status":=Applicant."Marital Status";
        Employee."NSSF No.":=Applicant."NSSF No";
        Employee.Insert(true);
        TransferApplicantQualifications(EmployeeNo, Applicant."No.");
        TransferExperienceQualifications(EmployeeNo, Applicant."No.");
        TransferApplicantAttachments(EmployeeNo, Applicant."No.");
    end;
    local procedure TransferApplicantQualifications(ApplicantNo: Code[20]; EmployeeNo: Code[20])
    var
        LineNo: Integer;
        AppQualifications: Record "Applicants Qualification";
        EmpQualifications: Record "Employee Qualification";
    begin
        //Create Qualification Lines
        AppQualifications.Reset();
        AppQualifications.SetRange("Applicant No.", ApplicantNo);
        if AppQualifications.FindSet()then begin
            repeat LineNo:=LineNo + 1000;
                EmpQualifications.Init();
                EmpQualifications."Employee No.":=EmployeeNo;
                EmpQualifications."Line No.":=LineNo;
                //EmpQualifications."Qualification Type" := AppQualifications."Qualification Type";
                EmpQualifications.Validate("Qualification Code", AppQualifications."Qualification Code");
                EmpQualifications."From Date":=AppQualifications."From Date";
                EmpQualifications."To Date":=AppQualifications."To Date";
                EmpQualifications.Type:=AppQualifications.Type;
                EmpQualifications."Institution/Company":=AppQualifications."Institution/Company";
                EmpQualifications.Description:=AppQualifications.Description;
                EmpQualifications."Employee Status":=AppQualifications."Employee Status";
                //EmpQualifications."Score ID" := AppQualifications."Score ID";
                EmpQualifications.Comment:=AppQualifications.Comment;
                EmpQualifications."Expiration Date":=AppQualifications."Expiration Date";
                EmpQualifications.Insert;
            until AppQualifications.Next() = 0;
        end;
    end;
    local procedure TransferExperienceQualifications(ApplicantNo: Code[20]; EmployeeNo: Code[20])
    var
        EmployeeWorkHistory: Record "Employee Work History";
        AppWorkExperience: Record "Applicant Current Employment";
    begin
        //Create WorkExperience
        AppWorkExperience.Reset();
        AppWorkExperience.SetRange("Applicant No.", ApplicantNo);
        if AppWorkExperience.FindSet()then begin
            repeat EmployeeWorkHistory.Init();
                EmployeeWorkHistory."Employee No.":=EmployeeNo;
                EmployeeWorkHistory."From Date":=AppWorkExperience."From Date";
                EmployeeWorkHistory."To Date":=AppWorkExperience."To Date";
                EmployeeWorkHistory."Institution/Company":=AppWorkExperience."Employer/Institution Name";
                EmployeeWorkHistory."Position Held":=AppWorkExperience."Substantive Post";
                EmployeeWorkHistory."Key Experience":=AppWorkExperience."Key Experience";
                EmployeeWorkHistory."Salary On Leaving":=AppWorkExperience."Gross Salary (KSH)";
                EmployeeWorkHistory."Reason For Leaving":=AppWorkExperience."Reason For Leaving";
                EmployeeWorkHistory.Insert;
            until AppWorkExperience.Next() = 0;
        end;
    end;
    procedure TransferApplicantAttachments(ApplicantNo: Code[20]; EmployeeNo: Code[20])
    var
        DocumentAttachment: array[2]of Record "Document Attachment";
    begin
        DocumentAttachment[1].Reset();
        DocumentAttachment[1].SetRange("Table ID", Database::Applicant);
        DocumentAttachment[1].SetRange("No.", ApplicantNo);
        if DocumentAttachment[1].FindSet()then begin
            repeat DocumentAttachment[2].Init();
                DocumentAttachment[2].TransferFields(DocumentAttachment[1], true);
                DocumentAttachment[2]."Table ID":=Database::Employee;
                DocumentAttachment[2]."No.":=EmployeeNo;
                DocumentAttachment[2].Insert(true);
            until DocumentAttachment[1].Next() = 0;
        end;
    end;
}
