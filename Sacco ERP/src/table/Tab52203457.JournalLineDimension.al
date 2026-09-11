table 52203457 "Journal Line Dimension"
{
    Caption = 'Journal Line Dimension';

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type"=CONST(Table));
        }
        field(2; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = IF("Table ID"=FILTER(81|221))"Gen. Journal Template".Name
            ELSE IF("Table ID"=CONST(83))"Item Journal Template".Name
            ELSE IF("Table ID"=CONST(207))"Res. Journal Template".Name
            ELSE IF("Table ID"=CONST(246))"Req. Wksh. Template".Name
            ELSE IF("Table ID"=CONST(5621))"FA Journal Template".Name
            ELSE IF("Table ID"=CONST(5635))"Insurance Journal Template".Name;
        }
        field(3; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = IF("Table ID"=FILTER(81|221))"Gen. Journal Batch".Name WHERE("Journal Template Name"=FIELD("Journal Template Name"))
            ELSE IF("Table ID"=CONST(83))"Item Journal Batch".Name WHERE("Journal Template Name"=FIELD("Journal Template Name"))
            ELSE IF("Table ID"=CONST(207))"Res. Journal Batch".Name WHERE("Journal Template Name"=FIELD("Journal Template Name"))
            ELSE IF("Table ID"=CONST(246))"Requisition Wksh. Name".Name WHERE("Worksheet Template Name"=FIELD("Journal Template Name"))
            ELSE IF("Table ID"=CONST(5621))"FA Journal Batch".Name WHERE("Journal Template Name"=FIELD("Journal Template Name"))
            ELSE IF("Table ID"=CONST(5635))"Insurance Journal Batch".Name WHERE("Journal Template Name"=FIELD("Journal Template Name"));
        }
        field(4; "Journal Line No."; Integer)
        {
            Caption = 'Journal Line No.';
        }
        field(5; "Allocation Line No."; Integer)
        {
            Caption = 'Allocation Line No.';
        }
        field(6; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            NotBlank = true;
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                if not DimMgt.CheckDim("Dimension Code")then Error(DimMgt.GetDimErr);
                "Dimension Value Code":='';
            end;
        }
        field(7; "Dimension Value Code"; Code[20])
        {
            Caption = 'Dimension Value Code';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code"=FIELD("Dimension Code"));

            trigger OnValidate()
            begin
                if not DimMgt.CheckDimValue("Dimension Code", "Dimension Value Code")then Error(DimMgt.GetDimErr);
            end;
        }
        field(8; "New Dimension Value Code"; Code[20])
        {
            Caption = 'New Dimension Value Code';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code"=FIELD("Dimension Code"));

            trigger OnValidate()
            begin
                if not DimMgt.CheckDimValue("Dimension Code", "New Dimension Value Code")then Error(DimMgt.GetDimErr);
            end;
        }
    }
    keys
    {
        key(Key1; "Table ID", "Journal Template Name", "Journal Batch Name", "Journal Line No.", "Allocation Line No.", "Dimension Code")
        {
        }
        key(Key2; "Dimension Code", "Dimension Value Code")
        {
        }
    }
    trigger OnDelete()
    begin
        GLSetup.Get;
        if "Dimension Code" = GLSetup."Global Dimension 1 Code" then UpdateGlobalDimCode(1, "Table ID", "Journal Template Name", "Journal Batch Name", "Journal Line No.", "Allocation Line No.", '', '');
        if "Dimension Code" = GLSetup."Global Dimension 2 Code" then UpdateGlobalDimCode(2, "Table ID", "Journal Template Name", "Journal Batch Name", "Journal Line No.", "Allocation Line No.", '', '');
    end;
    trigger OnInsert()
    begin
        if("Dimension Value Code" = '') and ("New Dimension Value Code" = '')then Error(Text001, TableCaption);
        GLSetup.Get;
        if "Dimension Code" = GLSetup."Global Dimension 1 Code" then UpdateGlobalDimCode(1, "Table ID", "Journal Template Name", "Journal Batch Name", "Journal Line No.", "Allocation Line No.", "Dimension Value Code", "New Dimension Value Code");
        if "Dimension Code" = GLSetup."Global Dimension 2 Code" then UpdateGlobalDimCode(2, "Table ID", "Journal Template Name", "Journal Batch Name", "Journal Line No.", "Allocation Line No.", "Dimension Value Code", "New Dimension Value Code");
    end;
    trigger OnModify()
    begin
        if("Dimension Value Code" = '') and ("New Dimension Value Code" = '')then Error(Text001, TableCaption);
        GLSetup.Get;
        if "Dimension Code" = GLSetup."Global Dimension 1 Code" then UpdateGlobalDimCode(1, "Table ID", "Journal Template Name", "Journal Batch Name", "Journal Line No.", "Allocation Line No.", "Dimension Value Code", "New Dimension Value Code");
        if "Dimension Code" = GLSetup."Global Dimension 2 Code" then UpdateGlobalDimCode(2, "Table ID", "Journal Template Name", "Journal Batch Name", "Journal Line No.", "Allocation Line No.", "Dimension Value Code", "New Dimension Value Code");
    end;
    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;
    var Text000: Label 'You can''t rename a %1.';
    GLSetup: Record "General Ledger Setup";
    DimMgt: Codeunit DimensionManagement;
    Text001: Label 'At least one dimension value code must have a value. Enter a value or delete the %1. ';
    procedure UpdateGlobalDimCode(GlobalDimCodeNo: Integer; "Table ID": Integer; "Journal Template Name": Code[10]; "Journal Batch Name": Code[10]; "Journal Line No.": Integer; "Allocation Line No.": Integer; NewDimValue: Code[20]; NewNewDimValue: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
        ItemJnlLine: Record "Item Journal Line";
        ResJnlLine: Record "Res. Journal Line";
        GenJnlAlloc: Record "Gen. Jnl. Allocation";
        ReqLine: Record "Requisition Line";
        FAJnlLine: Record "FA Journal Line";
        InsuranceJnlLine: Record "Insurance Journal Line";
        PlanningComponent: Record "Planning Component";
        StdGenJnlLine: Record "Standard General Journal Line";
        StdItemJnlLine: Record "Standard Item Journal Line";
    begin
        case "Table ID" of DATABASE::"Gen. Journal Line": begin
            if GenJnlLine.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.")then begin
                case GlobalDimCodeNo of 1: GenJnlLine."Shortcut Dimension 1 Code":=NewDimValue;
                2: GenJnlLine."Shortcut Dimension 2 Code":=NewDimValue;
                end;
                GenJnlLine.Modify(true);
            end;
        end;
        DATABASE::"Item Journal Line": begin
            if ItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.")then begin
                case GlobalDimCodeNo of 1: begin
                    ItemJnlLine."Shortcut Dimension 1 Code":=NewDimValue;
                    ItemJnlLine."New Shortcut Dimension 1 Code":=NewNewDimValue;
                end;
                2: begin
                    ItemJnlLine."Shortcut Dimension 2 Code":=NewDimValue;
                    ItemJnlLine."New Shortcut Dimension 2 Code":=NewNewDimValue;
                end;
                end;
                ItemJnlLine.Modify(true);
            end;
        end;
        /*----------------denno DATABASE::"BOM Journal Line":
                   BEGIN
                     IF BOMJnlLine.GET("Journal Template Name","Journal Batch Name","Journal Line No.") THEN BEGIN
                       CASE GlobalDimCodeNo OF
                         1:
                           BOMJnlLine."Shortcut Dimension 1 Code" := NewDimValue;
                         2:
                           BOMJnlLine."Shortcut Dimension 2 Code" := NewDimValue;
                       end;
                       BOMJnlLine.MODIFY(TRUE);
                     end;
                   end;
                   ----------------*/
        DATABASE::"Res. Journal Line": begin
            if ResJnlLine.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.")then begin
                case GlobalDimCodeNo of 1: ResJnlLine."Shortcut Dimension 1 Code":=NewDimValue;
                2: ResJnlLine."Shortcut Dimension 2 Code":=NewDimValue;
                end;
                ResJnlLine.Modify(true);
            end;
        end;
        DATABASE::"Gen. Jnl. Allocation": begin
            if GenJnlAlloc.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.", "Allocation Line No.")then begin
                case GlobalDimCodeNo of 1: GenJnlAlloc."Shortcut Dimension 1 Code":=NewDimValue;
                2: GenJnlAlloc."Shortcut Dimension 2 Code":=NewDimValue;
                end;
                GenJnlAlloc.Modify(true);
            end;
        end;
        DATABASE::"Requisition Line": begin
            if ReqLine.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.")then begin
                case GlobalDimCodeNo of 1: ReqLine."Shortcut Dimension 1 Code":=NewDimValue;
                2: ReqLine."Shortcut Dimension 2 Code":=NewDimValue;
                end;
                ReqLine.Modify(true);
            end;
        end;
        DATABASE::"FA Journal Line": begin
            if FAJnlLine.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.")then begin
                case GlobalDimCodeNo of 1: FAJnlLine."Shortcut Dimension 1 Code":=NewDimValue;
                2: FAJnlLine."Shortcut Dimension 2 Code":=NewDimValue;
                end;
                FAJnlLine.Modify(true);
            end;
        end;
        DATABASE::"Insurance Journal Line": begin
            if InsuranceJnlLine.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.")then begin
                case GlobalDimCodeNo of 1: InsuranceJnlLine."Shortcut Dimension 1 Code":=NewDimValue;
                2: InsuranceJnlLine."Shortcut Dimension 2 Code":=NewDimValue;
                end;
                InsuranceJnlLine.Modify(true);
            end;
        end;
        DATABASE::"Planning Component": begin
            if PlanningComponent.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.", "Allocation Line No.")then begin
                case GlobalDimCodeNo of 1: PlanningComponent."Shortcut Dimension 1 Code":=NewDimValue;
                2: PlanningComponent."Shortcut Dimension 2 Code":=NewDimValue;
                end;
                PlanningComponent.Modify(true);
            end;
        end;
        DATABASE::"Standard General Journal Line": begin
            if StdGenJnlLine.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.")then begin
                case GlobalDimCodeNo of 1: StdGenJnlLine."Shortcut Dimension 1 Code":=NewDimValue;
                2: StdGenJnlLine."Shortcut Dimension 2 Code":=NewDimValue;
                end;
                StdGenJnlLine.Modify(true);
            end;
        end;
        DATABASE::"Standard Item Journal Line": begin
            if StdItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Journal Line No.")then begin
                case GlobalDimCodeNo of 1: StdItemJnlLine."Shortcut Dimension 1 Code":=NewDimValue;
                2: StdItemJnlLine."Shortcut Dimension 2 Code":=NewDimValue;
                end;
                StdItemJnlLine.Modify(true);
            end;
        end;
        end;
    end;
}
