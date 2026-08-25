table 52204026 "Collateral Application"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Collateral Applications";
    DrillDownPageId = "Collateral Applications";

    fields
    {
        field(1; "No."; code[20])
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(2; "Member No"; Code[20])
        {
            TableRelation = Members;

            trigger onValidate()
            var
                Members: Record Members;
            begin
                if members.Get("Member No") then begin
                    "Member Name" := members."Full Name";
                    "National ID No" := Members."Identification No.";
                    "KRA PIN No." := Members."KRA PIN";
                end;
            end;
        }
        field(3; "Member Name"; Text[150])
        {
            Editable = false;
        }
        field(4; Category; Option)
        {
            OptionMembers = " ",Vehicle,"Real Estate";
        }
        field(5; "Collateral Type"; Code[20])
        {
            TableRelation = "Collateral Types" where(Category = field(Category));

            trigger OnValidate()
            var
                CollateralType: Record "Collateral Types";
            begin
                if CollateralType.Get("Collateral Type") then begin
                    Multiplier := CollateralType."Value Multiplier";
                    "Collateral Description" := CollateralType.Description;
                end;
            end;
        }
        field(6; "Collateral Description"; Text[150])
        {
            Editable = false;
        }
        field(7; Multiplier; Decimal)
        {
            Editable = false;
        }
        field(8; "Collateral Value"; Decimal)
        {
            trigger OnValidate()
            begin
                Guarantee := "Collateral Value" * Multiplier * 0.01;
            end;
        }
        field(9; Guarantee; Decimal)
        {
            Editable = false;
        }
        field(10; "Last Valuation Date"; Date)
        {
        }
        field(11; "Joint Ownership"; boolean)
        {
        }
        field(12; "National ID No"; Code[20])
        {
            Editable = false;
        }
        field(13; "KRA PIN No."; code[20])
        {
            Editable = false;

            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                MemberMgmt.KRAPinValidation("KRA PIN No.");
            end;
        }
        field(14; "Processed On"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(15; "Created By"; Code[50])
        {
            TableRelation = "User Setup";
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(16; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(17; Posted; Boolean)
        {
        }
        field(18; "Re-Opened"; Boolean)
        {
        }
        field(19; "Collateral Image"; Blob)
        {
            Subtype = Bitmap;
        }
        field(20; "Serial/Reg No."; code[100])
        {
            trigger OnValidate()
            var
                CollateralRegister: Record "Collateral Register";
            begin
                if not "Multi-Linking" then begin
                    CollateralRegister.Reset();
                    CollateralRegister.SetRange("Serial/Reg No.", "Serial/Reg No.");
                    if CollateralRegister.FindSet() then begin
                        if CollateralRegister.Status <> CollateralRegister.Status::"Linked to Loan" then Error('Collatral Is already Received in the system under Document No %1 for Member %2', CollateralRegister."No.", CollateralRegister."Member Name");
                    end;
                end;
            end;
        }
        field(21; Date; Date)
        {
            Editable = false;
        }
        field(22; "Owner Name"; Code[150])
        {
        }
        field(23; "Owner Phone No."; Code[50])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Mobile Phone No." where("No." = field("Member No")));
        }
        field(24; "Owner ID No"; Code[20])
        {
        }
        field(25; "Multi-Linking"; Boolean)
        {
        }
        field(26; "Collateral Image 1"; Blob)
        {
            Subtype = Bitmap;
        }
        field(27; "Collateral Image 2"; Blob)
        {
            Subtype = Bitmap;
        }
        field(28; "Collateral Image 3"; Blob)
        {
            Subtype = Bitmap;
        }
        field(29; "Collateral Image 4"; Blob)
        {
            Subtype = Bitmap;
        }
        field(30; "Cheque No."; Code[30])
        {
        }
        field(31; "Insurance Expiry Date"; Date)
        {
        }
        field(32; "Linking Date"; Date)
        {
        }
        field(33; "Car Track Due Date"; Date)
        {
        }
        field(34; County; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Counties;
        }
        field(35; "County Name"; Text[50])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Counties.Name where("County Code" = field(County)));
        }


    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
    var
        NoSeries: codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Collateral Application Nos.");
        "No." := NoSeries.GetNextNo(SaccoSetup."Collateral Application Nos.", Today, true);
        Date := WorkDate;
        "Created By" := UserId;
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;

    trigger OnRename()
    begin
        TestField(Status, Status::Open);
    end;

    procedure OnBeforeSendForApproval()
    begin
        TestField(Date);
        TestField("Serial/Reg No.");
        TestField("Collateral Type");
        TestField("Collateral Value");
        TestField(Guarantee);
    end;
}
