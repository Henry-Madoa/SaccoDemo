table 52203775 "Job Requisition"
{
    DrillDownPageID = "Job Requisitions";
    LookupPageID = "Job Requisitions";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            NotBlank = false;
        }
        field(2; "Job ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
            TableRelation = "Company Jobs" where(Status=const(Approved));

            trigger OnValidate()
            begin
                /*Jobs.RESET;
                Jobs.SETRANGE(Jobs."Job ID","Job ID");*/
                if Jobs.Get("Job ID")then Description:=Jobs.Name;
                IF Jobs.GET("Job ID")THEN BEGIN
                    Jobs.TESTFIELD(Objective);
                    Jobs.TESTFIELD(Profession);
                    Jobs.TestField("No of Posts");
                    Description:=Jobs.Name;
                    Objective:=Jobs.Objective;
                    Positions:=Jobs."No of Posts";
                    Profession:=Jobs.Profession;
                END;
            end;
        }
        field(3; Date; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; Priority; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'High,Medium,Low';
            OptionMembers = High, Medium, Low;
        }
        field(5; Positions; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; Approved; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Date Approved":=Today;
            end;
        }
        field(7; "Date Approved"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Description; Text[200])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; Profession; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Professions;
            Editable = false;
        }
        field(10; "Expected Reporting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; Shortlisted; Boolean)
        {
        }
        field(12; "Turn Around Time"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(13; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(14; "No. Series"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(15; "Reason for Recruitment"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ", "New Position", "Existing Position";
        }
        field(16; "Appointment Type"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employment Contract";
        }
        field(17; "Requested By"; Code[40])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(19; Status;Enum "Document Status")
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(20; Objective; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(21; "Advertisement Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ", Internal, External, Both;
        }
        field(22; "Advertisement Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Validate("Advertisement Period");
            end;
        }
        field(23; "Advertisement Close Date"; Date)
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(24; "Advertisement Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ", Open, Closed;
            Editable = false;
        }
        field(25; "Advertisement Period"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Advertisement Date");
                "Advertisement Close Date":=CalcDate("Advertisement Period", "Advertisement Date");
            end;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Job ID", Description)
        {
        }
        fieldgroup(Brick; "No.", "Job ID", Description)
        {
        }
    }
    trigger OnDelete()
    begin
        TestField(Rec.Status, Rec.Status::Open);
    end;
    trigger OnInsert()
    begin
        if "No." = '' then begin
            HumanResSetup.Get;
            HumanResSetup.TestField(HumanResSetup."Job Requisition Nos");
            NoSeriesMgt.InitSeries(HumanResSetup."Job Requisition Nos", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        Date:=Today;
        "Requested By":=UserId;
    end;
    var Jobs: Record "Company Jobs";
    DimMgt: Codeunit DimensionManagement;
    HumanResSetup: Record "Human Resources Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        //DimMgt.SaveDefaultDim(DATABASE::"Recruitment Needs","No.",FieldNumber,ShortcutDimCode);
        Modify;
    end;
}
