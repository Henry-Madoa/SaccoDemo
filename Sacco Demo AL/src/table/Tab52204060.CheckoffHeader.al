table 52204060 "Checkoff Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Document Date"; Date)
        {
            Editable = false;
        }
        field(3; "Posting Date"; Date)
        {
        }
        field(4; "Posting Description"; Text[50])
        {
        }
        field(5; "Balancing Account Type"; Option)
        {
            OptionMembers = Receivable,"Bank Account","G/L Account";
        }
        field(6; "Balancing Account No"; Code[20])
        {
            TableRelation = if ("Balancing Account Type" = const("Bank Account")) "Bank Account"
            else if ("Balancing Account Type" = const(Receivable)) Customer
            else if ("Balancing Account Type" = const("G/L Account")) "G/L Account";
        }
        field(7; "Charge Code"; Code[20])
        {
            TableRelation = if ("Upload Type" = const(Salary)) "Transaction Charges" where("Posting Transaction Type" = const("End Month Salary"));
        }
        field(8; "Created By"; Code[50])
        {
            tableRelation = "User Setup";
        }
        field(9; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(10; Posted; Boolean)
        {
            Editable = false;

            trigger OnValidate()
            var
                CheckoffLines: Record "Checkoff Lines";
            begin
                CheckoffLines.Reset();
                CheckoffLines.SetRange("No.", "No.");
                if CheckoffLines.FindSet() then begin
                    repeat
                        CheckoffLines.Posted := true;
                        CheckoffLines.Modify(true);
                    until CheckoffLines.Next = 0;
                end;
            end;
        }
        field(12; "Suspense Account"; code[20])
        {
            TableRelation = if ("Balancing Account Type" = const("Bank Account")) "Bank Account"
            else if ("Balancing Account Type" = const(Receivable)) Customer
            else if ("Balancing Account Type" = const("G/L Account")) "G/L Account";
        }
        field(11; "Upload Type"; Option)
        {
            OptionMembers = Salary,Checkoff;
        }
        field(13; "Uploaded Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Checkoff Upload".Amount where("Document No" = field("No.")));
            Editable = false;
        }
        field(14; "Employer Code"; code[20])
        {
            TableRelation = Employers;
        }
        field(15; Amount; Decimal)
        {
        }
        field(16; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(17; "Search Type"; Enum "CheckOff Search Type")
        {
        }
        field(18; "Calculation Type"; Option)
        {
            OptionMembers = "Block Amount","Per Product Amount";
        }
        field(19; "Sacco 360"; Boolean)
        {
        }
        field(20; "Bank Charges"; Decimal)
        {
        }
        field(21; "Bank Charges Income Account"; Code[20])
        {
            TableRelation = "G/L Account" where("Direct Posting" = const(true), "Account Type" = const(Posting));
        }
        field(22; Variance; Decimal)
        {
            Editable = false;
        }
        field(23; "Total Members"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Checkoff Lines" where("No." = field("No.")));
            Editable = false;
        }
        field(24; "Calculated Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Checkoff Calculation".Amount where("Entry Type" = const("Net Amount"), "Document No" = field("No.")));
            Editable = false;
        }
        field(25; "Total Recoveries"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Checkoff Calculation".Amount where("Entry Type" = filter(<> "Net Amount"), "Document No" = field("No."), UnMatched = const(false)));
            Editable = false;
        }
        field(26; "Allow Double Recovery"; Boolean)
        {
        }
        field(27; "Income Type"; Option)
        {
            OptionMembers = " ",Salary,"Other Incomes";
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    var
        NoSeries: Codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";

    trigger OnDelete()
    var
        CheckoffLines: Record "Checkoff Lines";
    begin
        TestField(Status, Status::Open);
        CheckoffLines.Reset();
        CheckoffLines.SetRange("No.", "No.");
        CheckoffLines.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        SaccoSetup.get;
        SaccoSetup.TestField("Checkoff Nos");
        if "No." = '' then "No." := NoSeries.GetNextNo(SaccoSetup."Checkoff Nos", Today, true);
        if "Upload Type" = "Upload Type"::Checkoff then begin
            SaccoSetup.TestField("Checkoff Nos");
            "No." := NoSeries.GetNextNo(SaccoSetup."Checkoff Nos", Today, true);
        end;
        if "Upload Type" = "Upload Type"::Salary then begin
            SaccoSetup.TestField("Salary Processing Nos");
            "No." := NoSeries.GetNextNo(SaccoSetup."Salary Processing Nos", Today, true);
        end;
        "Document Date" := WorkDate;
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        "Posting Date" := WorkDate;
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posting Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;

    procedure OnBeforeSendForApproval()
    begin
        CalcFields("Total Members", "Uploaded Amount", "Calculated Amount", "Total Recoveries");
        if "Sacco 360" then begin
            TestField("Bank Charges");
            TestField("Bank Charges Income Account");
        end;
        if (Amount + "Bank Charges") <> "Uploaded Amount" then
            Error('Amount must be equal to Uploaded Amount');
        TestField("Posting Date");
        TestField("Posting Description");
        TestField("Total Members");
        TestField("Suspense Account");

        if "Upload Type" = "Upload Type"::Salary then
            TestField("Income Type");

        If "Search Type" = "Search Type"::"Payroll Number" then
            TestField("Employer Code");
        if "Upload Type" = "Upload Type"::Checkoff then
            TestField("Total Recoveries", Amount);
    end;
}
