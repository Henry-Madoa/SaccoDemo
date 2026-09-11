table 52204059 "Loan Security Mgmt Det. Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            trigger OnValidate()
            var
                GuarantorHeader: Record "Loan Security Mgmt";
            begin
                If GuarantorHeader.Get("No.") then "Member No" := GuarantorHeader."Member No";
            end;
        }
        field(2; "Line No"; Integer)
        {
        }
        field(3; "Entry No"; Integer)
        {
            AutoIncrement = true;
        }
        field(4; "Member No"; Code[20])
        {
            Editable = false;
        }
        field(5; "Security Type"; Enum "Security Type")
        {
        }
        field(6; "Security Code"; code[20])
        {
            TableRelation = if ("Security Type" = const(Guarantor)) Members where(Status = const(Active))
            else if ("Security Type" = const(Collateral)) "Collateral Register" where("Member No." = field("Member No"))
            else if ("Security Type" = const("Fixed Deposit")) "Member Fixed Deposits" where("Member No." = field("Member No"));

            trigger OnValidate()
            var
                LoansMgt: Codeunit "Loans Management";
                GuarantorLines: Record "Loan Security Mgmt Lines";
                Member: Record Members;
                CollateralRegister: Record "Collateral Register";
                FixedDeposits: Record "Member Fixed Deposits";
            begin
                "Qualified Guarantee" := 0;
                if GuarantorLines.Get("No.", "Line No") then begin
                    "Loan No." := GuarantorLines."Loan No.";
                    if "Security Type" = "Security Type"::Guarantor then begin
                        Member.Get("Security Code");
                        "Security Name" := Member."Full Name";
                        if "Security Code" = "Member No" then begin
                            "Qualified Guarantee" := LoansMgt.GetSelfGuaranteeEligibility("Security Code");
                            "Self Guarantee" := true;
                        end
                        else begin
                            "Qualified Guarantee" := LoansMgt.GetNonSelfGuaranteeEligibility("Security Code");
                            "Self Guarantee" := false;
                        end;
                    end
                    else if "Security Type" = "Security Type"::Collateral then begin
                        If CollateralRegister.Get("Security Code") then begin
                            CollateralRegister.UpdateCollateralRegister;
                            CollateralRegister.CalcFields("Linked Loan Balance");
                            "Security Name" := CollateralRegister."Collateral Description";
                            "Qualified Guarantee" := CollateralRegister.Guarantee - CollateralRegister."Linked Loan Balance";
                        end;
                    end
                    else if "Security Type" = "Security Type"::"Fixed Deposit" then begin
                        if FixedDeposits.Get("Security Code") then begin
                            FixedDeposits.CalcFields("Linked Loan Balance");
                            "Security Name" := FixedDeposits.Description;
                            "Qualified Guarantee" := FixedDeposits.Amount - CollateralRegister."Linked Loan Balance";
                        end;
                    end;
                end;
            end;
        }
        field(7; "Security Name"; Text[100])
        {
            Editable = false;
        }
        field(8; "Qualified Guarantee"; Decimal)
        {
            Editable = false;
        }
        field(9; "Self Guarantee"; Boolean)
        {
            Editable = false;
        }
        field(10; "Original Amount"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Loan Security Mgmt Lines"."Intial Guaranteed" where("No." = field("No."), "Line No" = field("Line No")));
        }
        field(11; "Propoation Remaining"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Loan Security Mgmt Lines"."Outstanding Guaranteed" where("No." = field("No."), "Line No" = field("Line No")));
        }
        field(12; "Guarantee Amount"; Decimal)
        {
            trigger OnValidate()
            begin
                if "Guarantee Amount" > "Qualified Guarantee" then
                    Error('Guarantee Amount is greater than Qualified Amount');
            end;
        }
        field(13; "Loan No."; code[20])
        {
        }
    }
    keys
    {
        key(Key1; "No.", "Line No", "Entry No")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        GuarantorHeader.Get("No.");
        GuarantorHeader.TestField(Status, GuarantorHeader.Status::Open);
    end;

    trigger OnModify()
    begin
        GuarantorHeader.Get("No.");
        GuarantorHeader.TestField(Status, GuarantorHeader.Status::Open);
    end;

    trigger OnDelete()
    begin
        GuarantorHeader.Get("No.");
        GuarantorHeader.TestField(Status, GuarantorHeader.Status::Open);
    end;

    var
        GuarantorHeader: Record "Loan Security Mgmt";
}
