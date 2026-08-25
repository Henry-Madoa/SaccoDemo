table 52204099 "Checkoff Advice"
{
    LookupPageId = "Checkoff Advice";
    DrillDownPageId = "Checkoff Advice";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No"; Code[20])
        {
        }
        field(3; "Amount On"; Decimal)
        {
        }
        field(4; "Amount Off"; Decimal)
        {
        }
        field(5; "Current Balance"; Decimal)
        {
        }
        field(6; "Loan No"; Code[20])
        {
            trigger OnValidate()
            var
                Loans: Record Loans;
            begin
                If Loans.Get("Loan No") then begin
                    "Recovery Mode" := Loans."Recovery Mode";
                end;
            end;
        }
        field(7; "Recovery Mode"; Enum "Recovery Modes")
        {
        }
        field(8; "Loan Account"; Code[20])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Loans."Loan Account" where("No." = field("Loan No")));
        }
        field(9; Installments; Integer)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Loans.Installments where("No." = field("Loan No")));
        }
        field(10; "Payroll No."; Code[20])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Payroll No." where("No." = field("Member No")));
        }
        field(11; "Product Code"; Code[20])
        {
        }
        field(12; "Product Name"; Text[100])
        {
        }
        field(13; "Advice Type"; Option)
        {
            OptionMembers = Adjustment,"New Loan","New Member",RMF,Stoppage;
        }
        field(14; "Advice Date"; Date)
        {
        }
        field(15; "Posting Date"; Date)
        {
        }
        field(16; "Employer Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Employer Code" where("No." = field("Member No")));
            TableRelation = Employers;
        }
        field(17; "Member Name"; Text[100])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Full Name" where("No." = field("Member No")));
        }
        // field(18; "Payroll No"; Code[40])
        // {
        //     DataClassification = ToBeClassified;
        //     Editable = false;
        // }
        field(19; "Approved Amount"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Loans."Approved Amount" where("No." = field("Loan No")));
        }
        field(20; "Principal Repayment"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = max("Loan Schedule"."Principal Repayment" where("Loan No." = field("Loan No"), "Expected Date" = field("Date Filter")));
        }
        field(21; "Interest Repayment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = max("Loan Schedule"."Interest Repayment" where("Loan No." = field("Loan No"), "Expected Date" = field("Date Filter")));
        }
        field(22; "Monthly Repayment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = max("Loan Schedule"."Monthly Repayment" where("Loan No." = field("Loan No"), "Expected Date" = field("Date Filter")));
        }
        field(23; "Total Repayment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Schedule"."Monthly Repayment" WHERE("Loan No." = field("Loan No"), "Expected Date" = field("Date Filter")));
        }
        field(24; "Total Principal Repayment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Schedule"."Principal Repayment" WHERE("Loan No." = field("Loan No"), "Expected Date" = field("Date Filter")));
        }
        field(25; "Total Interest Repayment"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Loan Schedule"."Interest Repayment" WHERE("Loan No." = field("Loan No"), "Expected Date" = field("Date Filter")));
        }
        field(26; "Loan Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No." = field("Loan Account"), "Loan No." = field("Loan No"), "Posting Date" = field("Date Filter")));
        }
        field(27; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
    }
}
