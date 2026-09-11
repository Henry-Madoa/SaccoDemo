table 52204130 "Money Laundary Check"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; Date; Date)
        {
            Editable = false;
        }
        field(3; "Created By"; Code[50])
        {
        }
        field(4; "Member No."; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                if Member.Get("Member No.") then begin
                    Member.CalcFields("Uncleared Funds");
                    "Member Name" := Member.FullName;
                    "Uncleared Balance" := Member."Uncleared Funds";
                    Vendor.Reset();
                    Vendor.SetRange("Member No.", "Member No.");
                    Vendor.SetRange(Blocked, Vendor.Blocked::" ");
                    Vendor.SetRange("Product Posting Type", Vendor."Product Posting Type"::"Withdrawable Deposit");
                    if Vendor.FindFirst then begin
                        Vendor.CalcFields(Balance);
                        "Account No." := Vendor."No.";
                        "Account Name" := Vendor.Name;
                        "Account Balance" := Vendor.Balance;
                    end;
                end;
            end;
        }
        field(5; "Member Name"; Text[100])
        {
            Editable = false;
        }
        field(6; "Account No."; Code[20])
        {
            TableRelation = Vendor where("Member No." = field("Member No."), "Product Posting Type" = const("Withdrawable Deposit"), Status = const(Active), Blocked = const(" "));
            Editable = false;
        }
        field(7; "Account Name"; Text[100])
        {
            Editable = false;
        }
        field(8; "Account Balance"; Decimal)
        {
            Editable = false;
        }
        field(9; "Uncleared Balance"; Decimal)
        {
            Editable = false;
        }
        field(10; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(11; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(12; "Reference No."; Code[20])
        {
            trigger OnLookup()
            var
                UnnclearedEffect: Record "Uncleared Funds";
            begin
                UnnclearedEffect.Reset;
                UnnclearedEffect.SetRange(Cleared, false);
                UnnclearedEffect.SetRange("Money Laundary Check", true);
                UnnclearedEffect.SetRange("Member No", "Member No.");
                if Page.RunModal(PAGE::"Held Amounts", UnnclearedEffect) = Action::LookupOK then begin
                    Validate("Reference No.", UnnclearedEffect."Document No");
                    Validate("Applied Amount", UnnclearedEffect.Amount);
                    "Uncleared Funds Entry No." := UnnclearedEffect."Entry No";
                end;
            end;
        }
        field(13; "Applied Amount"; Decimal)
        {
            trigger OnValidate()
            begin
                if "Applied Amount" > "Uncleared Balance" then Error(StrSubstNo('You cannot apply an amount greater than %1 which is not cleared', "Uncleared Balance"));
            end;
        }
        field(14; Narration; Text[50])
        {
        }
        field(15; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(16; Cleared; Boolean)
        {
            Editable = false;
        }
        field(17; "Cleared By"; Code[50])
        {
            Editable = false;
        }
        field(18; "Cleared On"; DateTime)
        {
            Editable = false;
        }
        field(19; "Uncleared Funds Entry No."; Integer)
        {
            Editable = false;
        }
        field(20; "Source Of Income"; Text[250])
        {
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
        NoSeries: Codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";
        Member: Record Members;
        Vendor: Record Vendor;

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Money Laundary Nos.");
        "No." := NoSeries.GetNextNo(SaccoSetup."Money Laundary Nos.", Today, true);
        Date := WorkDate;
        "Created By" := UserId;
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;
}
