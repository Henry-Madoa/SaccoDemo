table 52204053 "ATM Application"
{
    DataClassification = ToBeClassified;
    LookupPageId = "ATM Applications";
    DrillDownPageId = "ATM Applications";

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; "Application Date"; Date)
        {
        }
        field(3; "Member No"; Code[100])
        {
            TableRelation = Members;

            trigger OnValidate()
            var
                Member: Record Members;
            begin
                if Member.Get("Member No") then begin
                    "Member Name" := Member."Full Name";
                    "Member ID" := Member."Identification No.";
                end;
            end;
        }
        field(4; "Member Name"; Text[150])
        {
            Editable = false;
        }
        field(5; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));
        }
        field(7; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = const(false));
        }
        field(6; "Created On"; Date)
        {
            Editable = false;
        }
        field(8; "Created By"; Code[100])
        {
            Editable = false;
        }
        field(9; "Last Updated On"; Date)
        {
            Editable = false;
        }
        field(10; "Last Updated By"; Code[100])
        {
            Editable = false;
        }
        field(11; "Application Type"; Option)
        {
            OptionMembers = New,Reactivation,Delinking;
        }
        field(12; "Account No."; Code[20])
        {
            TableRelation = Vendor Where("Member No." = field("Member No"));

            trigger OnValidate()
            var
                vendor: Record Vendor;
            begin
                vendor.Get("Account No.");
                vendor.CalcFields(Balance);
                "Account Name" := vendor.Name;
                "Current Balance" := vendor.Balance;
            end;
        }
        field(13; "Account Name"; Text[100])
        {
            Editable = false;
        }
        field(14; "ATM Type"; Code[20])
        {
            TableRelation = "ATM Types";

            trigger OnValidate()
            begin
                ATMTypes.Get("ATM Type");
                ATMTypes.TestField("Application Charge");
                "Transaction Code" := ATMTypes."Application Charge";
            end;
        }
        field(15; "ATM Type Name"; Text[50])
        {
            Editable = false;
        }
        field(16; "Card No."; Code[20])
        {
            trigger OnValidate()
            var
                ATMCards: Record "ATM Cards";
            begin
                if ATMCards.Get("ATM Type", "Card No.") then begin
                    Error('The Card Already Exists and is linked');
                end;
            end;
        }
        field(17; "Card Expiry Date"; Date)
        {
        }
        field(18; "Processed By"; Code[100])
        {
            editable = false;
        }
        field(19; "Processed On"; Date)
        {
            editable = false;
        }
        field(20; "Processed At"; Time)
        {
            editable = false;
        }
        field(21; "Processed"; Boolean)
        {
            editable = false;
        }
        field(22; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(23; Collected; Boolean)
        {
            Editable = false;
        }
        field(24; "ATM Collected By"; Text[100])
        {
        }
        field(25; "ATM Collected By ID No."; Code[50])
        {
        }
        field(26; "Current Balance"; Decimal)
        {
        }
        field(27; "Member ID"; Code[20])
        {
            Editable = false;
        }
        field(28; "Transaction Code"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(29; "Uncleared Effect No."; Integer)
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
    var
        SaccoSetup: Record "General Ledger Setup";
        NoSeries: Codeunit NoSeriesManagement;
        ATMTypes: Record "ATM Types";
        UserSetup: Record "User Setup";
        Employee: Record Employee;

    trigger OnInsert()
    begin
        SaccoSetup.get;
        SaccoSetup.TestField("ATM Application Nos");
        "No." := NoSeries.GetNextNo(SaccoSetup."ATM Application Nos", Today, true);
        "Application Date" := WorkDate;
        "Created By" := UserId;
        "Last Updated By" := UserId;
        "Created On" := WorkDate;
        "Last Updated On" := WorkDate;
        UserSetup.Get(UserId);
        Employee.Get(UserSetup."Employee No.");
        "Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
        "Global Dimension 2 Code" := Employee."Global Dimension 2 Code";
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Processed On", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;
}
