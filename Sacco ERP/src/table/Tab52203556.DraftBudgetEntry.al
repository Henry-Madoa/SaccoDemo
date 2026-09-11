table 52203556 "Draft Budget Entry"
{
    // version BUDGETCaption = 'Draft Budget Entry';
    DrillDownPageID = "Draft Budget Entries";
    LookupPageID = "Draft Budget Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Budget Name"; Code[10])
        {
            Caption = 'Budget Name';
            TableRelation = "G/L Budget Name";
        }
        field(3; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
            ClosingDates = true;
        }
        field(5; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));

            trigger OnValidate()
            begin
                if "Global Dimension 1 Code" = xRec."Global Dimension 1 Code" then exit;
                GetGLSetup;
                ValidateDimValue(GLSetup."Global Dimension 1 Code", "Global Dimension 1 Code");
                UpdateDimensionSetId(GLSetup."Global Dimension 1 Code", "Global Dimension 1 Code");
            end;
        }
        field(6; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));

            trigger OnValidate()
            begin
                if "Global Dimension 2 Code" = xRec."Global Dimension 2 Code" then exit;
                GetGLSetup;
                ValidateDimValue(GLSetup."Global Dimension 2 Code", "Global Dimension 2 Code");
                UpdateDimensionSetId(GLSetup."Global Dimension 2 Code", "Global Dimension 2 Code");
            end;
        }
        field(7; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(9; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(10; "Business Unit Code"; Code[10])
        {
            Caption = 'Business Unit Code';
            TableRelation = "Business Unit";
        }
        field(11; "User ID"; Code[50])
        {
            Caption = 'User ID';
            Editable = false;
            TableRelation = User."User Name";
        }
        field(12; "Budget Dimension 1 Code"; Code[20])
        {
            AccessByPermission = TableData Dimension=R;
            CaptionClass = GetCaptionClass(1);
            Caption = 'Budget Dimension 1 Code';

            trigger OnLookup()
            begin
                "Budget Dimension 1 Code":=OnLookupDimCode(2, "Budget Dimension 1 Code");
            end;
            trigger OnValidate()
            begin
                if "Budget Dimension 1 Code" = xRec."Budget Dimension 1 Code" then exit;
                if GLBudgetName.Name <> "Budget Name" then GLBudgetName.Get("Budget Name");
                ValidateDimValue(GLBudgetName."Budget Dimension 1 Code", "Budget Dimension 1 Code");
                UpdateDimensionSetId(GLBudgetName."Budget Dimension 1 Code", "Budget Dimension 1 Code");
            end;
        }
        field(13; "Budget Dimension 2 Code"; Code[20])
        {
            AccessByPermission = TableData Dimension=R;
            CaptionClass = GetCaptionClass(2);
            Caption = 'Budget Dimension 2 Code';

            trigger OnLookup()
            begin
                "Budget Dimension 2 Code":=OnLookupDimCode(3, "Budget Dimension 2 Code");
            end;
            trigger OnValidate()
            begin
                if "Budget Dimension 2 Code" = xRec."Budget Dimension 2 Code" then exit;
                if GLBudgetName.Name <> "Budget Name" then GLBudgetName.Get("Budget Name");
                ValidateDimValue(GLBudgetName."Budget Dimension 2 Code", "Budget Dimension 2 Code");
                UpdateDimensionSetId(GLBudgetName."Budget Dimension 2 Code", "Budget Dimension 2 Code");
            end;
        }
        field(14; "Budget Dimension 3 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination"=R;
            CaptionClass = GetCaptionClass(3);
            Caption = 'Budget Dimension 3 Code';

            trigger OnLookup()
            begin
                "Budget Dimension 3 Code":=OnLookupDimCode(4, "Budget Dimension 3 Code");
            end;
            trigger OnValidate()
            begin
                if "Budget Dimension 3 Code" = xRec."Budget Dimension 3 Code" then exit;
                if GLBudgetName.Name <> "Budget Name" then GLBudgetName.Get("Budget Name");
                ValidateDimValue(GLBudgetName."Budget Dimension 3 Code", "Budget Dimension 3 Code");
                UpdateDimensionSetId(GLBudgetName."Budget Dimension 3 Code", "Budget Dimension 3 Code");
            end;
        }
        field(15; "Budget Dimension 4 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination"=R;
            CaptionClass = GetCaptionClass(4);
            Caption = 'Budget Dimension 4 Code';

            trigger OnLookup()
            begin
                "Budget Dimension 4 Code":=OnLookupDimCode(5, "Budget Dimension 4 Code");
            end;
            trigger OnValidate()
            begin
                if "Budget Dimension 4 Code" = xRec."Budget Dimension 4 Code" then exit;
                if GLBudgetName.Name <> "Budget Name" then GLBudgetName.Get("Budget Name");
                ValidateDimValue(GLBudgetName."Budget Dimension 4 Code", "Budget Dimension 4 Code");
                UpdateDimensionSetId(GLBudgetName."Budget Dimension 4 Code", "Budget Dimension 4 Code");
            end;
        }
        field(16; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions;
            end;
            trigger OnValidate()
            begin
                if not DimMgt.CheckDimIDComb("Dimension Set ID")then Error(DimMgt.GetDimCombErr);
            end;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Budget Name", "G/L Account No.", Date)
        {
            SumIndexFields = Amount;
        }
        key(Key3; "Budget Name", "G/L Account No.", "Business Unit Code", "Global Dimension 1 Code", "Global Dimension 2 Code", "Budget Dimension 1 Code", "Budget Dimension 2 Code", "Budget Dimension 3 Code", "Budget Dimension 4 Code", Date)
        {
            SumIndexFields = Amount;
        }
        key(Key4; "Budget Name", "G/L Account No.", Description, Date)
        {
        }
        key(Key5; "G/L Account No.", Date, "Budget Name", "Dimension Set ID")
        {
            SumIndexFields = Amount;
        }
        key(Key6; "Last Date Modified", "Budget Name")
        {
        }
    }
    trigger OnDelete()
    begin
        CheckIfBlocked;
    end;
    trigger OnInsert()
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        CheckIfBlocked;
        //Rec.Testfield(Date);
        Rec.Testfield("G/L Account No.");
        Rec.Testfield("Budget Name");
        LockTable;
        "User ID":=UserId;
        "Last Date Modified":=WorkDate;
        if "Entry No." = 0 then "Entry No.":=GetNextEntryNo;
        GetGLSetup;
        DimMgt.GetDimensionSet(TempDimSetEntry, "Dimension Set ID");
        UpdateDimSet(TempDimSetEntry, GLSetup."Global Dimension 1 Code", "Global Dimension 1 Code");
        UpdateDimSet(TempDimSetEntry, GLSetup."Global Dimension 2 Code", "Global Dimension 2 Code");
        UpdateDimSet(TempDimSetEntry, GLBudgetName."Budget Dimension 1 Code", "Budget Dimension 1 Code");
        UpdateDimSet(TempDimSetEntry, GLBudgetName."Budget Dimension 2 Code", "Budget Dimension 2 Code");
        UpdateDimSet(TempDimSetEntry, GLBudgetName."Budget Dimension 3 Code", "Budget Dimension 3 Code");
        UpdateDimSet(TempDimSetEntry, GLBudgetName."Budget Dimension 4 Code", "Budget Dimension 4 Code");
        Validate("Dimension Set ID", DimMgt.GetDimensionSetID(TempDimSetEntry));
    end;
    trigger OnModify()
    begin
        CheckIfBlocked;
        "User ID":=UserId;
        "Last Date Modified":=WorkDate;
    end;
    var Text000: Label 'The dimension value %1 has not been set up for dimension %2.';
    Text001: Label '1,5,,Budget Dimension 1 Code';
    Text002: Label '1,5,,Budget Dimension 2 Code';
    Text003: Label '1,5,,Budget Dimension 3 Code';
    Text004: Label '1,5,,Budget Dimension 4 Code';
    GLBudgetName: Record "G/L Budget Name";
    GLSetup: Record "General Ledger Setup";
    DimVal: Record "Dimension Value";
    DimMgt: Codeunit DimensionManagement;
    GLSetupRetrieved: Boolean;
    local procedure CheckIfBlocked()
    begin
        if "Budget Name" = GLBudgetName.Name then exit;
        if GLBudgetName.Name <> "Budget Name" then GLBudgetName.Get("Budget Name");
        GLBudgetName.TestField(Blocked, false);
    end;
    local procedure ValidateDimValue(DimCode: Code[20]; var DimValueCode: Code[20])
    var
        DimValue: Record "Dimension Value";
    begin
        if DimValueCode = '' then exit;
        DimValue."Dimension Code":=DimCode;
        DimValue.Code:=DimValueCode;
        DimValue.Find('=><');
        if DimValueCode <> CopyStr(DimValue.Code, 1, StrLen(DimValueCode))then Error(Text000, DimValueCode, DimCode);
        DimValueCode:=DimValue.Code;
    end;
    local procedure GetGLSetup()
    begin
        if not GLSetupRetrieved then begin
            GLSetup.Get;
            GLSetupRetrieved:=true;
        end;
    end;
    local procedure OnLookupDimCode(DimOption: Option "Global Dimension 1", "Global Dimension 2", "Budget Dimension 1", "Budget Dimension 2", "Budget Dimension 3", "Budget Dimension 4"; DefaultValue: Code[20]): Code[20]var
        DimValue: Record "Dimension Value";
        DimValueList: Page "Dimension Value List";
    begin
        if DimOption in[DimOption::"Global Dimension 1", DimOption::"Global Dimension 2"]then GetGLSetup
        else if GLBudgetName.Name <> "Budget Name" then GLBudgetName.Get("Budget Name");
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
    local procedure GetNextEntryNo(): Integer var
        GLBudgetEntry: Record "G/L Budget Entry";
    begin
        GLBudgetEntry.SetCurrentKey("Entry No.");
        if GLBudgetEntry.FindLast then exit(GLBudgetEntry."Entry No." + 1);
        exit(1);
    end;
    local procedure GetCaptionClass(BudgetDimType: Integer): Text[250]begin
        if GetFilter("Budget Name") <> '' then if GLBudgetName.Name <> GetRangeMin("Budget Name")then if not GLBudgetName.Get(GetRangeMin("Budget Name"))then Clear(GLBudgetName);
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
    procedure ShowDimensions()
    var
        DimSetEntry: Record "Dimension Set Entry";
        OldDimSetID: Integer;
    begin
        OldDimSetID:="Dimension Set ID";
        "Dimension Set ID":=DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', "Budget Name", "G/L Account No.", "Entry No."));
        if OldDimSetID = "Dimension Set ID" then GLBudgetName.Get("Budget Name");
        "Global Dimension 1 Code":='';
        "Global Dimension 2 Code":='';
        "Budget Dimension 1 Code":='';
        "Budget Dimension 2 Code":='';
        "Budget Dimension 3 Code":='';
        "Budget Dimension 4 Code":='';
        if DimSetEntry.Get("Dimension Set ID", GLSetup."Global Dimension 1 Code")then "Global Dimension 1 Code":=DimSetEntry."Dimension Value Code";
        if DimSetEntry.Get("Dimension Set ID", GLSetup."Global Dimension 2 Code")then "Global Dimension 2 Code":=DimSetEntry."Dimension Value Code";
        if DimSetEntry.Get("Dimension Set ID", GLBudgetName."Budget Dimension 1 Code")then "Budget Dimension 1 Code":=DimSetEntry."Dimension Value Code";
        if DimSetEntry.Get("Dimension Set ID", GLBudgetName."Budget Dimension 2 Code")then "Budget Dimension 2 Code":=DimSetEntry."Dimension Value Code";
        if DimSetEntry.Get("Dimension Set ID", GLBudgetName."Budget Dimension 3 Code")then "Budget Dimension 3 Code":=DimSetEntry."Dimension Value Code";
        if DimSetEntry.Get("Dimension Set ID", GLBudgetName."Budget Dimension 4 Code")then "Budget Dimension 4 Code":=DimSetEntry."Dimension Value Code";
    end;
    procedure UpdateDimSet(var TempDimSetEntry: Record "Dimension Set Entry" temporary; DimCode: Code[20]; DimValueCode: Code[20])
    begin
        if DimCode = '' then exit;
        if TempDimSetEntry.Get("Dimension Set ID", DimCode)then TempDimSetEntry.Delete;
        if DimValueCode = '' then DimVal.Init
        else
            DimVal.Get(DimCode, DimValueCode);
        TempDimSetEntry.Init;
        TempDimSetEntry."Dimension Set ID":="Dimension Set ID";
        TempDimSetEntry."Dimension Code":=DimCode;
        TempDimSetEntry."Dimension Value Code":=DimValueCode;
        TempDimSetEntry."Dimension Value ID":=DimVal."Dimension Value ID";
        TempDimSetEntry.Insert;
    end;
    local procedure UpdateDimensionSetId(DimCode: Code[20]; DimValueCode: Code[20])
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, "Dimension Set ID");
        UpdateDimSet(TempDimSetEntry, DimCode, DimValueCode);
        "Dimension Set ID":=DimMgt.GetDimensionSetID(TempDimSetEntry);
    end;
}
