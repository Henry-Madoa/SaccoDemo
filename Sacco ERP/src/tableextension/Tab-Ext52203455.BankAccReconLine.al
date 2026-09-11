tableextension 52203455 "Bank Acc. Recon. Line" extends "Bank Acc. Reconciliation Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; Reconciled; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Bal Account No."; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(50002; Closed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "Closing Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "Statement Link"; Code[20])
        {
            CalcFormula = Lookup("Bank Account Statement Line"."Cheque Number" WHERE("Cheque Number" = FIELD("Check No.")));
            FieldClass = FlowField;
        }
        field(50005; "Deposit Slip Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50006; "Statement Amt"; Decimal)
        {
            CalcFormula = Sum("Bank Account Statement Line"."Statement Amount" WHERE("Bank Account No." = FIELD("Bank Account No."), "Statement No." = FIELD("Statement No."), "Check No." = FIELD("Check No.")));
            FieldClass = FlowField;
        }
        field(50007; "Statement Link No"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Bank Account Statement Line"."Statement Line No." WHERE("Bank Account No." = FIELD("Bank Account No."), "Statement No." = FIELD("Statement No."));

            trigger OnValidate()
            begin
                if "Statement Link No" <> 0 then begin
                    Reconciled := true;
                    Rec.Modify;
                    if StatementLines.Get("Bank Account No.", "Statement No.", "Statement Link No") then begin
                        StatementLines.Reconciled := true;
                        StatementLines.Modify;
                    end;
                end;
            end;
        }
        field(50008; "Transaction Type"; Option)
        {
            DataClassification = ToBeClassified;
            Editable = true;
            OptionMembers = " ",Receipt,Payment;
        }
        field(50009; "External Document No"; Code[30])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50010; "FT Number"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50011; "Cheque No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50012; "Voucher No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50013; Found; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    var
        StatementLines: Record "Bank Account Statement Line";
}
