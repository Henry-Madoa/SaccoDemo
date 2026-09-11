table 52204065 "Transaction Recoveries"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Recovery Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Loan,"Standing Order","Internal Deposit";
        }
        field(3; "Recovery Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF ("Recovery Type" = CONST(Loan)) "Sacco Products".Code where(Indentation = const(1), "Product Posting Type" = const("Loan Account"))
            ELSE IF ("Recovery Type" = CONST("Standing Order")) "Standing Order Types"
            ELSE IF ("Recovery Type" = CONST("Internal Deposit")) "Sacco Products".Code where(Indentation = const(1), "Product Posting Type" = filter(<> "Loan Account"));

            trigger OnValidate()
            var
                SaccoProduct: Record "Sacco Products";
                STOTypes: Record "Standing Order Types";
            begin
                case "Recovery Type" of
                    "Recovery Type"::"Standing Order":
                        begin
                            if STOTypes.Get("Recovery Code") then "Recovery Description" := STOTypes.Description;
                        end;
                    "Recovery Type"::Loan:
                        begin
                            if SaccoProduct.Get("Recovery Code") then "Recovery Description" := SaccoProduct.Description;
                        end;
                    "Recovery Type"::"Internal Deposit":
                        begin
                            if SaccoProduct.Get("Recovery Code") then "Recovery Description" := SaccoProduct.Description;
                        end;
                end;
            end;
        }
        field(4; "Recovery Description"; Text[100])
        {
        }
        field(5; "Prioirity"; Integer)
        {
        }
        field(6; "Deduction Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Monthly Installment,Arrears Amount,Loan Balance,Boost to Minimum';
            OptionMembers = "Monthly Installment","Arrears Amount","Loan Balance","Boost to Minimum";
        }
    }
    keys
    {
        key(Key1; Code, "Recovery Type", "Recovery Code")
        {
            Clustered = true;
        }
        key(Key2; Prioirity)
        {
        }
    }
}
