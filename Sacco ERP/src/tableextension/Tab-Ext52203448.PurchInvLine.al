tableextension 52203448 "Purch. Inv. Line" extends "Purch. Inv. Line"
{
    fields
    {
        modify("Direct Unit Cost")
        {
            trigger OnAfterValidate()
            begin
                if Type <> Type::"Fixed Asset" then BudgetMgt.ValidatePurchaseLinesBudgetPI(Rec, "Amount Including VAT");
            end;
        }
        field(50000; "RFQ No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50001; MFR; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50002; "Catalog No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50003; Status; Enum "Purchase Document Status")
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "Expense Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Expense Codes" where("Account No" = filter(<> ''));

            trigger OnValidate()
            begin
                if Expense.Get("Expense Code") then begin
                    Type := Expense."Account Type";
                    Validate(Type);
                    Validate("No.", Expense."Account No");
                    "Expense Code" := Expense.Code;
                    "Payment Code" := Expense.Code;
                    "Expense Description" := Expense.Description;
                    "Payment Description" := Expense.Description;
                end;
            end;
        }
        field(50005; "Expense Description"; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50006; "Cost Center"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = FILTER(1), Blocked = const(false));
        }
        field(50007; "Asset No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Fixed Asset";
        }
        field(50008; "Payment Code"; Code[20])
        {
            Caption = 'Expense Code';
            DataClassification = ToBeClassified;
            TableRelation = "Expense Codes" where("Account No" = filter(<> ''));

            trigger OnValidate()
            begin
                if Expense.Get("Payment Code") then begin
                    Validate(Type, Expense."Account Type");
                    Validate("No.", Expense."Account No");
                    "Expense Code" := Expense.Code;
                    "Payment Code" := Expense.Code;
                    "Expense Description" := Expense.Description;
                    "Payment Description" := Expense.Description;
                end;
            end;
        }
        field(50009; "Payment Description"; Text[50])
        {
            Caption = 'Expense Description';
            DataClassification = ToBeClassified;
        }
        field(500010; Committed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(500011; "Budget Available"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50015; "Shortcut Dimension 3 Code"; Code[10])
        {
            CaptionClass = '1,2,3';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3));
        }
        field(50016; "Procurement Plan No."; Code[10])
        {
            DataClassification = ToBeClassified;
        }
    }
    var
        Expense: Record "Expense Codes";
        BudgetMgt: Codeunit "Budget Management";
        ExpenseCode: Code[20];
        ExpenseDescription: Text;
}
