codeunit 52203464 "Employee Management"
{
    trigger OnRun()
    begin
        EmployeeTrainingReminder;
    end;
    [IntegrationEvent(false, false)]
    procedure OnEmployeeMemberApplication(Emp: Record Employee)
    begin
    end;
    procedure EmployeeTrainingReminder()
    begin
        TrainingApp.Reset();
        TrainingApp.SetRange(Status, TrainingApp.Status::"Awaiting Attendance Confirmation");
        TrainingApp.SetRange("Notification Sent", false);
        if TrainingApp.FindSet()then begin
            repeat if(HRDates.DifferenceStartEnd(TrainingApp."Start Date", TrainingApp."End Date") <= 7)then HRCommunicationMgmt.EmployeeTraininingReminder(TrainingApp);
            until TrainingApp.Next() = 0;
        end;
    end;
    procedure RenameEmployeeOnApproval(var Employee: Record Employee)
    begin
        HumanResourcesSetup.GET;
        HumanResourcesSetup.TESTFIELD("Employee Nos.");
        IF Employee."Type of Employee" IN[Employee."Type of Employee"::Contract]THEN NextEmployeeNo:=NoSeriesManagement.GetNextNo(HumanResourcesSetup."Employee Nos.", 0D, TRUE);
        IF NextEmployeeNo <> '' THEN BEGIN
            EmployeeBeneficiaries.RESET;
            EmployeeBeneficiaries.SETRANGE("Employee No.", Employee."No.");
            IF EmployeeBeneficiaries.FINDSET THEN BEGIN
                REPEAT EmployeeBeneficiaries.RENAME(EmployeeBeneficiaries."No.", NextEmployeeNo);
                UNTIL EmployeeBeneficiaries.NEXT = 0;
            END;
            EmployeeContractDetails.RESET;
            EmployeeContractDetails.SETRANGE("Employee No", Employee."No.");
            IF EmployeeContractDetails.FINDSET THEN BEGIN
                REPEAT EmployeeContractDetails.RENAME(NextEmployeeNo, EmployeeContractDetails."Line No");
                    EmployeeDonors.RESET;
                    EmployeeDonors.SETRANGE("Employee No", Employee."No.");
                    IF EmployeeDonors.FINDSET THEN BEGIN
                        REPEAT EmployeeDonors.RENAME(NextEmployeeNo, EmployeeDonors."Donor Code", EmployeeContractDetails."Line No", EmployeeContractDetails."Contract Code");
                        UNTIL EmployeeDonors.NEXT = 0;
                    END;
                UNTIL EmployeeContractDetails.NEXT = 0;
            END;
            EmployeeDepandants.RESET;
            EmployeeDepandants.SETRANGE("Employee No.", Employee."No.");
            IF EmployeeDepandants.FINDSET THEN BEGIN
                REPEAT EmployeeDepandants.RENAME(EmployeeDepandants."Line No.", NextEmployeeNo);
                UNTIL EmployeeDepandants.NEXT = 0;
            END;
            EmployeeEmergencyContacts.RESET;
            EmployeeEmergencyContacts.SETRANGE("Employee No.", Employee."No.");
            IF EmployeeEmergencyContacts.FINDSET THEN BEGIN
                REPEAT EmployeeEmergencyContacts.RENAME(EmployeeEmergencyContacts."Line No", NextEmployeeNo);
                UNTIL EmployeeEmergencyContacts.NEXT = 0;
            END;
            EmployeeProffesionalBodies.RESET;
            EmployeeProffesionalBodies.SETRANGE("Employee No.", Employee."No.");
            IF EmployeeProffesionalBodies.FINDSET THEN BEGIN
                REPEAT EmployeeProffesionalBodies.RENAME(NextEmployeeNo, EmployeeProffesionalBodies."Line No.");
                UNTIL EmployeeProffesionalBodies.NEXT = 0;
            END;
            EmployeeQualification.RESET;
            EmployeeQualification.SETRANGE("Employee No.", Employee."No.");
            IF EmployeeQualification.FINDSET THEN BEGIN
                REPEAT EmployeeQualification.RENAME(NextEmployeeNo, EmployeeQualification."Line No.");
                UNTIL EmployeeQualification.NEXT = 0;
            END;
            EmployeeRelative.RESET;
            EmployeeRelative.SETRANGE("Employee No.", Employee."No.");
            IF EmployeeRelative.FINDSET THEN BEGIN
                REPEAT EmployeeRelative.RENAME(NextEmployeeNo, EmployeeRelative."Line No.");
                UNTIL EmployeeRelative.NEXT = 0;
            END;
            EmployeeWorkHistory.RESET;
            EmployeeWorkHistory.SETRANGE("Employee No.", Employee."No.");
            IF EmployeeWorkHistory.FINDSET THEN BEGIN
                REPEAT EmployeeWorkHistory.RENAME(NextEmployeeNo, EmployeeWorkHistory."Line No.");
                UNTIL EmployeeWorkHistory.NEXT = 0;
            END;
            Employee.RENAME(NextEmployeeNo);
        END;
    end;
    var TrainingApp: Record "Training Application";
    HRDates: Codeunit "HR Dates";
    HRCommunicationMgmt: Codeunit "Communications Mgmt";
    EmployeeBeneficiaries: Record "Employee Beneficiaries";
    EmployeeProffesionalBodies: Record "Employee Proffesional Bodies";
    EmployeeEmergencyContacts: Record "Employee Emergency Contacts";
    EmployeeRelative: Record "Employee Relative";
    EmployeeDepandants: Record "Employee Depandants";
    HumanResourcesSetup: Record "Human Resources Setup";
    EmployeeContractDetails: Record "Employee Contract Details";
    EmployeeDonors: Record "Employee Donors";
    EmployeeQualification: Record "Employee Qualification";
    EmployeeWorkHistory: Record "Employee Work History";
    NextEmployeeNo: Code[20];
    NoSeriesManagement: Codeunit NoSeriesManagement;
}
