table 52203561 "Budget Plan"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; Budget; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Budget Name" where(Status=const(Open));
        }
        field(3; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Global Dimension 1 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(5; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));

            trigger OnValidate()
            begin
                BudgetPlan.Reset();
                BudgetPlan.SetRange(Budget, Budget);
                BudgetPlan.SetRange("Global Dimension 1 Code", "Global Dimension 1 Code");
                BudgetPlan.SetRange("Global Dimension 2 Code", "Global Dimension 2 Code");
                if BudgetPlan.FindFirst()then Error(StrSubstNo(Text000, "Global Dimension 2 Code"));
            end;
        }
        field(6; "Global Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(7; Amount; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Budget Plan Lines".Amount WHERE("Document No"=field("No.")));
        }
        field(8; Status;Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                UpdateLines;
            end;
        }
        field(9; "Created By"; Code[50])
        {
            Editable = false;

            trigger OnValidate()
            begin
                if UserSetup.Get("Created By")then if Employee.Get(UserSetup."Employee No.")then "Global Dimension 2 Code":=Employee."Global Dimension 2 Code";
            end;
        }
        field(10; "Created Date"; Date)
        {
            Editable = false;
        }
        field(11; "No. Series"; Code[11])
        {
            TableRelation = "No. Series";
        }
        field(12; "Reference Date"; Date)
        {
        }
        field(13; Posted; Boolean)
        {
            Editable = false;

            trigger OnValidate()
            begin
                UpdateLines;
            end;
        }
        field(14; "Global Dimension 1 Filter"; Text[250])
        {
            Editable = false;
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Filter';
        }
        field(15; "Global Dimension 2 Filter"; Text[250])
        {
            Editable = false;
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Filter';
        }
        field(16; "Global Dimension 3 Filter"; Text[250])
        {
            Editable = false;
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Filter';
        }
        field(17; "Budget Acounts Range"; Text[30])
        {
            Editable = false;
            Caption = 'Budget Acounts Filter';
        }
        field(18; Scheduled; Boolean)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            AdvancedFinanceSetup.Get;
            AdvancedFinanceSetup.TestField("Budget Plan");
            NoSeriesMgt.InitSeries(AdvancedFinanceSetup."Budget Plan", xRec."No. Series", 0D, "No.", "No. Series");
            "Created Date":=WorkDate;
            Validate("Created By", UserId);
            FindMaturityDate;
        end;
        if UserBudgetRoles.Get(UserId)then begin
            "Global Dimension 1 Filter":=UserBudgetRoles."Global Dimension 1 Code";
            "Global Dimension 2 Filter":=UserBudgetRoles."Global Dimension 2 Code";
            "Global Dimension 3 Filter":=UserBudgetRoles."Global Dimension 3 Code";
            "Budget Acounts Range":=UserBudgetRoles."Budget Acounts Range";
        end
        else
            Error('Please contact admin for User Budget Role Setup');
    end;
    trigger OnDelete()
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;
    trigger OnModify()
    begin
    //Rec.Testfield(Distributed, false);
    end;
    procedure FindMaturityDate()
    var
        AccPeriod: Record "Accounting Period";
    begin
        AccPeriod.Reset;
        AccPeriod.SetRange("Starting Date", 0D, Today);
        AccPeriod.SetRange("New Fiscal Year", true);
        if AccPeriod.Find('+')then begin
            "Reference Date":=AccPeriod."Starting Date";
        end;
    end;
    procedure OnBeforeSendForApprovalValidator(): Boolean begin
        exit(true);
    // DocumentAttachment.Reset();
    // DocumentAttachment.SetRange("Table ID", 52203564);
    // DocumentAttachment.SetRange("No.", Rec."No.");
    // DocumentAttachment.SetFilter("File Name", '<>%1', '');
    // if ((DocumentAttachment.FindSet()) and (Description <> '')) then
    //     exit(true)
    // else begin
    //     Error('Kindly Attach Document for %1 before sending for approval', Rec."No.");
    //     exit(false);
    // end;
    end;
    procedure UpdateLines()
    begin
        BudgetPlanLines.Reset();
        BudgetPlanLines.SetRange("Document No", Rec."No.");
        BudgetPlanLines.SetFilter(Amount, '<>%1', 0);
        BudgetPlanLines.SetFilter("Budget Line Account", '<>%1', '');
        If BudgetPlanLines.FindSet()then begin
            repeat BudgetPlanLines.Status:=Status;
                BudgetPlanLines.Posted:=Posted;
                BudgetPlanLines.Modify(true);
            until BudgetPlanLines.Next() = 0;
        end;
    end;
    procedure ValidatorResponse(): Text begin
        exit(Validator_Err);
    end;
    var DocumentAttachment: Record "Document Attachment";
    Validator_Err: Label 'Either Narration/Description Field is Empty or You have not attached any document, Please check and try again';
    AdvancedFinanceSetup: Record "General Ledger Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    BudgetPlan: Record "Budget Plan";
    BudgetPlanLines: Record "Budget Plan Lines";
    Text000: Label 'The Budget Plan for % have already been Created!';
    UserBudgetRoles: Record "User Budget Roles";
    BudgetMgmt: Codeunit "Budget Management";
    Employee: Record Employee;
    UserSetup: Record "User Setup";
}
