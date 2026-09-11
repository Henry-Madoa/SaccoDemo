table 52203563 "Commitment Entries"
{
    DrillDownPageID = "Commitment Entries";
    LookupPageID = "Commitment Entries";

    fields
    {
        field(1; "Commitment No"; Code[20])
        {
            trigger OnValidate()
            begin
            /*
                    IF "Commitment No" <> xRec."Commitment No" THEN BEGIN
                        GenLedgerSetup.GET();
                        NoSeriesMgt.TestManual( GenLedgerSetup."Commitment No");
                         "Commitment No" := '';
                    end;
                     */
            end;
        }
        field(2; "Commitment Date"; Date)
        {
        }
        field(3; "Commitment Type"; Option)
        {
            OptionMembers = , Committed, Reversal, LPO, Imprest, Uncommitted;
        }
        field(4; Account; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(5; "Committed Amount"; Decimal)
        {
        }
        field(6; User; Code[50])
        {
        }
        field(7; "Document No"; Code[20])
        {
        }
        field(8; InvoiceNo; Code[20])
        {
        }
        field(9; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(10; "No."; Code[20])
        {
        }
        field(11; "Entry No"; Integer)
        {
            AutoIncrement = false;
        }
        field(12; "Global Dimension 1"; Code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(13; "Global Dimension 2"; Code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(14; "Line No."; Integer)
        {
            AutoIncrement = true;
        }
        field(15; "Account No."; Code[20])
        {
            TableRelation = IF("Account Type"=CONST("G/L Account"))"G/L Account"
            ELSE IF("Account Type"=CONST(Customer))Customer
            ELSE IF("Account Type"=CONST(Vendor))Vendor
            ELSE IF("Account Type"=CONST("Fixed Asset"))"Fixed Asset";
        }
        field(16; "Account Name"; Text[100])
        {
        }
        field(17; Description; Text[250])
        {
        }
        field(18; "Account Type"; Option)
        {
            OptionCaption = 'G/L Account,Customer,Vendor,Bank Account,Fixed Asset';
            OptionMembers = "G/L Account", Customer, Vendor, "Bank Account", "Fixed Asset";
        }
        field(19; "Uncommittment Date"; Date)
        {
        }
        field(20; Invoiced; Boolean)
        {
        }
        field(21; Paid; Boolean)
        {
        }
        field(22; "PV No."; Code[20])
        {
        }
        field(23; "Invoiced Date"; Date)
        {
        }
        field(24; "Paid Date"; Date)
        {
        }
        field(26; "Budget"; Code[10])
        {
        }
        field(27; "Global Dimension 3"; Code[20])
        {
            CaptionClass = '1,2,3';
        }
    }
    keys
    {
        key(Key1; "No.", "Line No.", "Committed Amount", Paid)
        {
        }
    }
    trigger OnInsert()
    begin
        /*IF "No." = '' THEN BEGIN
          AdvancedFinanceSetup.GET;
          AdvancedFinanceSetup.TESTFIELD(AdvancedFinanceSetup."Commitment Nos.");
          NoSeriesMgt.InitSeries(AdvancedFinanceSetup."Commitment Nos.",xRec."No. Series",0D,"No.","No. Series");
        end;*/
        User:=UserId;
        "Commitment Date":=WorkDate;
    end;
    var GenLedgerSetup: Record "General Ledger Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    AdvancedFinanceSetup: Record "General Ledger Setup";
}
