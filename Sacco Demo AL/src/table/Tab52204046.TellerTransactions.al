table 52204046 "Teller Transactions"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Transaction Type"; Option)
        {
            OptionMembers = "Cash Deposit","Cash Withdrawal";

            trigger OnValidate()
            begin
                SaccoSetup.Get();
                if "Transaction Type" = "Transaction Type"::"Cash Deposit" then
                    "Charge Code" := SaccoSetup."Cash Deposit Charges"
                else
                    "Charge Code" := SaccoSetup."Cash Withdrawal Charges";
            end;
        }
        field(3; Description; Text[250])
        {
            Caption = 'Source Of Funds';
        }
        field(4; "Member No."; Code[20])
        {
            TableRelation = if ("Transaction Type" = const("Cash Withdrawal")) Members where(Status = filter(Active | Dormant | Withdrawn))
            else if ("Transaction Type" = const("Cash Deposit")) Members where(Status = filter(Active | Dormant));

            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
                ProductPostingType: Enum "Product Posting Type";
            begin
                if Member.Get("Member No.") then begin
                    "Member Name" := Member."Full Name";
                    If Member.Status = Member.Status::Dormant then
                        Dormant := true
                    else
                        Dormant := false;
                    Validate("Account No", MemberMgmt.GetMemberAccount("Member No.", ProductPostingType::"Withdrawable Deposit"));
                    if "Transaction Type" = "Transaction Type"::"Cash Withdrawal" then begin
                        "Transacted By ID No" := Member."Identification No.";
                        "Transacted By Name" := Member.FullName;
                    end;
                    if Amount <> 0 then Validate(Amount);
                end;
            end;
        }
        field(5; "Member Name"; Text[100])
        {
            Editable = false;
        }
        field(6; "Account No"; Code[20])
        {
            trigger OnValidate()
            var
                SaccoProduct: Record "Sacco Products";
                ChannelsIntegrations: Codeunit "Channels Integrations";
            begin
                Vendor.Get("Account No");
                Vendor.CalcFields(Balance, "Uncleared Funds");
                SaccoProduct.Get(Vendor."Product Code");
                "Account Name" := Vendor.Name;
                "Available Balance" := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor."Member No.");

                if "Available Balance" < 0 then "Available Balance" := 0;

                "Book Balance" := "Available Balance" + Vendor."Uncleared Funds";

                if "Book Balance" < 0 then
                    "Book Balance" := 0;
            end;

            trigger OnLookup()
            var
                Vendor: Record Vendor;
            begin
                Vendor.Reset();
                Vendor.SetRange("Member No.", "Member No.");
                Vendor.SetFilter("Product Posting Type", '%1|%2|%3|%4|%5', Vendor."Product Posting Type"::"Withdrawable Deposit", Vendor."Product Posting Type"::"Investments Account", Vendor."Product Posting Type"::"Holiday Account", Vendor."Product Posting Type"::"School Fee Account", Vendor."Product Posting Type"::"Junior Account");
                Vendor.SetRange(Blocked, Vendor.Blocked::" ");
                if Page.RunModal(0, Vendor) = Action::LookupOK then begin
                    Validate("Account No", Vendor."No.");
                end;
            end;
        }
        field(7; "Account Name"; Text[150])
        {
            Editable = false;
        }
        field(8; Amount; Decimal)
        {
            MinValue = 0;
            MaxValue = 1000000;

            trigger OnValidate()
            var
                ObLnMgt: Codeunit "Loans Management";
                SaccoJnl: Codeunit "Journal Management";
            begin
                if "Charge Code" <> '' then "Available Balance" := "Available Balance" - SaccoJnl.GetChargesAmount("Charge Code", Amount);
                if "Available Balance" < 0 then "Available Balance" := 0;
                if "Transaction Type" = "Transaction Type"::"Cash Withdrawal" then begin
                    if Amount > "Available Balance" then Error('You Can only transact upto %1', "Available Balance");
                end;
                UserSetup.Get(UserId);
                Employee.Get(UserSetup."Employee No.");
                if "Member No." = Employee."Member No." then
                    "Approval Required" := true
                else begin
                    if Amount > "Approval Limmit" then
                        "Approval Required" := true
                    else
                        "Approval Required" := false;
                end;
            end;
        }
        field(9; Teller; Code[100])
        {
            Editable = false;
            TableRelation = "Teller Setup";
        }
        field(10; Till; Code[50])
        {
            Editable = false;
            TableRelation = "Bank Account";
        }
        field(11; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(12; "Approval Required"; Boolean)
        {
            Editable = false;
        }
        field(13; Posted; Boolean)
        {
            Editable = false;
        }
        field(14; "Created On"; Datetime)
        {
            Editable = false;
        }
        field(15; "Posted On"; DateTime)
        {
            Editable = false;
        }
        field(16; "Created By"; Code[50])
        {
            TableRelation = "User Setup";
            Editable = false;
        }
        field(17; "Posted By"; Code[50])
        {
            TableRelation = "User Setup";
            Editable = false;
        }
        field(18; "Posting Date"; Date)
        {
            Editable = false;
        }
        field(19; "Available Balance"; Decimal)
        {
            Editable = false;
        }
        field(20; "Transacted By Name"; Text[50])
        {
        }
        field(21; "Transacted By ID No"; code[20])
        {
        }
        field(22; "Charge Code"; Code[20])
        {
            Editable = false;
            TableRelation = "Transaction Charges" where("Posting Transaction Type" = filter("Cash Withdrawal" | "Cash Deposit"));

            trigger OnValidate()
            begin
                Validate(Amount);
            end;
        }
        field(23; Denominations; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Transaction Denomination"."Total Value" where("No." = field("No."), "Document Type" = const("Teller Transactions")));
            Editable = false;
        }
        field(24; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            Editable = false;
        }
        field(25; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            Editable = false;
        }
        field(26; "Book Balance"; Decimal)
        {
            Editable = false;
        }
        field(27; "Approval Limmit"; Decimal)
        {
            Editable = false;
        }
        field(28; Dormant; Boolean)
        {
            Editable = false;
        }
        field(29; "Till Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Bank Account Ledger Entry".Amount where("Bank Account No." = field(Till)));
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
        TellerSetup: Record "Teller Setup";
        Member: Record Members;
        Vendor: Record Vendor;
        UserSetup: Record "User Setup";
        Employee: Record Employee;
        UserMgmtExt: Codeunit "User Management Ext";
        FosaMGT: Codeunit "FOSA Management";
        DocType: Enum "FOSA Transaction Types";

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Teller Transaction Nos");
        "No." := NoSeries.GetNextNo(SaccoSetup."Teller Transaction Nos", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        UserMgmtExt.GetUserDimensions(UserId, "Global Dimension 1 Code", "Global Dimension 2 Code");

        if TellerSetup.Get(UserId, TellerSetup."Setup Type"::Teller) then begin
            TellerSetup.TestField("Account Code");
            TellerSetup.TestField("Approval Limit");
            Till := TellerSetup."Account Code";
            Teller := UserId;
            "Approval Limmit" := TellerSetup."Approval Limit";
        end
        else
            Error('You are not setup as a teller');
        "Posting Date" := WorkDate;
        FosaMGT.ValidateTransactionDenominations(Rec."No.", DocType::"Teller Transactions");
    end;

    trigger OnDelete()
    begin
        Rec.Testfield(Status, Rec.Status::Open);
        Rec.Testfield("Created By", UserId);
    end;

    procedure FnGetTCharges(): Decimal;
    var
        ChargeAount: Decimal;
        TransactionChargesSetup: Record "Transaction Charges Setup";
        ObjCalcSchemes: Record "Transaction Calc. Scheme";
        ObjSaccoSetup: Record "General Ledger Setup";
    begin
        ChargeAount := 0;
        TransactionChargesSetup.Reset();
        TransactionChargesSetup.SetRange("Transaction Code", "Charge Code");
        if TransactionChargesSetup.FindSet then begin
            repeat
                ObjCalcSchemes.reset;
                ObjCalcSchemes.SetRange("Source Code", "Charge Code");
                ObjCalcSchemes.SetRange("Charge Code", TransactionChargesSetup.Code);
                if ObjCalcSchemes.FindSet() then begin
                    if ((Amount >= ObjCalcSchemes."Lower Limit") and (Amount <= ObjCalcSchemes."Upper Limit")) then
                        repeat
                            ChargeAount += ObjCalcSchemes.Rate;
                        until ObjCalcSchemes.next = 0;
                end;
            until TransactionChargesSetup.Next = 0;
        end;
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posting Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;
}
