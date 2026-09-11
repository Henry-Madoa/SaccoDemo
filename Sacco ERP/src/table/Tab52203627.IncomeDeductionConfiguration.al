table 52203627 "Income/Deduction Configuration"
{
    fields
    {
        field(1; Scale; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Transaction Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payroll Transaction Code".Code WHERE(Type=FILTER(Income|Deduction));

            trigger OnValidate()
            begin
                if PayrollTransactionCode.Get("Transaction Code")then "Transaction Description":=PayrollTransactionCode.Name
                else
                    "Transaction Description":='';
                if "Transaction Code" = '' then Employee.Reset;
                Employee.SetRange("Job Scale", Rec.Scale);
                if Employee.FindSet then begin
                    repeat PayrollEmployeeTransaction.Reset;
                        PayrollEmployeeTransaction.SetRange("Employee Code", Employee."No.");
                        PayrollEmployeeTransaction.SetRange("Transaction Code", Rec."Transaction Code");
                        if not PayrollEmployeeTransaction.FindFirst then begin
                            PayrollEmployeeTransaction.Init;
                            PayrollEmployeeTransaction.Validate("Employee Code", Employee."No.");
                            PayrollEmployeeTransaction.Validate("Transaction Code", Rec."Transaction Code");
                            PayrollEmployeeTransaction.Insert;
                        end;
                    until Employee.Next = 0;
                end;
            end;
        }
        field(3; "Transaction Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; Amount; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if xRec.Amount = Rec.Amount then exit;
                Employee.Reset;
                Employee.SetRange("Job Scale", Rec.Scale);
                if Employee.FindSet then begin
                    repeat PayrollEmployeeTransaction.Reset;
                        PayrollEmployeeTransaction.SetRange("Employee Code", Employee."No.");
                        PayrollEmployeeTransaction.SetRange("Transaction Code", Rec."Transaction Code");
                        if PayrollEmployeeTransaction.FindFirst then begin
                            PayrollEmployeeTransaction.Amount:=Rec.Amount;
                            PayrollEmployeeTransaction.Modify(true);
                        end
                        else
                        begin
                            PayrollEmployeeTransaction.Init;
                            PayrollEmployeeTransaction.Validate("Employee Code", Employee."No.");
                            PayrollEmployeeTransaction.Validate("Transaction Code", Rec."Transaction Code");
                            PayrollEmployeeTransaction.Validate(Amount, Rec.Amount);
                            PayrollEmployeeTransaction.Insert;
                        end;
                    until Employee.Next = 0;
                end;
            end;
        }
        field(5; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Income,Deduction';
            OptionMembers = Income, Deduction;
        }
        field(6; Pointer; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Scale, "Transaction Code", Pointer)
        {
        }
    }
    trigger OnDelete()
    begin
        Employee.Reset;
        Employee.SetRange("Job Scale", Rec.Scale);
        if Employee.FindSet then begin
            repeat PayrollEmployeeTransaction.Reset;
                PayrollEmployeeTransaction.SetRange("Employee Code", Employee."No.");
                PayrollEmployeeTransaction.SetRange("Transaction Code", Rec."Transaction Code");
                if PayrollEmployeeTransaction.FindFirst then begin
                    PayrollEmployeeTransaction.Delete;
                end until Employee.Next = 0;
        end;
    end;
    var PayrollTransactionCode: Record "Payroll Transaction Code";
    Employee: Record Employee;
    PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
}
