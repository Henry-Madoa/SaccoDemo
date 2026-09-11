table 52204193 "Benevolent Fund"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Benevolent Funds";
    LookupPageId = "Benevolent Funds";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No."; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                SaccoSetup.get;
                "Fosa Account" := MemberMgt.GetMemberAccount("Member No.", ProductPostingType::"Withdrawable Deposit");
                if "Payment Type" = "Payment Type"::"Principal Member" then begin
                    ExpHdr.Reset();
                    ExpHdr.SetRange("Member No.", "Member No.");
                    ExpHdr.SetRange("Payment Type", ExpHdr."Payment Type"::"Principal Member");
                    if ExpHdr.FindFirst() then Error('The Principal Member has already been paid');
                end;
                SaccoSetup.Get();
                if "Payment Type" = "Payment Type"::Nominee then
                    "Payment Amount" := SaccoSetup."NOK Amount"
                else
                    "Payment Amount" := SaccoSetup."Principal Member Amount";
            end;
        }
        field(3; "Full Name"; Text[250])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Full Name" where("No." = field("Member No.")));
        }
        field(4; "Fosa Account"; Code[20])
        {
            Editable = false;
        }
        field(5; "Available Balance"; Decimal)
        {
            Editable = false;
        }
        field(6; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(7; "Created By"; Code[100])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(8; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(9; "Processed On"; DateTime)
        {
            Editable = false;
        }
        field(10; Processed; Boolean)
        {
            Editable = false;
        }
        field(11; "Posting Date"; Date)
        {
        }
        field(12; "Posting Description"; Text[50])
        {
        }
        field(13; "Paying Account Type"; Option)
        {
            OptionMembers = Payable,"Bank Account","G/L Account";
        }
        field(14; "Paying Account No"; Code[20])
        {
            TableRelation = if ("Paying Account Type" = const("Bank Account")) "Bank Account" where(Blocked = const(false))
            else if ("Paying Account Type" = const(Payable)) Vendor where("Member No." = const(''))
            else
            "G/L Account"."No." where("Direct Posting" = const(true));
        }
        field(15; "Payment Type"; Option)
        {
            OptionMembers = "Principal Member",Nominee;

            trigger OnValidate()
            var
                SaccoSetup: Record "General Ledger Setup";
            begin
                Validate("Member No.");
                "Posting Description" := 'Payment for ' + Format("Payment Type");
                SaccoSetup.Get();
                if "Payment Type" = "Payment Type"::Nominee then
                    "Payment Amount" := SaccoSetup."NOK Amount"
                else
                    "Payment Amount" := SaccoSetup."Principal Member Amount";
            end;
        }
        field(16; "Payment Amount"; Decimal)
        {
            trigger OnValidate()
            begin
                SaccoSetup.Get();
                if "Payment Type" = "Payment Type"::Nominee then begin
                    if "Payment Amount" > SaccoSetup."NOK Amount" then Error('You Cannot Exceed %1', SaccoSetup."NOK Amount");
                end
                else begin
                    if "Payment Amount" > SaccoSetup."Principal Member Amount" then Error('You Cannot Exceed %1', SaccoSetup."Principal Member Amount");
                end;
            end;
        }
        field(17; "KIN"; Text[200])
        {
            Editable = false;
        }
        field(18; "KIN Identication No."; Code[20])
        {
            TableRelation = "Member Nominee/Kin"."Identification No." where("Document Type" = const(Nominee), "Source Code" = field("Member No."));

            trigger OnValidate()
            begin
                if "Payment Type" = "Payment Type"::Nominee then begin
                    ExpHdr.Reset();
                    ExpHdr.SetRange("Member No.", "Member No.");
                    ExpHdr.SetRange("Payment Type", ExpHdr."Payment Type"::Nominee);
                    ExpHdr.SetRange("KIN Identication No.", "KIN Identication No.");
                    if ExpHdr.FindFirst() then Error('The Next of Kin has already been paid');
                end;
                FamilyTree.Reset();
                FamilyTree.SetRange("Source Code", "Member No.");
                FamilyTree.SetRange("Identification No.", "KIN Identication No.");
                if FamilyTree.FindFirst then begin
                    "Kin Relationship" := FamilyTree."Relative Code";
                    "Kin DOB" := FamilyTree."Date of Birth";
                    "KIN Name" := FamilyTree.Name;
                end;
            end;
        }
        field(19; "KIN Relationship"; Code[10])
        {
            TableRelation = Relative;
            Editable = false;
        }
        field(20; "KIN DOB"; Date)
        {
            Editable = false;
        }
        field(21; "KIN Name"; Text[80])
        {
            Editable = false;
        }
        field(22; "Pay Mode"; Code[20])
        {
            TableRelation = "Payment Method";

            trigger OnValidate()
            var
                PaymentMethod: Record "Payment Method";
            begin
                if PaymentMethod.Get(Rec."Pay Mode") then begin
                    "Payment Methods Types" := PaymentMethod.Type;
                    if PaymentMethod.Type = PaymentMethod.Type::Cheque then begin
                        if "Cheque Date" = 0D then "Cheque Date" := WorkDate;
                    end;
                    if PaymentMethod.Type = PaymentMethod.Type::FOSA then Error('FOSA Payment For Vendor Payment is still under review');
                end;
            end;
        }
        field(23; "Payment Methods Types"; Enum "Payment Methods Types")
        {
            Editable = false;
        }
        field(24; "Cheque Number"; Code[20])
        {
            trigger OnValidate()
            var
                BenevolentFund: Record "Benevolent Fund";
            begin
                if "Cheque Number" <> '' then begin
                    BenevolentFund.Reset;
                    BenevolentFund.SetRange(BenevolentFund."Cheque Number", "Cheque Number");
                    if BenevolentFund.Find('-') then begin
                        if BenevolentFund."No." <> "No." then Error('Cheque No. already exists');
                    end;
                end;
            end;
        }
        field(25; "Cheque Date"; Date)
        {
        }
        field(26; "Cheque Received By"; Text[250])
        {
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Member No.")
        {
        }
    }
    var
        NoSeries: Codeunit "No. Series";
        SaccoSetup: Record "General Ledger Setup";
        FamilyTree: Record "Member Nominee/Kin";
        ExpHdr: Record "Benevolent Fund";
        MemberMgt: Codeunit "Member Management";
        ProductPostingType: Enum "Product Posting Type";

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        if "No." = '' then "No." := NoSeries.GetNextNo(SaccoSetup."Benevolent Fund Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        "Paying Account Type" := "Paying Account Type"::Payable;
        "Posting Date" := Today;
        "Posting Description" := 'Payment for ' + Format("Payment Type");
    end;

    trigger OnModify()
    begin
        Rec.TestField(Processed, false);
    end;

    trigger OnDelete()
    begin
        Rec.TestField(Processed, false);
    end;

    procedure OnBeforeSendForApproval()
    begin
        TestField("Payment Amount");
        TestField("Member No.");
        TestField("Posting Description");
    end;
}
