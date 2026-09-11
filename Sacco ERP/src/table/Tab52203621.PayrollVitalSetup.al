table 52203621 "Payroll Vital Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Tax Relief"; Decimal)
        {
            Description = '[Relief]';
        }
        field(3; "Insurance Relief %"; Decimal)
        {
            Description = '[Relief]';
        }
        field(4; "Max Relief"; Decimal)
        {
            Description = '[Relief]';
        }
        field(5; "Mortgage Relief"; Decimal)
        {
            Description = '[Relief]';
        }
        field(6; "Max Pension Contribution"; Decimal)
        {
            Description = '[Pension]';
        }
        field(7; "Tax On Excess Pension"; Decimal)
        {
            Description = '[Pension]';
        }
        field(8; "Loan Market Rate"; Decimal)
        {
            Description = '[Loans]';
        }
        field(9; "Loan Corporate Rate"; Decimal)
        {
            Description = '[Loans]';
        }
        field(10; "Taxable Pay (Normal)"; Decimal)
        {
            Description = '[Housing]';
        }
        field(11; "Taxable Pay (Agricultural)"; Decimal)
        {
            Description = '[Housing]';
        }
        field(12; "SHIF Based on"; Option)
        {
            Description = '[SHIF] - Gross,Basic,Taxable Pay';
            OptionMembers = Gross,Basic,"Taxable Pay";
        }
        field(13; "NSSF Employer Factor"; Decimal)
        {
            Description = '[NSSF]';
        }
        field(14; "OOI Deduction"; Decimal)
        {
            Description = '[OOI]';
        }
        field(15; "OOI December"; Decimal)
        {
            Description = '[OOI]';
        }
        field(16; "Security Day (U)"; Decimal)
        {
            Description = '[Servant]';
        }
        field(17; "Security Night (U)"; Decimal)
        {
            Description = '[Servant]';
        }
        field(18; "Ayah (U)"; Decimal)
        {
            Description = '[Servant]';
        }
        field(19; "Gardener (U)"; Decimal)
        {
            Description = '[Servant]';
        }
        field(20; "Security Day (R)"; Decimal)
        {
            Description = '[Servant]';
        }
        field(21; "Security Night (R)"; Decimal)
        {
            Description = '[Servant]';
        }
        field(22; "Ayah (R)"; Decimal)
        {
            Description = '[Servant]';
        }
        field(23; "Gardener (R)"; Decimal)
        {
            Description = '[Servant]';
        }
        field(24; "Benefit Threshold"; Decimal)
        {
            Description = '[Servant]';
        }
        field(25; "NSSF Based on"; Option)
        {
            Description = '[NSSF] - Gross,Basic,Taxable Pay';
            OptionMembers = Gross,Basic,"Taxable Pay";
        }
        field(26; "Value Posting"; Decimal)
        {
        }
        field(27; "Disbled Tax Limit"; Decimal)
        {
        }
        field(28; "Minimum Relief Amount"; Decimal)
        {
        }
        field(29; "Secondary Tax Percentage"; Decimal)
        {
        }
        field(30; "Mortgage Relief Percentage"; Decimal)
        {
        }
        field(31; "NHF - Maximum Age"; DateFormula)
        {
        }
        field(32; "Leave Allowance Percentage"; Decimal)
        {
        }
        field(33; "Incremental percentage"; Decimal)
        {
        }
        field(34; "Max. Leave Allowance"; Decimal)
        {
        }
        field(35; "Acting Allowance Percentage"; Decimal)
        {
        }
        field(36; "Acting Allowance Based On"; Option)
        {
            OptionCaption = ' ,Basic Pay,Gross Pay';
            OptionMembers = " ","Basic Pay","Gross Pay";
        }
        field(37; "Acting Allowance Duration"; DateFormula)
        {
        }
        field(38; "Leave Allowance Based On"; Option)
        {
            OptionMembers = " ","Basic Pay","Gross Pay","Net Pay";
        }
        field(39; "Training Deduction Percentage"; Decimal)
        {
        }
        field(40; "Market Rate"; Decimal)
        {
        }
        field(41; "SHIF %"; Decimal)
        {
        }
        field(42; "SHIF Relief %"; Decimal)
        {
        }
        field(43; "Enable SHIF Relief"; Boolean)
        {
            trigger OnValidate()
            begin
                if "Enable SHIF Relief" = false then "SHIF Relief %" := 0;
            end;
        }
        field(44; "Based On Hours worked"; Option)
        {
            OptionCaption = ' ,BasedOnWorkedHrs';
            OptionMembers = " ",BasedOnWorkedHrs;

            trigger OnValidate()
            var
                i: Integer;
            begin
                /*
                            HREmp.RESET;
                            IF HREmp.FIND('-') THEN
                            BEGIN
                                REPEAT
                                     i:=i+1;
                                    HREmp."Based On Hours worked":="Based On Hours worked";
                                    HREmp.VALIDATE(HREmp."Based On Hours worked");
                                     HREmp.MODIFY;
                                UNTIL HREmp.NEXT =0;
                                MESSAGE('%1 Employees Payroll will be calculated Based on attendance records',i);
                            end;
                            */
            end;
        }
        field(45; "Monthly Expected Work Hrs"; Decimal)
        {
        }
        field(46; prVitalSetup; Decimal)
        {
        }
        field(47; "Salary increment %"; Decimal)
        {
        }
        field(48; "Gratuity %"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(49; "NHF %"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50; "Activate NHF"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51; "NHF Based On"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Gross,Basic,Taxable Pay';
            OptionMembers = Gross,Basic,"Taxable Pay";
        }
        field(52; "Secondary Employee Tax %"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(53; "Graturity Percentage"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Weekdays Multiplier"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Monthly Working Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(56; "Weekend Multiplier"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(57; "Payroll Cut off Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(58; "Statutories Exclusion"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}
