table 52204192 Lien
{
    DataClassification = ToBeClassified;
    LookupPageId = Liens;
    DrillDownPageId = Liens;

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(2; "Member No."; Code[20])
        {
            TableRelation = Members;
        }
        field(3; "Member Name"; Text[250])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Full Name" where("No." = field("Member No.")));
        }
        field(4; "Account No"; Code[20])
        {
            trigger OnValidate()
            var
                MemberMgt: Codeunit "Member Management";
            begin
                Vendor.get("Account No");
                Vendor.CalcFields(Balance, "Uncleared Funds");
                "Account Name" := Vendor.Name;
            end;

            trigger OnLookup()
            var
                Vendor: Record Vendor;
            begin
                Vendor.Reset();
                Vendor.SetRange("Member No.", "Member No.");
                Vendor.SetRange("Cash Transfer Allowed", true);
                Vendor.SetFilter("Product Posting Type", '%1|%2|%3|%4|%5', Vendor."Product Posting Type"::"Withdrawable Deposit", Vendor."Product Posting Type"::"Investments Account", Vendor."Product Posting Type"::"Holiday Account", Vendor."Product Posting Type"::"School Fee Account", Vendor."Product Posting Type"::"Junior Account");
                Vendor.SetRange(Blocked, Vendor.Blocked::" ");
                if Page.RunModal(0, Vendor) = Action::LookupOK then begin
                    Validate("Account No", Vendor."No.");
                end;
            end;
        }
        field(5; "Account Name"; Text[100])
        {
            Editable = false;
        }
        field(6; Amount; Decimal)
        {
            trigger OnValidate()
            var
                MemberMgt: Codeunit "Member Management";
                BookBalance, Uncleared, ActualBalance : Decimal;
            begin
                MemberMgt.GetAccountBalance("Account No", "Posting Date", BookBalance, Uncleared, ActualBalance);
                if "Transaction Type" = "Transaction Type"::Holding then begin
                    if Amount > ActualBalance then begin
                        Error('You Can Only Lien upto %1', ActualBalance);
                    end;
                end;
                if "Transaction Type" = "Transaction Type"::Unholding then begin
                    if Amount > Uncleared then begin
                        Error('You Can Only Unlien upto %1', Uncleared);
                    end;
                end;
            end;
        }
        field(7; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(8; "Created By"; Code[100])
        {
            TableRelation = "User Setup";
            Editable = false;
        }
        field(9; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(10; Processed; Boolean)
        {
            Editable = false;
        }
        field(11; "Processed By"; Code[100])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(12; "Processed On"; DateTime)
        {
            Editable = false;
        }
        field(13; "Posting Date"; Date)
        {
        }
        field(14; "Transaction Type"; Option)
        {
            OptionMembers = " ",Holding,Unholding;
        }
        field(15; Narration; Text[500])
        {
        }
        field(16; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(17; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(key2; "Member No.", "Account No", "Posting Date")
        {
        }
    }
    fieldgroups
    {
        // Add changes to field groups here
    }
    var
        NoSeries: Codeunit "No. Series";
        SaccoSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
        UserSetup: Record "User Setup";
        Employee: Record Employee;

    trigger OnInsert()
    begin
        SaccoSetup.get;
        SaccoSetup.TestField("Lien Nos.");
        "No." := NoSeries.GetNextNo(SaccoSetup."Lien Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        UserSetup.get(UserId);
        Employee.Get(UserSetup."Employee No.");
        "Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
        "Global Dimension 2 Code" := Employee."Global Dimension 2 Code"
    end;

    procedure OnBeforeSendApproval()
    begin
        TestField(Narration);
    end;
}
