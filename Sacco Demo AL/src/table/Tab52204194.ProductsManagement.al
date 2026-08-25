table 52204194 "Products Management"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Document Type"; Option)
        {
            OptionMembers = Application,Update;
        }
        field(3; Reason; Text[250])
        {
        }
        field(4; Status; Enum "Document Status")
        {
        }
        field(5; "Created By"; Code[100])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(6; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(7; "Processed By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(8; Processed; Boolean)
        {
            Editable = false;
        }
        field(9; "Processed On"; Date)
        {
            Editable = false;
        }
        field(10; "Product Code"; Code[20])
        {
            TableRelation = if ("Document Type" = const(Update)) "Sacco Products" where(Indentation = const(1));

            trigger OnValidate()
            begin
                if "Document Type" = "Document Type"::Application then begin
                    if SaccoProducts.Get("Product Code") then Error(StrSubstNo('The Product %1 is already in the Sacco Product List', SaccoProducts.Description));
                end
                else begin
                    LoanProductLinking[1].Reset();
                    LoanProductLinking[1].SetRange("Source Code", "No.");
                    LoanProductLinking[1].DeleteAll();
                    ProductInterestBands[1].Reset();
                    ProductInterestBands[1].SetRange("Source Code", "No.");
                    ProductInterestBands[1].DeleteAll();
                    ProductChargeSetup[1].Reset();
                    ProductChargeSetup[1].SetRange("Source Code", "No.");
                    ProductChargeSetup[1].DeleteAll();
                    TransactionCalcScheme[1].Reset();
                    TransactionCalcScheme[1].SetRange("Source Code", "No.");
                    TransactionCalcScheme[1].DeleteAll();
                    if SaccoProducts.Get("Product Code") then begin
                        Validate(Category, SaccoProducts.Category);
                        Validate(Description, SaccoProducts.Description);
                        Validate("Product Posting Type", SaccoProducts."Product Posting Type");
                        Validate("Posting Group", SaccoProducts."Posting Group");
                        Validate(Prefix, SaccoProducts.Prefix);
                        Validate(Suffix, SaccoProducts.Suffix);
                        Validate("Print Sequence", SaccoProducts."Print Sequence");
                        Validate("Hide on Statement", SaccoProducts."Hide on Statement");
                        Validate("Loan Recovery Priority", SaccoProducts."Loan Recovery Priority");
                        Validate("Blocked", SaccoProducts.Blocked);
                        if "Product Posting Type" <> "Product Posting Type"::"Loan Account" then begin
                            Validate("Business Account", SaccoProducts."Business Account");
                            Validate("Cash Deposit Allowed", SaccoProducts."Cash Deposit Allowed");
                            Validate("Cash Withdraw Allowed", SaccoProducts."Cash Withdraw Allowed");
                            Validate("Cash Transfer Allowed", SaccoProducts."Cash Transfer Allowed");
                            Validate("ATM Use Allowed", SaccoProducts."ATM Use Allowed");
                            Validate("Cheque Book Allowed", SaccoProducts."Cheque Book Allowed");
                            Validate("Checkoff Product", SaccoProducts."Checkoff Product");
                            Validate("Minimum Balance", SaccoProducts."Minimum Balance");
                            Validate("Maximum Balance", SaccoProducts."Maximum Balance");
                            Validate("Minimum Contribution", SaccoProducts."Minimum Contribution");
                        end
                        else begin
                            Validate("Rate Type", SaccoProducts."Rate Type");
                            Validate("Interest Rate", SaccoProducts."Interest Rate");
                            Validate("Interest Due Account", SaccoProducts."Interest Due Account");
                            Validate("Interest Paid Account", SaccoProducts."Interest Paid Account");
                            Validate("Interest Repayment Method", SaccoProducts."Interest Repayment Method");
                            Validate("Penalty Due Account", SaccoProducts."Penalty Due Account");
                            Validate("Penalty Paid Account", SaccoProducts."Penalty Paid Account");
                            Validate("Penalty Rate", SaccoProducts."Penalty Rate");
                            Validate("Loan Multiplier", SaccoProducts."Loan Multiplier");
                            Validate("Maximum Loan Multiplier", SaccoProducts."Maximum Loan Multiplier");
                            Validate("Ordinary Default Intallments", SaccoProducts."Ordinary Default Intallments");
                            Validate("Max. Running Loans", SaccoProducts."Max. Running Loans");
                            Validate("Minimum Loan Amount", SaccoProducts."Minimum Loan Amount");
                            Validate("Maximum Loan Amount", SaccoProducts."Maximum Loan Amount");
                            Validate("Minimum Deposit Balance", SaccoProducts."Minimum Deposit Balance");
                            Validate("Minimum Deposit Contribution", SaccoProducts."Minimum Deposit Contribution");
                            Validate("Minimum Installments", SaccoProducts."Minimum Installments");
                            Validate("Maximum Installments", SaccoProducts."Maximum Installments");
                            Validate("Max. NWD Boost", SaccoProducts."Max. NWD Boost");
                            Validate("Max. NWD Boost %", SaccoProducts."Max. NWD Boost %");
                            Validate("Bridging Commision %", SaccoProducts."Bridging Commision %");
                            Validate("Charge UpFront Interest", SaccoProducts."Charge UpFront Interest");
                            Validate("View Online", SaccoProducts."View Online");
                            Validate("Mobile Loan", SaccoProducts."Mobile Loan");
                            Validate("Exclude Billing & Interest", SaccoProducts."Exclude Billing & Interest");
                            Validate("Boosting Commission %", SaccoProducts."Boosting Commission %");
                            Validate("Max. Bridging Commission", SaccoProducts."Max. Bridging Commission");
                            Validate("Commission Account", SaccoProducts."Commission Account");
                            Validate("Insurance Rate", SaccoProducts."Insurance Rate");
                            Validate("Insurance Factor", SaccoProducts."Insurance Factor");
                            Validate("Insurance Account", SaccoProducts."Insurance Account");
                            Validate("Insurance Income %", SaccoProducts."Insurance Income %");
                            Validate("Insurance Income Account", SaccoProducts."Insurance Income Account");
                            Validate("Boost Deposits", SaccoProducts."Boost Deposits");
                            Validate("Appraise with 0 Deposits", SaccoProducts."Appraise with 0 Deposits");
                            Validate("Mobile Appraisal Type", SaccoProducts."Mobile Appraisal Type");
                            Validate("Salary Based", SaccoProducts."Salary Based");
                            Validate("Dividend Based", SaccoProducts."Dividend Based");
                            Validate("Min. Salary Count", SaccoProducts."Min. Salary Count");
                            Validate("Salary %", SaccoProducts."Salary %");
                            Validate("Salary Appraisal Type", SaccoProducts."Salary Appraisal Type");
                            Validate("Special Loan Multiplier", SaccoProducts."Special Loan Multiplier");
                            Validate("Max. Running Loans", SaccoProducts."Max. Running Loans");
                            Validate("Unsecured Product", SaccoProducts."Unsecured Product");
                            Validate("Repayment Cutoff Date", SaccoProducts."Repayment Cutoff Date");
                            Validate("Mode of Disbursement", SaccoProducts."Mode of Disbursement");
                            Validate("Disbursement Account", SaccoProducts."Disbursement Account");
                            LoanProductLinking[2].Reset();
                            LoanProductLinking[2].SetRange("Source Code", "Product Code");
                            if LoanProductLinking[2].FindSet() then begin
                                repeat
                                    LoanProductLinking[3].Init();
                                    LoanProductLinking[3].TransferFields(LoanProductLinking[2]);
                                    LoanProductLinking[3]."Source Code" := "No.";
                                    LoanProductLinking[3].Insert();
                                until LoanProductLinking[2].Next() = 0;
                            end;
                            ProductInterestBands[2].Reset();
                            ProductInterestBands[2].SetRange("Source Code", "Product Code");
                            if ProductInterestBands[2].FindSet() then begin
                                repeat
                                    ProductInterestBands[3].Init();
                                    ProductInterestBands[3].TransferFields(ProductInterestBands[2], false);
                                    ProductInterestBands[3]."Source Code" := "No.";
                                    ProductInterestBands[3]."Entry No." := ProductInterestBands[2]."Entry No.";
                                    ProductInterestBands[3].Insert(true);
                                until ProductInterestBands[2].Next() = 0;
                            end;
                            ProductChargeSetup[2].Reset();
                            ProductChargeSetup[2].SetRange("Source Code", "Product Code");
                            if ProductChargeSetup[2].FindSet() then begin
                                repeat
                                    ProductChargeSetup[3].Init();
                                    ProductChargeSetup[3].TransferFields(ProductChargeSetup[2]);
                                    ProductChargeSetup[3]."Source Code" := "No.";
                                    ProductChargeSetup[3].Insert(true);
                                until ProductChargeSetup[2].Next() = 0;
                            end;
                            TransactionCalcScheme[2].Reset();
                            TransactionCalcScheme[2].SetRange("Source Code", "Product Code");
                            if TransactionCalcScheme[2].FindSet() then begin
                                repeat
                                    TransactionCalcScheme[3].Init();
                                    TransactionCalcScheme[3].TransferFields(TransactionCalcScheme[2]);
                                    TransactionCalcScheme[3]."Source Code" := "No.";
                                    TransactionCalcScheme[3].Insert(true);
                                until TransactionCalcScheme[2].Next() = 0;
                            end;
                        end;
                    end;
                end;
            end;
        }
        field(11; Category; Code[20])
        {
            TableRelation = "Sacco Product Categories";
        }
        field(12; Description; Text[100])
        {
        }
        field(13; "Product Posting Type"; Enum "Product Posting Type")
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Posting Group"; Code[10])
        {
            TableRelation = "Vendor Posting Group" where("Account Type" = filter(Sacco | Loan));
        }
        field(15; Prefix; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(16; Suffix; Code[20])
        {
        }
        field(17; "Processing Fee Acc."; Code[20])
        {
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting), Blocked = CONST(false));
        }
        field(18; "Rate Type"; Option)
        {
            OptionMembers = "Per-Annum","Per Month","Fixed";
        }
        field(19; "Interest Rate"; Decimal)
        {
        }
        field(20; "Interest Due Account"; Code[20])
        {
            TableRelation = "G/L Account"."No." where("Direct Posting" = const(true), "Income/Balance" = filter("Balance Sheet"));

            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", "Product Posting Type"::"Loan Account");
            end;
        }
        field(21; "Interest Paid Account"; Code[20])
        {
            TableRelation = "G/L Account"."No." where("Direct Posting" = const(true), "Income/Balance" = filter("Income Statement"));

            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", "Product Posting Type"::"Loan Account");
            end;
        }
        field(22; "Interest Repayment Method"; Enum "Loan Rate Type")
        {
        }
        field(23; "Interest Bands"; Integer)
        {
            fieldClass = Flowfield;
            CalcFormula = count("Product Interest Bands" where("Source Code" = field("No."), Active = const(true)));
        }
        field(24; "Penalty Due Account"; Code[20])
        {
            TableRelation = "G/L Account" where("Direct Posting" = const(true));
        }
        field(25; "Penalty Paid Account"; code[20])
        {
            TableRelation = "G/L Account" where("Direct Posting" = const(true));
        }
        field(26; "Penalty Rate"; Decimal)
        {
        }
        field(27; "Loan Multiplier"; Decimal)
        {
        }
        field(28; "Maximum Loan Multiplier"; Decimal)
        {
            trigger OnValidate()
            begin
                if "Maximum Loan Multiplier" = 0 then
                    "Maximum Loan Multiplier" := "Loan Multiplier"
                else
                    if "Maximum Loan Multiplier" < "Loan Multiplier" then
                        Error(StrSubstNo('Maximum Loan Multiplier cannot be less than %1', "Loan Multiplier"));
            end;
        }
        field(29; "Ordinary Default Intallments"; integer)
        {
        }
        field(30; "Minimum Balance"; Decimal)
        {
        }
        field(31; "Maximum Balance"; Decimal)
        {
        }
        field(32; "Minimum Contribution"; Decimal)
        {
        }
        field(36; "Minimum Loan Amount"; Decimal)
        {
        }
        field(33; "Maximum Loan Amount"; Decimal)
        {
        }
        field(34; "Minimum Deposit Balance"; Decimal)
        {
        }
        field(35; "Minimum Deposit Contribution"; Decimal)
        {
        }
        field(37; "Minimum Installments"; Integer)
        {
        }
        field(38; "Maximum Installments"; Integer)
        {
        }
        field(39; "Max. NWD Boost"; Decimal)
        {
        }
        field(40; "Max. NWD Boost %"; Decimal)
        {
        }
        field(41; "Bridging Commision %"; Decimal)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(42; "Charge UpFront Interest"; boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(43; "View Online"; Boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(49; "Mobile Loan"; Boolean)
        {
        }
        field(44; "Exclude Billing & Interest"; Boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(45; "Boosting Commission %"; Decimal)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(46; "Max. Bridging Commission"; Decimal)
        {
        }
        field(47; "Commission Account"; code[20])
        {
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(48; "Insurance Rate"; Decimal)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(50; "Insurance Factor"; Decimal)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(51; "Insurance Account"; code[20])
        {
            TableRelation = "G/L Account" where("Direct Posting" = const(true));

            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(52; "Insurance Income %"; Decimal)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(53; "Insurance Income Account"; Code[20])
        {
            TableRelation = "G/L Account" where("Direct Posting" = const(true));

            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(54; "Boost Deposits"; Boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
                if "Boost Deposits" = false then begin
                    "Max. NWD Boost" := 0;
                    "Max. NWD Boost %" := 0;
                end;
            end;
        }
        field(55; "Appraise with 0 Deposits"; Boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(56; "Cheque Book Allowed"; Boolean)
        {
            trigger OnValidate()
            var
                Window: Dialog;
                Vendor: Record Vendor;
            begin
                If "Cheque Book Allowed" then begin
                    if "Product Posting Type" <> "Product Posting Type"::"Withdrawable Deposit" then Error('Cheque Books cannot be linked to %1 accounts', "Product Posting Type");
                end;
            end;
        }
        field(57; "Mobile Appraisal Type"; Option)
        {
            OptionMembers = "Deposit Multiplier","Percent Of Lowest Salary","Dividend Percentage","Percent of Net Salary","Defined Amount";
        }
        field(58; "Salary Based"; Boolean)
        {
        }
        field(59; "Dividend Based"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60; "Min. Salary Count"; Integer)
        {
        }
        field(61; "Salary %"; Decimal)
        {
        }
        field(62; "Salary Appraisal Type"; Option)
        {
            OptionMembers = "Average Net","Lowest Net";
        }
        field(63; "Special Loan Multiplier"; Boolean)
        {
        }
        field(64; "Business Account"; Boolean)
        {
        }
        field(65; "Cash Withdraw Allowed"; Boolean)
        {
        }
        field(66; "Cash Deposit Allowed"; Boolean)
        {
        }
        field(67; "Cash Transfer Allowed"; Boolean)
        {
        }
        field(68; "ATM Use Allowed"; Boolean)
        {
        }
        field(69; "Max. Running Loans"; Integer)
        {
        }
        field(70; "Checkoff Product"; Boolean)
        {
        }
        field(71; "Unsecured Product"; Boolean)
        {
        }
        field(72; "Repayment Cutoff Date"; Integer)
        {
        }
        field(73; "Print Sequence"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(74; "Hide on Statement"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(75; "Loan Recovery Priority"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(76; "Blocked"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(77; "Mode of Disbursement"; Enum "Mode of Disbursement")
        {
        }
        field(78; "Disbursement Account"; Code[20])
        {
            TableRelation = if ("Mode of Disbursement" = const(BOSA)) "G/L Account" where(Blocked = const(false), "Account Type" = const(Posting), "Account Category" = const(Liabilities));
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
        GeneralLedgerSetup: Record "General Ledger Setup";
        NoSeries: Codeunit "No. Series";
        SaccoProducts: Record "Sacco Products";
        LoanProductLinking: array[3] of Record "Loan Product Linking";
        ProductInterestBands: array[3] of Record "Product Interest Bands";
        ProductChargeSetup: array[3] of Record "Product Charge Setup";
        TransactionCalcScheme: array[3] of Record "Transaction Calc. Scheme";

    trigger OnInsert()
    begin
        GeneralLedgerSetup.Get;
        GeneralLedgerSetup.TestField("Product Application Nos.");
        GeneralLedgerSetup.TestField("Product Editing Nos.");
        If "Document Type" = "Document Type"::Application then
            "No." := NoSeries.GetNextNo(GeneralLedgerSetup."Product Application Nos.", Today, true)
        else if "Document Type" = "Document Type"::Update then "No." := NoSeries.GetNextNo(GeneralLedgerSetup."Product Editing Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;

    procedure AssistEdit(OldProductApp: Record "Products Management"): Boolean
    var
        SaccoProductApp: Record "Products Management";
    begin
        SaccoProductApp := Rec;
        GeneralLedgerSetup.Get;
        GeneralLedgerSetup.TestField("Product Application Nos.");
        GeneralLedgerSetup.TestField("Product Editing Nos.");
        If "Document Type" = "Document Type"::Application then begin
            if NoSeries.LookupRelatedNoSeries(GeneralLedgerSetup."Product Application Nos.", GeneralLedgerSetup."Product Application Nos.", GeneralLedgerSetup."Product Application Nos.") then begin
                SaccoProductApp."No." := NoSeries.GetNextNo(GeneralLedgerSetup."Product Application Nos.");
                Rec := SaccoProductApp;
                exit(true);
            end;
        end
        else if "Document Type" = "Document Type"::Update then begin
            if NoSeries.LookupRelatedNoSeries(GeneralLedgerSetup."Product Editing Nos.", GeneralLedgerSetup."Product Editing Nos.", GeneralLedgerSetup."Product Editing Nos.") then begin
                SaccoProductApp."No." := NoSeries.GetNextNo(GeneralLedgerSetup."Product Editing Nos.");
                Rec := SaccoProductApp;
                exit(true);
            end;
        end;
    end;

    procedure DocumentNoIsVisible(): Boolean
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        DocNoVisible: Boolean;
        NoSeriesCode: Code[20];
    begin
        GeneralLedgerSetup.Get;
        GeneralLedgerSetup.TestField("Product Application Nos.");
        GeneralLedgerSetup.TestField("Product Editing Nos.");
        If "Document Type" = "Document Type"::Application then
            NoSeriesCode := GeneralLedgerSetup."Product Application Nos."
        else if "Document Type" = "Document Type"::Update then NoSeriesCode := GeneralLedgerSetup."Product Editing Nos.";
        DocNoVisible := DocumentNoVisibility.ForceShowNoSeriesForDocNo(NoSeriesCode);
        exit(DocNoVisible);
    end;

    procedure OnBeforeSendForApproval()
    begin
        TestField("Product Code");
        TestField(Description);
        TestField(Category);
        TestField("Product Posting Type");
        TestField("Posting Group");
        TestField(Prefix);
        TestField(Suffix);
        if "Document Type" = "Document Type"::Update then TestField(Reason);
    end;
}
