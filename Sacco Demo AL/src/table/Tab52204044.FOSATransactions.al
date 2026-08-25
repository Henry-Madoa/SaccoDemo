table 52204044 "FOSA Transactions"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "FOSA Transaction Types")
        {
            Editable = false;
        }
        field(2; "No."; Code[20])
        {
            Editable = false;
        }
        field(3; "Source No"; Code[20])
        {
            TableRelation = if ("Document Type" = const("Inter Teller Transfer")) "Bank Account" where("Account Type" = const(Teller))
            else if ("Document Type" = const("Receive From Bank")) "Bank Account" where("Account Type" = const(Main))
            else if ("Document Type" = const("Treasury Request")) "Bank Account" where("Account Type" = const(Treasury))
            else if ("Document Type" = const("Treasury Return")) "Bank Account" where("Account Type" = const(Teller))
            else if ("Document Type" = const("Send to Bank")) "Bank Account" where("Account Type" = const(Treasury));

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
            begin
                BankAccount.Get("Source No");
                "Source Name" := BankAccount.Name;
            end;
        }
        field(4; "Source Name"; Text[100])
        {
            Editable = false;
        }
        field(5; "Source Balance"; Decimal)
        {
            Caption = 'Balance';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Bank Account Ledger Entry".Amount where("Bank Account No." = field("Source No")));
        }
        field(6; "Destination No"; Code[20])
        {
            TableRelation = if ("Document Type" = const("Inter Teller Transfer")) "Bank Account" where("Account Type" = const(Teller))
            else if ("Document Type" = const("Receive From Bank")) "Bank Account" where("Account Type" = const(Treasury))
            else if ("Document Type" = const("Treasury Request")) "Bank Account" where("Account Type" = const(Teller))
            else if ("Document Type" = const("Treasury Return")) "Bank Account" where("Account Type" = const(Treasury))
            else if ("Document Type" = const("Send to Bank")) "Bank Account" where("Account Type" = const(Main));

            trigger OnValidate()
            var
                Bank: Record "Bank Account";
            begin
                Bank.Get("Destination No");
                "Destination Name" := Bank.Name;
            end;
        }
        field(7; "Destination Name"; Text[100])
        {
            Editable = false;
        }
        field(8; "Destination Balance"; Decimal)
        {
            Caption = 'Balance';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Bank Account Ledger Entry".Amount where("Bank Account No." = field("Destination No")));
        }
        field(9; Amount; Decimal)
        {
            trigger OnValidate()
            begin
                FosaMGT.ValidateTransactionDenominations(Rec."No.", Rec."Document Type");
            end;
        }
        field(10; Denominations; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Transaction Denomination"."Total Value" where("No." = field("No."), "Document Type" = field("Document Type")));
            Editable = false;
        }
        field(11; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(12; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(13; "Created By"; Code[50])
        {
            Editable = false;
        }
        field(14; Posted; Boolean)
        {
            Editable = false;
        }
        field(15; "Posting Date"; Date)
        {
            Editable = false;
        }
        field(16; "Posted By"; Code[50])
        {
            Editable = false;
        }
        field(17; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));
        }
        field(18; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = const(false));
        }
    }
    keys
    {
        key(Key1; "Document Type", "No.")
        {
            Clustered = true;
        }
    }
    var
        SaccoSetup: Record "General Ledger Setup";
        Noseries: Codeunit NoSeriesManagement;
        TellerSetup: Record "Teller Setup";
        FosaMGT: Codeunit "FOSA Management";
        UserSetup: Record "User Setup";
        Employee: Record Employee;
        FosaTransactions: Record "FOSA Transactions";

    trigger OnInsert()
    begin

        FosaTransactions.Reset();
        FosaTransactions.SetRange("Created By", UserId);
        FosaTransactions.SetRange(Status, FosaTransactions.Status::Open);
        FosaTransactions.SetRange("Document Type", Rec."Document Type");
        if FosaTransactions.FindFirst then begin
            if not (FosaTransactions."Document Type" in [FosaTransactions."Document Type"::"Receive From Bank", FosaTransactions."Document Type"::"Send to Bank"]) then Error(StrSubstNo('You have another Open Document, Kindly make use of %1 before opening another Document', FosaTransactions."No."));
            if (FosaTransactions."Document Type" in [FosaTransactions."Document Type"::"Receive From Bank", FosaTransactions."Document Type"::"Send to Bank"]) and (not FosaTransactions.Posted) then Error(StrSubstNo('You have another Open Document, Kindly make use of %1 before opening another Document', FosaTransactions."No."));
        end;

        SaccoSetup.Get();
        SaccoSetup.TestField("FOSA Nos");
        "No." := NoSeries.GetNextNo(SaccoSetup."FOSA Nos", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        case "Document Type" of
            "Document Type"::"Receive From Bank":
                begin
                    TellerSetup.Get(UserId, TellerSetup."Setup Type"::Treasury);
                    Validate("Destination No", TellerSetup."Account Code");
                end;
            "Document Type"::"Treasury Request", "Document Type"::"Inter Teller Transfer":
                begin
                    TellerSetup.Get(UserId, TellerSetup."Setup Type"::Teller);
                    Rec.Validate("Destination No", TellerSetup."Account Code");
                end;
            "Document Type"::"Treasury Return":
                begin
                    TellerSetup.Get(UserId, TellerSetup."Setup Type"::Teller);
                    Rec.Validate("Source No", TellerSetup."Account Code");
                end;
            "Document Type"::"Send to Bank":
                begin
                    TellerSetup.Get(UserId, TellerSetup."Setup Type"::Treasury);
                    Rec.Validate("Source No", TellerSetup."Account Code");
                end;
        end;
        FosaMGT.ValidateTransactionDenominations(Rec."No.", Rec."Document Type");
        UserSetup.Get(UserId);
        Employee.Get(UserSetup."Employee No.");
        "Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
        "Global Dimension 2 Code" := Employee."Global Dimension 2 Code";
    end;

    trigger OnDelete()
    begin
        TestField("Created By", UserId);
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posting Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;

    procedure OnBeforeSendForApproval()
    begin
        SaccoSetup.Get;
        TestField("Destination No");
        TestField(Amount);
        TestField("Source No");
        CalcFields("Source Balance");
        CalcFields(Denominations);
        if ((SaccoSetup."Validate Cash Denomination") and (Denominations <> Amount)) then Error('The Denominations breakdown is not equal to the Total Amount');
    end;
}
