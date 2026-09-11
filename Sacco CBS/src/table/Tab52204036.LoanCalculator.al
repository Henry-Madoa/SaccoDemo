table 52204036 "Loan Calculator"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; code[20])
        {
            Editable = false;
        }
        field(2; "Member No"; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            var
                Member: Record Members;
            begin
                Member.Get("Member No");
                Member.CalcFields("Total Deposits", "Outstanding Loans");
                "Current Deposits" := Member."Total Deposits";
                "Ouststanding Loans" := Member."Outstanding Loans";
                "Deposit Appraisal" := "Loan Deposit Multiplier" - "Ouststanding Loans";
            end;
        }
        field(3; "Current Deposits"; Decimal)
        {
            Editable = false;
        }
        field(4; "Loan Deposit Multiplier"; Decimal)
        {
            Editable = false;
        }
        field(5; "Ouststanding Loans"; Decimal)
        {
            Editable = false;
        }
        field(6; "Deposit Appraisal"; Decimal)
        {
            Editable = false;
        }
        field(7; "Loan Product"; Code[20])
        {
            TableRelation = "Sacco Products" where("Product Posting Type" = const("Loan Account"));

            trigger OnValidate()
            begin
                If SaccoProduct.Get("Loan Product") then begin
                    SaccoProduct.TestField("Maximum Installments");
                    SaccoProduct.TestField("Loan Multiplier");
                    SaccoProduct.TestField("Posting Group");
                    SaccoProduct.TestField("Interest Repayment Method");
                    "Loan Deposit Multiplier" := "Current Deposits" * SaccoProduct."Loan Multiplier";
                    "Product Description" := SaccoProduct.Description;
                    "Rate Type" := SaccoProduct."Interest Repayment Method";
                end;
                LoansManagement.PopulatePreAppraisalParameters(Rec);
            end;
        }
        field(8; "Product Description"; Text[50])
        {
            Editable = false;
        }
        field(9; "Principal Amount"; Decimal)
        {
        }
        field(10; "Interest Rate"; Decimal)
        {
            Editable = false;
        }
        field(11; "Rate Type"; Enum "Loan Rate Type")
        {
        }
        field(12; "Repayment Start Date"; Date)
        {
        }
        field(13; "Installments (Months)"; Integer)
        {
            trigger OnValidate()
            var
                Tparty: Codeunit "Channels Integrations";
                ProcessingFee: Decimal;
            begin
                SaccoProduct.Get("Loan Product");
                if "Installments (Months)" > SaccoProduct."Maximum Installments" then Error('Installments cannot exceed %1 which is the maximun installments for %2', SaccoProduct."Maximum Installments", "Product Description");
                if "Installments (Months)" < SaccoProduct."Minimum Installments" then Error('Installments cannot be less than %1 which is the minimum installments for %2', SaccoProduct."Minimum Installments", "Product Description");
                "Interest Rate" := Tparty.GetInterestRate("Loan Product", "Installments (Months)", ProcessingFee);
                "Repayment Start Date" := WorkDate;
            end;
        }
        field(15; Earnings; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loanees Payroll Transactions".Amount where("Source No." = field("No."), Type = const(Income)));
        }
        field(19; Deductions; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loanees Payroll Transactions".Amount where("Source No." = field("No."), Type = const(Deduction)));
        }
        field(20; "Net Income"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loanees Payroll Transactions".Amount where("Source No." = field("No.")));
        }
        field(22; "Amount Available"; Decimal)
        {
            Editable = false;
        }
        field(23; "Created By"; code[100])
        {
            Editable = false;
        }
        field(24; "Created On"; Date)
        {
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
        SaccoProduct: Record "Sacco Products";
        LoansManagement: Codeunit "Loans Management";

    trigger OnInsert()
    begin
        GenSetup.Get();
        GenSetup.TestField("Calculator Nos");
        "No." := NoSeries.GetNextNo(GenSetup."Calculator Nos", Today, true);
        "Created By" := UserId;
        "Created On" := WorkDate;
    end;
}
