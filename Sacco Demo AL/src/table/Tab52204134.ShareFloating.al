table 52204134 "Share Floating"
{
    DataCaptionFields = "Document No", "Member No.", "Member Name";
    DrillDownPageID = "Floated Shares";
    LookupPageID = "Floated Shares";

    fields
    {
        field(1; "Document No"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(2; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members;

            trigger OnValidate()
            begin
                if Members.Get("Member No.") then begin
                    "Member Name" := Members."Full Name";
                    "Global Dimension 1 Code" := Members."Global Dimension 1 Code";
                    Members.CalcFields("Total Shares");
                    "Total Shares" := Members."Total Shares" / "Par Value";
                    "Account No." := MemberMgmt.GetMemberAccount("Member No.", ProductPostingType::"Share Trading Account");
                end;
                CategoryChecklist.Reset;
                CategoryChecklist.SetRange("Source Code", "Share Type");
                CategoryChecklist.SetRange("Application Area", CategoryChecklist."Application Area"::"Share Transfer");
                if CategoryChecklist.FindFirst then begin
                    repeat
                        MemberRegistrationChecklist.Init;
                        MemberRegistrationChecklist."Source Code" := "Document No";
                        MemberRegistrationChecklist."Document No." := CategoryChecklist."Document No.";
                        MemberRegistrationChecklist.Description := CategoryChecklist.Description;
                        MemberRegistrationChecklist.Mandatory := CategoryChecklist.Mandatory;
                        MemberRegistrationChecklist."Application Area" := MemberRegistrationChecklist."Application Area"::"Share Transfer";
                        Ok := MemberRegistrationChecklist.Insert;
                    until CategoryChecklist.Next = 0;
                end;
                Validate("Share Type");
                Validate("Charge Amount");
            end;
        }
        field(3; "Member Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(4; "Share Type"; Code[20])
        {
            Editable = false;
            DataClassification = ToBeClassified;
            TableRelation = "Share Trading Setup"."Document No." WHERE(Status = CONST(Published));

            trigger OnValidate()
            begin
                if ShareTradingSetup.Get("Share Type") then begin
                    "Par Value" := ShareTradingSetup."Base Price";
                    Validate("Account No.");
                    //"Global Dimension 2 Code" := ShareTradingSetup."Document No.";
                    "Reserve Price" := ShareTradingSetup."Reserve Price";
                    "Share Life" := ShareTradingSetup."Share Life";
                    "On No Bid" := ShareTradingSetup."On No Bid";
                    "Tolerance Period" := ShareTradingSetup."Tolerance Period";
                end;
                // if "Float Type" = "Float Type"::Full then
                //     "Minimum Balance" := 0;
                Validate("Total Shares");
                if "Float Type" = "Float Type"::Full then Validate("Shares to Float", "Total Shares");
                Validate("Charge Amount");
            end;
        }
        field(6; "Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Par Value"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(8; "Total Shares"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "Minimum Acceptable Price"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Minimum Acceptable Price" > "Par Value" then Error('You Cannot go Higher Than %1', "Par Value");
                if "Minimum Acceptable Price" < "Reserve Price" then Error('You Cannot go Lowe then %1', "Reserve Price");
            end;
        }
        field(10; "Shares to Float"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Shares to Float" > "Total Shares" then Error('You Can Only Float upto %1', "Total Shares");
                Validate("Floated Value");
                Validate("Charge Amount");
            end;
        }
        field(13; "Current Balance"; Decimal)
        {
            CalcFormula = - Sum("Detailed Vendor Ledg. Entry".Amount WHERE("Vendor No." = FIELD("Account No.")));
            Editable = true;
            FieldClass = FlowField;
        }
        field(14; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = ToBeClassified;
            Editable = true;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(15; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = ToBeClassified;
            Editable = true;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(16; Published; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(17; "Maximum Bid Price"; Decimal)
        {
            CalcFormula = Max("Share Trading Lines"."Bid Price" WHERE("Document No." = FIELD("Document No")));
            Editable = true;
            FieldClass = FlowField;
        }
        field(18; "Payment Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Bank Deposit,FOSA Deposit';
            OptionMembers = "Bank Deposit","FOSA Deposit";
        }
        field(19; "Payment Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF ("Payment Type" = CONST("Bank Deposit")) "Bank Account"."No."
            ELSE IF ("Payment Type" = CONST("FOSA Deposit")) Vendor."No." WHERE("Member No." = FIELD("Member No."), "Product Posting Type" = const("Withdrawable Deposit"));
        }
        field(20; "Payment Method"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payment Method".Code;
        }
        field(21; "External Refrence No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Payment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Payment Amount"; Decimal)
        {
            CalcFormula = Sum("Share Trading Lines"."Total Amount" WHERE("Document No." = FIELD("Document No"), Awarded = CONST(true)));
            Editable = true;
            FieldClass = FlowField;
        }
        field(24; "Proceeds Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF (Proceeds = CONST("FOSA Account")) Vendor."No." WHERE("Member No." = FIELD("Member No."), "Product Posting Type" = CONST("Withdrawable Deposit"))
            ELSE IF (Proceeds = CONST(Cheque)) Vendor."No." WHERE("Account Type" = CONST(Supplier), Blocked = CONST(" "))
            ELSE IF (Proceeds = CONST("NWD Account")) Vendor."No." WHERE("Member No." = FIELD("Member No."), "Product Posting Type" = CONST("Non Withdrawable Deposit"));

            trigger OnValidate()
            begin
                Validate("Member No.");
            end;
        }
        field(25; Archived; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(26; "Floated Value"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = true;

            trigger OnValidate()
            begin
                "Floated Value" := "Par Value" * "Shares to Float";
                If "Float Type" = "Float Type"::Partial then begin
                    SaccoProducts.Reset;
                    SaccoProducts.SetRange("Product Posting Type", SaccoProducts."Product Posting Type"::"Share Capital Account");
                    if SaccoProducts.FindFirst then begin
                        If (("Total Shares" - "Floated Value") < SaccoProducts."Minimum Balance") then Error(StrSubstNo('For Partial Trading you cannot trade beyond Minimum Shares (%1)', SaccoProducts."Minimum Balance"));
                    end;
                end;
            end;
        }
        field(27; Awarded; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Reserve Price"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(29; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = true;
            TableRelation = "User Setup";
        }
        field(30; "Created On"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(31; "Float Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Partial,Full';
            OptionMembers = Partial,Full;

            trigger OnValidate()
            begin
                Validate("Share Type");
            end;
        }
        field(32; "Share Life"; DateFormula)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(33; "On No Bid"; Option)
        {
            DataClassification = ToBeClassified;
            Editable = true;
            OptionCaption = 'Extend,Reverse';
            OptionMembers = Extend,Reverse;
        }
        field(34; "Published On"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(35; "Exiry Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(36; "Charge Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = true;

            trigger OnValidate()
            var
                JournalMgmt: Codeunit "Journal Management";
                TempBase: Decimal;
            begin
                TempBase := "Par Value" * "Shares to Float";
                if ShareTradingSetup.Get("Share Type") then begin
                    "Charge Amount" := JournalMgmt.GetChargesAmount(ShareTradingSetup.Charges, TempBase);
                end;
            end;
        }
        field(37; "Payment Due Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(38; "Purchase Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(39; "Tolerance Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(40; "Minimum Shares To Float"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(41; Status; Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(42; "Approval Loop"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(43; "Action ID"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup";
        }
        field(44; "Approval Level"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(45; Source; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Walking,App,Ussd,Portal';
            OptionMembers = Walking,App,Ussd,Portal;
        }
        field(46; Proceeds; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'FOSA Account,Cheque,NWD Account';
            OptionMembers = "FOSA Account",Cheque,"NWD Account";
        }
        field(47; "Allocated Amount"; Decimal)
        {
            CalcFormula = Sum("Share Transfer Receipt"."Allocated Amount" WHERE("Document No." = FIELD("Document No")));
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(Key1; "Document No")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        GeneralSetup.Get;
        GeneralSetup.TestField("Share Bid Nos.");
        "Document No" := NoSeriesManagement.GetNextNo(GeneralSetup."Share Bid Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CreateDateTime(Today, Time);
        ShareTradingSetup.Reset;
        ShareTradingSetup.SetRange(Published, true);
        if ShareTradingSetup.FindFirst then begin
            "Share Type" := ShareTradingSetup."Document No.";
        end;
    end;

    var
        GeneralSetup: Record "General Ledger Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        Members: Record Members;
        ShareTradingSetup: Record "Share Trading Setup";
        Vendor: Record Vendor;
        SaccoProducts: Record "Sacco Products";
        MemberCategories: Record "Member Categories";
        Ok: Boolean;
        CategoryChecklist: Record "Doc. Attachments Checklist";
        MemberRegistrationChecklist: Record "Doc. Attachments Checklist";
        MemberMgmt: Codeunit "Member Management";
        ProductPostingType: Enum "Product Posting Type";
}
