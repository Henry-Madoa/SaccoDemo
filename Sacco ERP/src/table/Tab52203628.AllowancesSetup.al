table 52203628 "Allowances Setup"
{
    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payroll Transaction Code" where(Type=const(Income), "Special Transactions"=const("Board/Staff Allowance"));

            trigger OnValidate()
            begin
                PayrollTransaction.Get(Code);
                PayrollTransaction.TestField("GL Account No.");
                Name:=PayrollTransaction.Name;
                "GL Account No.":=PayrollTransaction."GL Account No.";
            end;
        }
        field(2; Name; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; "Type"; Option)
        {
            OptionMembers = "", Staff, Board;
        }
        field(4; Group; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = if(Type=const(Staff))"Employee Payroll Scales"
            else if(Type=const(Board))"Board Member Categories";
        }
        field(5; "GL Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
            Editable = false;
        }
        field(6; Taxable; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Tax Relief"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Relief Days"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(9; Rate; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; Editable; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Tax Code"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "VAT Product Posting Group" where(Type=const(Allowance));
        }
    }
    keys
    {
        key(Key1; Code, Group)
        {
        }
    }
    var PayrollTransaction: Record "Payroll Transaction Code";
}
