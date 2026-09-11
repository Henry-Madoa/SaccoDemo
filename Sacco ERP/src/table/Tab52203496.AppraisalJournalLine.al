table 52203496 "Appraisal Journal Line"
{
    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
        //TableRelation = Table39003926;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        //TableRelation = Table39003927.Field2 WHERE (Field1=FIELD("Journal Template Name"));
        }
        field(3; "Line No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Line No.';
        }
        field(4; "Appraisal Period"; Code[20])
        {
            Caption = 'Appraisal Period';

            trigger OnValidate()
            begin
            /*IF "Leave Application No." = '' THEN BEGIN
                      CreateDim(DATABASE::Table5628,"Leave Application No.");
                      EXIT;
                    end;

                    Insurance.GET("Leave Application No.");
                    //Insurance.TESTFIELD(Blocked,FALSE);
                    Description := Insurance.Description;
                    "Leave Approval Date":=Insurance."HOD Start Date";
                    "No. of Days":=Insurance."HOD Approved Days";
                    "Leave Type Code":=Insurance."Leave Code";
                    CreateDim(DATABASE::Table5628,"Leave Application No.");
                      */
            end;
        }
        field(6; "Staff No."; Code[20])
        {
            Caption = 'Staff No.';
            TableRelation = Employee;
        }
        field(7; "Staff Name"; Text[120])
        {
            Caption = 'Staff Name';
            Editable = false;
        }
        field(8; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(9; "Appraisal Entry Type"; Option)
        {
            Caption = 'Leave Entry Type';
            Editable = true;
            OptionCaption = 'target setting,Achievement';
            OptionMembers = "target setting", Achievement;
        }
        field(10; "Appraisal Approval Date"; Date)
        {
            Caption = 'Leave Approval Date';
            Editable = false;
        }
        field(11; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(12; "Appraisal Calendar"; Code[20])
        {
            Caption = 'External Document No.';
        }
        field(13; "Maximum Weight"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'No. of Days';
            Editable = true;

            trigger OnValidate()
            begin
            /*IF LeaveType.GET("Leave Type") THEN BEGIN
                    IF (LeaveType."Fixed Days"=TRUE) THEN BEGIN
                    IF "No. of Days">LeaveType.Days THEN
                    ERROR(Text001,"Leave Type");

                    end;
                    end;
                     */
            end;
        }
        field(14; "Score Card"; Text[50])
        {
            Caption = 'Description';
        }
        field(15; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));

            trigger OnValidate()
            begin
            /*ValidateShortcutDimCode(1,"Shortcut Dimension 1 Code");
                   Rec.Modify;
                    */
            end;
        }
        field(16; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));

            trigger OnValidate()
            begin
            /*ValidateShortcutDimCode(2,"Shortcut Dimension 2 Code");
                   Rec.Modify;*/
            end;
        }
        field(17; "KPI Code"; Code[50])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(18; "KPI Description"; Code[100])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(20; "Target Score"; Decimal)
        {
            Caption = 'Index Entry';
        }
        field(21; "Self Comments"; Code[250])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(22; "Supervisor Comments"; Option)
        {
            Editable = true;
            OptionCaption = ' ,Service Delivery,Financial Stewardship,Training and Development,Customer and Sales';
            OptionMembers = " ", "Service Delivery", "Financial Stewardship", "Training and Development", "Customer and Sales";

            trigger OnValidate()
            begin
            //   IF HRLeaveTypes.GET("Leave Type") THEN
            //  "No. of Days":=HRLeaveTypes.Days;
            end;
        }
        field(23; "Appraisal Period Start Date"; Date)
        {
            trigger OnValidate()
            begin
            //"Leave Period End Date":=CALCDATE('-1D',CALCDATE('12M',"Leave Period Start Date"));
            end;
        }
        field(24; "Appraisal Period End Date"; Date)
        {
        }
        field(25; "Appraisal No."; Code[20])
        {
            Caption = 'Leave Application No.';
        }
        field(26; "Self Score"; Decimal)
        {
        }
        field(27; "Supervisor Score"; Decimal)
        {
        }
        field(28; "Agreed Score"; Decimal)
        {
        }
        field(29; "Supervisor Final Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Justification of Score"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
        }
        key(Key2; "Journal Template Name", "Journal Batch Name", "Posting Date")
        {
            MaintainSQLIndex = false;
        }
    }
    trigger OnDelete()
    begin
    /*DimMgt.DeleteJnlLineDim(
              DATABASE::"HR Journal Line",
              "Journal Template Name","Journal Batch Name","Line No.",0);
                */
    end;
    trigger OnInsert()
    begin
    //JnlLineDim.LOCKTABLE;
    //LOCKTABLE;
    /*InsuranceJnlTempl.GET("Journal Template Name");
            "Source Code" := InsuranceJnlTempl."Source Code";
            InsuranceJnlBatch.GET("Journal Template Name","Journal Batch Name");
            "Reason Code" := InsuranceJnlBatch."Reason Code";

            ValidateShortcutDimCode(1,"Shortcut Dimension 1 Code");
            ValidateShortcutDimCode(2,"Shortcut Dimension 2 Code");
            DimMgt.InsertJnlLineDim(
              DATABASE::"HR Journal Line",
              "Journal Template Name","Journal Batch Name","Line No.",0,
              "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
              */
    end;
    var Insurance: Record "Individual Targets Header";
    InsuranceJnlLine: Record "Appraisal Journal Line";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    DimMgt: Codeunit DimensionManagement;
    Text001: Label 'You can not post more than maximum days allowed for this leave type %1';
    procedure SetUpNewLine()
    begin
    /*InsuranceJnlTempl.GET("Journal Template Name");
            InsuranceJnlBatch.GET("Journal Template Name","Journal Batch Name");
            InsuranceJnlLine.SETRANGE("Journal Template Name","Journal Template Name");
            InsuranceJnlLine.SETRANGE("Journal Batch Name","Journal Batch Name");
            IF InsuranceJnlLine.FIND('-') THEN BEGIN
              "Posting Date" := LastInsuranceJnlLine."Posting Date";
              "Document No." := LastInsuranceJnlLine."Document No.";
            END ELSE BEGIN
              "Posting Date" := WORKDATE;
              IF InsuranceJnlBatch."No. Series" <> '' THEN BEGIN
                CLEAR(NoSeriesMgt);
                "Document No." := NoSeriesMgt.TryGetNextNo(InsuranceJnlBatch."No. Series","Posting Date");
              end;
            end;
            "Source Code" := InsuranceJnlTempl."Source Code";
            "Reason Code" := InsuranceJnlBatch."Reason Code";
            "Posting No. Series" := InsuranceJnlBatch."Posting No. Series";
            */
    end;
    procedure CreateDim(Type1: Integer; No1: Code[20])
    var
        TableID: array[10]of Integer;
        No: array[10]of Code[20];
    begin
    /*TableID[1] := Type1;
            No[1] := No1;
            "Shortcut Dimension 1 Code" := '';
            "Shortcut Dimension 2 Code" := '';
            DimMgt.GetDefaultDim(
              TableID,No,"Source Code",
              "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
            IF "Line No." <> 0 THEN
              DimMgt.UpdateJnlLineDefaultDim(
                DATABASE::Table5635,
                "Journal Template Name","Journal Batch Name","Line No.",0,
                "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
              */
    end;
    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    /*DimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
            IF "Line No." <> 0 THEN BEGIN
              DimMgt.SaveJnlLineDim(
                DATABASE::Table5635,"Journal Template Name",
                "Journal Batch Name","Line No.",0,FieldNumber,ShortcutDimCode);
              IF MODIFY THEN;
            END ELSE
              DimMgt.SaveTempDim(FieldNumber,ShortcutDimCode);
             */
    end;
    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    /*DimMgt.LookupDimValueCode(FieldNumber,ShortcutDimCode);
            IF "Line No." <> 0 THEN BEGIN
              DimMgt.SaveJnlLineDim(
                DATABASE::Table5635,"Journal Template Name",
                "Journal Batch Name","Line No.",0,FieldNumber,ShortcutDimCode);
             Rec.Modify;
            END ELSE
              DimMgt.SaveTempDim(FieldNumber,ShortcutDimCode);
            */
    end;
    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8]of Code[20])
    begin
    /*IF "Line No." <> 0 THEN
              DimMgt.ShowJnlLineDim(
                DATABASE::Table5635,"Journal Template Name",
                "Journal Batch Name","Line No.",0,ShortcutDimCode)
            ELSE
              DimMgt.ShowTempDim(ShortcutDimCode);
            */
    end;
    procedure ValidateOpenPeriod()
    begin
    /*WITH LeavePeriod DO
            BEGIN
             Rec1.RESET;
            IF Rec1.FIND('-')THEN BEGIN
            "Leave Period Start Date":=Rec1."Starting Date";
            VALIDATE("Leave Period Start Date");    `
            end;
            end;*/
    end;
}
