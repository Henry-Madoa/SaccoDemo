table 52203612 "Payroll Transaction Code"
{
    DrillDownPageID = "Payroll Transaction Codes";
    LookupPageID = "Payroll Transaction Codes";

    fields
    {
        field(1; Code; Code[20])
        {
            Description = 'Unique Trans line code';
        }
        field(2; Name; Text[100])
        {
            Description = 'Description';
        }
        field(3; "Balance Type"; Option)
        {
            Description = 'None,Increasing,Reducing';
            OptionMembers = "None",Increasing,Reducing;
        }
        field(4; Type; Option)
        {
            Description = 'Income,Deduction,Company Deduction';
            OptionMembers = Income,Deduction,"Company Deduction";
        }
        field(5; Frequency; Option)
        {
            Description = 'Fixed,Varied';
            OptionMembers = "Fixed",Varied;
        }
        field(6; "Is Cash"; Boolean)
        {
            Description = 'Does staff receive cash for this transaction';
        }
        field(7; Taxable; Boolean)
        {
            Description = 'Is it taxable or not';

            trigger OnValidate()
            begin
                //TESTFIELD("Transaction Type","Transaction Type"::Income);
            end;
        }
        field(8; "Is Formula"; Boolean)
        {
            Description = 'Is the transaction based on a formula';
        }
        field(9; Formula; Text[200])
        {
            Description = '[Formula] If the above field is "Yes", give the formula';
        }
        field(10; "Amount Preference"; Option)
        {
            Description = 'Either (Posted Amount), (Take Higher) or (Take Lower)';
            OptionMembers = "Posted Amount","Take Higher","Take Lower ";
        }
        field(11; "Special Transactions"; Enum "Payroll Transaction Types")
        {
            Description = 'Represents all Special Transactions';
        }
        field(12; "Deduct Premium"; Boolean)
        {
            Description = '[Insurance] Should the Premium be treated as a payroll deduction?';
        }
        field(13; "Interest Rate"; Decimal)
        {
            Description = '[Loan] If above is "Yes", give the interest rate';
        }
        field(14; "Repayment Method"; Option)
        {
            Description = '[Loan] Reducing,Straight line';
            OptionMembers = Reducing,"Straight line",Amortized;
        }
        field(15; "Fringe Benefit"; Boolean)
        {
            Description = '[Loan] should the loan be treated as a Fringe Benefit?';
        }
        field(16; "Employer Deduction"; Boolean)
        {
            Description = 'Caters for Employer Deductions';
        }
        field(17; isHouseAllowance; Boolean)
        {
        }
        field(18; "Include Employer Deduction"; Boolean)
        {
        }
        field(19; "Is Formula for employer"; Text[200])
        {
        }
        field(20; "Transaction Code old"; Code[50])
        {
        }
        field(21; "GL Account No."; Code[20])
        {
            TableRelation = "G/L Account" where(Blocked = const(false), "Direct Posting" = const(true), "Account Type" = const(Posting));
        }
        field(22; "GL Employer Account"; Code[20])
        {
            TableRelation = "G/L Account" where(Blocked = const(false), "Direct Posting" = const(true), "Account Type" = const(Posting));
        }
        field(23; "Coop Parameter"; Option)
        {
            OptionMembers = "none",Shares,loan,"loan Interest","Emergency loan","Emergency loan Interest","School Fees loan","School Fees loan Interest",Welfare,Pension,NSSF,Overtime,"Benevolent Fund";
        }
        field(24; "Sacco Loan"; Boolean)
        {
        }
        field(25; "Deduct Mortgage"; Boolean)
        {
        }
        field(26; "Sub Ledger Type"; Option)
        {
            OptionMembers = " ",Customer,Vendor,Savings;
        }
        field(27; "Subledger Account"; Code[10])
        {
            TableRelation = if ("Sub Ledger Type" = const(Vendor)) Vendor where(Blocked = filter(<> All))
            else if ("Sub Ledger Type" = const(Customer)) Customer where(Blocked = filter(<> All))
            else if ("Sub Ledger Type" = const(Savings)) Vendor where("Account Type" = const(Sacco));
        }
        field(28; Welfare; Boolean)
        {
        }
        field(29; CustomerPostingGroup; Code[20])
        {
            TableRelation = "Customer Posting Group".Code;
        }
        field(30; "Show on Master Roll"; Boolean)
        {
        }
        field(31; "Vendor Posting Group"; Code[20])
        {
            TableRelation = "Vendor Posting Group";
        }
        field(32; "Is Voluntary"; Boolean)
        {
        }
        field(33; "Previous Month Filter"; Date)
        {
            FieldClass = FlowFilter;
            TableRelation = "Payroll Periods"."Start Date";
        }
        field(34; "Current Month Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(35; "Prev. Amount"; Decimal)
        {
            FieldClass = Normal;
        }
        field(36; "Curr. Amount"; Decimal)
        {
            FieldClass = Normal;
        }
        field(37; "Transaction Category"; Option)
        {
            OptionCaption = ' ,Housing,Transport,Other Allowances,NHF,Pension,Company Loan,Housing Deduction,Personal Loan,Inconvinience,Bonus Special,Other Deductions,Overtime,Entertainment,Leave,Utility,Other Co-deductions,Car Loan,Call Duty,Co-op,Lunch,Compassionate Loan';
            OptionMembers = " ",Housing,Transport,"Other Allowances",NHF,Pension,"Company Loan","Housing Deduction","Personal Loan",Inconvinience,"Bonus Special","Other Deductions",Overtime,Entertainment,Leave,Utility,"Other Co-deductions","Car Loan","Call Duty","Co-op",Lunch,"Compassionate Loan";
        }
        field(38; "Employee Code Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            TableRelation = Employee."No.";
        }
        field(39; Suspended; Boolean)
        {
        }
        field(40; "Include in Net"; Boolean)
        {
        }
        field(41; "Taxable Percentage"; Decimal)
        {
        }
        field(42; "No. Series"; Code[20])
        {
        }
        field(43; "IsTraining Deduction"; Boolean)
        {
        }
        field(44; "Is Salary Advance"; Boolean)
        {
        }
        field(45; "Is Income/Deduction"; Boolean)
        {
        }
        field(46; "iTax Grouping"; Option)
        {
            OptionMembers = " ","Housing Allowances","Transport Allowance",OT,"Directors Fees";
        }
        field(47; "Is HR Loan"; Boolean)
        {
        }
        field(48; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));

            trigger OnValidate()
            begin
                "Global Dimension 1 Name" := '';
                DimensionValue.Reset;
                DimensionValue.SetRange(DimensionValue.Code, "Global Dimension 1 Code");
                if DimensionValue.Find('-') then begin
                    "Global Dimension 1 Name" := DimensionValue.Name;
                end;
            end;
        }
        field(49; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = const(false));
        }
        field(50; "Global Dimension 1 Name"; Text[60])
        {
            Editable = false;
        }
        field(51; "Global Dimension 2 Name"; Text[60])
        {
            Editable = false;
        }
        field(52; "IsTransfer Allowance"; Boolean)
        {
        }
        field(53; "IsLeave Allowance"; Boolean)
        {
        }
        field(54; "IsActing Allowance"; Boolean)
        {
        }
        field(55; "Group Code"; Code[20])
        {
        }
        field(56; "Group Description"; Text[50])
        {
        }
        field(57; "Loan Product Type"; Code[20])
        {
        }
        field(58; "Based on Loans"; Boolean)
        {
        }
        field(59; "Interest Code"; Code[20])
        {
        }
        field(60; "Interest Percentage"; Decimal)
        {
        }
        field(61; "Exempt Pension"; Boolean)
        {
        }
        field(62; "Is Pension"; Boolean)
        {
        }
        field(63; "Salary Recovery"; Boolean)
        {
        }
        field(64; "P10 Allowance Type"; Option)
        {
            OptionCaption = ' ,House,Transport,Leave,Over Time,Directors Fee';
            OptionMembers = " ",House,Transport,Leave,"Over Time","Directors Fee";
        }
        field(65; "Subject To Suspension"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(66; "Percentage To Hold"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(67; "Principal Loan"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payroll Transaction Code".Code WHERE(Type = CONST(Deduction), "Coop Parameter" = CONST(loan));
        }
        field(68; "For Every Employee"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(69; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70; "CBS Loan Instruction"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'None,Combine Loan And Interest,Separate Loan And Interest';
            OptionMembers = "None","Combine Loan And Interest","Separate Loan And Interest";
        }
        field(71; "Employee Category"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Long Term,Short Term,Both';
            OptionMembers = " ","Long Term","Short Term",Both;
        }
        field(72; "Specific Month"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(73; "Has Upper Limit"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(74; "Upper Limit"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(75; "Do not prorate"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

    }
    keys
    {
        key(Key1; Code)
        {
        }
        key(Key2; Name)
        {
        }
        key(Key3; Type)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Name)
        {
        }
    }
    trigger OnInsert()
    begin
        /*
                    IF "Transaction Type" = "Transaction Type"::Deduction THEN
                    BEGIN
                      IF "Transaction Code" = '' THEN
                      BEGIN
                          HRSetup.GET;
                          HRSetup.TESTFIELD(HRSetup."PR Deduction Nos.");
                          NoSeriesMgt.InitSeries(HRSetup."PR Deduction Nos.",xRec."No. Series",0D,"Transaction Code","No. Series");
                      end;
                    end;

                    IF "Transaction Type" = "Transaction Type"::Income THEN
                    BEGIN
                      IF "Transaction Code" = '' THEN
                      BEGIN
                          HRSetup.GET;
                          HRSetup.TESTFIELD(HRSetup."PR Allowances Nos.");
                          NoSeriesMgt.InitSeries(HRSetup."PR Allowances Nos.",xRec."No. Series",0D,"Transaction Code","No. Series");
                      end;
                    end;
                    */
    end;

    var
        PRTransCodes: Record "Payroll Period Transaction";
        HRSetup: Record "Human Resource Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimensionValue: Record "Dimension Value";
}
