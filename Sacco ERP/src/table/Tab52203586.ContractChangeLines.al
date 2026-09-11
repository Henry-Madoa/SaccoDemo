table 52203586 "Contract Change Lines"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then begin
                    "Employee Name":=Employee.FullName;
                    "Job Title":=Employee."Job Title";
                    "Employee Title":=Employee.Title;
                    Grade:=Employee."Job Scale";
                    Pointer:=Employee."J-G Steps";
                    Validate("Line Manager", Employee."Manager No.");
                    Department:=Employee."Global Dimension 1 Code";
                    "Employee Title":=Employee.Title;
                    Validate("Job Code", Employee."Job Title");
                    if EmployeePayrollScales.Get(Grade)then begin
                        //"Notice Period":=EmployeePayrollScales."Notice Period";
                        "Probation Notice Period":=EmployeePayrollScales."Probation Notice Period";
                    end;
                    if PayrollSalaryCard.Get("Employee No")then Salary:=PayrollSalaryCard."Basic Pay";
                //    EmployeeContractDetails.RESET;
                //    EmployeeContractDetails.SETRANGE("Employee No",Rec."Employee No");
                //    EmployeeContractDetails.SETRANGE("Contract Status",EmployeeContractDetails."Contract Status"::Active);
                //    IF EmployeeContractDetails.FINDFIRST THEN
                //      "Contract Start Date":=CALCDATE('+1D',EmployeeContractDetails."Contract End Date");
                //    COMMIT;
                end;
            end;
        }
        field(2; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Contract Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employment Contract";

            trigger OnValidate()
            begin
                if EmploymentContract.Get("Contract Code")then begin
                    "Contract Description":=EmploymentContract.Description;
                    "Notice Period":=EmploymentContract."Notice Period";
                    "Probation Period":=EmploymentContract."Probation period";
                    EmployeeContractDetails.Reset;
                    EmployeeContractDetails.SetRange("Employee No", Rec."Employee No");
                    EmployeeContractDetails.SetRange("Contract Status", EmployeeContractDetails."Contract Status"::Active);
                    if EmployeeContractDetails.FindFirst then begin
                        Rec."Contract Start Date":=CalcDate('+1D', EmployeeContractDetails."Contract End Date");
                    end;
                    EmployeePayrollScales.Get(Grade);
                    if EmploymentContract."Contract Type" in[EmploymentContract."Contract Type"::"Long Term"]then if EmployeePayrollScales."Notice Period" <> "Notice Period" then "Notice Period":=EmployeePayrollScales."Notice Period";
                    "Contract Period":=EmploymentContract."Contract Period";
                end;
            end;
        }
        field(4; "Contract Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Contract Period"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Format("Contract Period") <> '' then begin
                    Rec.Testfield("Contract Start Date");
                    "Contract End Date":=CalcDate("Contract Period", "Contract Start Date");
                    "Contract End Date":=CalcDate('-1D', "Contract End Date");
                    EmploymentContract.Get("Contract Code");
                    EndDate:=0D;
                    EndDate:=CalcDate('1Y-2D', "Contract Start Date");
                    if EmploymentContract."Contract Type" in[EmploymentContract."Contract Type"::"Long Term"]then if "Contract End Date" <= EndDate then Error('Should be more than one year');
                    EndDate:=0D;
                    EndDate:=CalcDate('1Y-2D', "Contract Start Date");
                    if EmploymentContract."Contract Type" in[EmploymentContract."Contract Type"::"Short Term"]then if "Contract End Date" > EndDate then Error('Should be more than less than an year'); /*ContractChangeLines.RESET;
                    ContractChangeLines.SETRANGE("Change No",Rec."Change No");
                    ContractChangeLines.SETRANGE(Status,ContractChangeLines.Status::Current);
                    IF ContractChangeLines.FINDFIRST THEN
                      BEGIN
                        EmployeeDonors.RESET;
                        EmployeeDonors.SETRANGE("Employee No",Rec."Employee No");
                        EmployeeDonors.SETRANGE("Contract Code",ContractChangeLines."Contract Code");
                        EmployeeDonors.SETRANGE("Contract Line No",ContractChangeLines."Line No");
                        IF EmployeeDonors.FINDFIRST THEN
                          BEGIN
                            REPEAT
                              NewEmployeeDonors.INIT;
                              NewEmployeeDonors."Change No":=Rec."Change No";
                              NewEmployeeDonors."Employee No":=Rec."Employee No";
                              NewEmployeeDonors."Contract Code":=Rec."Contract Code";
                              NewEmployeeDonors."Contract Line No":=Rec."Line No";
                              NewEmployeeDonors."Line No":=NewEmployeeDonors.COUNT+1;
                              NewEmployeeDonors.VALIDATE("Donor Code",EmployeeDonors."Donor Code");
                              NewEmployeeDonors."Grant Start Date":=Rec."Contract Start Date";
                              NewEmployeeDonors."Grant End Date":=Rec."Contract End Date";
                              NewEmployeeDonors.Percentage:=EmployeeDonors.Percentage;
                              NewEmployeeDonors.INSERT;
                            UNTIL EmployeeDonors.NEXT=0;
                          end;
                      end;*/
                end;
            end;
        }
        field(6; "Contract Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Contract Start Date" = 0D then exit;
                if EmployeeChangeRequest.Get("Change No")then begin
                    if EmployeeChangeRequest."Nature of Change" in[EmployeeChangeRequest."Nature of Change"::"Contract Renewal"]then begin
                        EmployeeContractDetails.Reset;
                        EmployeeContractDetails.SetRange("Employee No", Rec."Employee No");
                        EmployeeContractDetails.SetRange("Contract Status", EmployeeContractDetails."Contract Status"::Active);
                    //        IF EmployeeContractDetails.FINDFIRST THEN
                    //          IF ("Contract Start Date"<>CALCDATE('1D',EmployeeContractDetails."Contract End Date")) AND (EmployeeContractDetails."Contract End Date"<>0D) THEN
                    //              ERROR('Start date must be equal to the previous contract end date')
                    end;
                end;
                Validate("Contract Period");
            end;
        }
        field(7; "Contract End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Job Title"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(9; Grade; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(11; "Current Contract"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Notice Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(13; Salary; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Line Manager"; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Employee.Get("Line Manager")then begin
                    "Manager Name":=Employee.FullName;
                end;
            end;
        }
        field(15; "Manager Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(16; Department; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Contract Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Active,Inactive';
            OptionMembers = Active, Inactive;
        }
        field(18; Pointer; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Pointer = '' then exit;
                Rec.Testfield(Grade);
                SalaryScalePointers.Get(Grade, Pointer);
                Salary:=SalaryScalePointers."Basic Pay";
            end;
        }
        field(19; "Employee Title"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(70000; "Change No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(70001; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Current,New';
            OptionMembers = Current, New;
        }
        field(70003; "New Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70004; "Probation Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(70005; "Probation Notice Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(70006; "Payroll Scale"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(70007; "Job Code"; Code[30])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if HRJobs.Get("Job Code")then "Job Title":=HRJobs.Name;
            end;
        }
    }
    keys
    {
        key(Key1; "Employee No", "Line No", "Change No")
        {
        }
    }
    trigger OnInsert()
    begin
        if EmployeeChangeRequest.Get("Change No")then begin
            if EmployeeChangeRequest."Nature of Change" in[EmployeeChangeRequest."Nature of Change"::"New Contract"]then begin
                ContractChangeLines.Reset;
                ContractChangeLines.SetRange("Change No", Rec."Change No");
                if ContractChangeLines.FindSet then if ContractChangeLines.Count > 1 then Error('You cannot create more than one contract');
            end;
            if EmployeeChangeRequest."Nature of Change" in[EmployeeChangeRequest."Nature of Change"::"Contract Renewal"]then begin
                ContractChangeLines.Reset;
                ContractChangeLines.SetRange("Change No", Rec."Change No");
                ContractChangeLines.SetRange(Status, ContractChangeLines.Status::New);
                if ContractChangeLines.FindFirst then if ContractChangeLines.Count > 1 then Error('You cannot create more than one contract');
            end;
        end;
        Validate("Employee No");
    end;
    var EmploymentContract: Record "Employment Contract";
    Employee: Record Employee;
    PayrollSalaryCard: Record "Payroll Salary Card";
    EmployeePayrollScales: Record "Employee Payroll Scales";
    EmployeeChangeRequest: Record "Employee Change Request";
    ContractChangeLines: Record "Contract Change Lines";
    EndDate: Date;
    StartDate: Date;
    HRJobs: Record "Company Jobs";
    EmployeeContractDetails: Record "Employee Contract Details";
    EmployeeDonors: Record "Employee Donors";
    NewEmployeeDonors: Record "New Employee Donors";
    SalaryScalePointers: Record "Salary Scale Pointers";
}
