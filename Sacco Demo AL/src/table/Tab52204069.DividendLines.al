table 52204069 "Dividend Lines"
{
    LookupPageId = "Dividend Lines";
    DrillDownPageId = "Dividend Lines";

    fields
    {
        field(1; "Dividend Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members;
        }
        field(3; "Member Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Automatic Amount Earned"; Decimal)
        {
            CalcFormula = Sum("Dividend Det. Entries".Amount WHERE("Dividend Code" = FIELD("Dividend Code"), "Member No." = FIELD("Member No."), "Destination Account" = FIELD("Account No")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Manual Amount Earned"; Decimal)
        {
            CalcFormula = Sum("Dividend Earned Entries".Amount WHERE("Dividend Code" = FIELD("Dividend Code"), "Member No." = FIELD("Member No."), "Destination Account" = FIELD("Account No")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Account Type"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Account No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Total Recoveries"; Decimal)
        {
            CalcFormula = Sum("Dividend Recoveries".Amount WHERE("Member No" = FIELD("Member No."), "Dividend Code" = FIELD("Dividend Code"), "Account No." = FIELD("Account No")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Net Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(11; "Savings Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = Vendor;
        }
        field(12; "Has Advance"; Boolean)
        {
            CalcFormula = Exist("Dividend Recoveries" WHERE("Dividend Code" = FIELD("Dividend Code"), "Entry Type" = const(Overdraft), "Member No" = FIELD("Member No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; Notified; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14; "Previous Month Balance"; Decimal)
        {
            CalcFormula = Sum("Dividend Det. Entries"."Previous Month Balance" WHERE("Dividend Code" = FIELD("Dividend Code"), "Member No." = FIELD("Member No."), "Destination Account" = FIELD("Account No")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Current Month Balance"; Decimal)
        {
            CalcFormula = Sum("Dividend Det. Entries"."Current Month Balance" WHERE("Dividend Code" = FIELD("Dividend Code"), "Member No." = FIELD("Member No."), "Destination Account" = FIELD("Account No")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Net Change"; Decimal)
        {
            CalcFormula = Sum("Dividend Det. Entries"."Net Change" WHERE("Dividend Code" = FIELD("Dividend Code"), "Member No." = FIELD("Member No."), "Destination Account" = FIELD("Account No")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Prefrential Boost"; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Customer.Get("Member No.") then begin
                    // "Prefrential Member" := Customer."Payout Allowed";
                end;
            end;
        }
        field(18; "Preferential Boost %"; Decimal)
        {
            DataClassification = ToBeClassified;
            MinValue = 1;
            MaxValue = 100;
        }
        field(19; "Boost Amount"; Decimal)
        {
            CalcFormula = Sum("Dividend Recoveries".Amount WHERE("Member No" = FIELD("Member No."), "Dividend Code" = FIELD("Dividend Code"), "Account No." = FIELD("Account No"), "Entry Type" = filter(Boost | "Preferential Boost")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Share Capital Boost Amount"; Decimal)
        {
            CalcFormula = Sum("Dividend Recoveries".Amount WHERE("Member No" = FIELD("Member No."), "Dividend Code" = FIELD("Dividend Code"), "Entry Type" = filter(Boost)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Phone No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Account Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Loans Recoveries"; Decimal)
        {
            CalcFormula = Sum("Dividend Recoveries".Amount WHERE("Member No" = FIELD("Member No."), "Dividend Code" = FIELD("Dividend Code"), "Account No." = FIELD("Account No"), "Entry Type" = filter("Interest Paid" | "Principal Paid" | "Principal Arrears" | "Interest Arrears")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(24; "Loan Arrears"; Decimal)
        {
            CalcFormula = Sum("Dividend Recoveries".Amount WHERE("Member No" = FIELD("Member No."), "Dividend Code" = FIELD("Dividend Code"), "Account No." = FIELD("Account No"), "Entry Type" = filter("Principal Arrears" | "Interest Arrears")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "Charges Amount"; Decimal)
        {
            CalcFormula = Sum("Dividend Recoveries".Amount WHERE("Member No" = FIELD("Member No."), "Dividend Code" = FIELD("Dividend Code"), "Account No." = FIELD("Account No"), "Entry Type" = CONST(Charges)));
            Editable = false;
            FieldClass = FlowField;
        }

        field(26; "Posting Description"; Text[100])
        {
        }
        field(27; Deceased; Boolean)
        {
        }
        field(28; "Blocked Account"; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; "Dividend Code", "Member No.", "Account Type", "Account No")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        //
    end;

    var
        Customer: Record Customer;
}
