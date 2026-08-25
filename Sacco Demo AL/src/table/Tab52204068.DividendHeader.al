table 52204068 "Dividend Header"
{
    fields
    {
        field(1; "No."; Code[10])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Document Type"; Option)
        {
            OptionMembers = BOSA,FOSA;
            Editable = false;
        }
        field(3; Description; Text[100])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Posting Description" = '' then "Posting Description" := Description;
            end;
        }
        field(4; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Created By"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup";
        }
        field(7; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; "Last Updated By"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup";
        }
        field(9; "Last Updated On"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Current Status"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Transaction Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Transaction Charges";
        }
        field(12; "Expense Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." WHERE("Direct Posting" = CONST(true));
        }
        field(13; "Payable Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." WHERE("Direct Posting" = CONST(true));
        }
        field(14; "Boost Shares"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Recover Loans"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Preferential Boost"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Posting Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Provisioning,Payout';
            OptionMembers = Provisioning,Payout;
        }
        field(18; "Posting Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(19; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Posted On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Posted By"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Total Net Amount"; Decimal)
        {
            CalcFormula = Sum("Dividend Lines"."Net Amount" WHERE("Dividend Code" = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(23; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(24; Scheduled; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(25; "Next Run Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Last Month"; Integer)
        {
            CalcFormula = max("Dividend Det. Entries"."Month No." WHERE("Dividend Code" = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(27; "Member Balances"; Decimal)
        {
            CalcFormula = Sum("Dividend Det. Entries"."Account Balance" WHERE("Dividend Code" = FIELD("No."), "Month No." = field("Last Month")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(28; "Dividend Year"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                //ValidateShortcutDimCode(1,"Global Dimension 1 Code");
            end;
        }
        field(30; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                //ValidateShortcutDimCode(2,"Global Dimension 2 Code");
            end;
        }
        field(31; "Boost to Minimum"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Maximum Boost Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(33; Status; Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(34; "Total Earned Amount"; Decimal)
        {
            CalcFormula = Sum("Dividend Det. Entries".Amount WHERE("Dividend Code" = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(35; "Boost Amount"; Decimal)
        {
            CalcFormula = Sum("Dividend Recoveries".Amount WHERE("Dividend Code" = FIELD("No."), "Entry Type" = filter(Boost | "Preferential Boost")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(36; Charges; Decimal)
        {
            CalcFormula = Sum("Dividend Recoveries".Amount WHERE("Dividend Code" = FIELD("No."), "Entry Type" = filter(Charges)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(37; "Loans Recoveries"; Decimal)
        {
            CalcFormula = Sum("Dividend Recoveries".Amount WHERE("Dividend Code" = FIELD("No."), "Entry Type" = filter("Interest Paid" | "Principal Paid" | "Principal Arrears" | "Interest Arrears")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(38; "Progression Computation Type"; Option)
        {
            OptionMembers = " ",Automatic,"Manual Upload";
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        GeneralSetup.Get;
        if "Document Type" = "Document Type"::BOSA then begin
            GeneralSetup.TestField("BOSA Dividend Nos");
            if "No." = '' then
                "No." := NoSeriesManagement.GetNextNo(GeneralSetup."BOSA Dividend Nos", Today, true);
        end else if "Document Type" = "Document Type"::FOSA then begin
            GeneralSetup.TestField("FOSA Dividend Nos");
            if "No." = '' then
                "No." := NoSeriesManagement.GetNextNo(GeneralSetup."FOSA Dividend Nos", Today, true);

        end;

        "Created By" := UserId;
        "Created On" := Today;
        "Last Updated By" := UserId;
        "Last Updated On" := Today;
    end;

    trigger OnModify()
    begin
        "Last Updated By" := UserId;
        "Last Updated On" := Today;
    end;

    var
        GeneralSetup: Record "General Ledger Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;

    procedure OnBeforeSendForApproval()
    begin
        TestField(Status, Status::Open);
        TestField(Description);
        TestField("Progression Computation Type");
        TestField("Transaction Code");
        TestField("Posting Date");
        TestField("Start Date");
        TestField("End Date");
        TestField("Payable Account No.");
        If "Posting Type" = "Posting Type"::Provisioning then
            TestField("Expense Account No.");

    end;
}
