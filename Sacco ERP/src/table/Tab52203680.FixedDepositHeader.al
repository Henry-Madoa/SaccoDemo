table 52203680 "Fixed Deposit Header"
{
    DataCaptionFields = "No.", "FD Certificate No.", "Investment Institution", Amount;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "FD Certificate No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Rec.Reset;
                Rec.SetFilter("FD Certificate No.", Rec."FD Certificate No.");
                if Rec.FindFirst then Error('You can can use one Certificate Twice');
            end;
        }
        field(3; "Investment Institution"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Debit Account Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Customer,Bank Account,Vendor,G/L Account';
            OptionMembers = Customer, "Bank Account", Vendor, "G/L Account";

            trigger OnValidate()
            begin
                "Debit Account Name":='';
                "Debit Account No.":='';
                Validate("Debit Account No.");
            end;
        }
        field(5; "Debit Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF("Debit Account Type"=CONST(Vendor))Vendor."No." WHERE(Blocked=CONST(" "))
            ELSE IF("Debit Account Type"=CONST("Bank Account"))"Bank Account"."No." WHERE(Blocked=CONST(false), "Currency Code"=CONST(' '))
            ELSE IF("Debit Account Type"=CONST("G/L Account"))"G/L Account"."No." WHERE(Blocked=CONST(false), "Direct Posting"=CONST(true), "Account Type"=CONST(Posting))
            ELSE IF("Debit Account Type"=CONST(Customer))Customer."No." WHERE(Blocked=CONST(" "));

            trigger OnValidate()
            begin
                "Debit Account Name":='';
                case "Debit Account Type" of "Debit Account Type"::"Bank Account": begin
                    if BankAccount.Get("Debit Account No.")then "Debit Account Name":=BankAccount.Name;
                end;
                "Debit Account Type"::Customer: begin
                    if Customer.Get("Debit Account No.")then "Debit Account Name":=Customer.Name;
                end;
                "Debit Account Type"::"G/L Account": begin
                    if GLAccount.Get("Debit Account No.")then "Debit Account Name":=GLAccount.Name;
                end;
                "Debit Account Type"::Vendor: begin
                    if Vendor.Get("Debit Account No.")then "Debit Account Name":=Vendor.Name;
                end;
                end;
            end;
        }
        field(6; "Credit Account Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Customer,Bank Account,Vendor,G/L Account';
            OptionMembers = Customer, "Bank Account", Vendor, "G/L Account";

            trigger OnValidate()
            begin
                "Credit Account Name":='';
                "Credit Account No":='';
                Validate("Credit Account No");
            end;
        }
        field(7; "Credit Account No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF("Credit Account Type"=CONST(Vendor))Vendor."No." WHERE(Blocked=CONST(" "))
            ELSE IF("Credit Account Type"=CONST("Bank Account"))"Bank Account"."No."
            ELSE IF("Credit Account Type"=CONST("G/L Account"))"G/L Account"."No." WHERE(Blocked=CONST(false), "Direct Posting"=CONST(true), "Account Type"=CONST(Posting))
            ELSE IF("Credit Account Type"=CONST(Customer))Customer."No." WHERE(Blocked=CONST(" "));

            trigger OnValidate()
            begin
                "Credit Account Name":='';
                case "Credit Account Type" of "Credit Account Type"::"Bank Account": begin
                    if BankAccount.Get("Credit Account No")then "Credit Account Name":=BankAccount.Name;
                end;
                "Credit Account Type"::Customer: begin
                    if Customer.Get("Credit Account No")then "Credit Account Name":=Customer.Name;
                end;
                "Credit Account Type"::"G/L Account": begin
                    if GLAccount.Get("Credit Account No")then "Credit Account Name":=GLAccount.Name;
                end;
                "Credit Account Type"::Vendor: begin
                    if Vendor.Get("Credit Account No")then "Credit Account Name":=Vendor.Name;
                end;
                end;
                "Investment Institution":="Credit Account Name";
            end;
        }
        field(8; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Investment Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Validate("Maturity Date");
            end;
        }
        field(10; "Investment Period"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Validate("Maturity Date");
            end;
        }
        field(11; "Maturity Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                "Maturity Date":=CalcDate("Investment Period", "Investment Date");
            end;
        }
        field(12; "Negotiated Intrest"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 1: 4;

            trigger OnValidate()
            begin
                if("Negotiated Intrest" < 0) or ("Negotiated Intrest" > 100)then Error('The Negotiated Interest must be between 1 and 100');
            end;
        }
        field(13; Status;Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14; "Created By"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup";
        }
        field(15; "Created On"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(16; "Last Updated By"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup";
        }
        field(17; "last Updated On"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(18; "Debit Account Name"; Text[200])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(19; "Credit Account Name"; Text[200])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Interest Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Reducing Balannce,Straight Line';
            OptionMembers = "Reducing Balannce", "Straight Line";
        }
        field(21; "Interest Receivable Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." WHERE(Blocked=CONST(false), "Direct Posting"=CONST(true));
        }
        field(22; "Interest Received Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." WHERE(Blocked=CONST(false), "Direct Posting"=CONST(true));
        }
        field(23; "W/Tax Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." WHERE(Blocked=CONST(false), "Direct Posting"=CONST(true));
        }
        field(24; "Principle Received"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(25; "Interest Received"; Decimal)
        {
            CalcFormula = Sum("Fixed Deposit Schedule"."Actual Amount" WHERE("Investment No"=FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; "Withholding Tax"; Decimal)
        {
            CalcFormula = Sum("Fixed Deposit Schedule"."Witholding Tax" WHERE("Investment No"=FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(27; "Receiving Account Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Customer,Bank Account,Vendor,G/L Account';
            OptionMembers = Customer, "Bank Account", Vendor, "G/L Account";

            trigger OnValidate()
            begin
                "Debit Account Name":='';
                "Debit Account No.":='';
                Validate("Debit Account No.");
            end;
        }
        field(28; "Receiving Account No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF("Receiving Account Type"=CONST(Vendor))Vendor."No." WHERE(Blocked=CONST(" "))
            ELSE IF("Receiving Account Type"=CONST("Bank Account"))"Bank Account"."No."
            ELSE IF("Receiving Account Type"=CONST("G/L Account"))"G/L Account"."No." WHERE(Blocked=CONST(false), "Direct Posting"=CONST(true), "Account Type"=CONST(Posting))
            ELSE IF("Receiving Account Type"=CONST(Customer))Customer."No." WHERE(Blocked=CONST(" "));

            trigger OnValidate()
            begin
                "Debit Account Name":='';
                case "Debit Account Type" of "Debit Account Type"::"Bank Account": begin
                    if BankAccount.Get("Debit Account No.")then "Debit Account Name":=BankAccount.Name;
                end;
                "Debit Account Type"::Customer: begin
                    if Customer.Get("Debit Account No.")then "Debit Account Name":=Customer.Name;
                end;
                "Debit Account Type"::"G/L Account": begin
                    if GLAccount.Get("Debit Account No.")then "Debit Account Name":=GLAccount.Name;
                end;
                "Debit Account Type"::Vendor: begin
                    if Vendor.Get("Debit Account No.")then "Debit Account Name":=Vendor.Name;
                end;
                end;
            end;
        }
        field(29; "External Document No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Receiving Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(31; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Posted By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Posted On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(34; "Posted at"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Global Dimension 1 Code"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=CONST(false));
        }
        field(36; "Global Dimension 2 Code"; Code[50])
        {
            CaptionClass = '1,1,2';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=CONST(false));
        }
        field(37; "Marked for Liquidation"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(38; Liquidated; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(39; Terminated; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Reason for Termination"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Interest Accrued"; Decimal)
        {
            CalcFormula = Sum("Fixed Deposit Schedule"."Actual Amount" WHERE("Investment No"=FIELD("No."), "Entry Type"=CONST("Interest Due"), Posted=CONST(true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(42; "Estimated Interest to Accrue"; Decimal)
        {
            CalcFormula = Sum("Fixed Deposit Schedule".Amount WHERE("Investment No"=FIELD("No."), "Entry Type"=CONST("Interest Due")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(43; "Investment Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Fixed Deposit,Treasury Bills';
            OptionMembers = " ", "Fixed Deposit", "Treasury Bills";
        }
        field(44; "Face Value"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Rec."Investment Type" = Rec."Investment Type"::"Treasury Bills" then Amount:="Face Value" - "Discount Amount";
            end;
        }
        field(45; "Discount Amount"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Rec."Investment Type" = Rec."Investment Type"::"Treasury Bills" then Amount:="Face Value" - "Discount Amount";
            end;
        }
        field(46; "Investment Posting Group"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Investment Posting Group".Group;

            trigger OnValidate()
            begin
                if InvestmentPostingGroup.Get("Investment Posting Group")then begin
                    Validate("Debit Account No.", InvestmentPostingGroup."Debit Account No.");
                    Validate("Credit Account No", InvestmentPostingGroup."Credit Account No.");
                    Validate("Interest Receivable Account", InvestmentPostingGroup."Interest Receivable Acc.");
                    Validate("Interest Received Account", InvestmentPostingGroup."Interest Received Acc.");
                end;
            end;
        }
        field(47; "Dimension Set ID"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(48; "Rollover No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Investment Group No"."Roll Over No.";
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", "FD Certificate No.", "Investment Institution")
        {
        }
    }
    trigger OnInsert()
    begin
        NGOSetup.Get;
        NGOSetup.TestField("FD No.");
        "No.":=NoSeriesManagement.GetNextNo(NGOSetup."FD No.", Today, true);
        "Created By":=UserId;
        "Last Updated By":=UserId;
        "Created On":=CurrentDateTime;
        "last Updated On":=CurrentDateTime;
        "Interest Type":="Interest Type"::"Straight Line";
    end;
    trigger OnModify()
    begin
        "last Updated On":=CurrentDateTime;
        "Last Updated By":=UserId;
    end;
    var NoSeriesManagement: Codeunit NoSeriesManagement;
    NGOSetup: Record "General Ledger Setup";
    Customer: Record Customer;
    Vendor: Record Vendor;
    BankAccount: Record "Bank Account";
    GLAccount: Record "G/L Account";
    InvestmentPostingGroup: Record "Investment Posting Group";
}
