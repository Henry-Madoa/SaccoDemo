table 52203552 "Virement Budget Request"
{
    DrillDownPageId = "Virement Budget Requests";
    LookupPageId = "Virement Budget Requests";

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; Narration; Text[500])
        {
        }
        field(3; "Created Date"; Date)
        {
            Editable = false;
        }
        field(4; "Created By"; Code[50])
        {
            Editable = false;
        }
        field(5; Status;Enum "Document Status")
        {
            Editable = false;
        }
        field(6; "No. Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(7; Effected; Boolean)
        {
            Editable = false;
        }
        field(8; "Effected By"; Code[50])
        {
            Editable = false;
        }
        field(9; "Effected Date"; Date)
        {
            Editable = false;
        }
        field(10; "Budget Code"; Code[10])
        {
            TableRelation = "G/L Budget Name";
            Caption = 'Budget';
        }
        field(11; "Budget Name"; Text[80])
        {
            CalcFormula = Lookup("G/L Budget Name".Description WHERE(Name=FIELD("Budget Code")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(12; Amount; Decimal)
        {
            CalcFormula = Sum("Virement Budget Request Lines".Amount WHERE("Document No"=FIELD("No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(13; "Document Date"; Date)
        {
        }
        field(14; "Budget Dimension 1 Code"; Code[20])
        {
            AccessByPermission = TableData Dimension=R;
            CaptionClass = GetCaptionClass(1);
            Caption = 'Budget Dimension 1 Code';

            trigger OnLookup()
            begin
                "Budget Dimension 1 Code":=OnLookupDimCode(2, "Budget Dimension 1 Code");
                ValidateDimValue(GLBudgetName."Budget Dimension 1 Code", "Budget Dimension 1 Code");
            end;
            trigger OnValidate()
            begin
                UpdateLinesDimensions;
            end;
        }
        field(15; "Budget Dimension 2 Code"; Code[20])
        {
            AccessByPermission = TableData Dimension=R;
            CaptionClass = GetCaptionClass(2);
            Caption = 'Budget Dimension 2 Code';

            trigger OnLookup()
            begin
                "Budget Dimension 2 Code":=OnLookupDimCode(3, "Budget Dimension 2 Code");
                ValidateDimValue(GLBudgetName."Budget Dimension 2 Code", "Budget Dimension 2 Code");
            end;
            trigger OnValidate()
            begin
                UpdateLinesDimensions;
            end;
        }
        field(16; "Budget Dimension 3 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination"=R;
            CaptionClass = GetCaptionClass(3);
            Caption = 'Budget Dimension 3 Code';

            trigger OnLookup()
            begin
                "Budget Dimension 3 Code":=OnLookupDimCode(4, "Budget Dimension 3 Code");
                ValidateDimValue(GLBudgetName."Budget Dimension 3 Code", "Budget Dimension 3 Code");
            end;
            trigger OnValidate()
            begin
                UpdateLinesDimensions;
            end;
        }
        field(17; "Budget Dimension 4 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination"=R;
            CaptionClass = GetCaptionClass(4);
            Caption = 'Budget Dimension 4 Code';

            trigger OnLookup()
            begin
                "Budget Dimension 4 Code":=OnLookupDimCode(5, "Budget Dimension 4 Code");
                ValidateDimValue(GLBudgetName."Budget Dimension 4 Code", "Budget Dimension 4 Code");
            end;
            trigger OnValidate()
            begin
                UpdateLinesDimensions;
            end;
        }
        field(18; Approvers; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(51123), "Document No."=FIELD("No."), Status=FILTER(Approved)));
            FieldClass = FlowField;
            Caption = 'Approvers';
            Editable = false;
        }
        field(19; "Pending Approvals Ext"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(51123), "Document No."=FIELD("No."), Status=FILTER(Open|Created)));
            Caption = 'Pending Approvals';
            FieldClass = FlowField;
            Editable = false;
        }
        field(20; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));

            trigger OnValidate()
            begin
                UpdateLinesDimensions;
            end;
        }
        field(21; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));

            trigger OnValidate()
            begin
                UpdateLinesDimensions;
            end;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    var AdvanceFinSetup: Record "General Ledger Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    Text001: Label '1,5,,Budget Dimension 1 Code';
    Text002: Label '1,5,,Budget Dimension 2 Code';
    Text003: Label '1,5,,Budget Dimension 3 Code';
    Text004: Label '1,5,,Budget Dimension 4 Code';
    GLBudgetName: Record "G/L Budget Name";
    Lines: Record "Virement Budget Request Lines";
    GLSetup: Record "General Ledger Setup";
    GLSetupRetrieved: Boolean;
    DimMgt: Codeunit DimensionManagement;
    trigger OnInsert()
    begin
        if "No." = '' then begin
            AdvanceFinSetup.Get;
            AdvanceFinSetup.TestField("Suppl. Budget Request Nos");
            NoSeriesMgt.InitSeries(AdvanceFinSetup."Suppl. Budget Request Nos", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        "Created By":=UserId;
        "Created Date":=WorkDate;
        Rec.Status:=Rec.Status::Open;
    end;
    trigger OnDelete()
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;
    procedure GetCaptionClass(BudgetDimType: Integer): Text[250]begin
        if GetFilter("Budget Code") <> '' then begin
            GLBudgetName.SetFilter(Name, GetFilter("Budget Code"));
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
    local procedure UpdateLinesDimensions()
    begin
        Lines.Reset();
        Lines.SetRange("Document No", Rec."No.");
        If Lines.FindSet()then begin
            repeat Lines."Budget Name":="Budget Code";
                Lines."Budget Dimension 1 Code":="Budget Dimension 1 Code";
                Lines."Budget Dimension 2 Code":="Budget Dimension 2 Code";
                Lines."Budget Dimension 3 Code":="Budget Dimension 3 Code";
                Lines."Budget Dimension 4 Code":="Budget Dimension 4 Code";
                Lines."Global Dimension 1 Code":="Global Dimension 1 Code";
                Lines."Global Dimension 2 Code":="Global Dimension 2 Code";
                Lines.Modify(true);
            until Lines.Next() = 0;
        end;
    end;
    local procedure OnLookupDimCode(DimOption: Option "Global Dimension 1", "Global Dimension 2", "Budget Dimension 1", "Budget Dimension 2", "Budget Dimension 3", "Budget Dimension 4"; DefaultValue: Code[20]): Code[20]var
        DimValue: Record "Dimension Value";
        DimValueList: Page "Dimension Value List";
    begin
        if DimOption in[DimOption::"Global Dimension 1", DimOption::"Global Dimension 2"]then GetGLSetup
        else if GLBudgetName.Name <> "Budget Code" then GLBudgetName.Get("Budget Code");
        case DimOption of DimOption::"Global Dimension 1": DimValue."Dimension Code":=GLSetup."Global Dimension 1 Code";
        DimOption::"Global Dimension 2": DimValue."Dimension Code":=GLSetup."Global Dimension 2 Code";
        DimOption::"Budget Dimension 1": DimValue."Dimension Code":=GLBudgetName."Budget Dimension 1 Code";
        DimOption::"Budget Dimension 2": DimValue."Dimension Code":=GLBudgetName."Budget Dimension 2 Code";
        DimOption::"Budget Dimension 3": DimValue."Dimension Code":=GLBudgetName."Budget Dimension 3 Code";
        DimOption::"Budget Dimension 4": DimValue."Dimension Code":=GLBudgetName."Budget Dimension 4 Code";
        end;
        DimValue.SetRange("Dimension Code", DimValue."Dimension Code");
        if DimValue.Get(DimValue."Dimension Code", DefaultValue)then;
        DimValueList.SetTableView(DimValue);
        DimValueList.SetRecord(DimValue);
        DimValueList.LookupMode:=true;
        if DimValueList.RunModal = ACTION::LookupOK then begin
            DimValueList.GetRecord(DimValue);
            exit(DimValue.Code);
        end;
        exit(DefaultValue);
    end;
    local procedure GetGLSetup()
    begin
        if not GLSetupRetrieved then begin
            GLSetup.Get();
            GLSetupRetrieved:=true;
        end;
    end;
    local procedure ValidateDimValue(DimCode: Code[20]; DimValueCode: Code[20])
    begin
        if not DimMgt.CheckDimValue(DimCode, DimValueCode)then Error(DimMgt.GetDimErr());
    end;
    procedure OnBeforeSendForApproval()
    begin
        TestField(Status, Rec.Status::Open);
        Testfield("Budget Code");
        Testfield("Budget Name");
        Testfield(Narration);
        CalcFields(Amount);
        if Amount = 0 then Error(Text000);
    end;
    procedure ValidatorResponse(): Text begin
        exit(Validator_Err);
    end;
    var DocumentAttachment: Record "Document Attachment";
    Validator_Err: Label 'You have not attached any document. Please attach document/s and continue.';
    Text000: Label 'Amount can not be equal to zero.';
}
