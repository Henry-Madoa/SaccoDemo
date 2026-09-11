table 52203440 "Payment Voucher Lines"
{
    DrillDownPageID = "Payment Voucher Lines";
    LookupPageID = "Payment Voucher Lines";

    fields
    {
        field(1; "No."; Code[20])
        {
            TableRelation = "Payment Voucher";

            trigger OnValidate()
            begin
                if Header.Get("No.")then begin
                    Validate("Payment Type", Header."Payment Type");
                    "Global Dimension 1 Code":=Header."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=Header."Global Dimension 2 Code";
                    Description:=Header.Description;
                end;
            end;
        }
        field(2; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(3; Date; Date)
        {
        }
        field(4; "Account Type";Enum "Gen. Journal Account Type")
        {
            Editable = false;
        }
        field(5; "Account No"; Code[20])
        {
            TableRelation = if("Payment Type"=const("Supplier Payment"))Vendor where("Account Type"=filter(Supplier))
            else if("Payment Type"=const("Customer Refund"))Customer
            else if("Payment Type"=const("Bank Transfer"))"Bank Account" where(Blocked=const(false))
            else if("Payment Type"=const("Employee Payment"))Employee where(Status=const(Active))
            else if("Payment Type"=filter("Direct Expensing"|"Board Allowances"|"Staff Bulk Payment"))"G/L Account" where("Account Type"=const(Posting), "Direct Posting"=const(true))
            else if("Payment Type"=filter("Payroll Settlement"|Remittance))"G/L Account" where("Account Type"=const(Posting), "Direct Posting"=const(true), "Account Category"=const(Liabilities));

            trigger OnValidate()
            var
                Text000: Label 'Please make sure the Payment Details have been set on Vendor Card!';
                Text001: Label 'Vendor No.: %1, SLA Validity Status is invalid, kindly contact Admin Dept to update the vendor card.';
                Text002: Label 'Vendor No.: %1, classification can not be empty in the vendor card.';
                Text003: Label 'Vendor No.: %1, SLA Validity Status is Expired, kindly contact Admin Dept to update the vendor card.';
                Text004: Label 'Vendor No.: %1, SLA Validity Status is Terminated, kindly contact Admin Dept to update the vendor card.';
            begin
                case "Payment Type" of "Payment Type"::"Direct Expensing", "Payment Type"::"Payroll Settlement", "Payment Type"::"Board Allowances", "Payment Type"::"Staff Bulk Payment", "Payment Type"::Remittance: begin
                    if GLAccount.Get("Account No")then begin
                        if Rec."Payment Type" = Rec."Payment Type"::Remittance then begin
                            GLAccount.TestField("Account Category", GLAccount."Account Category"::Liabilities);
                            GLAccount.CalcFields(Balance);
                            if GLAccount.Balance < 0 then Validate(Amount, Abs(GLAccount.Balance))
                            else
                                Validate(Amount, GLAccount.Balance);
                        end;
                        if Rec."Payment Type" = Rec."Payment Type"::"Payroll Settlement" then begin
                            GLAccount.TestField("Account Category", GLAccount."Account Category"::Liabilities);
                            CashMgmt.GeneratePayrollPaymentSchedule(Rec);
                        end;
                        "Account No":=GLAccount."No.";
                        Validate("Account Name", GLAccount.Name);
                    end;
                end;
                "Payment Type"::"Customer Refund": begin
                    if Customer.Get("Account No")then Validate("Account Name", Customer.Name);
                end;
                "Payment Type"::"Supplier Payment": begin
                    Vendor.Get("Account No");
                    Validate("Account Name", Vendor.Name);
                    PayeeBankDetails.Reset();
                    PayeeBankDetails.SetRange("Vendor No", Vendor."No.");
                    PayeeBankDetails.SetRange(Active, true);
                    if PayeeBankDetails.FindFirst()then begin
                        Validate(Payee, PayeeBankDetails."Beneficiary Name");
                        Validate("Payee Bank Code", PayeeBankDetails."Bank Code");
                        Validate("Payee Bank Branch Code", PayeeBankDetails."Branch Code");
                        "Payee Account No.":=PayeeBankDetails."Bank Account Number";
                    end;
                end;
                "Payment Type"::"Bank Transfer": begin
                    BankAccount.Get("Account No");
                    Validate("Account Name", BankAccount.Name);
                end;
                "Payment Type"::"Employee Payment": begin
                    Employee.Get("Account No");
                    Validate("Account Name", Employee.FullName);
                end;
                end;
            end;
        }
        field(6; "Account Name"; Text[100])
        {
            Editable = false;

            trigger OnValidate()
            begin
                if "Account Type" = "Account Type"::Vendor then begin
                    If Header.Get("No.")then begin
                        Header."Vendor No":="Account No";
                        Header.Modify(true);
                    end;
                end
                else
                begin
                    If Header.Get("No.")then begin
                        Header."Vendor No":='';
                        Header.Modify(true);
                    end;
                end;
                Validate(Amount);
            end;
        }
        field(7; Description; Text[250])
        {
            Caption = 'Narration';
        }
        field(8; Amount; Decimal)
        {
            Editable = true;
            Caption = 'Amount To Be Paid';

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
                GenLedSetup: Record "General Ledger Setup";
                BudgetAmount: Decimal;
                Expenses: Decimal;
                BudgetAvailable: Decimal;
                Committments: Record "Commitment Entries";
                CommittedAmount: Decimal;
                CommitmentEntries: Record "Commitment Entries";
                PVHeader: Record "Payment Voucher";
                TotalCommittedAmount: Decimal;
            begin
                if(Rec."Payment Type" <> Rec."Payment Type"::"Supplier Payment")then "Net Amount":=Amount;
                GLSetup.Get;
                GLSetup.TestField("Rounding Type");
                GLSetup.TestField("Amount Rounding Precision");
                if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Up then Direction:='>'
                else if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Nearest then Direction:='='
                    else if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Down then Direction:='<';
                case "Account Type" of "Account Type"::"G/L Account": begin
                    if "VAT Code" <> '' then begin
                        if GLAccount.Get("Account No")then if VATSetup.Get(GLAccount."VAT Bus. Posting Group", "VAT Code")then begin
                                if VATSetup."VAT %" <> 0 then begin
                                    if "Purchase Invoice Amount" <> 0 then begin
                                        VATAmount:=Round(("Purchase Invoice Amount" / (1 + VATSetup."VAT %" / 100) * VATSetup."VAT %" / 100), 1, '>');
                                        NetAmount:="Purchase Invoice Amount" - VATAmount;
                                    end
                                    else
                                    begin
                                        VATAmount:=Round((Amount / (1 + VATSetup."VAT %" / 100) * VATSetup."VAT %" / 100), 1, '>');
                                        NetAmount:=Amount - VATAmount;
                                    end;
                                end
                                else if "Purchase Invoice Amount" <> 0 then NetAmount:="Purchase Invoice Amount"
                                    else
                                        NetAmount:=Amount;
                                "VAT Amount":=VATAmount;
                                //Check IF VAT is to be posted
                                if GLSetup."Post VAT" then "Net Amount":=Amount - VATAmount
                                else
                                    "Net Amount":=Amount;
                                //Withholding Tax Calculations
                                if "WHT Code One" <> '' then begin
                                    if GLAccount.Get("Account No")then if VATSetup.Get(GLAccount."VAT Bus. Posting Group", "WHT Code One")then begin
                                            if VATSetup."VAT %" <> 0 then WHTAmountOne:=Round(NetAmount * VATSetup."VAT %" / 100, 1, '>')
                                            else
                                                WHTAmountOne:=0;
                                            "WHT Amount One":=WHTAmountOne;
                                            //Check IF VAT is to be posted
                                            if GLSetup."Post VAT" then "Net Amount":=NetAmount
                                            else
                                                "Net Amount":=Amount - "WHT Amount One";
                                        end
                                        else
                                            Error(StrSubstNo('There is no VAT Posting Setup For %1 and %2, kindly contact admin for the setup to be done', GLAccount."VAT Bus. Posting Group", "WHT Code One"));
                                end;
                            end
                            else
                                Error(StrSubstNo('There is no VAT Posting Setup For %1 and %2, kindly contact admin for the setup to be done', GLAccount."VAT Bus. Posting Group", "VAT Code"));
                    end;
                end;
                "Account Type"::Customer: begin
                    if "VAT Code" <> '' then begin
                        if Customer.Get("Account No")then if VATSetup.Get(Customer."VAT Bus. Posting Group", "VAT Code")then begin
                                if VATSetup."VAT %" <> 0 then begin
                                    if "Purchase Invoice Amount" <> 0 then begin
                                        VATAmount:=Round(("Purchase Invoice Amount" / (1 + VATSetup."VAT %" / 100) * VATSetup."VAT %" / 100), 1, '>');
                                        NetAmount:="Purchase Invoice Amount" - VATAmount;
                                    end
                                    else
                                    begin
                                        VATAmount:=Round((Amount / (1 + VATSetup."VAT %" / 100) * VATSetup."VAT %" / 100), 1, '>');
                                        NetAmount:=Amount - VATAmount;
                                    end;
                                end
                                else if "Purchase Invoice Amount" <> 0 then NetAmount:="Purchase Invoice Amount"
                                    else
                                        NetAmount:=Amount;
                                "VAT Amount":=VATAmount;
                                //Check IF VAT is to be posted
                                if GLSetup."Post VAT" then "Net Amount":=Amount - VATAmount
                                else
                                    "Net Amount":=Amount;
                                //Withholding Tax Calculations
                                if "WHT Code One" <> '' then begin
                                    if Customer.Get("Account No")then if VATSetup.Get(Customer."VAT Bus. Posting Group", "WHT Code One")then begin
                                            WHTAmountOne:=Round(NetAmount * VATSetup."VAT %" / 100, 1, '>');
                                            "WHT Amount One":=WHTAmountOne;
                                            //Check IF VAT is to be posted
                                            if GLSetup."Post VAT" then "Net Amount":=NetAmount
                                            else
                                                "Net Amount":=Amount - "WHT Amount One";
                                        end
                                        else
                                            Error(StrSubstNo('There is no VAT Posting Setup For %1 and %2, kindly contact admin for the setup to be done', Vendor."VAT Bus. Posting Group", "WHT Code One"));
                                end;
                            end
                            else
                                Error(StrSubstNo('There is no VAT Posting Setup For %1 and %2, kindly contact admin for the setup to be done', Vendor."VAT Bus. Posting Group", "VAT Code"));
                    end;
                end;
                "Account Type"::Vendor: begin
                    if "VAT Code" <> '' then begin
                        if Vendor.Get("Account No")then if VATSetup.Get(Vendor."VAT Bus. Posting Group", "VAT Code")then begin
                                if VATSetup."VAT %" <> 0 then begin
                                    VATAmount:=Round((Amount / (1 + VATSetup."VAT %" / 100) * VATSetup."VAT %" / 100), GenLedSetup."Amount Rounding Precision", Direction);
                                    NetAmount:=Amount - VATAmount;
                                end
                                else
                                    NetAmount:=Amount;
                                "VAT Amount":=VATAmount;
                                //Check IF VAT is to be posted
                                if GLSetup."Post VAT" then "Net Amount":=Amount - VATAmount
                                else
                                    "Net Amount":=Amount;
                                //Withholding Tax Calculations
                                if "WHT Code One" <> '' then begin
                                    if Vendor.Get("Account No")then if VATSetup.Get(Vendor."VAT Bus. Posting Group", "WHT Code One")then begin
                                            WHTAmountOne:=Round(NetAmount * VATSetup."VAT %" / 100, 1, '>');
                                            "WHT Amount One":=WHTAmountOne;
                                            //Check IF VAT is to be posted
                                            if GLSetup."Post VAT" then "Net Amount":=NetAmount
                                            else
                                                "Net Amount":=Amount - "WHT Amount One" - "WHT Amount Two";
                                        end
                                        else
                                            Error(StrSubstNo('There is no VAT Posting Setup For %1 and %2, kindly contact admin for the setup to be done', Vendor."VAT Bus. Posting Group", "WHT Code One"));
                                end;
                                if "WHT Code Two" <> '' then begin
                                    if Vendor.Get("Account No")then if VATSetup.Get(Vendor."VAT Bus. Posting Group", "WHT Code Two")then begin
                                            WHTAmountTwo:=Round(NetAmount * VATSetup."VAT %" / 100, 1, '>');
                                            "WHT Amount Two":=WHTAmountTwo;
                                            //Check IF VAT is to be posted
                                            if GLSetup."Post VAT" then "Net Amount":=NetAmount
                                            else
                                                "Net Amount":=Amount - "WHT Amount One" - "WHT Amount Two";
                                        end
                                        else
                                            Error(StrSubstNo('There is no VAT Posting Setup For %1 and %2, kindly contact admin for the setup to be done', Vendor."VAT Bus. Posting Group", "WHT Code One"));
                                end;
                            end
                            else
                                Error(StrSubstNo('There is no VAT Posting Setup For %1 and %2, kindly contact admin for the setup to be done', Vendor."VAT Bus. Posting Group", "VAT Code"));
                    end;
                end;
                "Account Type"::"Bank Account": "Net Amount":=Amount;
                end;
                if Amount < 0 then Error('Amount cannot be less than Zero');
            end;
        }
        field(9; "Scheduled Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Payment Schedule".Amount where("PV No."=field("No."), "PV Line No."=field("Line No")));
        }
        field(10; "Net Allowance Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Payment Schedule"."Net Allowance Amount" where("PV No."=field("No."), "PV Line No."=field("Line No")));
        }
        field(11; Posted; Boolean)
        {
        }
        field(12; "Posted Date"; Date)
        {
        }
        field(13; "Posted Time"; Time)
        {
        }
        field(14; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
            Editable = false;
        }
        field(15; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
            Editable = false;
        }
        field(16; "Applies to Doc. No"; Code[20])
        {
            trigger OnLookup()
            begin
                "Applies to Doc. No":='';
                Amt:=0;
                VATAmount:=0;
                WHTAmountOne:=0;
                "Excise/TAmount":=0;
                case "Account Type" of "Account Type"::Customer: begin
                    CustLedger.Reset;
                    CustLedger.SetCurrentKey(CustLedger."Customer No.", Open, "Document No.");
                    CustLedger.SetRange(CustLedger."Customer No.", "Account No");
                    CustLedger.SetRange(Open, true);
                    CustLedger.CalcFields(CustLedger.Amount);
                    if PAGE.RunModal(Page::"Customer Ledger Entries", CustLedger) = ACTION::LookupOK then begin
                        if CustLedger."Applies-to ID" <> '' then begin
                            CustLedger1.Reset;
                            CustLedger1.SetCurrentKey(CustLedger1."Customer No.", Open, "Applies-to ID");
                            CustLedger1.SetRange(CustLedger1."Customer No.", "Account No");
                            CustLedger1.SetRange(Open, true);
                            CustLedger1.SetRange("Applies-to ID", CustLedger."Applies-to ID");
                            if CustLedger1.Find('-')then begin
                                repeat CustLedger1.CalcFields(CustLedger1.Amount);
                                    Amt:=Amt + Abs(CustLedger1.Amount);
                                until CustLedger1.Next = 0;
                            end;
                            if Amt <> Amt then //ERROR('Amount is not equal to the amount applied on the application form');
 if Amount = 0 then Amount:=Amt;
                            Validate(Amount);
                            "Applies to Doc. No":=CustLedger."Document No.";
                            Description:=CustLedger.Description;
                            Validate("Currency Code", CustLedger."Currency Code");
                            "Global Dimension 1 Code":=CustLedger."Global Dimension 1 Code";
                            "Global Dimension 2 Code":=CustLedger."Global Dimension 2 Code";
                        end
                        else
                        begin
                            if Amount <> Abs(CustLedger.Amount)then CustLedger.CalcFields(CustLedger."Remaining Amount");
                            if Amount = 0 then Amount:=Abs(CustLedger."Remaining Amount");
                            Validate(Amount);
                            "Applies to Doc. No":=CustLedger."Document No.";
                            Description:=CustLedger.Description;
                            "Global Dimension 1 Code":=CustLedger."Global Dimension 1 Code";
                            "Global Dimension 2 Code":=CustLedger."Global Dimension 2 Code";
                        end;
                    end;
                    Validate(Amount);
                end;
                "Account Type"::Vendor: begin
                    VendLedger.Reset;
                    VendLedger.SetCurrentKey(VendLedger."Vendor No.", Open, "Document No.");
                    VendLedger.SetRange(VendLedger."Vendor No.", "Account No");
                    VendLedger.SetRange("Document Type", VendLedger."Document Type"::Invoice);
                    VendLedger.SetRange(Open, true);
                    VendLedger.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
                    if PAGE.RunModal(Page::"Vendor Ledger Entries", VendLedger) = ACTION::LookupOK then begin
                        if VendLedger."Applies-to ID" <> '' then begin
                            VendLedger1.Reset;
                            VendLedger1.SetCurrentKey(VendLedger1."Vendor No.", Open, "Applies-to ID");
                            VendLedger1.SetRange(VendLedger1."Vendor No.", "Account No");
                            VendLedger1.SetRange(Open, true);
                            VendLedger1.SetRange(VendLedger1."Applies-to ID", VendLedger."Applies-to ID");
                            if VendLedger1.Find('-')then begin
                                repeat VendLedger1.CalcFields(VendLedger1."Remaining Amount");
                                    NetAmount:=NetAmount + Abs(VendLedger1."Remaining Amount");
                                until VendLedger1.Next = 0;
                                if Amount <> Amount then //ERROR('Amount is not equal to the amount applied on the application form');
 if Amount = 0 then Amount:=Amount;
                                Validate(Amount);
                                "Applies to Doc. No":=VendLedger."Document No.";
                                Description:=VendLedger.Description;
                                Validate("Currency Code", VendLedger."Currency Code");
                                "Global Dimension 1 Code":=VendLedger."Global Dimension 1 Code";
                                "Global Dimension 2 Code":=VendLedger."Global Dimension 2 Code";
                            end
                            else
                            begin
                                if Amount <> Abs(VendLedger."Remaining Amount")then VendLedger.CalcFields(VendLedger."Remaining Amount", VendLedger."Remaining Amt. (LCY)");
                                if Amount = 0 then Amount:=Abs(VendLedger."Remaining Amount");
                                "Applied Amount LCY":=Abs(VendLedger."Remaining Amt. (LCY)");
                                //"Purchase Invoice Amount" := Amount;
                                Validate(Amount);
                                "Applies to Doc. No":=VendLedger."Document No.";
                                Description:=VendLedger.Description;
                                Validate("Currency Code", VendLedger."Currency Code");
                                "Global Dimension 1 Code":=VendLedger."Global Dimension 1 Code";
                                "Global Dimension 2 Code":=VendLedger."Global Dimension 2 Code";
                            end;
                        end;
                        DocumentAttachment[1].Reset();
                        DocumentAttachment[1].SetRange("Table ID", Database::"Purch. Inv. Header");
                        DocumentAttachment[1].SetRange("No.", VendLedger."Document No.");
                        if DocumentAttachment[1].FindSet()then begin
                            repeat DocumentAttachment[2].Reset();
                                DocumentAttachment[2].SetRange("Table ID", Database::"Payment Voucher");
                                DocumentAttachment[2].SetRange("No.", Rec."No.");
                                DocumentAttachment[2].SetRange("File Name", DocumentAttachment[1]."File Name");
                                DocumentAttachment[2].SetRange("File Type", DocumentAttachment[1]."File Type");
                                DocumentAttachment[2].SetRange("File Extension", DocumentAttachment[1]."File Extension");
                                if not DocumentAttachment[2].FindFirst then begin
                                    DocumentAttachment[3].Init();
                                    DocumentAttachment[3].TransferFields(DocumentAttachment[1]);
                                    DocumentAttachment[3]."Table ID":=Database::"Payment Voucher";
                                    DocumentAttachment[3]."No.":=Rec."No.";
                                    DocumentAttachment[3].Insert(true);
                                end;
                            until DocumentAttachment[1].Next() = 0;
                        end;
                        "Applies to Doc. No":=VendLedger."Document No.";
                        Amount:=Abs(VendLedger."Remaining Amount");
                        "Currency Code":=VendLedger."Currency Code";
                        "Applied Amount LCY":=Abs(VendLedger."Remaining Amt. (LCY)");
                        Validate(Amount);
                        Description:=VendLedger.Description;
                        Validate("Currency Code", VendLedger."Currency Code");
                        "Global Dimension 1 Code":=VendLedger."Global Dimension 1 Code";
                        "Global Dimension 2 Code":=VendLedger."Global Dimension 2 Code";
                    end;
                end;
                end;
            end;
            trigger OnValidate()
            begin
                PVLines.Reset();
                PVLines.SetRange("Applies to Doc. No", "Applies to Doc. No");
                if PVLines.FindSet then begin
                    PVLines.CalcSums("VAT Amount", "WHT Amount One");
                    "VAT Already Charged":=PVLines."VAT Amount";
                    "W\Tax Already Charged":=PVLines."WHT Amount One";
                end;
            end;
        }
        field(17; "VAT Code"; Code[20])
        {
            TableRelation = "VAT Product Posting Group" where(Type=const(VAT));

            trigger OnValidate()
            begin
                if "VAT Code" = '' then "VAT Amount":=0;
                Validate(Amount);
            end;
        }
        field(18; "WHT Code One"; Code[20])
        {
            TableRelation = "VAT Product Posting Group" where(Type=const(WHT));

            trigger OnValidate()
            begin
                Rec.Testfield("VAT Code");
                if "WHT Code One" = '' then "WHT Amount One":=0;
                Validate(Amount);
            end;
        }
        field(19; "WHT Code Two"; Code[20])
        {
            TableRelation = "VAT Product Posting Group" where(Type=const(WHT));

            trigger OnValidate()
            begin
                Rec.Testfield("VAT Code");
                if "WHT Code Two" = '' then "WHT Amount Two":=0;
                Validate(Amount);
            end;
        }
        field(20; "Retention Code"; Code[20])
        {
        }
        field(21; "VAT Amount"; Decimal)
        {
            Editable = false;
        }
        field(22; "WHT Amount One"; Decimal)
        {
            Editable = false;
        }
        field(23; "WHT Amount Two"; Decimal)
        {
            Editable = false;
        }
        field(24; "Retention Amount"; Decimal)
        {
        }
        field(25; "Net Amount"; Decimal)
        {
            Editable = false;
        }
        field(26; "Exchange Rate"; Decimal)
        {
            trigger OnValidate()
            begin
                GLSetup.Get;
                GLSetup.TestField("Rounding Type");
                GLSetup.TestField("Amount Rounding Precision");
                if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Up then Direction:='>'
                else if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Nearest then Direction:='='
                    else if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Down then Direction:='<';
                "Amount LCY":=Round(Amount * "Exchange Rate", GLSetup."Amount Rounding Precision", Direction);
                if "Applied Amount LCY" = 0 then "Applied Amount LCY":="Amount LCY";
                if "Applied Amount LCY" <> 0 then "Exchange Rate Gain/Loss":="Amount LCY" - "Applied Amount LCY"
                else
                    "Exchange Rate Gain/Loss":=0;
            end;
        }
        field(27; "Currency Code"; Code[10])
        {
            TableRelation = Currency;

            trigger OnValidate()
            begin
                if Header.Get("No.")then begin
                    Header.Currency:="Currency Code";
                    Header.Modify;
                end;
            end;
        }
        field(28; "Applied Amount LCY"; Decimal)
        {
        }
        field(29; "Exchange Rate Gain/Loss"; Decimal)
        {
        }
        field(30; "Amount LCY"; Decimal)
        {
        }
        field(31; "M-Pesa Phone No."; Code[15])
        {
            trigger OnValidate()
            begin
                if CopyStr("M-Pesa Phone No.", 1, 3) <> '234' then Error('The M-Pesa Phone Number must start with 234...');
            end;
        }
        field(32; "Payee Bank Code"; Code[10])
        {
            TableRelation = "External Banks";

            trigger OnValidate()
            begin
                if CommercialBanks.Get("Payee Bank Code")then begin
                    "Payee Bank Name":=CommercialBanks."Bank Name";
                end;
            end;
        }
        field(33; "Payee Bank Branch Code"; Code[10])
        {
            TableRelation = "External Bank Branches"."Branch Code" where("Bank Code"=field("Payee Bank Code"));

            trigger OnValidate()
            begin
                if CommercialBankBranches.Get("Payee Bank Branch Code", "Payee Bank Code")then begin
                    "Payee Bank Branch Name":=CommercialBankBranches."Branch Name";
                end;
            end;
        }
        field(34; "Payee Bank Branch Name"; Text[80])
        {
            Editable = false;
        }
        field(35; "Payment Type";Enum "Payment Types")
        {
            trigger OnValidate()
            begin
                if((Rec."Payment Type" = Rec."Payment Type"::"Supplier Payment"))then Validate("Account Type", "Account Type"::Vendor)
                else if Rec."Payment Type" = Rec."Payment Type"::"Petty Cash Topup" then Validate("Account Type", "Account Type"::"Bank Account")
                    else if Rec."Payment Type" = Rec."Payment Type"::"Employee Payment" then Validate("Account Type", "Account Type"::Employee)
                        else if Rec."Payment Type" = Rec."Payment Type"::"Customer Refund" then Validate("Account Type", "Account Type"::Customer)
                            else if Rec."Payment Type" = Rec."Payment Type"::"Bank Transfer" then Validate("Account Type", "Account Type"::"Bank Account")
                                else if Rec."Payment Type" in[Rec."Payment Type"::"Direct Expensing", Rec."Payment Type"::Remittance, Rec."Payment Type"::"Staff Bulk Payment"]then Validate("Account Type", "Account Type"::"G/L Account");
            end;
        }
        field(36; "Payee Type"; Option)
        {
            OptionMembers = " ", Vendor, Staff;
            OptionCaption = ' ,Vendor,Staff';
        }
        field(37; "Vend/Staff No."; Code[20])
        {
            TableRelation = if("Payee Type"=const(Vendor))Vendor
            else if("Payee Type"=const(Staff))Employee where(Status=const(Active), "Bank Account No."=filter(<>''));

            trigger OnValidate()
            begin
                if "Payee Type" = "Payee Type"::Vendor then begin
                    BankDetails.Reset;
                    BankDetails.SetRange("Ben ID", "Vend/Staff No.");
                    BankDetails.SetRange(Active, true);
                    if BankDetails.FindFirst()then begin
                        Validate(Payee, BankDetails."Beneficiary Name");
                        Validate("Payee Bank Code", BankDetails."Bank Code");
                        "Payee Account No.":=BankDetails."Bank Account Number";
                    end
                    else
                        Error('There is no active Payee Bank details');
                end;
                if "Payee Type" = "Payee Type"::Staff then begin
                    if Employee.Get("Vend/Staff No.")then begin
                        Employee.Get("Vend/Staff No.");
                        Validate(Payee, Employee.FullName);
                        Validate("Payee Bank Code", Employee."Bank Code");
                        "Payee Account No.":=Employee."Bank Account No.";
                    end;
                end;
            end;
        }
        field(38; "Payee Bank Name"; Text[30])
        {
        }
        field(39; Payee; Text[100])
        {
            trigger OnValidate()
            begin
                "Payee Account Name":=Payee;
            end;
            trigger OnLookup()
            begin
                if Rec."Payment Type" = Rec."Payment Type"::"Supplier Payment" then begin
                    BankDetails.Reset();
                    BankDetails.SetRange("Ben ID", "Account No");
                    if BankDetails.FindSet()then begin
                        if Page.RunModal(Page::"Payee Bank Details", BankDetails) = Action::LookupOK then begin
                            Validate(Payee, BankDetails."Beneficiary Name");
                            Validate("Payee Bank Code", BankDetails."Bank Code");
                            Validate("Payee Bank Branch Code", BankDetails."Branch Code");
                            "Payee Account No.":=BankDetails."Bank Account Number";
                        end;
                    end;
                end;
                if((Rec."Payment Type" = Rec."Payment Type"::"Direct Expensing") and ("Payee Type" = "Payee Type"::Vendor))then begin
                    BankDetails.Reset();
                    BankDetails.SetRange("Ben ID", "Vend/Staff No.");
                    if BankDetails.FindSet()then begin
                        if Page.RunModal(Page::"Payee Bank Details", BankDetails) = Action::LookupOK then begin
                            Validate(Payee, BankDetails."Beneficiary Name");
                            Validate("Payee Bank Code", BankDetails."Bank Code");
                            Validate("Payee Bank Branch Code", BankDetails."Branch Code");
                            "Payee Account No.":=BankDetails."Bank Account Number";
                        end;
                    end;
                end;
            end;
        }
        field(40; "Payee Account No."; Code[20])
        {
        }
        field(41; "Payee Account Name"; Text[100])
        {
        }
        field(42; "Global Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(43; "Global Dimension 4 Code"; Code[20])
        {
            CaptionClass = '1,2,4';
            Caption = 'Global Dimension 4 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(4), Blocked=const(false));
        }
        field(44; "Global Dimension 5 Code"; Code[20])
        {
            CaptionClass = '1,2,5';
            Caption = 'Global Dimension 5 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(5), Blocked=const(false));
        }
        field(45; "Cost Centre"; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(46; Uncommitted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(47; Surrendered; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(48; "Purchase Invoice Amount"; Decimal)
        {
            Editable = false;
        }
        field(49; "Outstanding Amount"; Decimal)
        {
            Editable = false;
        }
        field(50; "VAT Already Charged"; Decimal)
        {
        }
        field(51; "W\Tax Already Charged"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "No.", "Line No")
        {
            Clustered = true;
            SumIndexFields = "Net Amount", "VAT Amount", "WHT Amount One";
        }
        key(Key2; "Line No")
        {
            SumIndexFields = "Net Amount", "VAT Amount", "WHT Amount One";
        }
    }
    trigger OnDelete()
    begin
        if Header.Get("No.")then Header.TestField(Status, Header.Status::Open);
    end;
    trigger OnModify()
    begin
        if Header.Get("No.")then Header.TestField(Posted, false);
    end;
    var GLAccount: Record "G/L Account";
    Customer: Record Customer;
    Vendor: Record Vendor;
    BankAccount: Record "Bank Account";
    Employee: Record Employee;
    VATAmount: Decimal;
    WHTAmountOne: Decimal;
    WHTAmountTwo: Decimal;
    "Excise/TAmount": Decimal;
    NetAmount: Decimal;
    VATSetup: Record "VAT Posting Setup";
    CustLedger: Record "Cust. Ledger Entry";
    CustLedger1: Record "Cust. Ledger Entry";
    VendLedger: Record "Vendor Ledger Entry";
    VendLedger1: Record "Vendor Ledger Entry";
    Amt: Decimal;
    GLSetup: Record "General Ledger Setup";
    Direction: Text[30];
    Header: Record "Payment Voucher";
    CommercialBanks: Record "External Banks";
    CommercialBankBranches: Record "External Bank Branches";
    BankDetails: Record "Payee Bank Details";
    PVLines: Record "Payment Voucher Lines";
    DocumentAttachment: array[3]of Record "Document Attachment";
    PayeeBankDetails: Record "Payee Bank Details";
    CashMgmt: Codeunit "Cash Management";
}
