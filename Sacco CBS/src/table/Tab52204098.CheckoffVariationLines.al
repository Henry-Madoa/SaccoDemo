table 52204098 "Checkoff Variation Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Product Code"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1));
        }
        field(3; Description; Text[100])
        {
            Editable = false;
        }
        field(4; "Current Contribution"; Decimal)
        {
            Editable = false;
        }
        field(5; "New Contribution"; Decimal)
        {
            trigger OnValidate()
            var
                ProductFactory: Record "Sacco Products";
                ObjSaccoSetup: Record "General Ledger Setup";
                DepositErrMsg: TextConst ENU = 'You cannot enter new contibution less than the minimum allowable deposits %1';
            begin
                if ProductFactory.Get("Product Code") then begin
                    if ProductFactory."Product Posting Type" = ProductFactory."Product Posting Type"::"Loan Account" then begin
                        if "Current Contribution" > "New Contribution" then Error('You Cannot Reduce the current contribution');
                    end;
                end;
                ObjSaccoSetup.Get();
                if ProductFactory."Product Posting Type" = ProductFactory."Product Posting Type"::"Non Withdrawable Deposit" then begin
                    if "New Contribution" < ObjSaccoSetup."Minimum Deposit Cont." then Error(DepositErrMsg, ObjSaccoSetup."Minimum Deposit Cont.");
                end;
            end;
        }
        field(6; "Account Balance"; Decimal)
        {
        }
        field(7; Modified; Boolean)
        {
            Editable = false;
        }
        field(8; "Member No."; Code[50])
        {
            // DataClassification = ToBeClassified;
            FieldClass = FlowField;
            CalcFormula = lookup("Checkoff Variation Header"."Member No" where("No." = field("No.")));
            Editable = false;
        }
        field(9; "Application No."; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Loans."No." where(Posted = const(true), "Member No." = field("Member No."));
            Editable = false;
        }
        field(10; "Loan Account"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Loans."Loan Account" where(Posted = const(true), "Member No." = field("Member No."));
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.", "Product Code")
        {
            Clustered = true;
        }
    }
    trigger OnModify()
    begin
        Modified := true;
    end;
}
