table 52203557 "Budget Plan Lines"
{
    fields
    {
        field(1; "Document No"; Code[20])
        {
            Editable = false;

            trigger OnValidate()
            begin
                if BudgetPlan.Get("Document No")then begin
                    Budget:=BudgetPlan.Budget;
                    "Global Dimension 1 Code":=BudgetPlan."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=BudgetPlan."Global Dimension 2 Code";
                end;
            end;
        }
        field(2; "Line No"; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(3; Budget; Code[10])
        {
            TableRelation = "G/L Budget Name" where(Status=const(Open));
            NotBlank = true;
            Editable = false;
        }
        field(4; "Budget Line Account"; Code[20])
        {
            TableRelation = "G/L Account" where("Income/Balance"=const("Income Statement"), "Account Category"=filter(Expense|Income), Blocked=const(false), "Direct Posting"=const(true), "Account Type"=const(Posting));

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                BudgetPlanLine.Reset();
                BudgetPlanLine.SetRange("Document No", "Document No");
                BudgetPlanLine.SetRange(Budget, Budget);
                BudgetPlanLine.SetRange(Date, Date);
                BudgetPlanLine.SetRange("Budget Line Account", "Budget Line Account");
                BudgetPlanLine.SetRange("Global Dimension 1 Code", "Global Dimension 1 Code");
                BudgetPlanLine.SetRange("Global Dimension 2 Code", "Global Dimension 2 Code");
                if BudgetPlanLine.FindFirst()then Error(StrSubstNo(Error001, "Budget Line Account", Format(Date)));
                if GLAcc.Get("Budget Line Account")then if GLBudget.Get(Budget)then begin
                        if GLBudget.Status <> GLBudget.Status::Open then Error('You can only Budget while the budget status is Open. Please select an open budget.');
                    end;
            end;
        }
        field(5; Description; Text[100])
        {
            Editable = false;
            CalcFormula = Lookup("G/L Account".Name WHERE("No."=FIELD("Budget Line Account")));
            FieldClass = FlowField;
        }
        field(6; Amount; Decimal)
        {
        }
        field(7; "Global Dimension 1 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(8; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(9; "Global Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(10; Status;Enum "Document Status")
        {
            Editable = false;
        }
        field(11; Posted; Boolean)
        {
            Editable = false;
        }
        field(12; Date; Date)
        {
        }
        field(13; "Attached Doc Count"; Integer)
        {
            BlankNumbers = DontBlank;
            CalcFormula = Count("Document Attachment" WHERE("Table ID"=CONST(51131), "No."=FIELD("Document No"), "Line No."=FIELD("Line No")));
            Caption = 'Attached Doc Count';
            FieldClass = FlowField;
            InitValue = 0;
        }
        field(14; "Period Type"; Option)
        {
            OptionMembers = Annual, Quarterly, Monthly;
        }
    }
    keys
    {
        key(Key1; "Line No", "Document No")
        {
            Clustered = true;
        }
        key(Key2; "Document No", "Line No")
        {
        }
    }
    trigger OnDelete()
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;
    trigger OnModify()
    begin
    //Rec.Testfield(Distributed, false);
    end;
    var GLAcc: Record "G/L Account";
    GLBudget: Record "G/L Budget Name";
    BudgetPlan: Record "Budget Plan";
    BudgetPlanLine: Record "Budget Plan Lines";
    Error001: Label '%1 Budget for %2 have already been created';
}
