table 52204035 "Loanees Payroll Transactions"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Loanees Payroll Transactions";
    DrillDownPageId = "Loanees Payroll Transactions";

    fields
    {
        field(1; "Source No."; Code[30])
        {
        }
        field(2; Type; Enum "Loanees Payroll Trans Types")
        {
        }
        field(3; Code; Code[20])
        {
            TableRelation = if (Type = const(Income)) "Loanees Payroll Codes".Code where(Type = const(Income))
            else if (Type = const(Deduction)) "Loanees Payroll Codes".Code where(Type = const(Deduction));

            trigger OnValidate()
            var
                DeductionAmount: Decimal;
            begin
                if TransactionCode[1].Get(Code, Type) then begin
                    Name := TransactionCode[1].Name;
                    "Is Formula" := TransactionCode[1]."Is Formula";
                    "Transaction Type" := TransactionCode[1]."Transaction Type";
                    "Cleared Effect" := TransactionCode[1]."Cleared Effect";
                    if TransactionCode[1]."Transaction Type" = TransactionCode[1]."Transaction Type"::"Basic Salary" then begin
                        TransactionCode[2].Reset();
                        TransactionCode[2].SetRange(Type, TransactionCode[2].Type::Deduction);
                        TransactionCode[2].SetRange("Transaction Type", TransactionCode[2]."Transaction Type"::"1/3 Basic Salary");
                        if not TransactionCode[2].FindFirst then
                            Error('You need to have a deduction flagged as One Third Basic before assigning Basic Salary')
                        else begin
                            PayrollTransaction[1].Init();
                            PayrollTransaction[1].Validate("Source No.", "Source No.");
                            PayrollTransaction[1].Validate(Type, PayrollTransaction[1].Type::Deduction);
                            PayrollTransaction[1].Validate(Code, TransactionCode[2].Code);
                            if Amount <> 0 then PayrollTransaction[1].Amount := -(Round((Amount * 1 / 3), 1, '='));
                            if not PayrollTransaction[2].Get("Source No.", PayrollTransaction[2].Type::Deduction, TransactionCode[2].Code) then
                                PayrollTransaction[1].Insert(true)
                            else begin
                                if Amount <> 0 then begin
                                    PayrollTransaction[2].Amount := -(Round((Amount * 1 / 3)));
                                    PayrollTransaction[2].Modify(true);
                                end;
                            end;
                            if Loans[1].Get("Source No.") then begin
                                Loans[2].Reset();
                                Loans[2].SetRange("Salary Based", true);
                                Loans[2].SetRange("Member No.", Loans[1]."Member No.");
                                Loans[2].SetFilter("Loan Balance", '<>%1', 0);
                                if Loans[2].FindSet then begin
                                    repeat
                                        Loans[2].CalcFields("Monthly Installment", "Loan Balance");
                                        if Loans[2]."Monthly Installment" > Loans[2]."Loan Balance" then
                                            DeductionAmount := Loans[2]."Loan Balance"
                                        else
                                            DeductionAmount := Loans[2]."Monthly Installment";
                                        TransactionCode[2].Reset();
                                        TransactionCode[2].SetRange(Type, TransactionCode[2].Type::Deduction);
                                        TransactionCode[2].SetRange("Transaction Type", TransactionCode[2]."Transaction Type"::"Loan Deduction");
                                        if not TransactionCode[2].FindFirst then
                                            Error('You need to have a deduction flagged as Loan Deduction')
                                        else begin
                                            PayrollTransaction[1].Init();
                                            PayrollTransaction[1].Validate("Source No.", "Source No.");
                                            PayrollTransaction[1].Validate(Type, PayrollTransaction[1].Type::Deduction);
                                            PayrollTransaction[1].Validate(Code, TransactionCode[2].Code);
                                            PayrollTransaction[1].Amount := -DeductionAmount;
                                            if not PayrollTransaction[2].Get("Source No.", PayrollTransaction[2].Type::Deduction, TransactionCode[2].Code) then
                                                PayrollTransaction[1].Insert(true)
                                            else begin
                                                PayrollTransaction[2].Amount += -DeductionAmount;
                                                PayrollTransaction[2].Modify(true);
                                            end;
                                        end;
                                    until Loans[2].Next = 0;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        }
        field(4; Name; Text[100])
        {
            Editable = false;
        }
        field(5; "Is Formula"; Boolean)
        {
            Description = 'Is the transaction based on a formula';
        }
        field(6; "Transaction Type"; Enum "Payroll Transaction Types")
        {
        }
        field(7; Amount; Decimal)
        {
            trigger OnValidate()
            begin
                if ((Type = Type::Deduction) and (Amount > 1)) then Amount := Amount * -1;
                if "Transaction Type" = "Transaction Type"::"Basic Salary" then Validate(Code);
            end;
        }
        field(8; "Cleared Effect"; Boolean)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Source No.", Type, Code)
        {
            Clustered = true;
        }
    }
    var
        TransactionCode: array[2] of Record "Loanees Payroll Codes";
        PayrollTransaction: array[3] of Record "Loanees Payroll Transactions";
        Loans: array[2] of Record Loans;
}
