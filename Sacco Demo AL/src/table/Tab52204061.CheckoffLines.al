table 52204061 "Checkoff Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No"; Code[20])
        {
            trigger OnValidate()
            var
                CheckOff: Record "Checkoff Header";
                Member: Record Members;
                Vendor: Record Vendor;
                LoansMgt: Codeunit "Loans Management";
                CheckoffManagement: Codeunit "Checkoff Management";
                CheckOffCalculations: array[2] of Record "Checkoff Calculation";
                CheckoffUpload: Record "Checkoff Upload";
                CheckoffLines: Record "Checkoff Lines";
                TotalAmount: Decimal;
            begin
                If CheckOff.Get("No.") then begin
                    If Member.Get("Member No") then begin
                        CheckoffLines.Reset();
                        CheckoffLines.SetRange("Member No", "Member No");
                        CheckoffLines.SetFilter("Check No", '<>%1', "Check No");
                        if CheckoffLines.FindFirst then
                            Error(StrSubstNo('You have an existing entry of Check No. %1', CheckoffLines."Check No"));

                        "Suspense Account" := false;
                        "Mobile Phone No" := Member."Mobile Phone No.";
                        "Member Name" := Member."Full Name";
                        "Payroll No" := Member."Payroll No.";

                        if CheckOff."Upload Type" = CheckOff."Upload Type"::Salary then
                            "Collections Account" := LoansMgt.GetFOSAAccount("Member No");

                        CheckOffCalculations[1].Reset();
                        CheckOffCalculations[1].SetRange("Document No", "No.");
                        CheckOffCalculations[1].SetRange("Check No", "Check No");
                        if CheckOffCalculations[1].FindFirst then
                            CheckOffCalculations[1].DeleteAll;

                        CheckoffUpload.Reset();
                        CheckoffUpload.SetRange("Check No", "Check No");
                        CheckoffUpload.SetRange("Document No", "No.");
                        if CheckoffUpload.FindSet() then begin
                            CheckoffUpload.CalcSums(Amount);
                            TotalAmount := CheckoffUpload.Amount;
                            CheckOffCalculations[2].Init();
                            CheckOffCalculations[2]."Document No" := "No.";
                            CheckOffCalculations[2]."Member No" := "Member No";
                            CheckOffCalculations[2]."Check No" := "Check No";
                            CheckOffCalculations[2]."Entry No" := CheckoffManagement.GetCheckOffEntryNo("No.", "Member No", "Check No");
                            CheckOffCalculations[2]."Entry Type" := CheckOffCalculations[2]."Entry Type"::"Net Amount";
                            CheckOffCalculations[2].Amount := TotalAmount;
                            CheckOffCalculations[2]."Amount Base" := -TotalAmount;
                            if CheckOff."Upload Type" = CheckOff."Upload Type"::Salary then begin
                                CheckOffCalculations[2]."Account No" := "Collections Account";
                                if Vendor.Get("Collections Account") then CheckOffCalculations[2]."Account Name" := Vendor.Name;
                            end;
                            if CheckOffCalculations[2].Amount <> 0 then CheckOffCalculations[2].Insert();
                        end;
                    end;
                end;
            end;
        }
        field(3; "Check No"; Code[20])
        {
        }
        field(4; "Payroll No"; Code[20])
        {
            Editable = false;
        }
        field(5; "Member Name"; Text[100])
        {
        }
        field(6; "Collections Account"; Code[20])
        {
        }
        field(7; "Mobile Phone No"; Code[30])
        {
        }
        field(8; Posted; Boolean)
        {
        }
        field(9; "Suspense Account"; Boolean)
        {
        }
        field(10; "Amount Earned"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Checkoff Calculation".Amount where("Document No" = field("No."), "Check No" = field("Check No"), "Member No" = field("Member No"), "Entry Type" = filter(= "Net Amount")));
        }
        field(11; Commission; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Checkoff Calculation".Amount where("Document No" = field("No."), "Check No" = field("Check No"), "Member No" = field("Member No"), "Entry Type" = filter(= Commission)));
        }
        field(12; "Recoveries"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Checkoff Calculation".Amount where("Document No" = field("No."), "Check No" = field("Check No"), "Member No" = field("Member No"), "Entry Type" = filter(<> "Net Amount")));
        }
        field(13; "Net Amount"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = - sum("Checkoff Calculation"."Amount Base" where("Document No" = field("No."), "Check No" = field("Check No"), "Member No" = field("Member No")));
        }
        field(14; "Running Loans"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Loans where("Member No." = field("Member No"), "Loan Balance" = filter(> 0)));
            Editable = false;
        }
        field(15; "Upload Type"; Option)
        {
            OptionMembers = Salary,Checkoff,Allowances,"Standing Order";
            FieldClass = FlowField;
            CalcFormula = lookup("Checkoff Header"."Upload Type" where("No." = field("No.")));
        }
        field(16; "Posting Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Checkoff Header"."Posting Date" where("No." = field("No.")));
        }
        field(17; Notified; Boolean)
        {
            Editable = false;
        }
        field(18; "Income Type"; Option)
        {
            OptionMembers = " ",Salary,"Other Incomes";
            FieldClass = FlowField;
            CalcFormula = lookup("Checkoff Header"."Income Type" where("No." = field("No.")));
        }
    }
    keys
    {
        key(Key1; "No.", "Member No", "Check No")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    begin
        Rec.Testfield(Posted, false);
    end;
}
