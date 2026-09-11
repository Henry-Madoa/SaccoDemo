table 52204018 "Member Fixed Deposits"
{
    LookupPageId = "Member Fixed Deposits";
    DrillDownPageId = "Member Fixed Deposits";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No."; code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            var
                Member: Record Members;
                Vend: Record Vendor;
            begin
                if Member.Get("Member No.") then begin
                    "Member Name" := Member."Full Name";
                    Vend.Reset;
                    Vend.SetRange("Member No.", "Member No.");
                    Vend.SetRange("Product Posting Type", Vend."Product Posting Type"::"Withdrawable Deposit");
                    if Vend.FindFirst then Validate("Source Account", Vend."No.");
                end;
            end;
        }
        field(3; "Member Name"; Text[150])
        {
            Editable = false;
        }
        field(4; Type; code[20])
        {
            TableRelation = "Member Fixed Deposit Types";

            trigger OnValidate()
            var
                FDTypes: Record "Member Fixed Deposit Types";
            begin
                if FDTypes.Get(Type) then begin
                    Description := FDTypes.Description;
                    Rate := FDTypes."Max. Interest Rate";
                end;
            end;
        }
        field(5; Description; Text[50])
        {
            Editable = False;
        }
        field(6; Rate; Decimal)
        {
            trigger OnValidate()
            var
                FDTypes: Record "Member Fixed Deposit Types";
            begin
                If FDTypes.Get(Type) then begin
                    If Rate <> 0 then begin
                        if Rate > FDTypes."Max. Interest Rate" then
                            Error(StrSubstNo('You cannot exceed Max Interest Rate, Max. is %1', FDTypes."Max. Interest Rate"))
                        else if Rate < FDTypes."Min. Interest Rate" then Error(StrSubstNo('You cannot exceed Min Interest Rate, Min. is %1', FDTypes."Min. Interest Rate"))
                    end;
                end;
            end;
        }
        field(7; "Maturity Instructions"; Option)
        {
            OptionMembers = "Roll Over Principal","Roll Over Net","Liquidate";
        }
        field(8; Amount; Decimal)
        {
        }
        field(9; "Source Account"; Code[20])
        {
            Editable = false;
            TableRelation = Vendor where("Member No." = field("Member No."), "Product Posting Type" = const("Withdrawable Deposit"));

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if Vendor.Get("Source Account") then begin
                    Vendor.CalcFields(Balance);
                    "Source Balance" := Vendor.Balance;
                end;
            end;
        }
        field(10; "Source Balance"; Decimal)
        {
            Editable = false;
        }
        field(11; "Control Account"; code[20])
        {
            Editable = false;
            TableRelation = Vendor;
        }
        field(12; "Start Date"; Date)
        {
            trigger OnValidate()
            begin
                Validate("End Date");
            end;
        }
        field(13; Period; DateFormula)
        {
            trigger OnValidate()
            begin
                Validate("End Date");
            end;
        }
        field(14; "End Date"; Date)
        {
            Editable = false;

            trigger OnValidate()
            begin
                "End Date" := CalcDate(Period, "Start Date");
            end;
        }
        field(15; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(16; "Running Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No." = field("Control Account"), "Posting Date" = field("Date Filter"), "Source Code" = field("No.")));
        }
        field(17; "Total Interest Payable"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Member Fixed Deposit Schedule".Amount where("No." = field("No.")));
        }
        field(18; "Total Interest Accrued"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Member Fixed Deposit Schedule".Amount where("No." = field("No."), Transferred = const(true)));
        }
        field(19; "Total Interest Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Member Fixed Deposit Schedule".Amount where("No." = field("No."), Transferred = const(false)));
        }
        field(20; "Linked Loan Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Collateral Linked Loans"."Current Balance" where("No." = field("No.")));
        }
        field(21; "Uncleared Funds"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Uncleared Funds".Amount where("Account No" = field("Control Account"), Cleared = const(false)));
        }
        field(22; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(23; Posted; Boolean)
        {
            Editable = false;
        }
        field(24; "Posted By"; code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(25; "Posting Date"; Date)
        {
        }
        field(26; Terminated; Boolean)
        {
            Editable = false;
        }
        field(27; Matured; Boolean)
        {
            Editable = false;
        }
        field(28; Due; Boolean)
        {
            Editable = false;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
    var
        SaccoSetup: Record "General Ledger Setup";
        NoSeries: Codeunit NoSeriesManagement;

    trigger OnInsert()
    begin
        SaccoSetup.get;
        SaccoSetup.TestField("FD Nos.");
        "No." := NoSeries.GetNextNo(SaccoSetup."FD Nos.", Today, true);
        "Posting Date" := WorkDate;
    end;

    procedure OnBeforeSendForApproval()
    begin
        TestField(Type);
        TestField(Amount);
        TestField("Start Date");
        TestField(Period);
    end;

    procedure OnBeforeLiquidate()
    begin
        CalcFields("Linked Loan Balance", "Uncleared Funds");
        if "Linked Loan Balance" > "Uncleared Funds" then Error('Kindly Create a Lien before Liquidating');
    end;

    procedure UpdateCollateralRegister()
    var
        Loans: Record Loans;
        LoanSecurity: Record "Loan Securities";
        LinkedLoans: array[2] of Record "Collateral Linked Loans";
    begin
        LinkedLoans[1].Reset();
        LinkedLoans[1].SetRange("No.", "No.");
        LinkedLoans[1].DeleteAll(true);

        LoanSecurity.Reset();
        LoanSecurity.SetRange("Security Type", LoanSecurity."Security Type"::"Fixed Deposit");
        LoanSecurity.SetRange("Security Code", "No.");
        LoanSecurity.SetRange("Member No.", "Member No.");
        LoanSecurity.SetRange(Substituted, false);
        if LoanSecurity.FindSet then begin
            repeat
                If Loans.Get(LoanSecurity."Loan No") then begin
                    Loans.CalcFields("Loan Balance");
                    if ((Loans.Status = Loans.Status::Approved) and (Loans.Posted) and (Loans."Loan Balance" <> 0)) then begin
                        LinkedLoans[2].Init();
                        LinkedLoans[2]."No." := "No.";
                        LinkedLoans[2]."Loan No." := Loans."No.";
                        LinkedLoans[2]."Product Code" := Loans."Product Code";
                        LinkedLoans[2]."Product Details" := Loans."Product Description";
                        if LoanSecurity.Guarantee <= Loans."Loan Balance" then
                            LinkedLoans[2]."Current Balance" := LoanSecurity.Guarantee
                        else
                            LinkedLoans[2]."Current Balance" := Loans."Loan Balance";
                        LinkedLoans[2]."Member No" := Loans."Member No.";
                        LinkedLoans[2]."Member Name" := Loans."Member Name";
                        LinkedLoans[2].Insert();
                    end;
                end;
            until LoanSecurity.Next = 0;
        end;
    end;
}
