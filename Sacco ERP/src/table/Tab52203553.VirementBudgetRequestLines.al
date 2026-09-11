table 52203553 "Virement Budget Request Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; LineNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Document No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Budget Name"; Code[10])
        {
            TableRelation = "G/L Budget Name";
            Caption = 'Budget';
        }
        field(4; "Transfer From"; Code[20])
        {
            TableRelation = "G/L Account" where("Income/Balance"=const("Income Statement"), "Account Category"=const(Expense), Blocked=const(false), "Direct Posting"=const(true), "Account Type"=const(Posting));
            Caption = 'Transfer Allocation From';

            trigger OnValidate()
            begin
                Rec.Testfield("Document Date");
                Rec.Testfield(Description);
                GLBudgetEntry.Reset();
                GLBudgetEntry.SetRange("Budget Name", "Budget Name");
                GLBudgetEntry.SetRange("G/L Account No.", "Transfer From");
                GLBudgetEntry.SetFilter(Amount, '>%1', 0);
                If GLBudgetEntry.FindFirst() = false then Error(Error01);
            end;
        }
        field(5; "Transfer To"; Code[20])
        {
            TableRelation = "G/L Account" where("Income/Balance"=const("Income Statement"), "Account Category"=const(Expense), Blocked=const(false), "Direct Posting"=const(true), "Account Type"=const(Posting));
            Caption = 'Transfer Allocation To';
        }
        field(6; "Document Date"; Date)
        {
            Caption = 'Date';
        }
        field(7; Description; Text[250])
        {
        }
        field(8; "Budget Dimension 1 Code"; Code[20])
        {
            AccessByPermission = TableData Dimension=R;
            CaptionClass = GetCaptionClass(1);
            Caption = 'Budget Dimension 1 Code';
        }
        field(9; "Budget Dimension 2 Code"; Code[20])
        {
            AccessByPermission = TableData Dimension=R;
            CaptionClass = GetCaptionClass(2);
            Caption = 'Budget Dimension 2 Code';
        }
        field(10; "Budget Dimension 3 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination"=R;
            CaptionClass = GetCaptionClass(3);
            Caption = 'Budget Dimension 3 Code';
        }
        field(11; "Budget Dimension 4 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination"=R;
            CaptionClass = GetCaptionClass(4);
            Caption = 'Budget Dimension 4 Code';
        }
        field(12; Amount; Decimal)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Transfer From");
                GLBudgetEntry.Reset();
                GLBudgetEntry.SetRange("G/L Account No.", "Transfer From");
                GLBudgetEntry.SetRange("Budget Name", "Budget Name");
                If GLBudgetEntry.FindSet()then begin
                    GLBudgetEntry.CalcSums(Amount);
                    GLEntry.Reset();
                    GLEntry.SetRange("G/L Account No.", "Transfer From");
                    If GLEntry.FindSet()then GLEntry.CalcSums(Amount);
                    If(Amount > (GLBudgetEntry.Amount - GLEntry.Amount))then Error(Error02);
                end
                else
                    Error(Error01);
            end;
        }
        field(13; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(14; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
    }
    keys
    {
        key(Key1; LineNo, "Document No")
        {
            Clustered = true;
        }
        key(Key2; "Document No", LineNo)
        {
        }
    }
    var Header: Record "Virement Budget Request";
    Text001: Label '1,5,,Budget Dimension 1 Code';
    Text002: Label '1,5,,Budget Dimension 2 Code';
    Text003: Label '1,5,,Budget Dimension 3 Code';
    Text004: Label '1,5,,Budget Dimension 4 Code';
    Error01: Label 'You cannot transfer Funds from an Account that do not have allocation';
    Error02: Label 'You cannot transfer an amount more than the Budget Balance';
    GLBudgetName: Record "G/L Budget Name";
    GLBudgetEntry: Record "G/L Budget Entry";
    GLEntry: Record "G/L Entry";
    trigger OnInsert()
    begin
        if Header.Get("Document No")then begin
            "Budget Name":=Header."Budget Code";
            "Budget Dimension 1 Code":=Header."Budget Dimension 1 Code";
            "Budget Dimension 2 Code":=Header."Budget Dimension 2 Code";
            "Budget Dimension 3 Code":=Header."Budget Dimension 3 Code";
            "Budget Dimension 4 Code":=Header."Budget Dimension 4 Code";
            "Global Dimension 1 Code":=Header."Global Dimension 1 Code";
            "Global Dimension 2 Code":=Header."Global Dimension 2 Code";
        end;
    end;
    procedure GetCaptionClass(BudgetDimType: Integer): Text[250]begin
        if GetFilter("Budget Name") <> '' then begin
            GLBudgetName.SetFilter(Name, GetFilter("Budget Name"));
            if not GLBudgetName.FindFirst then Clear(GLBudgetName);
        end;
        case BudgetDimType of 1: begin
            if GLBudgetName."Budget Dimension 1 Code" <> '' then exit('1,5,' + GLBudgetName."Budget Dimension 1 Code");
            exit(Text001);
        end;
        2: begin
            if GLBudgetName."Budget Dimension 2 Code" <> '' then exit('1,5,' + GLBudgetName."Budget Dimension 2 Code");
            exit(Text002);
        end;
        3: begin
            if GLBudgetName."Budget Dimension 3 Code" <> '' then exit('1,5,' + GLBudgetName."Budget Dimension 3 Code");
            exit(Text003);
        end;
        4: begin
            if GLBudgetName."Budget Dimension 4 Code" <> '' then exit('1,5,' + GLBudgetName."Budget Dimension 4 Code");
            exit(Text004);
        end;
        end;
    end;
}
