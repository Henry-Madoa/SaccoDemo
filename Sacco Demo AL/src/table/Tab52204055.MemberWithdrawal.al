table 52204055 "Member Withdrawal"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Document Type"; Option)
        {
            OptionMembers = Withdrawal,Refund;
            Editable = false;
        }
        field(3; "Member No"; Code[20])
        {
            tableRelation = Members;

            trigger OnValidate()
            var
                Member: Record Members;
            begin
                if Member.Get("Member No") then "Member Name" := Member."Full Name";
            end;
        }
        field(4; "Member Name"; Text[150])
        {
            Editable = false;
        }
        field(5; "Withdrawal Type"; Option)
        {
            OptionMembers = General,Retiree,Desceased;
        }
        field(6; "Balance Option"; Option)
        {
            OptionMembers = "FOSA Withdrawal","Bank Transfer";
        }
        field(7; Instant; Boolean)
        {
        }
        field(8; "Holding Account"; Code[20])
        {
            Editable = false;
            TableRelation = Vendor Where("Account Type" = CONST("Supplier"));
        }
        field(9; "Total Assets"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Member Withdrawal Lines"."Amount (Base)" where("No." = field("No."), "Entry Type" = const(Asset), "Share Capital" = const(false)));
            Editable = false;
        }
        field(10; Guarantees; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Member Withdrawal Lines"."Amount (Base)" where("No." = field("No."), "Entry Type" = const(Guarantee)));
            Editable = false;
        }
        field(11; Liabilities; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Member Withdrawal Lines"."Amount (Base)" where("No." = field("No."), "Entry Type" = const(Liability)));
            Editable = false;
        }
        field(12; "Charge Code"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(13; Date; Date)
        {
            trigger OnValidate()
            begin
                "Maturity Date" := CalcDate(SaccoSetup."Withdrawal Period", WorkDate);
            end;
        }
        field(14; "Maturity Date"; Date)
        {
            Editable = false;
        }
        field(15; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(16; Posted; Boolean)
        {
            Editable = false;
        }
        field(17; "Posted By"; Code[50])
        {
            Editable = false;
        }
        field(18; "Posted On"; Date)
        {
            Editable = false;
        }
        field(19; "Withdrawal Reason"; Text[100])
        {
        }
        field(20; "Net Amount"; Decimal)
        {
            Editable = false;
        }
        field(21; "Requested Amount"; Decimal)
        {
            trigger OnValidate()
            var
                Member: Record Members;
                SaccoProducts: Record "Sacco Products";
            begin
                If "Requested Amount" > "Net Amount" then Error('You cannot request more than Available Balance');
                SaccoProducts.Reset();
                SaccoProducts.SetRange("Product Posting Type", SaccoProducts."Product Posting Type"::"Non Withdrawable Deposit");
                If SaccoProducts.FindFirst then;
                Member.Get("Member No");
                Member.CalcFields("Total Deposits");
                If "Requested Amount" > (Member."Total Deposits" - SaccoProducts."Minimum Balance") then Error('You cannot Request more than the Total Deposits');
            end;
        }
        field(22; "Accrued Interest"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Member Withdrawal Lines"."Accrued Interest" where("No." = field("No."), "Entry Type" = const(Liability)));
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
        Noseries: Codeunit NoSeriesManagement;

    trigger OnInsert()
    begin
        SaccoSetup.Get;
        SaccoSetup.TestField("Withdrawal Period");
        if "Document Type" = "Document Type"::Withdrawal then begin
            SaccoSetup.TestField("Member Exit Nos");
            "No." := NoSeries.GetNextNo(SaccoSetup."Member Exit Nos", Today, true);
        end;
        if "Document Type" = "Document Type"::Refund then begin
            SaccoSetup.TestField("Member Refund Nos");
            "No." := NoSeries.GetNextNo(SaccoSetup."Member Refund Nos", Today, true);
        end;
        Date := WorkDate;
        "Maturity Date" := CalcDate(SaccoSetup."Withdrawal Period", WorkDate);
    end;

    trigger OnDelete()
    begin
        Testfield(Status, Status::Open);
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc(Date, "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;

    procedure OnBeforeSendForApproval()
    begin
        if "Document Type" = "Document Type"::Refund then TestField("Requested Amount");
        TestField("Withdrawal Reason");
        CalcFields(Guarantees, "Total Assets", Liabilities);
        if "Document Type" = "Document Type"::Withdrawal then begin
            if Guarantees <> 0 then Error('Please substitute the guarantors before processing member withdrawal');
        end;
        if "Document Type" = "Document Type"::Refund then begin
            if (Guarantees > ("Net Amount" - "Requested Amount")) then Error('Please substitute the guarantors before processing member withdrawal');
        end;
        if ((("Total Assets" + Liabilities) < 0) AND ("Withdrawal Type" <> "Withdrawal Type"::Desceased)) then Error('The Liabilities are higher than the assets. The member withdrawal cannot be processed');
    end;
}
