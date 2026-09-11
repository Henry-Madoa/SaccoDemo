table 52204197 "Custodial Header"
{
    DrillDownPageID = "Custodial Applications";
    LookupPageID = "Custodial Applications";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Service Type"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Custodia Service Types";

            trigger OnValidate()
            begin
                if CustodiaServiceTypes.Get("Service Type") then begin
                    "Service Description" := CustodiaServiceTypes."Service Description";
                    "Grace Period" := CustodiaServiceTypes."Grace Period";
                end;
            end;
        }
        field(3; "Refrence No."; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Owner Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Investment Member,Customer';
            OptionMembers = "Investment Member",Customer;
        }
        field(6; "Owner No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members."No." WHERE(Category = FIELD("Member Category"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if "Owner Type" = "Owner Type"::Customer then begin
                    if Customer.Get("Owner No") then "Owner Name" := Customer.Name;
                end
                else begin
                    if Members.Get("Owner No") then begin
                        "Owner Name" := Members."Full Name";
                    end;
                end;
            end;
        }
        field(8; "Owner Name"; Text[150])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; Remarks; Text[2000])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Format("Grace Period") <> '' then begin
                    "Payment Start Date" := CalcDate("Grace Period", "Posting Date");
                end;
            end;
        }
        field(11; "Created By"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup";
        }
        field(12; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(17; "Document Status"; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionMembers = New,Instore,Released,"In-Transit";
        }
        field(18; "Service Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(19; "Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Storage Period"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Posting Date");
                "Expected Collection Date" := CalcDate("Storage Period", "Posting Date");
            end;
        }
        field(21; "Expected Collection Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(22; "Source Account No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF ("Source Type" = CONST("Bank Account")) "Bank Account"."No."
            ELSE IF ("Source Type" = CONST("Member Account")) Vendor."No." WHERE("Member No." = FIELD("Owner No"), "Product Posting Type" = const("Withdrawable Deposit"));
        }
        field(23; "Amount Expected"; Decimal)
        {
            CalcFormula = Sum("Custodial Services Entries".Amount WHERE("Custodial No." = FIELD("No."), Posted = CONST(true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(24; "Amount Paid"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Payment Method"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payment Method".Code;
        }
        field(26; "Payment Refrence"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Payment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Payment Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(29; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                //ValidateShortcutDimCode(1,"Global Dimension 1 Code");
            end;
        }
        field(30; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                //ValidateShortcutDimCode(2,"Global Dimension 2 Code");
            end;
        }
        field(31; "Approval Entries"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Document No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(32; "Storage Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Safe,Safety Deposit Box';
            OptionMembers = Safe,"Safety Deposit Box";
        }
        field(33; "Storage Serial No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Deposit Box Lines"."Serial No." WHERE(Type = FIELD("Storage Type"));
        }
        field(34; "Collected By"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Expected Return Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Collected By Phone No"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(37; "Collected By ID  No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(38; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Check-In","Check-Out",Viewing;
        }
        field(39; "Member Category"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Member Categories";
        }
        field(40; "Grace Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(41; "Payment Start Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(46; Status; Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52; "Source Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Bank Account,Member Account';
            OptionMembers = "Bank Account","Member Account";
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    begin
        TestField("Document Status", "Document Status"::New);
        TestField(Status, Status::Open);
    end;

    trigger OnInsert()
    begin
        GeneralSetup.Get;
        if "No." = '' then begin
            GeneralSetup.TestField("Custodial Nos.");
            "No." := NoSeriesManagement.GetNextNo(GeneralSetup."Custodial Nos.", Today, true);
        end;
        "Created By" := UserId;
        "Created On" := WorkDate;
    end;

    var
        CustodiaServiceTypes: Record "Custodia Service Types";
        Customer: Record Customer;
        Members: Record Members;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        GeneralSetup: Record "General Ledger Setup";
        FixedAsset: Record "Fixed Asset";
        CompanyInfo: Record "Company Information";

    procedure OnBeforeSendForApproval()
    begin
    end;
}
