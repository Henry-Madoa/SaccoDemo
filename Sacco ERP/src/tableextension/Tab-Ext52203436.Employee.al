tableextension 52203436 Employee extends Employee
{
    fields
    {
        // Add changes to table fields here
        modify("Job Title")
        {
        Width = 100;
        }
        modify("Company E-Mail")
        {
        trigger OnAfterValidate()
        begin
            UserSetup.Reset;
            UserSetup.SetRange("Employee No.", "No.");
            if UserSetup.FindFirst then begin
                UserSetup."E-Mail":="Company E-Mail";
                UserSetup.Modify(true);
            end;
        end;
        }
        modify("Phone No.")
        {
        trigger OnAfterValidate()
        begin
            UserSetup.Reset;
            UserSetup.SetRange("Employee No.", "No.");
            if UserSetup.FindFirst then begin
                UserSetup."Phone No.":="Phone No.";
                UserSetup.Modify(true);
            end;
        end;
        }
        modify("Manager No.")
        {
        Caption = 'Line Manager';

        trigger OnAfterValidate()
        begin
            if Employee.Get("Manager No.")then begin
                "Line Manager Name":=Employee.FullName;
                AppraisalHeader.Reset;
                AppraisalHeader.SetRange("Employee No", Rec."No.");
                AppraisalHeader.SetFilter(Status, '<>%1', AppraisalHeader.Status::Closed);
                if AppraisalHeader.FindFirst then begin
                    AppraisalHeader.Validate("Supervisor No", "Manager No.");
                    AppraisalHeader.Modify(true);
                end;
            end;
        end;
        }
        modify("Birth Date")
        {
        trigger OnAfterValidate()
        begin
            AgeValidation;
        end;
        }
        modify("Bank Branch No.")
        {
        TableRelation = "External Bank Branches" where("Bank Code"=field("Bank Code"));
        }
        modify(Title)
        {
        TableRelation = Title;
        }
        modify(Status)
        {
        trigger OnAfterValidate()
        begin
            if Rec.Status = Rec.Status::Active then "Employee Status":="Employee Status"::Active
            else if Rec.Status = Rec.Status::Inactive then "Employee Status":="Employee Status"::Inactive
                else if Rec.Status = Rec.Status::Terminated then "Employee Status":="Employee Status"::Terminated;
        end;
        }
        field(52203423; "Employee Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Employee,Employer,Driver,NYSC,Intern';
            OptionMembers = Employee, Employer, Driver, NYSC, Intern;
        }
        field(52203424; "National ID"; Code[10])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "National ID" = '' then exit;
                Employee.Reset;
                Employee.SetRange("National ID", Rec."National ID");
                if Employee.FindFirst then Error('%1 has this ID number', Employee.FullName);
                OnNationalIDValidation("National ID");
            end;
        }
        field(52203425; Age; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203426; "Physical Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203427; "Job Scale"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employee Payroll Scales".Scale;

            trigger OnValidate()
            begin
                if EmployeePayrollScales.Get("Job Scale")then begin
                    "Notice Period":=EmployeePayrollScales."Notice Period";
                    if "Long Term" then "Inpatient Ward Entitlement":=EmployeePayrollScales."Inpatient Ward Entitlement";
                end; // if "Job Grade" = '' then begin
                //     "Payroll Grade" := '';
                //     "Job Grade" := '';
                //     Validate("J-G Steps", '');
                // end;            // if xRec."Job Grade" <> Rec."Job Grade" then begin
                //     "Payroll Grade" := '';
                //     "Job Grade" := '';
                // end;
                "Payroll Grade":="Job Scale" + '.' + "J-G Steps";
            end;
        }
        field(52203428; "Nature Of Employment"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ", Contract, Permanent, Board, Seconded;
        }
        field(52203429; "Global Dimension 1 Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(52203430; "SHIF No."; Code[15])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "SHIF No." = '' then exit;
                Employee.Reset;
                Employee.SetRange("SHIF No.", Rec."SHIF No.");
                if Employee.FindFirst then Error('%1 has this SHIF number', Employee.FullName);
                if "SHIF No." = Format(0)then HasLower:=false;
                HasUpper:=false;
                HasNumeric:=false;
                KeyLen:=StrLen("SHIF No.");
                for i:=1 to StrLen("SHIF No.")do begin
                    case "SHIF No."[i]of 'A' .. 'Z': HasUpper:=true;
                    'a' .. 'z': HasLower:=true;
                    '0' .. '9': HasNumeric:=true;
                    end;
                end;
                if(not HasUpper) and (not HasNumeric) and (not HasNumeric)then Error('SHIF No. Must be alphanumeric');
            end;
        }
        field(52203431; "NSSF No."; Code[15])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "NSSF No." = '' then exit;
                Employee.Reset;
                Employee.SetRange("NSSF No.", Rec."NSSF No.");
                if Employee.FindFirst then Error('%1 has this nssf number', Employee.FullName); /*"NSSF Number":=UPPERCASE("NSSF Number");
                
                HasLower:=FALSE;
                HasUpper:=FALSE;
                HasNumeric:=FALSE;
                
                KeyLen := STRLEN("NSSF Number");
                
                FOR i := 1 TO STRLEN("NSSF Number") DO BEGIN
                  CASE "NSSF Number"[i] OF
                    'A'..'Z':
                      HasUpper := TRUE;
                    'a'..'z':
                      HasLower := TRUE;
                    '0'..'9':
                      HasNumeric := TRUE;
                  end;
                end;
                
                IF (HasUpper) OR (HasLower) THEN
                  ERROR('NSSF No. Must be numeric');
                */
            end;
        }
        field(52203432; "KRA Number"; Code[15])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "KRA Number" = '' then exit;
                Employee.Reset;
                Employee.SetRange("KRA Number", Rec."KRA Number");
                if Employee.FindFirst then Error('%1 has this kra number', Employee.FullName);
                OnKRAPinValidation("KRA Number");
            end;
        }
        field(52203433; "Marital Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Single,Married,Separated,Divorced,Widow(er),Other';
            OptionMembers = " ", Single, Married, Separated, Divorced, "Widow(er)", Other;
        }
        field(52203434; "Suspend Leave Application"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203435; "Suspend Pay"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203436; "Date of Leaving"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(52203437; Disabled; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if not Disabled then "Disability Id":='';
            end;
        }
        field(52203438; "Describe Disability"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(52203439; "Board Category"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Board Member Categories";
        }
        field(52203440; "Surrendered Imprest"; Integer)
        {
            CalcFormula = Count("Request Header" WHERE("Employee No."=FIELD("No."), "Request Type"=CONST(Imprest), Surrendered=CONST(true), Status=CONST(Approved), Posted=CONST(true)));
            FieldClass = FlowField;
        }
        field(52203441; "Unserended Imprest"; Integer)
        {
            CalcFormula = Count("Request Header" WHERE("Employee No."=FIELD("No."), "Request Type"=CONST(Imprest), Surrendered=CONST(true), Status=CONST(Approved), Posted=CONST(true)));
            FieldClass = FlowField;
        }
        field(52203442; "End of Probation Period"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(52203443; "End of Contract Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(52203444; "Annual Leave Balance"; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('ANNUAL'), Closed=CONST(false)));
            FieldClass = FlowField;
        }
        field(52203445; "Martenity Leave Balance"; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('MATERNITY'), Closed=CONST(false)));
            FieldClass = FlowField;
        }
        field(52203446; "Study Leave Balance"; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('STUDY'), Closed=CONST(false)));
            FieldClass = FlowField;
        }
        field(52203447; "Partenity Leave Balance"; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('PATERNITY'), Closed=CONST(false)));
            FieldClass = FlowField;
        }
        field(52203448; "Compasionate Leave Balance"; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('COMPASSION'), Closed=CONST(false)));
            FieldClass = FlowField;
        }
        field(52203449; "Compulsory Leave Balance"; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('COMPULSORY'), Closed=CONST(false)));
            FieldClass = FlowField;
        }
        field(52203450; "Terminal Leave Balance"; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('TERMINAL'), Closed=CONST(false)));
            FieldClass = FlowField;
        }
        field(52203451; "Unpaid Leave Balance"; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('ANNUAL'), Closed=CONST(false)));
            FieldClass = FlowField;
        }
        field(52203452; "Max Imprest Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52203453; "Global Dimension 3 Code"; Code[50])
        {
            CaptionClass = '1,2,3';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), "Dimension Value Type"=CONST(Standard), Blocked=CONST(false));

            trigger OnValidate()
            begin
                DimensionValue.Reset;
                DimensionValue.SetRange("Dimension Code", 'DEPARTMENT');
                DimensionValue.SetRange(Code, "Global Dimension 3 Code");
                if DimensionValue.FindFirst then "Department Name":=DimensionValue.Name;
            end;
        }
        field(52203454; "Period To Retirement"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203455; "Job Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Company Jobs";

            trigger OnValidate()
            var
                HRJob: Record "Company Jobs";
            begin
                If HRJob.Get("Job Code")then begin
                    "Job Title":=HRJob.Name;
                end;
            end;
        }
        field(52203456; "Service Period"; Text[40])
        {
            DataClassification = ToBeClassified;
        }
        field(52203457; "Serving Notice"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203458; "Notice Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203459; "Maximum Applicable Trainings"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52203460; "Passport Number"; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Passport Number" = '' then exit;
                Employee.Reset;
                Employee.SetRange("Passport Number", Rec."Passport Number");
                if Employee.FindFirst then Error('%1 has this passport number', Employee.FullName);
            end;
        }
        field(52203461; "Reason For Pay Suspension"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(52203462; "Percentage To Hold"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52203463; "Probabtion Extended By"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203464; "New Probation Period End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(52203465; "Reasons For Extension"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(52203466; "County of Origin"; Text[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Counties;
        }
        field(52203467; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = ToBeClassified;
            TableRelation = "User Setup"."User ID";

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
            end;
            trigger OnValidate()
            var
                UserMgt: Codeunit "User Management";
            begin
                if UserSetup.Get("User ID")then begin
                    UserSetup.Validate("Employee No.", Rec."No.");
                    UserSetup.Modify(true);
                end;
            end;
        }
        field(52203468; "Probation Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,On Probation,Terminated,Confirmed,Extended';
            OptionMembers = " ", "On Probation", Terminated, Confirmed, Extended;

            trigger OnValidate()
            begin
                if "Probation Status" in["Probation Status"::"On Probation", "Probation Status"::Extended]then begin
                    EmployeePayrollScales.Get("Job Scale");
                    "Notice Period":=EmployeePayrollScales."Probation Notice Period";
                end;
                if "Probation Status" in["Probation Status"::Confirmed]then begin
                    EmployeePayrollScales.Get("Job Scale");
                    "Notice Period":=EmployeePayrollScales."Notice Period";
                end;
            end;
        }
        field(52203469; "Probation Period Extended"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203470; "Payroll Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203471; "Sub-County"; Text[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sub Counties"."Sub County Code" WHERE("County Code"=FIELD("County of Origin"));
        }
        field(52203472; "Approval Entries"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Document No."=FIELD("No.")));
            FieldClass = FlowField;
        }
        field(52203473; Location; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203474; "Sub-Location"; Text[50])
        {
        }
        field(52203475; Village; Text[50])
        {
        }
        field(52203476; "Payment Methods"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payment Method".Code;
        }
        field(52203477; "Location Code"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
        }
        field(52203478; "Grant Approver"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if xRec."Grant Approver" <> Rec."Grant Approver" then begin
                    if xRec."Grant Approver" <> '' then begin
                        Employee.Reset;
                        Employee.SetRange("Grant Approver", xRec."Grant Approver");
                        if not Employee.FindFirst then if GrantApprovers.Get(xRec."Grant Approver", GrantApprovers.Level::"Grant Approver")then GrantApprovers.Delete;
                    end;
                    if(xRec."Grant Approver" = '') and (Rec."Grant Approver" <> '')then begin
                        if not GrantApprovers.Get("Grant Approver", GrantApprovers.Level::"Grant Approver")then begin
                            GrantApprovers.Init;
                            GrantApprovers."Emp No":="Grant Approver";
                            GrantApprovers.Level:=GrantApprovers.Level::"Grant Approver";
                            GrantApprovers.Insert;
                        end;
                    end;
                    if(xRec."Grant Approver" <> '') and (Rec."Grant Approver" <> '')then begin
                        if not GrantApprovers.Get("Grant Approver", GrantApprovers.Level::"Grant Approver")then begin
                            GrantApprovers.Init;
                            GrantApprovers."Emp No":="Grant Approver";
                            GrantApprovers.Level:=GrantApprovers.Level::"Grant Approver";
                            GrantApprovers.Insert;
                        end;
                    end;
                end;
                if Employee.Get("Grant Approver")then "Grant Approver Name":=Employee.FullName;
            end;
        }
        field(52203479; ProfileID; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(52203480; "Employee Category"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203481; "J-G Steps"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salary Scale Pointers".Pointer WHERE(Scale=FIELD("Job Scale"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if(Rec."J-G Steps" <> xRec."J-G Steps") and (xRec."J-G Steps" <> '')then begin
                    if not Confirm('You are about to change the grade of Employee ' + Format("No." + ':' + FullName) + '\ The Effects of doing this will be \' + '\ 1. Payroll Earnings and deductions only related to the previous pointer will be replaced' + 'with earnings and deductions of new notch' + '\ 2. Basic pay of the employee will be replaced with the basic pay linked to the new notch' + '\ Do you still wish to continue?')then begin
                        "Job Scale":=xRec."J-G Steps";
                        Rec.Modify(true);
                        exit;
                    end;
                end;
                if(Rec."J-G Steps" = '') and (xRec."J-G Steps" <> '')then begin
                    if PayrollSalaryCard.Get("No.")then begin
                        PayrollSalaryCard."Basic Pay":=0;
                        PayrollSalaryCard."Pays SHIF":=false;
                        PayrollSalaryCard."Pays NSSF":=false;
                        PayrollSalaryCard."Pays PAYE":=false;
                        PayrollSalaryCard.Modify(true);
                    end;
                    PayrollEmployeeTransaction.Reset;
                    PayrollEmployeeTransaction.SetRange("Employee Code", "No.");
                //    IF PayrollEmployeeTransaction.FINDSET THEN
                //      PayrollEmployeeTransaction.DELETEALL;
                end;
                if(Rec."J-G Steps" <> xRec."J-G Steps")then begin
                    if PayrollSalaryCard.Get("No.")then begin
                        PayrollSalaryCard."Basic Pay":=0;
                        PayrollSalaryCard."Pays SHIF":=false;
                        PayrollSalaryCard."Pays NSSF":=false;
                        PayrollSalaryCard."Pays PAYE":=false;
                        PayrollSalaryCard.Modify(true);
                    end;
                    IncomeDeductionConfiguration.Reset;
                    IncomeDeductionConfiguration.SetRange(Scale, "Job Scale");
                    IncomeDeductionConfiguration.SetRange(Pointer, Rec."J-G Steps");
                    if IncomeDeductionConfiguration.FindSet then begin
                        repeat PayrollEmployeeTransaction.Reset;
                            PayrollEmployeeTransaction.SetRange("Employee Code", "No.");
                            PayrollEmployeeTransaction.SetRange("Transaction Code", IncomeDeductionConfiguration."Transaction Code");
                        //IF PayrollEmployeeTransaction.FIND('-') THEN
                        //PayrollEmployeeTransaction.DELETEALL;
                        until IncomeDeductionConfiguration.Next = 0;
                    end;
                end;
                if SalaryScalePointers.Get("Job Scale", "J-G Steps")then begin
                    if PayrollSalaryCard.Get("No.")then begin
                        PayrollSalaryCard."Basic Pay":=SalaryScalePointers."Basic Pay";
                        if not Disabled then begin
                            PayrollSalaryCard."Pays SHIF":=true;
                            PayrollSalaryCard."Pays NSSF":=true;
                            PayrollSalaryCard."Pays PAYE":=true;
                        end;
                        PayrollSalaryCard.Modify(true);
                    end;
                    if not PayrollSalaryCard.Get("No.")then begin
                        PayrollSalaryCard.Init;
                        PayrollSalaryCard.Validate("Employee Code", "No.");
                        if not Disabled then begin
                            PayrollSalaryCard."Pays SHIF":=true;
                            PayrollSalaryCard."Pays NSSF":=true;
                            PayrollSalaryCard."Pays PAYE":=true;
                        end;
                        PayrollSalaryCard."Basic Pay":=SalaryScalePointers."Basic Pay";
                        PayrollSalaryCard.Insert(true);
                    end;
                    IncomeDeductionConfiguration.Reset;
                    IncomeDeductionConfiguration.SetRange(Scale, "Job Scale");
                    IncomeDeductionConfiguration.SetRange(Pointer, Rec."J-G Steps");
                    if IncomeDeductionConfiguration.FindSet then begin
                        repeat PayrollEmployeeTransaction.Init;
                            PayrollEmployeeTransaction."Employee Code":="No.";
                            PayrollEmployeeTransaction.Validate("Employee Code");
                            PayrollEmployeeTransaction."Transaction Code":=IncomeDeductionConfiguration."Transaction Code";
                            PayrollEmployeeTransaction.Validate("Transaction Code");
                            PayrollEmployeeTransaction.Validate(Amount, IncomeDeductionConfiguration.Amount);
                            PayrollEmployeeTransaction.Insert(true);
                        until IncomeDeductionConfiguration.Next = 0;
                    end;
                end;
                "Payroll Grade":="Job Scale" + '-' + "J-G Steps";
            end;
        }
        field(52203482; "Ethnic Origin"; Text[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Tribes;
        }
        field(52203483; "Driving License"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203484; "Reimbursed Leave Days"; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('ANNUAL'), Closed=CONST(false), "Leave Entry Type"=CONST(Reimbursement)));
            FieldClass = FlowField;
        }
        field(52203485; "Allocated Leave Days"; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('ANNUAL'), Closed=CONST(false), "Leave Entry Type"=filter(Positive|OpeinigBalance|Accrued)));
            FieldClass = FlowField;
        }
        field(52203486; "Total Leave Days Taken"; Decimal)
        {
            Editable = false;
            CalcFormula = -Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('ANNUAL'), Closed=CONST(false), "Leave Entry Type"=CONST(Negative)));
            FieldClass = FlowField;
        }
        field(52203487; "Type of Employee"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Contract,Expertriate(Payable),Expertriate(Non-Payable),Casual,Part Time,Seconded,Arch,Permanent';
            OptionMembers = Contract, "Expertriate-Payable", "Expertriate-Non-Payable", Casual, "Part Time", Seconded, Arch, Permanent;
        }
        field(52203488; Religion; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Religions.Religion;
        }
        field(52203489; "Health Conditions"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(52203490; "Date of joining Medical Scheme"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(52203491; Currency; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Currency;
        }
        field(52203492; "Bank Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "External Banks";

            trigger OnValidate()
            begin
                if KenyaBankCodes.Get("Bank Code")then "Bank Name":=KenyaBankCodes."Bank Name";
            end;
        }
        field(52203493; "Bank Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(52203494; "Branch Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(52203495; "Active Contract Code"; Code[50])
        {
            CalcFormula = Lookup("Employee Contract Details"."Contract Code" WHERE("Employee No"=FIELD("No."), "Contract Status"=CONST(Active)));
            FieldClass = FlowField;
            TableRelation = "Employment Contract".Code;
        }
        field(52203496; "Contract Start Date"; Date)
        {
            CalcFormula = Lookup("Employee Contract Details"."Contract Start Date" WHERE("Employee No"=FIELD("No."), "Contract Status"=CONST(Active)));
            FieldClass = FlowField;
        }
        field(52203497; "Contract End Date"; Date)
        {
            CalcFormula = Lookup("Employee Contract Details"."Contract End Date" WHERE("Employee No"=FIELD("No."), "Contract Status"=CONST(Active)));
            FieldClass = FlowField;
        }
        field(52203498; "Disability Id"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(52203499; "Global Dimension 4 Code"; Code[50])
        {
            CaptionClass = '1,2,4';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(4), "Dimension Value Type"=CONST(Standard), Blocked=CONST(false));

            trigger OnValidate()
            begin
                DimensionValue.Reset;
                DimensionValue.SetRange("Dimension Code", 'SECTION');
                DimensionValue.SetRange(Code, "Global Dimension 4 Code");
                if DimensionValue.FindFirst then "Section Name":=DimensionValue.Name;
            end;
        }
        field(52203500; "Payroll Grade"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(52203501; "Long Term"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203502; "Overview Manager"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if xRec."Overview Manager" <> Rec."Overview Manager" then begin
                    if xRec."Overview Manager" <> '' then begin
                        Employee.Reset;
                        Employee.SetRange("Overview Manager", xRec."Overview Manager");
                        if not Employee.FindFirst then if GrantApprovers.Get(xRec."Overview Manager", GrantApprovers.Level::OverView)then GrantApprovers.Delete;
                    end;
                    if(xRec."Overview Manager" = '') and (Rec."Overview Manager" <> '')then begin
                        if not GrantApprovers.Get("Overview Manager", GrantApprovers.Level::OverView)then begin
                            GrantApprovers.Init;
                            GrantApprovers."Emp No":="Overview Manager";
                            GrantApprovers.Level:=GrantApprovers.Level::OverView;
                            GrantApprovers.Insert;
                        end;
                    end;
                    if(xRec."Overview Manager" <> '') and (Rec."Overview Manager" <> '')then begin
                        if not GrantApprovers.Get("Overview Manager", GrantApprovers.Level::OverView)then begin
                            GrantApprovers.Init;
                            GrantApprovers."Emp No":="Overview Manager";
                            GrantApprovers.Level:=GrantApprovers.Level::OverView;
                            GrantApprovers.Insert;
                        end;
                    end;
                    if Employee.Get("Overview Manager")then begin
                        "Overview Manager Name":=Employee.FullName;
                        AppraisalHeader.Reset;
                        //AppraisalHeader.SETRANGE("Overview Manager",xRec."Overview Manager");
                        AppraisalHeader.SetRange("Employee No", Rec."No.");
                        AppraisalHeader.SetFilter(Status, '<>%1', AppraisalHeader.Status::Closed);
                        if AppraisalHeader.FindFirst then begin
                            AppraisalHeader.Validate("Overview Manager", "Overview Manager");
                            AppraisalHeader.Modify(true);
                        end;
                    end;
                end;
            end;
        }
        field(52203503; "Alternative Phone No."; Code[13])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Alternative Phone No." = '' then exit;
                "Alternative Phone No.":=UpperCase("Alternative Phone No.");
                HasLower:=false;
                HasUpper:=false;
                HasNumeric:=false;
                KeyLen:=StrLen("Alternative Phone No.");
                for i:=1 to StrLen("Phone No.")do begin
                    case "Alternative Phone No."[i]of 'A' .. 'Z': HasUpper:=true;
                    'a' .. 'z': HasLower:=true;
                    '0' .. '9': HasNumeric:=true;
                    end;
                end;
                if(HasUpper) or (HasLower)then Error('Phone Number must be numeric');
            end;
        }
        field(52203504; "Global Dimension 5 Code"; Code[50])
        {
            CaptionClass = '1,2,5';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(5), "Dimension Value Type"=CONST(Standard), Blocked=CONST(false));
        }
        field(52203505; "Covered Medically"; Option)
        {
            DataClassification = ToBeClassified;
            Editable = true;
            OptionCaption = ' ,Yes,No';
            OptionMembers = " ", Yes, No;
        }
        field(52203506; "Global Dimension 6 Code"; Code[50])
        {
            CaptionClass = '1,2,6';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(6), "Dimension Value Type"=CONST(Standard), Blocked=CONST(false));
        }
        field(52203507; "Probation Period"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                //EVALUATE("Probation Period",ProbationDurationText);
                if Format("Probation Period") = '' then exit;
                "End of Probation Period":=CalcDate("Probation Period", "Employment Date");
                "End of Probation Period":=CalcDate('-1D', "End of Probation Period");
            end;
        }
        field(52203508; "Flout 1/3 Rule"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203509; "Inpatient Word Entitlment"; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = ' ,General,Semi Private,Private';
            OptionMembers = " ", General, "Semi Private", Private;
        }
        field(52203510; "Sick Leave Balance"; Decimal)
        {
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('SCK'), Closed=CONST(false)));
            FieldClass = FlowField;
        }
        field(52203511; "Inpatient Ward Entitlement"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,General,Semi Private,Private';
            OptionMembers = " ", General, "Semi Private", Private;
        }
        field(52203512; "Line Manager Name"; Text[70])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52203513; "Overview Manager Name"; Text[70])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52203514; "Grant Approver Name"; Text[70])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52203515; "Division Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(52203516; "Department Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(52203517; "Section Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(52203518; "Unit Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(52203519; "Dont Pay Gratuity"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203520; Housed; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if not Housed then begin
                    PayrollTransactionCode.Reset;
                    PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"House Allownace");
                    PayrollTransactionCode.FindFirst;
                    IncomeDeductionConfiguration.Reset;
                    IncomeDeductionConfiguration.SetRange(Scale, "Job Scale");
                    IncomeDeductionConfiguration.SetRange(Pointer, Rec."J-G Steps");
                    IncomeDeductionConfiguration.SetRange("Transaction Code", PayrollTransactionCode.Code);
                    IncomeDeductionConfiguration.FindFirst;
                    PayrollEmployeeTransaction.Init;
                    PayrollEmployeeTransaction.Validate("Employee Code", Rec."No.");
                    PayrollEmployeeTransaction.Validate("Transaction Code", PayrollTransactionCode.Code);
                    PayrollEmployeeTransaction.Validate(Amount, IncomeDeductionConfiguration.Amount);
                    PayrollTransactionCode.Insert;
                    PayrollTransactionCode.Reset;
                    PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::Rent);
                    PayrollTransactionCode.FindFirst;
                    PayrollEmployeeTransaction.Reset;
                    PayrollEmployeeTransaction.SetRange("Employee Code", Rec."No.");
                    PayrollEmployeeTransaction.SetRange("Transaction Code", PayrollTransactionCode.Code);
                    if PayrollEmployeeTransaction.FindFirst then PayrollEmployeeTransaction.DeleteAll end;
                if Housed then begin
                    PayrollTransactionCode.Reset;
                    PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::Rent);
                    PayrollTransactionCode.FindFirst;
                    PayrollEmployeeTransaction.Init;
                    PayrollEmployeeTransaction.Validate("Employee Code", Rec."No.");
                    PayrollEmployeeTransaction.Validate("Transaction Code", PayrollTransactionCode.Code);
                    PayrollEmployeeTransaction.Validate(Amount, Rec.Rent);
                    PayrollEmployeeTransaction.Insert;
                    PayrollTransactionCode.Reset;
                    PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"House Allownace");
                    PayrollTransactionCode.FindFirst;
                    PayrollEmployeeTransaction.Reset;
                    PayrollEmployeeTransaction.SetRange("Employee Code", Rec."No.");
                    PayrollEmployeeTransaction.SetRange("Transaction Code", PayrollTransactionCode.Code);
                    if PayrollEmployeeTransaction.FindFirst then PayrollEmployeeTransaction.DeleteAll end;
            end;
        }
        field(52203521; "Spouse Payroll No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Spouse Payroll No")then begin
                    "Spouse Name":=Employee.FullName;
                    if not Housed then exit;
                    PayrollTransactionCode.Reset;
                    PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"House Allownace");
                    PayrollTransactionCode.FindFirst;
                    PayrollEmployeeTransaction.Reset;
                    PayrollEmployeeTransaction.SetRange("Employee Code", Rec."Spouse Payroll No");
                    PayrollEmployeeTransaction.SetRange("Transaction Code", PayrollTransactionCode.Code);
                    if PayrollEmployeeTransaction.FindFirst then PayrollEmployeeTransaction.DeleteAll end;
            end;
        }
        field(52203522; "Spouse Name"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52203523; "Payroll Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Active,Inactive';
            OptionMembers = " ", Active, Inactive;
        }
        field(52203524; "Overtime Calculation"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Non unionizables,Unionizables';
            OptionMembers = " ", "Non unionizables", Unionizables;
        }
        field(52203525; Rent; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Housed then begin
                    PayrollTransactionCode.Reset;
                    PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::Rent);
                    PayrollTransactionCode.FindFirst;
                    PayrollPeriods.Reset;
                    PayrollPeriods.SetRange(Closed, false);
                    PayrollPeriods.FindFirst;
                    PayrollEmployeeTransaction.Init;
                    PayrollEmployeeTransaction.Validate("Employee Code", Rec."No.");
                    PayrollEmployeeTransaction.Validate("Transaction Code", PayrollTransactionCode.Code);
                    PayrollEmployeeTransaction.Validate(Amount, Rec.Rent);
                    if PayrollEmployeeTransaction.Get("No.", PayrollTransactionCode.Code, PayrollPeriods."Start Date", PayrollPeriods."Period Month", PayrollPeriods."Period Year")then begin
                        PayrollEmployeeTransaction.Amount:=Rent;
                        PayrollEmployeeTransaction.Modify;
                    end;
                    PayrollTransactionCode.Reset;
                    PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"House Allownace");
                    PayrollTransactionCode.FindFirst;
                    PayrollEmployeeTransaction.Reset;
                    PayrollEmployeeTransaction.SetRange("Employee Code", Rec."No.");
                    PayrollEmployeeTransaction.SetRange("Transaction Code", PayrollTransactionCode.Code);
                    if PayrollEmployeeTransaction.FindFirst then PayrollEmployeeTransaction.DeleteAll end;
            end;
        }
        field(52203526; Beedrooms; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52203527; "House Market Value"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52203528; "Bank Account Number"; Code[20])
        {
        }
        field(52203529; "Employee Status";Enum "Employee Status Ext")
        {
            trigger OnValidate()
            begin
                if "Employee Status" = "Employee Status"::Active then begin
                    Rec.Status:=Rec.Status::Active;
                    EmployeeMgmt.OnEmployeeMemberApplication(Rec);
                    EmployeeMgmt.RenameEmployeeOnApproval(Rec);
                end
                else if "Employee Status" = "Employee Status"::Inactive then Rec.Status:=Rec.Status::Inactive
                    else if "Employee Status" = "Employee Status"::Terminated then Rec.Status:=Rec.Status::Terminated;
            end;
        }
        field(52203530; "Employee Age"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52203531; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                OnValidateMemberNo(Rec, "Member No.");
            end;
        }
        field(52203532; "FOSA Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52203533; "Allowance Scale"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employee Payroll Scales".Scale;

            trigger OnValidate()
            begin
                IF EmployeePayrollScales.GET("Job Scale")THEN BEGIN
                    "Notice Period":=EmployeePayrollScales."Notice Period";
                    IF "Long Term" THEN "Inpatient Ward Entitlement":=EmployeePayrollScales."Inpatient Ward Entitlement";
                end;
                IF "Job Scale" = '' THEN BEGIN
                    "Payroll Grade":='';
                    "Job Scale":='';
                    VALIDATE("J-G Steps", '');
                end;
                IF xRec."Job Scale" <> Rec."Job Scale" THEN BEGIN
                    "Payroll Grade":='';
                    "Job Scale":='';
                end;
                "Payroll Grade":="Job Scale" + '.' + "J-G Steps";
            end;
        }
        field(52203534; "Checked In"; Boolean)
        {
        }
        field(52203535; "Period Filter"; Date)
        {
            FieldClass = FlowFilter;
            TableRelation = "Payroll Periods"."Start Date";
        }
        field(52203537; "Overtime Leave Balance"; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Leave Ledger Entries".Quantity WHERE("Employee No."=FIELD("No."), "Posting Date"=FIELD("Date Filter"), "Leave Type"=CONST('OVERTIME'), Closed=CONST(false)));
            FieldClass = FlowField;
        }
    }
    var KeyLen: Integer;
    i: Integer;
    HasUpper: Boolean;
    HasLower: Boolean;
    HasNumeric: Boolean;
    EmployeePayrollScales: Record "Employee Payroll Scales";
    PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
    PayrollSalaryCard: Record "Payroll Salary Card";
    IncomeDeductionConfiguration: Record "Income/Deduction Configuration";
    Employee: Record Employee;
    DimensionValue: Record "Dimension Value";
    SalaryScalePointers: Record "Salary Scale Pointers";
    KenyaBankCodes: Record "External Banks";
    UserSetup: Record "User Setup";
    GrantApprovers: Record "Grant Approvers";
    AppraisalHeader: Record "Appraisal Header";
    PayrollTransactionCode: Record "Payroll Transaction Code";
    PayrollPeriods: Record "Payroll Periods";
    HumanResSetup: Record "Human Resources Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    EmployeeMgmt: Codeunit "Employee Management";
    // LoanManagement: Codeunit "Loans Management";
    trigger OnBeforeInsert()
    begin
        if "No." = '' then begin
            HumanResSetup.Get;
            if "Type of Employee" in["Type of Employee"::Contract]then begin
                HumanResSetup.TestField("Employee Nos.");
                "Probation Status":="Probation Status"::"On Probation";
            end
            else if "Type of Employee" in["Type of Employee"::"Part Time"]then HumanResSetup.TestField("Maximum Imprest Amount")
                else if "Type of Employee" in["Type of Employee"::"Expertriate-Payable"]then HumanResSetup.TestField("Medical Expense Account")
                    else if "Type of Employee" in["Type of Employee"::"Expertriate-Non-Payable"]then HumanResSetup.TestField("Medical Expense Account");
            NoSeriesMgt.InitSeries(HumanResSetup."Employee Nos.", xRec."No. Series", 0D, "No.", "No. Series");
            Commit;
        end;
    end;
    local procedure AgeValidation()
    begin
        if "Birth Date" <> 0D then if((Date2DMY(WorkDate, 3) - Date2DMY("Birth Date", 3)) < 18)then Error('You cannot employ an underage candidate');
    end;
    [IntegrationEvent(false, false)]
    procedure OnKRAPinValidation(var KRAPIN: Code[20])
    begin
    end;
    [IntegrationEvent(false, false)]
    procedure OnNationalIDValidation(var NationalID: Code[20])
    begin
    end;
    [IntegrationEvent(false, false)]
    procedure OnValidateMemberNo(var Employee: Record Employee; var MemberNo: Code[20])
    begin
    end;
}
