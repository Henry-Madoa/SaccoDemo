codeunit 52203442 "Employee Change Request"
{
    [IntegrationEvent(false, false)]
    procedure OnEffectChange(var EmployeeChangeRequest: Record "Employee Change Request")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure BeforeonEffectingChange(var EmployeeChangeRequest: Record "Employee Change Request")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnAfterEffectingChange(var EmployeeChangeRequest: Record "Employee Change Request")
    begin
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Employee Change Request", 'OnEffectChange', '', false, false)]
    local procedure EffectChange(var EmployeeChangeRequest: Record "Employee Change Request")
    var
        Employee: Record Employee;
    begin
        BeforeonEffectingChange(EmployeeChangeRequest);
        with EmployeeChangeRequest do begin
            if Employee.Get("Employee No")then begin
                case "Nature of Change" of "Nature of Change"::"Bio Data": begin
                    Employee.Validate("Emplymt. Contract Code", "New Contract");
                    Employee.Modify(true);
                end;
                "Nature of Change"::"Asset Assignment": begin
                    Employee.Validate("Global Dimension 2 Code", "New Department");
                    Employee.Modify(true);
                end;
                "Nature of Change"::"Next Of Kin": begin
                    Employee.Validate("Job Title", "New Job");
                    Employee.Modify(true);
                end;
                "Nature of Change"::"Proffesional Bodies": begin
                    Employee.Validate("Job Title", "New Job");
                    Employee.Validate("Job Scale", "New Grade");
                    Employee.Validate("J-G Steps", "Current Pointer");
                    Employee.Modify(true);
                end;
                "Nature of Change"::Beneficiaries: begin
                    Employee.Validate("Location Code", "New Location");
                    Employee.Modify(true);
                end;
                "Nature of Change"::"Emergency Contacts": begin
                    Employee.Validate("Global Dimension 1 Code", "New Project");
                    Employee.Modify(true);
                end;
                end;
            end;
        end;
        OnAfterEffectingChange(EmployeeChangeRequest);
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Employee Change Request", 'BeforeonEffectingChange', '', false, false)]
    local procedure CheckIfThereAreAnyChanges(var EmployeeChangeRequest: Record "Employee Change Request")
    var
        Employee: Record Employee;
    begin
        with EmployeeChangeRequest do begin
            if Employee.Get("Employee No")then begin
                case "Nature of Change" of "Nature of Change"::"Bio Data": begin
                    TestField("New Contract");
                    if "New Contract" = "Current Contract" then Message('No Change to effect');
                end;
                "Nature of Change"::"Asset Assignment": begin
                    TestField("New Department");
                    if "Current Department" = "New Department" then Message('No Change to effect');
                end;
                "Nature of Change"::"Next Of Kin": begin
                    TestField("New Job");
                    if "Current Job" = "New Job" then Message('No Change to effect');
                end;
                "Nature of Change"::Beneficiaries: begin
                    TestField("New Location");
                    if "Current Location" = "New Location" then Message('No Change to effect');
                end;
                "Nature of Change"::"Emergency Contacts": begin
                    TestField("New Project");
                    if "Current Project" = "New Project" then Message('No Change to effect');
                end;
                end;
            end;
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Employee Change Request", 'OnAfterEffectingChange', '', false, false)]
    local procedure ChangeDocumentStatus(var EmployeeChangeRequest: Record "Employee Change Request")
    begin
        with EmployeeChangeRequest do begin
            Executed:=true;
            if Modify then Message('Successfully executed');
        end;
    end;
}
