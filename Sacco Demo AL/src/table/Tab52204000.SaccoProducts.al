table 52204000 "Sacco Products"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Sacco Products";
    DrillDownPageId = "Sacco Products";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Category; Code[20])
        {
            TableRelation = "Sacco Product Categories";

            trigger OnValidate()
            begin
                if Category = '' then
                    Indentation := 0
                else if not SaccoProducts[1].Get(Category) then begin
                    ProductsCategories.Get(Category);
                    SaccoProducts[2].Init();
                    SaccoProducts[2].Code := ProductsCategories.Code;
                    SaccoProducts[2].Category := ProductsCategories.Code;
                    SaccoProducts[2].Description := ProductsCategories.Description;
                    SaccoProducts[2].Indentation := 0;
                    SaccoProducts[2].Insert(true);
                    Indentation := 1;
                end
                else begin
                    "Product Posting Type" := SaccoProducts[1]."Product Posting Type";
                    Indentation := 1;
                end;
            end;
        }
        field(3; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = SystemMetadata;
        }
        field(4; Description; Text[100])
        {
        }
        field(5; "Product Posting Type"; Enum "Product Posting Type")
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Posting Group"; Code[10])
        {
            TableRelation = "Vendor Posting Group" where("Account Type" = filter(Sacco | Loan));
        }
        field(7; Prefix; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Suffix; Code[20])
        {
        }
        field(9; "Rate Type"; Option)
        {
            OptionMembers = "Per-Annum","Per Month","Fixed";
        }
        field(10; "Interest Rate"; Decimal)
        {
        }
        field(11; "Interest Due Account"; Code[20])
        {
            TableRelation = "G/L Account"."No." where("Income/Balance" = filter("Balance Sheet"));

            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", "Product Posting Type"::"Loan Account");
            end;
        }
        field(12; "Interest Paid Account"; Code[20])
        {
            TableRelation = "G/L Account"."No." where("Income/Balance" = filter("Income Statement"));

            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", "Product Posting Type"::"Loan Account");
            end;
        }
        field(13; "Interest Repayment Method"; Enum "Loan Rate Type")
        {
        }
        field(14; "Interest Bands"; Integer)
        {
            fieldClass = Flowfield;
            CalcFormula = count("Product Interest Bands" where("Source Code" = field(Code), Active = const(true)));
        }
        field(15; "Penalty Due Account"; Code[20])
        {
            TableRelation = "G/L Account" where("Direct Posting" = const(true));
        }
        field(16; "Penalty Paid Account"; code[20])
        {
            TableRelation = "G/L Account" where("Direct Posting" = const(true));
        }
        field(17; "Penalty Rate"; Decimal)
        {
        }
        field(18; "Loan Multiplier"; Decimal)
        {
        }
        field(19; "Maximum Loan Multiplier"; Decimal)
        {
            trigger OnValidate()
            begin
                if "Maximum Loan Multiplier" < "Loan Multiplier" then
                    Error(StrSubstNo('Maximum Loan Multiplier cannot be less than %1', "Loan Multiplier"));
            end;
        }
        field(20; "Ordinary Default Intallments"; integer)
        {
        }
        field(21; "Minimum Balance"; Decimal)
        {
        }
        field(22; "Maximum Balance"; Decimal)
        {
        }
        field(23; "Minimum Contribution"; Decimal)
        {
        }
        field(24; "Minimum Loan Amount"; Decimal)
        {
        }
        field(25; "Maximum Loan Amount"; Decimal)
        {
        }
        field(26; "Minimum Deposit Balance"; Decimal)
        {
        }
        field(27; "Minimum Deposit Contribution"; Decimal)
        {
        }
        field(28; "Minimum Installments"; Integer)
        {
        }
        field(29; "Maximum Installments"; Integer)
        {
        }
        field(30; "Boost Deposits"; Boolean)
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
        field(31; "Max. NWD Boost"; Decimal)
        {
        }
        field(32; "Max. NWD Boost %"; Decimal)
        {
        }
        field(33; "Bridging Commision %"; Decimal)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(34; "Boosting Commission %"; Decimal)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(35; "Max. Bridging Commission"; Decimal)
        {
        }
        field(36; "Commission Account"; Code[20])
        {
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(37; "Charge UpFront Interest"; boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(38; "View Online"; Boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(39; "Mobile Loan"; Boolean)
        {
        }
        field(40; "Exclude Billing & Interest"; Boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(41; "Insurance Rate"; Decimal)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(42; "Insurance Factor"; Decimal)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(43; "Insurance Account"; code[20])
        {
            TableRelation = "G/L Account" where("Direct Posting" = const(true));

            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(44; "Insurance Income %"; Decimal)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(45; "Insurance Income Account"; Code[20])
        {
            TableRelation = "G/L Account" where("Direct Posting" = const(true));

            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(46; "Appraise with 0 Deposits"; Boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Product Posting Type", Rec."Product Posting Type"::"Loan Account");
            end;
        }
        field(47; "Cheque Book Allowed"; Boolean)
        {
            trigger OnValidate()
            var
                Window: Dialog;
                Vendor: Record Vendor;
            begin
                if (("Cheque Book Allowed" = true) and ("Product Posting Type" <> "Product Posting Type"::"Withdrawable Deposit")) then Error('Cheque Books cannot be linked to %1 accounts', "Product Posting Type");
                Vendor.Reset();
                Vendor.SetRange("Product Code", Code);
                if Vendor.FindSet() then begin
                    Window.Open('Endforcing Changes  \#1### \#2##');
                    repeat
                        Window.Update(1, Vendor."Search Name");
                        Vendor."Cheque Book Allowed" := "Cheque Book Allowed";
                        Vendor.Modify();
                    until Vendor.Next() = 0;
                    Window.Close;
                end;
            end;
        }
        field(48; "Mobile Appraisal Type"; Option)
        {
            OptionMembers = "Deposit Multiplier","Percent Of Lowest Salary","Dividend Percentage","Percent of Net Salary","Defined Amount";
        }
        field(49; "Salary Based"; Boolean)
        {
        }
        field(50; "Min. Salary Count"; Integer)
        {
        }
        field(51; "Salary %"; Decimal)
        {
            MaxValue = 086;
        }
        field(52; "Salary Appraisal Type"; Option)
        {
            OptionMembers = "Average Net","Lowest Net";
        }
        field(53; "Special Loan Multiplier"; Boolean)
        {
        }
        field(54; "Business Account"; Boolean)
        {
        }
        field(55; "Cash Withdraw Allowed"; Boolean)
        {
        }
        field(56; "Cash Deposit Allowed"; Boolean)
        {
        }
        field(57; "Cash Transfer Allowed"; Boolean)
        {
        }
        field(58; "ATM Use Allowed"; Boolean)
        {
        }
        field(59; "Max. Running Loans"; Integer)
        {
        }
        field(60; "Checkoff Product"; Boolean)
        {
        }
        field(61; "Unsecured Product"; Boolean)
        {
        }
        field(62; "Repayment Cutoff Date"; Integer)
        {
        }
        field(63; "Print Sequence"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(64; "Hide on Statement"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(65; "Loan Recovery Priority"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(66; Blocked; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(67; "Mode of Disbursement"; Enum "Mode of Disbursement")
        {
        }
        field(68; "Disbursement Account"; Code[20])
        {
            TableRelation = if ("Mode of Disbursement" = const(BOSA)) "G/L Account" where(Blocked = const(false), "Account Type" = const(Posting), "Account Category" = const(Liabilities));
        }
        field(69; "Dividend Based"; Boolean)
        {
        }
        field(70; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(Key2; Category, Indentation)
        {
        }
    }
    var
        LoansManagement: Codeunit "Loans Management";
        SaccoProducts: array[3] of Record "Sacco Products";
        ProductsCategories: Record "Sacco Product Categories";
        PageManagement: Codeunit "Page Management";

    trigger OnDelete()
    begin
        SaccoProducts[3].Reset();
        SaccoProducts[3].SetFilter(Code, '<>%1', Code);
        SaccoProducts[3].SetRange(Category, Code);
        if SaccoProducts[3].FindSet then begin
            repeat
                SaccoProducts[3].Validate(Category, '');
                SaccoProducts[3].Modify(true);
            until SaccoProducts[3].Next = 0;
        end;
    end;

    procedure ShowRecord()
    var
        RecRef: RecordRef;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then exit;
        if not RecRef.Get(Rec.RecordId) then exit;
        RecRef.SetRecFilter();
        PageManagement.PageRun(RecRef);
    end;
}
