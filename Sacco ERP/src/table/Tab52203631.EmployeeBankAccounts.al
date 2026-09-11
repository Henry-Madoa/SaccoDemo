table 52203631 "Employee Bank Accounts"
{
    fields
    {
        field(1; "Line No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Employee Code"; Code[20])
        {
            Editable = false;
        }
        field(3; "Bank  Code"; Code[20])
        {
            TableRelation = "External Banks";

            trigger OnValidate()
            begin
                "Bank Name":='';
                "Branch Code":='';
                "Branch Name":='';
                PRBankAccount.Reset;
                PRBankAccount.SetRange(PRBankAccount."Bank Code", "Bank  Code");
                if PRBankAccount.Find('-')then begin
                    "Bank Name":=PRBankAccount."Bank Name";
                    "Percentage to Transfer":=100;
                end;
            end;
        }
        field(4; "Bank Name"; Text[100])
        {
            Editable = false;
        }
        field(5; "Branch Code"; Code[10])
        {
            TableRelation = "External Bank Branches" WHERE("Branch Code"=FIELD("Bank  Code"));

            trigger OnValidate()
            begin
                PRBankBranch.Reset;
                PRBankBranch.SetRange(PRBankBranch."Branch Code", "Branch Code");
                if PRBankBranch.Find('-')then begin
                    "Branch Name":=PRBankBranch."Branch Name" end;
            end;
        }
        field(6; "Branch Name"; Text[100])
        {
            Editable = false;
        }
        field(7; "A/C  Number"; Code[10])
        {
        }
        field(8; "Percentage to Transfer"; Decimal)
        {
            trigger OnValidate()
            var
                currAmount: Decimal;
                Total: Decimal;
            begin
            /*
                    HREmployeeBankAcc.reset;
                    HREmployeeBankAcc.setrange(HREmployeeBankAcc."Employee Code","Employee Code");
                    if HREmployeeBankAcc.find('-') then
                    begin
                        Total:=0;
                        currAmount:=HREmployeeBankAcc."Amount to Transfer (%)";
                        repeat
                            Total += HREmployeeBankAcc."Amount to Transfer (%)";
                        until HREmployeeBankAcc.next = 0;
                        if total + curramount > 100 then error('Percentage of amount to tranfer exceed 100%');
                    end;
                    */
            end;
        }
    }
    keys
    {
        key(Key1; "Line No.", "Employee Code")
        {
        }
    }
    var HREmployeeBankAcc: Record "Employee Bank Accounts";
    PRBankAccount: Record "External Banks";
    PRBankBranch: Record "External Bank Branches";
}
