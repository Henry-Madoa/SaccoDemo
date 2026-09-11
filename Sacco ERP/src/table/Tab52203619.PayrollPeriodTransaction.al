table 52203619 "Payroll Period Transaction"
{
    fields
    {
        field(1; "Employee Code"; Code[50])
        {
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Employee Code") then begin
                    "Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
                    "Global Dimension 2 Code" := Employee."Global Dimension 2 Code";
                    "Staff Name" := Employee.FullName;
                    "Payment Held" := Employee."Suspend Pay";
                end;
            end;
        }
        field(2; "Transaction Code"; Text[30])
        {
            TableRelation = "Payroll Transaction Code".Code;
        }
        field(3; "Group Text"; Text[30])
        {
        }
        field(4; "Transaction Name"; Text[200])
        {
        }
        field(5; Amount; Decimal)
        {
        }
        field(6; Balance; Decimal)
        {
        }
        field(7; "Original Amount"; Decimal)
        {
        }
        field(8; "Group Order"; Integer)
        {
        }
        field(9; "Sub Group Order"; Integer)
        {
        }
        field(10; "Period Month"; Integer)
        {
        }
        field(11; "Period Year"; Integer)
        {
        }
        field(12; "Period Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(13; "Payroll Period"; Date)
        {
            TableRelation = "Payroll Periods"."Start Date";
        }
        field(14; Membership; Code[50])
        {
        }
        field(15; "Reference No"; Text[20])
        {
        }
        field(16; "Department Code"; Code[20])
        {
        }
        field(17; Lumpsumitems; Boolean)
        {
        }
        field(18; TravelAllowance; Code[20])
        {
        }
        field(19; "GL Account"; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(20; "Company Deduction"; Boolean)
        {
        }
        field(21; "Emp Amount"; Decimal)
        {
        }
        field(22; "Emp Balance"; Decimal)
        {
        }
        field(23; "Journal Account Code"; Code[20])
        {
        }
        field(24; "Journal Account Type"; Option)
        {
            OptionCaption = ' ,G/L Account,Customer,Vendor,Credit,Savings';
            OptionMembers = " ","G/L Account",Customer,Vendor,Credit,Savings;
        }
        field(25; "Post As"; Option)
        {
            OptionMembers = " ",Debit,Credit;
        }
        field(26; "Loan Number"; Code[50])
        {
        }
        field(27; "Coop Parameters"; Option)
        {
            OptionMembers = "none",shares,loan,"loan Interest","Emergency loan","Emergency loan Interest","School Fees loan","School Fees loan Interest",Welfare,Pension,NSSF,Overtime,"Benevolent Fund";
        }
        field(28; "Payroll Code"; Code[20])
        {
        }
        field(29; "Payment Mode"; Option)
        {
            OptionMembers = " ","Bank Transfer",Cheque,Cash,SACCO;
        }
        field(30; "Location/Division"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4));
        }
        field(31; Department; Code[20])
        {
        }
        field(32; "Cost Centre"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('COSTCENTRE'));
        }
        field(33; "Salary Grade"; Code[20])
        {
        }
        field(34; "Salary Notch"; Code[20])
        {
        }
        field(35; "Payslip Order"; Integer)
        {
        }
        field(36; "No. Of Units"; Decimal)
        {
        }
        field(37; "Employee Classification"; Code[20])
        {
        }
        field(38; State; Code[20])
        {
            TableRelation = "Post Code";
        }
        field(39; "New Departmental Code"; Code[20])
        {
        }
        field(40; grants; Code[20])
        {
        }
        field(41; "Bank Code"; Code[10])
        {
        }
        field(42; "Branch Code"; Code[10])
        {
        }
        field(43; "A/C Number"; Code[20])
        {
        }
        field(44; "Bank Details"; Text[100])
        {
        }
        field(45; "Branch Details"; Text[100])
        {
        }
        field(50001; "Emp Status"; Option)
        {
            CalcFormula = Lookup(Employee.Status WHERE("No." = FIELD("Employee Code")));
            FieldClass = FlowField;
            OptionMembers = New,"Pending Approval",Active,InActive;
        }
        field(39003900; "Global Dimension 1 Code"; Code[70])
        {
            CalcFormula = Lookup(Employee."Global Dimension 1 Code" WHERE("No." = FIELD("Employee Code")));
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            FieldClass = FlowField;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));
        }
        field(39003901; "Global Dimension 2 Code"; Code[70])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = const(false));
        }
        field(39003902; "Contract Type"; Code[20])
        {
        }
        field(39003903; "Transaction Type"; Option)
        {
            OptionCaption = 'Income,Deduction,Company Deduction';
            OptionMembers = Income,Deduction,"Company Deduction";
        }
        field(39003904; "Posting Group"; Code[30])
        {
        }
        field(39003905; "Staff Name"; Text[250])
        {
            CalcFormula = Lookup(Employee."Search Name" WHERE("No." = FIELD("Employee Code")));
            FieldClass = FlowField;
        }
        field(39003906; "Post To Journal"; Boolean)
        {
        }
        field(39003907; "P10 Allowance Type"; Option)
        {
            OptionCaption = ' ,House,Transport,Leave,Over Time,Directors Fee';
            OptionMembers = " ",House,Transport,Leave,"Over Time","Directors Fee";
        }
        field(39003908; "Payment Held"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(39003909; "Amount Held"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(39003910; "Reason For Hold"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(39003911; "Post In"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,ERP,CBS';
            OptionMembers = " ",ERP,CBS;
        }
        field(39003912; Subledger; Enum "Gen. Journal Account Type")
        {
            DataClassification = ToBeClassified;
        }
        field(39003913; "Imprest No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee Code", "Transaction Code", "Period Month", "Period Year", Membership, "Reference No")
        {
            SumIndexFields = Amount, "No. Of Units";
        }
        key(Key2; "Employee Code", "Period Month", "Period Year", "Group Order", "Sub Group Order", "Payslip Order", Membership, "Reference No")
        {
            SumIndexFields = Amount, "No. Of Units";
        }
        key(Key3; "Group Order", "Transaction Code", "Period Month", "Period Year", Membership, "Reference No", "Department Code")
        {
            SumIndexFields = Amount, "No. Of Units";
        }
        key(Key4; Membership)
        {
        }
        key(Key5; "Transaction Code", "Payroll Period", Membership, "Reference No")
        {
            SumIndexFields = Amount, "No. Of Units";
        }
        key(Key6; "Payroll Period", "Group Order", "Sub Group Order")
        {
            SumIndexFields = Amount, "No. Of Units";
        }
        key(Key7; "Employee Code", "Department Code")
        {
            SumIndexFields = Amount, "No. Of Units";
        }
        key(Key8; "Transaction Code", "Employee Code", "Payroll Period", "Location/Division", Department)
        {
            SumIndexFields = Amount, "No. Of Units";
        }
        key(Key9; "Payslip Order")
        {
        }
        key(Key10; "Transaction Code", "Employee Code", "Payroll Period", "Reference No")
        {
        }
        key(Key11; Department)
        {
            SumIndexFields = Amount;
        }
    }
    trigger OnDelete()
    begin
        /*
                    PRPayrollPeriods.RESET;
                    IF PRPayrollPeriods.GET("Payroll Period") THEN
                    BEGIN
                        IF PRPayrollPeriods.Closed = TRUE THEN
                        BEGIN
                            ERROR(Text001,'DELETE',"Payroll Period");
                        end;
                    end;
                    */
    end;

    trigger OnInsert()
    begin
        /*
                    PRPayrollPeriods.RESET;
                    IF PRPayrollPeriods.GET("Payroll Period") THEN
                    BEGIN
                        IF PRPayrollPeriods.Closed = TRUE THEN
                        BEGIN
                            ERROR(Text001,'INSERT',"Payroll Period");
                        end;
                    end;
                    */
    end;

    trigger OnModify()
    begin
        PRPayrollPeriods.Reset;
        if PRPayrollPeriods.Get("Payroll Period") then begin
            if PRPayrollPeriods.Closed = true then begin
                //    ERROR(Text001,'MODIFY',"Payroll Period");
            end;
        end;
    end;

    trigger OnRename()
    begin
        PRPayrollPeriods.Reset;
        if PRPayrollPeriods.Get("Payroll Period") then begin
            if PRPayrollPeriods.Closed = true then begin
                Error(Text001, 'RENAME', "Payroll Period");
            end;
        end;
    end;

    var
        PRPayrollPeriods: Record "Payroll Periods";
        Text001: Label 'You cannot [ %1  ] records in this Payroll Period [ %2  ] because it is CLOSED';
        Employee: Record Employee;
}
