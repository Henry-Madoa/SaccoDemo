table 52203571 "Employee Exit"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No." WHERE(Status=CONST(Active));

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then begin
                    "Employee Name":=Employee.FullName;
                    Grade:=Employee."Job Scale";
                    "Global Dimension 1 Code":=Employee."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=Employee."Global Dimension 2 Code";
                    "Global Dimension 3 Code":=Employee."Global Dimension 3 Code";
                    Employee.TestField("Notice Period");
                    //    "Global Dimension 4 Code":=Employee."Global Dimension 4 Code";
                    //    "Global Dimension 5 Code":=Employee."Global Dimension 5 Code";
                    if Employee."Probation Status" in[Employee."Probation Status"::Confirmed]then "Notice Period":=Employee."Notice Period";
                    if Employee."Probation Status" in[Employee."Probation Status"::"On Probation", Employee."Probation Status"::Extended]then Evaluate("Notice Period", '7D');
                    Validate("Job Code", Employee."Job Code");
                    "Payroll Grade":=Employee."Job Scale";
                    if Rec.Type in[Rec.Type::Renewal]then begin
                        "Contract start Date":=Employee."Employment Date";
                        "Contract start Date":=Employee."End of Contract Date";
                    end;
                end;
            end;
        }
        field(3; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Date of Exit"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Date of Exit" = 0D then exit;
                Rec.Testfield("Reason For Exit");
                Rec.Testfield("Date Of Notice");
                if GroundsForTermination.Get("Reason For Exit")then;
                If PayrollSalaryCard.Get("Employee No")then;
                FinalDuesCalculation.Reset;
                FinalDuesCalculation.SetRange("Employee No.", Rec."Employee No");
                FinalDuesCalculation.SetRange("Exit No", Rec."No.");
                if FinalDuesCalculation.FindSet then FinalDuesCalculation.DeleteAll;
                if "Date of Exit" < Today then Error('You cannot exit after expiry of your notice');
                if "Date of Exit" < "Date Of Notice" then Error('Date of exit cannot be less than date of exit');
                if "Date of Exit" < "Expiry of Notice" then "Notice Fully Served":="Notice Fully Served"::No
                else
                    "Notice Fully Served":="Notice Fully Served"::Yes;
                Employee.Get("Employee No");
                Employee.CalcFields("Annual Leave Balance");
                if Employee."Annual Leave Balance" <> 0 then begin
                    FinalDuesCalculation.Init;
                    FinalDuesCalculation."Employee No.":=Rec."Employee No";
                    FinalDuesCalculation."Days Balance":=Employee."Annual Leave Balance";
                    FinalDuesCalculation."Line No":=FinalDuesCalculation.Count + 1;
                    FinalDuesCalculation."Exit No":=Rec."No.";
                    FinalDuesCalculation.Description:='Leave Balance Payment';
                    FinalDuesCalculation.Type:=FinalDuesCalculation.Type::"Leave Encashment";
                    FinalDuesCalculation."Amount To Pay":=(PayrollSalaryCard."Basic Pay" / 30) * Employee."Annual Leave Balance";
                    FinalDuesCalculation.Amount:=FinalDuesCalculation."Amount To Pay";
                    if FinalDuesCalculation.Amount > 0 then FinalDuesCalculation.Insert;
                end;
                if(("Notice Fully Served" in["Notice Fully Served"::No]) and (GroundsForTermination.Type = GroundsForTermination.Type::Self))then begin
                    Rec.Testfield("Date of Exit");
                    FinalDuesCalculation.Init;
                    FinalDuesCalculation."Employee No.":=Rec."Employee No";
                    FinalDuesCalculation."Line No":=FinalDuesCalculation.Count + 1;
                    FinalDuesCalculation."Exit No":=Rec."No.";
                    FinalDuesCalculation.Description:='Notice Penalty';
                    FinalDuesCalculation."Days Balance":="Expiry of Notice" - "Date of Exit";
                    FinalDuesCalculation.Type:=FinalDuesCalculation.Type::"Notice Penalty";
                    FinalDuesCalculation."Amount To Pay":=("Expiry of Notice" - "Date of Exit") * (PayrollSalaryCard."Basic Pay" / 30);
                    FinalDuesCalculation.Amount:=FinalDuesCalculation."Amount To Pay";
                    if FinalDuesCalculation."Amount To Pay" > 0 then FinalDuesCalculation.Insert;
                end;
                if(("Notice Fully Served" in["Notice Fully Served"::No]) and (GroundsForTermination.Type = GroundsForTermination.Type::HR))then begin
                    Rec.Testfield("Date of Exit");
                    FinalDuesCalculation.Init;
                    FinalDuesCalculation."Employee No.":=Rec."Employee No";
                    FinalDuesCalculation."Line No":=FinalDuesCalculation.Count + 1;
                    FinalDuesCalculation."Exit No":=Rec."No.";
                    FinalDuesCalculation.Description:='Notice Income';
                    FinalDuesCalculation."Days Balance":="Expiry of Notice" - "Date of Exit";
                    FinalDuesCalculation.Type:=FinalDuesCalculation.Type::"Notice Income";
                    FinalDuesCalculation."Amount To Pay":=("Expiry of Notice" - "Date of Exit") * (PayrollSalaryCard."Basic Pay" / 30);
                    FinalDuesCalculation.Amount:=FinalDuesCalculation."Amount To Pay";
                    if FinalDuesCalculation."Amount To Pay" > 0 then FinalDuesCalculation.Insert;
                end;
                if not GroundsForTermination."Pay Gratuity" then exit;
                FinalDuesCalculation.Init;
                FinalDuesCalculation."Employee No.":=Rec."Employee No";
                FinalDuesCalculation."Line No":=FinalDuesCalculation.Count + 1;
                FinalDuesCalculation."Exit No":=Rec."No.";
                FinalDuesCalculation.Description:='Gratuity';
                FinalDuesCalculation.Type:=FinalDuesCalculation.Type::Gratuity;
                FinalDuesCalculation.Amount:=FinalDuesCalculation."Amount To Pay";
                if FinalDuesCalculation."Amount To Pay" > 0 then FinalDuesCalculation.Insert;
            end;
        }
        field(5; "Reason For Exit"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Grounds for Termination";

            trigger OnValidate()
            begin
                if GroundsForTermination.Get("Reason For Exit")then "Reason Description":=GroundsForTermination.Description
                else
                    "Reason Description":='';
            end;
        }
        field(6; Grade; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Global Dimension 1 Code"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
        }
        field(8; Status;Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Interview Conducted By"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";
        }
        field(13; "Notice Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Reason Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Job Code"; Code[20])
        {
            Editable = false;
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                If HRJobs.Get("Job Code")then begin
                    "Job Description":=HRJobs.Name;
                end;
            end;
        }
        field(16; "Job Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(17; "Payroll Grade"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Date Of Notice"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if xRec."Date Of Notice" <> Rec."Date Of Notice" then begin
                    "Date of Exit":=0D;
                    "Expiry of Notice":=0D;
                    FinalDuesCalculation.Reset;
                    FinalDuesCalculation.SetRange("Employee No.", Rec."Employee No");
                    FinalDuesCalculation.SetRange("Exit No", Rec."No.");
                    if FinalDuesCalculation.FindSet then FinalDuesCalculation.DeleteAll;
                end;
                if "Date Of Notice" = 0D then Employee.Get("Employee No");
                if Employee."Employment Date" > "Date Of Notice" then Error('Employment date cannot be higher than date of notice');
                "Expiry of Notice":=CalcDate("Notice Period", "Date Of Notice");
            end;
        }
        field(19; "Expiry of Notice"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Notice Fully Served"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Yes,No';
            OptionMembers = " ", Yes, No;
        }
        field(21; "Reasons For Not Serving Notice"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Date of Exit Interview"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Total Leave Balances"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Leave Day Worth"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Leave Pay"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(26; Gratuity; Decimal)
        {
            CalcFormula = Sum("Final Dues Calculation"."Amount To Pay" WHERE("Employee No."=FIELD("Employee No"), Type=FILTER("Notice Income"|"Notice Penalty")));
            FieldClass = FlowField;
        }
        field(27; "Basic Pay"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Approval Entries"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Document No."=FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(29; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Exit,Renewal';
            OptionMembers = "Exit", Renewal;
        }
        field(30; "Contract start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Contract Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Contract End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Renewal Period"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Format("Renewal Period") <> '' then "New Contract End Date":=CalcDate("Renewal Period", "Contract End Date");
            end;
        }
        field(34; "New Contract End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Global Dimension 2 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(36; "Global Dimension 3 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3));
        }
        field(37; "Global Dimension 4 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(4));
        }
        field(38; Pointer; Code[5])
        {
            DataClassification = ToBeClassified;
        }
        field(39; "Can Be Reemployed"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Interviwer Feedback"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Interviewer Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(42; "Pay Gratuity"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(43; "Current Contract Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(44; "Current Contract Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(45; "Current Contract End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(46; "Unreturned Asset Worth"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(47; "Global Dimension 5 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            HumanResourcesSetup.Get;
            HumanResourcesSetup.TestField("Exit Nos");
            NoSeriesManagement.InitSeries(HumanResourcesSetup."Exit Nos", "No. Series", 0D, "No.", "No. Series");
        end;
        "Created By":=UserId;
        "Created On":=WorkDate;
    end;
    var HumanResourcesSetup: Record "Human Resources Setup";
    Employee: Record Employee;
    UserSetup: Record "User Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    GroundsForTermination: Record "Grounds for Termination";
    LeaveTypes: Record "Leave Types";
    LeaveCalendar: Record "Leave Calendar";
    LeaveLedgerEntries: Record "Leave Ledger Entries";
    PayrollProcessing: Codeunit "Payroll Processing";
    GratuityCalculation: Codeunit "Gratuity Calculation";
    PayrollPeriods: Record "Payroll Periods";
    PayrollSalaryCard: Record "Payroll Salary Card";
    LeaveDaysToAccrueMatrix: Record "Leave Days To Accrue Matrix";
    FinalDuesCalculation: Record "Final Dues Calculation";
    EmployeeExit: Record "Employee Exit";
    HRJobs: Record "Company Jobs";
}
