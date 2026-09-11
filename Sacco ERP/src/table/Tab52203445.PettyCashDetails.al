table 52203445 "Petty Cash Details"
{
    fields
    {
        field(1; No; Code[10])
        {
            trigger OnValidate()
            begin
                If ExpenseClaimHeader.Get(No)then begin
                    "Global Dimension 1 Code":=ExpenseClaimHeader."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=ExpenseClaimHeader."Global Dimension 2 Code";
                    "Global Dimension 3 Code":=ExpenseClaimHeader."Global Dimension 3 Code";
                end;
            end;
        }
        field(2; "Line No"; Integer)
        {
        }
        field(3; "Expense Code"; Code[20])
        {
            TableRelation = "Expense Codes" where("Account No"=filter(<>''));

            trigger OnValidate()
            begin
                Validate(No);
                if ExpenseCode.Get("Expense Code")then begin
                    Expense:=ExpenseCode.Description;
                    Type:=ExpenseCode."Account Type";
                    "Account No":=ExpenseCode."Account No";
                    Description:=ExpenseCode."Account Name";
                end;
            end;
        }
        field(4; Expense; Text[100])
        {
            Editable = false;
        }
        field(5; Type;Enum "Purchase Line Type")
        {
            Editable = false;
        }
        field(6; "Account No"; Code[20])
        {
            Editable = false;
        }
        field(7; Description; Text[250])
        {
        }
        field(8; Amount; Decimal)
        {
            trigger OnValidate()
            var
                TotalAmount: Decimal;
                GeneralLedSetup: Record "General Ledger Setup";
            begin
                TotalAmount:=0;
                
                GeneralLedSetup.Get;
                GeneralLedSetup.TestField("Petty Cash Limit");
                If Amount <= GeneralLedSetup."Petty Cash Limit" then begin
                    ClaimDetails.Reset();
                    ClaimDetails.SetRange(No, Rec.No);
                    ClaimDetails.SetFilter(Amount, '<>%1', 0);
                    ClaimDetails.CalcSums(Amount);
                    TotalAmount:=ClaimDetails.Amount;
                    if((TotalAmount - xRec.Amount) + Rec.Amount > GeneralLedSetup."Petty Cash Limit")then Error(StrSubstNo('For an expense claim above = %1, Kindly create a Imprest Request or Staff Claim!', Format(GeneralLedSetup."Petty Cash Limit")));
                end
                else
                    Error(StrSubstNo('For an expense claim above %1, Kindly create a Imprest Request or Staff Claim!', Format(GeneralLedSetup."Petty Cash Limit")));
            end;
        }
        field(9; "Global Dimension 1 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(10; "Global Dimension 2 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(11; "Global Dimension 3 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,2,3';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(12; Status;Enum "Document Status")
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; No, "Line No")
        {
        }
    }
    trigger OnDelete()
    begin
        if ExpenseClaimHeader.Get(No)then ExpenseClaimHeader.TestField(Status, ExpenseClaimHeader.Status::Open);
    end;
    trigger OnModify()
    begin
        if ExpenseClaimHeader.Get(No)then ExpenseClaimHeader.TestField(Posted, false);
    end;
    var ExpenseCode: Record "Expense Codes";
    ClaimDetails: Record "Petty Cash Details";
    ExpenseClaimHeader: Record "Petty Cash Header";
}
