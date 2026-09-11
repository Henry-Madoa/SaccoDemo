codeunit 52203461 "Change Request Management"
{
    procedure EffectChangesOfApprovedRequest(var EmpChangeReq: Record "Employee Change Request")
    begin
        if EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::Beneficiaries]then ChangeBeneficiaries(EmpChangeReq);
        if EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"Emergency Contacts"]then ChangeEmergencyContacts(EmpChangeReq);
        if EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"Medical Dependants"]then ChangeMedicalDependants(EmpChangeReq);
        if EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"Next Of Kin"]then ChangeNextOfKin(EmpChangeReq);
        if EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"Proffesional Bodies"]then ChangeProffesionalBodies(EmpChangeReq);
        if EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::Qualifications]then ChangeQualification(EmpChangeReq);
        if EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"Work History"]then ChangeWorkHistory(EmpChangeReq);
        if EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"Bio Data"]then ChangeEmployeeBioData(EmpChangeReq);
        if EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"Asset Assignment"]then ChangeAssignAssets(EmpChangeReq);
        OnAfterEffectChangesOfApprovedRequest(EmpChangeReq);
    end;
    local procedure ChangeQualification(EmployeeChangeRequest: Record "Employee Change Request")
    var
        EmployeeQualificationChange: Record "Employee Qualification Change";
        EmployeeQualification: Record "Employee Qualification";
    begin
        EmployeeQualificationChange.Reset;
        EmployeeQualificationChange.SetRange("Change No", EmployeeChangeRequest."No.");
        EmployeeQualificationChange.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
        if EmployeeQualificationChange.FindSet then begin
            repeat if EmployeeQualificationChange.Action in[EmployeeQualificationChange.Action::"New Addition"]then begin
                    EmployeeQualification.Init;
                    EmployeeQualification.TransferFields(EmployeeQualificationChange);
                    EmployeeQualification.Insert;
                end;
            until EmployeeQualificationChange.Next = 0;
        end;
    end;
    local procedure ChangeWorkHistory(EmployeeChangeRequest: Record "Employee Change Request")
    var
        EmployeeWorkHistory: Record "Employee Work History";
        EmployeeWorkHistoryCH: Record "Employee Work History CH";
    begin
        EmployeeWorkHistoryCH.Reset;
        EmployeeWorkHistoryCH.SetRange("Change No", EmployeeChangeRequest."No.");
        EmployeeWorkHistoryCH.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
        if EmployeeWorkHistoryCH.FindSet then begin
            repeat if EmployeeWorkHistoryCH.Action in[EmployeeWorkHistoryCH.Action::"New Addition"]then begin
                    EmployeeWorkHistory.Init;
                    EmployeeWorkHistory.TransferFields(EmployeeWorkHistoryCH);
                    EmployeeWorkHistory.Insert;
                end;
            until EmployeeWorkHistoryCH.Next = 0;
        end;
    end;
    local procedure ChangeMedicalDependants(EmployeeChangeRequest: Record "Employee Change Request")
    var
        EmployeeDepandants: Record "Employee Depandants";
        EmployeeDepandantsChange: Record "Employee Depandants Change";
    begin
        EmployeeDepandantsChange.Reset;
        EmployeeDepandantsChange.SetRange("Change No", EmployeeChangeRequest."No.");
        EmployeeDepandantsChange.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
        if EmployeeDepandantsChange.FindSet then begin
            repeat if EmployeeDepandantsChange.Action in[EmployeeDepandantsChange.Action::"New Addition"]then begin
                    EmployeeDepandants.Init;
                    EmployeeDepandants.TransferFields(EmployeeDepandantsChange);
                    EmployeeDepandants.Insert;
                end;
                if EmployeeDepandantsChange.Action in[EmployeeDepandantsChange.Action::Remove]then begin
                    EmployeeDepandants.Reset;
                    EmployeeDepandants.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
                    EmployeeDepandants.SetRange("Line No.", EmployeeDepandantsChange."Line No.");
                    if EmployeeDepandants.FindFirst then EmployeeDepandants.Delete;
                end;
            until EmployeeDepandantsChange.Next = 0;
        end;
    end;
    local procedure ChangeBeneficiaries(EmployeeChangeRequest: Record "Employee Change Request")
    var
        EmployeeBeneficiaries: Record "Employee Beneficiaries";
        EmployeeBeneficiariesChange: Record "Employee Beneficiaries Change";
    begin
        EmployeeBeneficiariesChange.Reset;
        EmployeeBeneficiariesChange.SetRange("Change No", EmployeeChangeRequest."No.");
        EmployeeBeneficiariesChange.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
        if EmployeeBeneficiariesChange.FindSet then begin
            repeat if EmployeeBeneficiariesChange.Action in[EmployeeBeneficiariesChange.Action::"New Addition"]then begin
                    EmployeeBeneficiaries.Init;
                    EmployeeBeneficiaries.TransferFields(EmployeeBeneficiariesChange);
                    EmployeeBeneficiaries.Insert;
                end;
                if EmployeeBeneficiariesChange.Action in[EmployeeBeneficiariesChange.Action::Remove]then begin
                    EmployeeBeneficiaries.Reset;
                    EmployeeBeneficiaries.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
                    EmployeeBeneficiaries.SetRange("No.", EmployeeBeneficiariesChange."No.");
                    if EmployeeBeneficiaries.FindFirst then EmployeeBeneficiaries.Delete;
                end;
                if EmployeeBeneficiariesChange.Action in[EmployeeBeneficiariesChange.Action::"Modify Allocation"]then begin
                    EmployeeBeneficiaries.Reset;
                    EmployeeBeneficiaries.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
                    EmployeeBeneficiaries.SetRange("No.", EmployeeBeneficiariesChange."No.");
                    if EmployeeBeneficiaries.FindFirst then begin
                        EmployeeBeneficiaries.Percentage:=EmployeeBeneficiariesChange."New Allocation";
                        EmployeeBeneficiaries.Modify(true);
                    end;
                end;
            until EmployeeBeneficiariesChange.Next = 0;
        end;
    end;
    local procedure ChangeEmergencyContacts(EmployeeChangeRequest: Record "Employee Change Request")
    var
        EmployeeEmergencyContacts: Record "Employee Emergency Contacts";
        EmployeeEmergencyContactsC: Record "Employee Emergency Contacts C";
    begin
        EmployeeEmergencyContactsC.Reset;
        EmployeeEmergencyContactsC.SetRange("Change No", EmployeeChangeRequest."No.");
        EmployeeEmergencyContactsC.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
        if EmployeeEmergencyContactsC.FindSet then begin
            repeat if EmployeeEmergencyContactsC.Action in[EmployeeEmergencyContactsC.Action::"New Addition"]then begin
                    EmployeeEmergencyContacts.Init;
                    EmployeeEmergencyContacts.TransferFields(EmployeeEmergencyContactsC);
                    EmployeeEmergencyContacts.Insert;
                end;
                if EmployeeEmergencyContactsC.Action in[EmployeeEmergencyContactsC.Action::Remove]then begin
                    EmployeeEmergencyContacts.Reset;
                    EmployeeEmergencyContacts.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
                    EmployeeEmergencyContacts.SetRange("Line No", EmployeeEmergencyContactsC."Line No");
                    if EmployeeEmergencyContacts.FindFirst then EmployeeEmergencyContacts.Delete;
                end;
            until EmployeeEmergencyContactsC.Next = 0;
        end;
    end;
    local procedure ChangeAssignAssets(EmployeeChangeRequest: Record "Employee Change Request")
    var
        MiscArticleInformation: Record "Misc. Article Information";
        MiscArticleInformationCH: Record "Misc. Article Information CH";
    begin
        MiscArticleInformationCH.Reset;
        MiscArticleInformationCH.SetRange("Change No", EmployeeChangeRequest."No.");
        MiscArticleInformationCH.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
        if MiscArticleInformationCH.FindSet then begin
            repeat if MiscArticleInformationCH.Action in[MiscArticleInformationCH.Action::"New Addition"]then begin
                    MiscArticleInformation.Init;
                    MiscArticleInformation.TransferFields(MiscArticleInformationCH);
                    MiscArticleInformation.Insert;
                end;
                if MiscArticleInformationCH.Action in[MiscArticleInformationCH.Action::Return]then begin
                    MiscArticleInformation.Reset;
                    MiscArticleInformation.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
                    MiscArticleInformation.SetRange("Line No.", MiscArticleInformationCH."Line No.");
                    if MiscArticleInformation.FindFirst then MiscArticleInformation.Delete;
                end;
            until MiscArticleInformationCH.Next = 0;
        end;
    end;
    local procedure ChangeNextOfKin(EmployeeChangeRequest: Record "Employee Change Request")
    var
        EmployeeRelative: Record "Employee Relative";
        EmployeeRelativeChange: Record "Employee Relative Change";
    begin
        EmployeeRelativeChange.Reset;
        EmployeeRelativeChange.SetRange("Change No", EmployeeChangeRequest."No.");
        EmployeeRelativeChange.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
        if EmployeeRelativeChange.FindSet then begin
            repeat if EmployeeRelativeChange.Action in[EmployeeRelativeChange.Action::"New Addition"]then begin
                    EmployeeRelative.Init;
                    EmployeeRelative.TransferFields(EmployeeRelativeChange);
                    EmployeeRelative.Insert;
                end;
                if EmployeeRelativeChange.Action in[EmployeeRelativeChange.Action::Remove]then begin
                    EmployeeRelative.Reset;
                    EmployeeRelative.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
                    EmployeeRelative.SetRange("Line No.", EmployeeRelativeChange."Line No.");
                    if EmployeeRelative.FindFirst then EmployeeRelative.Delete;
                end;
            until EmployeeRelativeChange.Next = 0;
        end;
    end;
    local procedure ChangeProffesionalBodies(EmployeeChangeRequest: Record "Employee Change Request")
    var
        EmployeeProffesionalBodies: Record "Employee Proffesional Bodies";
        EmployeeProffesionalBodiesC: Record "Employee Proffesional Bodies C";
    begin
        EmployeeProffesionalBodiesC.Reset;
        EmployeeProffesionalBodiesC.SetRange("Change No", EmployeeChangeRequest."No.");
        EmployeeProffesionalBodiesC.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
        if EmployeeProffesionalBodiesC.FindSet then begin
            repeat if EmployeeProffesionalBodiesC.Action in[EmployeeProffesionalBodiesC.Action::"New Addition"]then begin
                    EmployeeProffesionalBodies.Init;
                    EmployeeProffesionalBodies.TransferFields(EmployeeProffesionalBodiesC);
                    EmployeeProffesionalBodies.Insert;
                end;
                if EmployeeProffesionalBodiesC.Action in[EmployeeProffesionalBodiesC.Action::Remove]then begin
                    EmployeeProffesionalBodies.Reset;
                    EmployeeProffesionalBodies.SetRange("Employee No.", EmployeeChangeRequest."Employee No");
                    EmployeeProffesionalBodies.SetRange("Line No.", EmployeeProffesionalBodiesC."Line No.");
                    if EmployeeProffesionalBodies.FindFirst then EmployeeProffesionalBodies.Delete;
                end;
            until EmployeeProffesionalBodiesC.Next = 0;
        end;
    end;
    local procedure ChangeEmployeeBioData(EmployeeChangeRequest: Record "Employee Change Request")
    var
        EmployeeBioDataChange: Record "Employee Bio Data Change";
        Employee: Record Employee;
    begin
        EmployeeBioDataChange.Reset;
        EmployeeBioDataChange.SetRange("Change No.", EmployeeChangeRequest."No.");
        EmployeeBioDataChange.SetRange(Status, EmployeeBioDataChange.Status::New);
        if EmployeeBioDataChange.FindFirst then begin
            Employee.Get(EmployeeBioDataChange."Employee No.");
            if EmployeeBioDataChange."Passport No" <> '' then Employee."Passport Number":=EmployeeBioDataChange."Passport No";
            if EmployeeBioDataChange."Phone Number" <> '' then Employee."Phone No.":=EmployeeBioDataChange."Phone Number";
            IF EmployeeBioDataChange."Personal E-mail" <> '' THEN Employee."E-Mail":=EmployeeBioDataChange."Personal E-mail";
            Employee.Modify(true);
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Request Management", 'CreateNewEmployeeContract', '', false, false)]
    local procedure CreateNewContract(var EmpChangeReq: Record "Employee Change Request")
    var
        NewEmployeeDonors: Record "New Employee Donors";
        EmployeeDonors: Record "Employee Donors";
        ContractChangeLine: Record "Contract Change Lines";
        EmployeeContractDetails: Record "Employee Contract Details";
        ContractConditions: Record "Contract Conditions";
        ContractChangeConditions: Record "Contract Change Conditions";
        Employee: Record Employee;
        EmploymentContract: Record "Employment Contract";
    begin
        if not(EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"New Contract"])then exit;
        OnBeforeCreateNewEmployeeContract(EmpChangeReq);
        ContractChangeLine.Reset;
        ContractChangeLine.SetRange("Change No", EmpChangeReq."No.");
        if ContractChangeLine.FindFirst then begin
            if Employee.Get(EmpChangeReq."Employee No")then begin
                Employee."Employment Date":=ContractChangeLine."Contract Start Date";
                Employee."Probation Period":=ContractChangeLine."Probation Period";
                Employee."End of Probation Period":=CalcDate(ContractChangeLine."Probation Period", Employee."Employment Date");
                Employee."End of Probation Period":=CalcDate('-1D', Employee."End of Probation Period");
                Employee."Notice Period":=ContractChangeLine."Notice Period";
                Employee.Modify(true);
                EmploymentContract.Get(ContractChangeLine."Contract Code");
                if EmploymentContract."Contract Type" in[EmploymentContract."Contract Type"::"Long Term"]then begin
                    Employee."Long Term":=true;
                    if EmploymentContract.Medical then Employee."Covered Medically":=Employee."Covered Medically"::Yes;
                    Employee.Modify(true);
                end;
            end;
            EmployeeContractDetails.Init;
            EmployeeContractDetails.TransferFields(ContractChangeLine);
            EmployeeContractDetails.Insert;
            NewEmployeeDonors.Reset;
            NewEmployeeDonors.SetRange("Contract Code", ContractChangeLine."Contract Code");
            NewEmployeeDonors.SetRange("Employee No", ContractChangeLine."Employee No");
            NewEmployeeDonors.SetRange("Contract Line No", ContractChangeLine."Line No");
            if NewEmployeeDonors.FindSet then begin
                repeat EmployeeDonors.Init;
                    EmployeeDonors.TransferFields(NewEmployeeDonors);
                    EmployeeDonors.Insert;
                until NewEmployeeDonors.Next = 0;
            end;
            ContractChangeConditions.Reset;
            ContractChangeConditions.SetRange("Contract Line No", ContractChangeLine."Line No");
            ContractChangeConditions.SetRange("Employee No", ContractChangeLine."Employee No");
            if ContractChangeConditions.FindSet then begin
                repeat ContractConditions.Init;
                    ContractConditions.TransferFields(ContractChangeConditions);
                    ContractConditions.Insert;
                until ContractChangeConditions.Next = 0;
            end;
        end;
        OnAfterCreateNewEmployeeContract(EmpChangeReq);
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Request Management", 'OnAfterEffectChangesOfApprovedRequest', '', false, false)]
    local procedure RenewContract(var EmpChangeReq: Record "Employee Change Request")
    var
        NewEmployeeDonors: Record "New Employee Donors";
        EmployeeDonors: Record "Employee Donors";
        ContractChangeLine: Record "Contract Change Lines";
        EmployeeContractDetails: Record "Employee Contract Details";
        ContractConditions: Record "Contract Conditions";
        ContractChangeConditions: Record "Contract Change Conditions";
        ContractChangeLineCopy: Record "Contract Change Lines";
        EmploymentContract: Record "Employment Contract";
        Employee: Record Employee;
        PayrollSalaryCard: Record "Payroll Salary Card";
        SalaryScalePointers: Record "Salary Scale Pointers";
        EmployeePayrollScales: Record "Employee Payroll Scales";
    begin
        if not(EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"Contract Renewal"])then exit;
        ContractChangeLine.Reset;
        ContractChangeLine.SetRange("Change No", EmpChangeReq."No.");
        ContractChangeLine.SetRange(Status, ContractChangeLine.Status::New);
        if ContractChangeLine.FindFirst then begin
            if Employee.Get(ContractChangeLine."Employee No")then begin
                Employee."Notice Period":=ContractChangeLine."Notice Period";
                Employee.Validate("Job Scale", ContractChangeLine.Grade);
                if SalaryScalePointers.Get(ContractChangeLine.Grade, ContractChangeLine.Pointer)then if PayrollSalaryCard.Get(EmpChangeReq."Employee No")then begin
                        PayrollSalaryCard."Basic Pay":=SalaryScalePointers."Basic Pay";
                        PayrollSalaryCard.Modify(true);
                    end;
                //Employee.VALIDATE(Pointer,ContractChangeLine.Pointer);
                Employee.Validate("Job Title", ContractChangeLine."Job Code");
                Employee.Modify(true);
            end;
            if EmploymentContract.Get(ContractChangeLine."Contract Code")then begin
                if EmploymentContract."Contract Type" in[EmploymentContract."Contract Type"::"Long Term"]then begin
                    Employee.Get(ContractChangeLine."Employee No");
                    Employee."Long Term":=true;
                    Employee.Modify(true);
                end;
                if EmploymentContract."Contract Type" in[EmploymentContract."Contract Type"::"Long Term"]then begin
                    Employee."Long Term":=true;
                    if EmploymentContract.Medical then begin
                        Employee."Covered Medically":=Employee."Covered Medically"::Yes;
                        if EmployeePayrollScales.Get(ContractChangeLine.Grade)then Employee."Inpatient Ward Entitlement":=EmployeePayrollScales."Inpatient Ward Entitlement";
                    end;
                    Employee.Modify(true);
                end;
            end;
            ContractChangeLineCopy.Reset;
            ContractChangeLineCopy.SetRange("Change No", EmpChangeReq."No.");
            ContractChangeLineCopy.SetRange(Status, ContractChangeLineCopy.Status::Current);
            if ContractChangeLineCopy.FindFirst then begin
                EmployeeContractDetails.Reset;
                EmployeeContractDetails.SetRange("Line No", ContractChangeLineCopy."Line No");
                EmployeeContractDetails.SetRange("Employee No", ContractChangeLineCopy."Employee No");
                EmployeeContractDetails.SetRange("Contract Code", ContractChangeLineCopy."Contract Code");
                if EmployeeContractDetails.FindFirst then begin
                    EmployeeContractDetails."Contract Status":=EmployeeContractDetails."Contract Status"::Inactive;
                    EmployeeContractDetails.Modify(true);
                end;
            end;
            EmployeeContractDetails.Init;
            EmployeeContractDetails.TransferFields(ContractChangeLine);
            EmployeeContractDetails."Contract Status":=EmployeeContractDetails."Contract Status"::Active;
            EmployeeContractDetails.Insert;
            NewEmployeeDonors.Reset;
            NewEmployeeDonors.SetRange("Contract Code", ContractChangeLine."Contract Code");
            NewEmployeeDonors.SetRange("Employee No", ContractChangeLine."Employee No");
            NewEmployeeDonors.SetRange("Contract Line No", ContractChangeLine."Line No");
            if NewEmployeeDonors.FindSet then begin
                repeat EmployeeDonors.Init;
                    EmployeeDonors.TransferFields(NewEmployeeDonors);
                    EmployeeDonors.Insert;
                until NewEmployeeDonors.Next = 0;
            end;
            ContractChangeConditions.Reset;
            ContractChangeConditions.SetRange("Contract Line No", ContractChangeLine."Line No");
            ContractChangeConditions.SetRange("Employee No", ContractChangeLine."Employee No");
            if ContractChangeConditions.FindSet then begin
                repeat ContractConditions.Init;
                    ContractConditions.TransferFields(ContractChangeConditions);
                    ContractConditions.Insert;
                until ContractChangeConditions.Next = 0;
            end;
        end;
    end;
    local procedure CopyDonors(var EmployeeDonors: Record "Employee Donors"; var NewEmployeeDonors: Record "New Employee Donors"; ContractCode: Code[20]; LineNo: Integer)
    begin
        NewEmployeeDonors.Init;
        NewEmployeeDonors.TransferFields(EmployeeDonors);
        NewEmployeeDonors."Contract Code":=ContractCode;
        NewEmployeeDonors."Contract Line No":=LineNo;
        NewEmployeeDonors.Insert;
    end;
    local procedure CopyConditions(var ContractChangeConditions: Record "Contract Change Conditions"; var ContractConditions: Record "Contract Conditions"; ChangeCode: Code[20]; LineNo: Integer)
    begin
        ContractChangeConditions.Init;
        ContractChangeConditions.TransferFields(ContractConditions);
        ContractChangeConditions."Contract Line No":=LineNo;
        ContractChangeConditions."Change No":=ChangeCode;
        ContractChangeConditions.Insert;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Request Management", 'OnAfterEffectChangesOfApprovedRequest', '', false, false)]
    local procedure ChangeEmployeeScales(var EmpChangeReq: Record "Employee Change Request")
    var
        EmployeeContractDetails: Record "Employee Contract Details";
        Employee: Record Employee;
        ContractChangeLines: Record "Contract Change Lines";
        PayrollSalaryCard: Record "Payroll Salary Card";
    begin
        if not(EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"Salary Increment"])then exit;
        Employee.Get(EmpChangeReq."Employee No");
        Employee."Job Scale":=EmpChangeReq."New Grade";
        Employee."J-G Steps":=EmpChangeReq."New Pointer";
        Employee."Payroll Grade":=EmpChangeReq."New Salary Grade";
        Employee.Modify(true);
        ContractChangeLines.Reset;
        ContractChangeLines.SetRange("Change No", EmpChangeReq."No.");
        if ContractChangeLines.FindFirst then begin
            PayrollSalaryCard.Get(EmpChangeReq."Employee No");
            PayrollSalaryCard."Basic Pay":=ContractChangeLines."New Salary";
            PayrollSalaryCard.Modify(true);
            EmployeeContractDetails.Reset;
            EmployeeContractDetails.SetRange("Employee No", EmpChangeReq."Employee No");
            EmployeeContractDetails.SetRange("Contract Status", EmployeeContractDetails."Contract Status"::Active);
            if EmployeeContractDetails.FindFirst then begin
                EmployeeContractDetails.Grade:=EmpChangeReq."New Grade";
                EmployeeContractDetails.Pointer:=EmpChangeReq."New Pointer";
                EmployeeContractDetails.Salary:=ContractChangeLines."New Salary";
                EmployeeContractDetails.Modify(true);
            end;
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Request Management", 'OnBeforeCreateNewEmployeeContract', '', false, false)]
    procedure RunChecksOnCreateNewEmployeeContract(var EmpChangeReq: Record "Employee Change Request")
    var
        NewEmployeeDonors: Record "New Employee Donors";
        ContractChangeLines: Record "Contract Change Lines";
    begin
        if not(EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"New Contract"])then exit;
        ContractChangeLines.Reset;
        ContractChangeLines.SetRange("Change No", EmpChangeReq."No.");
        if not ContractChangeLines.FindFirst then Error('You have to specify a contract');
        ContractChangeLines.Reset;
        ContractChangeLines.SetRange("Change No", EmpChangeReq."No.");
        if ContractChangeLines.FindFirst then begin
            ContractChangeLines.TestField("Contract Code");
            ContractChangeLines.TestField("Contract Period");
            ContractChangeLines.TestField("Contract Start Date");
            ContractChangeLines.TestField("Contract End Date");
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Request Management", 'OnAfterCreateNewEmployeeContract', '', false, false)]
    local procedure ChangeStatusOfNewContract(var EmpChangeReq: Record "Employee Change Request")
    begin
        EmpChangeReq.Executed:=true;
        if EmpChangeReq.Modify then Message('Contract Successfully created');
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Request Management", 'OnBeforeCreateNewEmployeeContract', '', false, false)]
    procedure RunChecksOnContractRenewalEmployeeContract(var EmpChangeReq: Record "Employee Change Request")
    var
        NewEmployeeDonors: Record "New Employee Donors";
        ContractChangeLines: Record "Contract Change Lines";
    begin
        if not(EmpChangeReq."Nature of Change" in[EmpChangeReq."Nature of Change"::"Contract Renewal"])then exit;
        ContractChangeLines.Reset;
        ContractChangeLines.SetRange("Change No", EmpChangeReq."No.");
        ContractChangeLines.SetRange(Status, ContractChangeLines.Status::New);
        if not ContractChangeLines.FindFirst then Error('You have to specify a contract');
        ContractChangeLines.Reset;
        ContractChangeLines.SetRange("Change No", EmpChangeReq."No.");
        ContractChangeLines.SetRange(Status, ContractChangeLines.Status::New);
        ContractChangeLines.SetFilter("Contract Code", '<>%1', '');
        if ContractChangeLines.FindFirst then begin
            ContractChangeLines.TestField("Contract Code");
            ContractChangeLines.TestField("Contract Period");
            ContractChangeLines.TestField("Contract Start Date");
            ContractChangeLines.TestField("Contract End Date");
            NewEmployeeDonors.Reset;
            NewEmployeeDonors.SetRange("Employee No", EmpChangeReq."Employee No");
            NewEmployeeDonors.SetRange("Contract Code", ContractChangeLines."Contract Code");
            NewEmployeeDonors.SetRange("Change No", ContractChangeLines."Change No");
            if not NewEmployeeDonors.FindFirst then Error('You have to specify atleast one grant');
            NewEmployeeDonors.Reset;
            NewEmployeeDonors.SetRange("Employee No", EmpChangeReq."Employee No");
            NewEmployeeDonors.SetRange("Contract Code", ContractChangeLines."Contract Code");
            NewEmployeeDonors.SetRange("Change No", ContractChangeLines."Change No");
            if NewEmployeeDonors.FindSet then begin
                NewEmployeeDonors.CalcSums(Percentage);
                if NewEmployeeDonors.Percentage < 100 then Error('Grant allocation cannot be less than 100%');
            end;
        end;
    end;
    [IntegrationEvent(false, false)]
    procedure CreateNewEmployeeContract(var EmpChangeReq: Record "Employee Change Request")
    begin
    end;
    [IntegrationEvent(false, false)]
    procedure OnBeforeCreateNewEmployeeContract(var EmpChangeReq: Record "Employee Change Request")
    begin
    end;
    [IntegrationEvent(false, false)]
    procedure OnAfterCreateNewEmployeeContract(var EmpChangeReq: Record "Employee Change Request")
    begin
    end;
    [IntegrationEvent(false, false)]
    procedure OnAfterEffectChangesOfApprovedRequest(var EmpChangeReq: Record "Employee Change Request")
    begin
    end;
}
