table 52204027 "Collateral Register"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Collateral Registers";
    LookupPageId = "Collateral Registers";

    fields
    {
        field(1; "No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No."; code[20])
        {
            TableRelation = Members where(Status = filter(Active | Dormant));
        }
        field(3; "Member Name"; Text[80])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Full Name" where("No." = field("Member No.")));
        }
        field(4; Category; Option)
        {
            OptionMembers = " ",Vehicle,"Real Estate";
        }
        field(5; "Collateral Type"; code[20])
        {
        }
        field(6; "Collateral Description"; text[150])
        {
        }
        field(7; "Collateral Value"; Decimal)
        {
        }
        field(8; Guarantee; Decimal)
        {
            Caption = 'LTV';
        }
        field(9; Status; Enum "Collateral Status")
        {
            Editable = false;
        }
        field(10; "Serial/Reg No."; Code[100])
        {
        }
        field(11; "Posting Date"; Date)
        {
        }
        field(12; "Owner Name"; Code[150])
        {
        }
        field(13; "Owner Phone No."; Code[50])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Mobile Phone No." where("No." = field("Member No.")));
        }
        field(14; "Owner ID No"; Code[20])
        {
        }
        field(15; "Insurance Expiry Date"; Date)
        {
        }
        field(16; "Car Track Due Date"; Date)
        {
        }
        field(17; "Linked Loan Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Collateral Linked Loans"."Current Balance" where("No." = field("No.")));
        }
        field(18; County; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Counties;
        }
        field(19; "County Name"; Text[50])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Counties.Name where("County Code" = field(County)));
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(CollateralInfo; "Member No.", "Collateral Type", "Collateral Description")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Member No.", "Member Name", "Collateral Type", "Collateral Description")
        {
        }
    }
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
        LoanSecurity.SetRange("Security Type", LoanSecurity."Security Type"::Collateral);
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
