table 52204028 "Loan Securities"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Loan Securities";
    LookupPageId = "Loan Securities";

    fields
    {
        field(1; "Loan No"; code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Loans.Get("Loan No") then "Member No." := Loans."Member No.";
            end;
        }
        field(2; "Security Type"; Enum "Security Type")
        {
            trigger OnValidate()
            begin
                if Loans.Get("Loan No") then
                    "Member No." := Loans."Member No.";
            end;
        }
        field(3; "Security Code"; code[20])
        {
            trigger OnValidate()
            begin
                if "Security Type" = "Security Type"::Collateral then begin
                    if CollateralRegister.Get("Security Code") then begin
                        CollateralRegister.UpdateCollateralRegister;
                        CollateralRegister.CalcFields("Linked Loan Balance");
                        Description := CollateralRegister."Collateral Description";
                        "Security Value" := CollateralRegister.Guarantee - CollateralRegister."Linked Loan Balance" + GetBridgedLoanCollateralValue("Loan No", "Security Code");
                        Guarantee := "Security Value";
                    end;
                end;
                if "Security Type" = "Security Type"::"Fixed Deposit" then begin
                    if MemberFixedDeposit.Get("Security Code") then begin
                        MemberFixedDeposit.UpdateCollateralRegister;
                        MemberFixedDeposit.CalcFields("Linked Loan Balance");
                        Description := MemberFixedDeposit.Description;
                        "Security Value" := MemberFixedDeposit.Amount - MemberFixedDeposit."Linked Loan Balance";
                        Guarantee := "Security Value";
                    end;
                end;
            end;

            trigger OnLookup()
            begin
                if Loans.Get("Loan No") then begin
                    If "Security Type" = "Security Type"::Collateral then begin
                        CollateralRegister.Reset();
                        CollateralRegister.SetRange("Member No.", Loans."Member No.");
                        if Page.RunModal(0, CollateralRegister) = Action::LookupOK then begin
                            Validate("Security Code", CollateralRegister."No.");
                        end;
                    end;
                    If "Security Type" = "Security Type"::"Fixed Deposit" then begin
                        MemberFixedDeposit.Reset();
                        MemberFixedDeposit.SetRange("Member No.", Loans."Member No.");
                        if Page.RunModal(0, MemberFixedDeposit) = Action::LookupOK then begin
                            Validate("Security Code", MemberFixedDeposit."No.");
                        end;
                    end;
                end;
            end;
        }
        field(4; Description; Text[150])
        {
            Editable = false;
        }
        field(5; "Security Value"; decimal)
        {
            Editable = false;
        }
        field(6; Guarantee; decimal)
        {
            trigger OnValidate()
            begin
                //Abel;
                // if Guarantee > "Security Value" then
                //     Error('The security can only guarantee upto %1', "Security Value");
            end;
        }
        field(7; "Member No."; code[20])
        {
            Editable = false;
        }
        field(8; "Linked Loan Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Collateral Linked Loans"."Current Balance" where("No." = field("Security Code")));
        }
        field(9; Substituted; Boolean)
        {
            Editable = false;
        }
        field(10; "Substituted By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(11; "Document No."; Code[20])
        {
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Loan No", "Security Type", "Security Code")
        {
            Clustered = true;
        }
    }
    var
        CollateralRegister: Record "Collateral Register";
        MemberFixedDeposit: Record "Member Fixed Deposits";
        Loans: Record Loans;

    trigger OnInsert()
    begin
        if Loans.Get("Loan No") then "Member No." := Loans."Member No.";
    end;

    trigger OnModify()
    begin
        if Loans.Get("Loan No") then "Member No." := Loans."Member No.";
    end;

    trigger OnDelete()
    begin
        if CollateralRegister.Get("Security Code") then begin
            CollateralRegister.Status := CollateralRegister.Status::Available;
            CollateralRegister.Modify();
        end;
    end;

    trigger OnRename()
    begin
        if CollateralRegister.Get("Security Code") then begin
            CollateralRegister.Status := CollateralRegister.Status::Available;
            CollateralRegister.Modify();
        end;
    end;

    local procedure GetBridgedLoanCollateralValue(LoanNo: Code[20]; CollateralCode: Code[20]): Decimal
    var
        LoanRecoveries: Record "Loan Recoveries";
        LoanSecurities: Record "Loan Securities";
        Loans: Record Loans;
        LinkedBalance: Decimal;
    begin
        LinkedBalance := 0;
        LoanRecoveries.Reset();
        LoanRecoveries.SetRange("Loan No", LoanNo);
        LoanRecoveries.SetRange("Recovery Type", LoanRecoveries."Recovery Type"::Loan);
        if LoanRecoveries.FindFirst then begin
            repeat
                if Loans.Get(LoanRecoveries."Loan No") then begin
                    LoanSecurities.Reset();
                    LoanSecurities.SetRange("Loan No", Loans."No.");
                    LoanSecurities.SetRange("Security Type", LoanSecurities."Security Type"::Collateral);
                    LoanSecurities.SetRange("Security Code", CollateralCode);
                    if LoanSecurities.FindFirst then begin
                        LoanSecurities.CalcFields("Linked Loan Balance");
                        LinkedBalance += LoanSecurities."Linked Loan Balance";
                    end;
                end;
            until LoanRecoveries.Next = 0;
        end;
        exit(LinkedBalance);
    end;
}
