table 52204076 "Standing Order"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Standing Orders";
    LookupPageId = "Standing Orders";

    fields
    {
        field(1; "No."; code[20])
        {
            Editable = false;
        }
        field(2; "Standing Order Class"; Enum "STO Types")
        {
            Editable = false;
        }
        field(3; "Amount Type"; Option)
        {
            OptionMembers = Fixed,Sweep,"Amount Based";
        }
        field(4; "Member No"; code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            var
                LoansMgt: Codeunit "Loans Management";
            begin
                if Members.Get("Member No") then begin
                    "Old FOSA No." := Members."Old No.";
                    "Member Name" := Members."Full Name";
                    "Account No" := LoansMgt.GetFOSAAccount("Member No");
                    Validate("Account No");
                end;
            end;
        }
        field(5; "Member Name"; Text[150])
        {
            Editable = false;
        }
        field(6; "Account No"; code[20])
        {
            TableRelation = Vendor where("Member No." = field("Member No"), "Product Posting Type" = filter("Withdrawable Deposit" | "Holding Account"));
        }
        field(7; Amount; Decimal)
        {
            trigger OnValidate()
            begin
                if "Amount Type" <> "Amount Type"::Fixed then Amount := 0;
            end;
        }
        field(8; "Posting Description"; Text[50])
        {
        }
        field(9; "Destination Member No"; code[20])
        {
            TableRelation = if ("Standing Order Class" = filter(<> External)) Members;

            trigger OnValidate()
            begin
                Validate("Destination Name");
                If "Member No" = "Destination Member No" then
                    "Destination Type" := "Destination Type"::Own
                else begin
                    "Destination Type" := "Destination Type"::Others;
                    "Destination Account" := MemberMgmt.GetMemberAccount("Destination Member No", ProductPostingType::"Withdrawable Deposit");
                    ;
                end;
            end;
        }
        field(10; "Destination Account"; code[20])
        {
            TableRelation = if ("Standing Order Class" = const(External)) "Bank Account" where(Blocked = const(false))
            else if ("Standing Order Class" = filter("Loan Principal+Interest" | "Loan-Interest" | "Loan-Principal")) Loans where("Loan Balance" = filter(> 0), "Member No." = field("Destination Member No"))
            else if ("Destination Type" = const(Own)) Vendor where("Member No." = field("Destination Member No"), "Product Posting Type" = filter(<> "Loan Account"))
            else if ("Destination Type" = const(Others)) Vendor where("Member No." = field("Destination Member No"), "Product Posting Type" = filter("Withdrawable Deposit"));

            trigger OnValidate()
            var
                StandingOrder: Record "Standing Order";
            begin
                StandingOrder.Reset();
                StandingOrder.SetRange("Member No", "Member No");
                StandingOrder.SetRange("Destination Account", "Destination Account");
                StandingOrder.SetFilter("Standing Order Class", '<>%1', StandingOrder."Standing Order Class"::External);
                StandingOrder.Setrange(Terminated, false);
                if StandingOrder.FindFirst then
                    Error(StrSubstNo('You have a simmilar Standing Order : %1', StandingOrder."No."));
                Validate("Destination Name");
            end;
        }
        field(11; "Destination Name"; Text[150])
        {
            Editable = false;

            trigger OnValidate()
            begin
                if Vendor.Get("Destination Account") then begin
                    "Destination Name" := Vendor.Name;
                    "Posting Description" := Vendor.Name;
                end;
                if Loans.Get("Destination Account") then begin
                    Loans.CalcFields("Monthly Installment");
                    "Destination Name" := Loans."Product Description";
                    "Posting Description" := Loans."Product Description";
                    Amount := Loans."Monthly Installment";
                end;
            end;
        }
        field(12; "Run Type"; Option)
        {
            OptionMembers = "Specific Day","End Month",Daily;
        }
        field(13; "Run From Day"; Integer)
        {
            Editable = true;

            trigger OnValidate()
            begin
                Rec.Testfield("Salary Based", false);
            end;
        }
        field(14; "EFT Account Name"; Text[150])
        {
        }
        field(15; "EFT Bank Name"; Text[150])
        {
            Editable = false;
        }
        field(16; "EFT Branch Name"; Text[150])
        {
            Editable = false;
        }
        field(17; "EFT Swift Code"; Code[20])
        {
        }
        field(18; "EFT Transfer Account No"; Code[20])
        {
        }
        field(19; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(20; "Charge Code"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(21; Running; Boolean)
        {
            Editable = false;
        }
        field(22; "Salary Based"; Boolean)
        {
            trigger OnValidate()
            begin
                if not Rec."Salary Based" then Priority := 0;
            end;
        }
        field(23; Priority; Integer)
        {
        }
        field(24; Terminated; Boolean)
        {
            Editable = false;
        }
        field(25; "STO Type"; Code[20])
        {
            TableRelation = "Standing Order Types";

            trigger OnValidate()
            var
                STOTypes: Record "Standing Order Types";
            begin
                if STOTypes.Get("STO Type") then begin
                    "Standing Order Class" := STOTypes."Standing Order Class";
                    Priority := STOTypes.Priority;
                end;
            end;
        }
        field(26; "Start Date"; Date)
        {
            trigger OnValidate()
            begin
                Validate("End Date");
            end;
        }
        field(27; Period; DateFormula)
        {
            trigger OnValidate()
            begin
                Validate("End Date");
            end;
        }
        field(28; "End Date"; Date)
        {
            trigger OnValidate()
            begin
                "End Date" := CalcDate(Period, "Start Date");
            end;
        }
        field(29; "Policy No."; Code[50])
        {
        }
        field(30; "EFT Bank Code"; Code[20])
        {
            TableRelation = "External Banks";

            trigger OnValidate()
            var
                ExternalBanks: Record "External Banks";
            begin
                ExternalBanks.Get("EFT Bank Code");
                "EFT Bank Name" := ExternalBanks."Bank Name";
                "EFT Branch Code" := '';
                "EFT Bank Name" := '';
            end;
        }
        field(31; "EFT Branch Code"; Code[20])
        {
            TableRelation = "External Bank Branches"."Branch Code" where("Bank Code" = field("EFT Bank Code"));

            trigger OnValidate()
            var
                Branches: Record "External Bank Branches";
            begin
                Branches.Get("EFT Bank Code", "EFT Branch Code");
                "EFT Branch Name" := Branches."Branch Name";
            end;
        }
        field(32; "Till Further Notice"; Boolean)
        {
            trigger OnValidate()
            var
                vPeriod: DateFormula;
            begin
                Evaluate(vPeriod, '99Y');
                if "Till Further Notice" then begin
                    Rec.Testfield("Start Date");
                    Validate(Period, vPeriod);
                end;
            end;
        }
        field(33; "Amount Limit"; Decimal)
        {
        }
        field(34; "Destination Type"; Option)
        {
            Editable = false;
            OptionMembers = Own,Others;
        }
        field(35; "Created By"; Code[100])
        {
            Editable = false;
        }
        field(36; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(37; "Source Account Code"; Code[20])
        {
            trigger OnValidate()
            begin
                Vendor.Reset();
                Vendor.SetRange("Member No.", "Member No");
                Vendor.SetRange("Product Code", "Source Account Code");
                if Vendor.FindFirst then begin
                    if Vendor."Product Posting Type" <> Vendor."Product Posting Type"::"Loan Account" then Validate("Account No", Vendor."No.");
                end;
            end;
        }
        field(38; "Destination Account Code"; Code[20])
        {
            trigger OnValidate()
            begin
                Vendor.Reset();
                Vendor.SetRange("Member No.", "Destination Member No");
                Vendor.SetRange("Product Code", "Destination Account Code");
                if Vendor.FindFirst then begin
                    if Vendor."Product Posting Type" <> Vendor."Product Posting Type"::"Loan Account" then Validate("Destination Account", Vendor."No.");
                end;
            end;
        }
        field(39; "Next Run Date"; Date)
        {
            Editable = false;
        }
        field(40; "Old FOSA No."; Code[20])
        {
            Editable = false;
        }
        field(41; Freezed; Boolean)
        {
            Editable = false;
        }
        field(42; "Freeze End Date"; Date)
        {
            Editable = false;
        }
        field(43; "Employer Code"; Code[20])
        {
            TableRelation = Employers;
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Employer Code" where("No." = field("Member No")));
            Editable = false;
        }
        field(44; "Last Run Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = max("Vendor Ledger Entry"."Posting Date" WHERE("Vendor No." = field("Account No"), "Document No." = field("No."), "Sacco Transaction Type" = const("Standing Order")));
            Editable = false;
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
        GenSetup: Record "General Ledger Setup";
        Members: Record Members;
        Vendor: Record Vendor;
        Loans: Record Loans;
        MemberMgmt: Codeunit "Member Management";
        ProductPostingType: Enum "Product Posting Type";

    trigger OnInsert()
    begin
        GenSetup.Get();
        GenSetup.TestField("Standing Order Nos");
        if "No." = '' then "No." := NoSeries.GetNextNo(GenSetup."Standing Order Nos", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;

    procedure OnBeforeSendingForApproval()
    begin
        TestField("Posting Description");
        TestField("Destination Account");
        if (not "Salary Based" and ("Amount Type" <> "Amount Type"::"Amount Based")) then begin
            if "Run Type" = "Run Type"::"Specific Day" then
                TestField("Run From Day");
        end;

        if "Amount Type" = "Amount Type"::Fixed then
            TestField(Amount);
        if "Amount Type" = "Amount Type"::"Amount Based" then
            TestField("Amount Limit");
        If "Start Date" < WorkDate then
            Error('You cannot backdate');
    end;
}
