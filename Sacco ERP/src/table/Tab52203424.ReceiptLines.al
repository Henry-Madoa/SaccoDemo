table 52203424 "Receipt Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if ReceiptHeader.Get("No.")then "Receipt Type":=ReceiptHeader."Receipt Type";
            end;
        }
        field(2; "Line No."; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Receipt Type";Enum "Receipt Type")
        {
        }
        field(5; "Account No"; Code[20])
        {
            TableRelation = if("Receipt Type"=const(Vendor))Vendor
            else if("Receipt Type"=const(Customer))Customer
            else if("Receipt Type"=const(Bank))"Bank Account" where(Blocked=const(false))
            else if("Receipt Type"=const(Employee))Employee where(Status=const(Active))
            else if("Receipt Type"=const("G/L Account"))"G/L Account" where("Direct Posting"=const(true));

            trigger OnValidate()
            begin
                case "Receipt Type" of "Receipt Type"::Vendor: begin
                    if Vendor.Get("Account No")then "Account Name":=Vendor.Name;
                end;
                "Receipt Type"::Bank: begin
                    if Bank.Get("Account No")then "Account Name":=Bank.Name;
                end;
                "Receipt Type"::Customer: begin
                    if Customer.Get("Account No")then "Account Name":=Customer.Name;
                end;
                "Receipt Type"::Employee: begin
                    if Employee.Get("Account No")then "Account Name":=Employee.FullName;
                end;
                "Receipt Type"::"G/L Account": begin
                    if GLAccount.Get("Account No")then "Account Name":=GLAccount.Name;
                end;
                end;
            end;
        }
        field(6; "Account Name"; Text[50])
        {
            Editable = false;
        }
        field(7; Description; Text[250])
        {
        //Editable = false;
        }
        field(10; Amount; Decimal)
        {
            trigger OnValidate()
            begin
                TestField("Account No");
                TestField(Description);
            end;
        }
        field(11; "Loan Balance"; Decimal)
        {
            Editable = false;
        }
        field(12; "Withholding Tax Code"; Code[20])
        {
            Caption = 'Withholding Tax code';
            DataClassification = ToBeClassified;
            TableRelation = "VAT Product Posting Group" where(Type=const(WHT));
        }
        field(13; "Withholding Tax Amount"; Decimal)
        {
            Caption = 'Withholding tax Amount';
            DataClassification = ToBeClassified;
        }
        field(14; "Applies to Doc. No"; Code[20])
        {
            trigger OnLookup()
            begin
                "Applies to Doc. No":='';
                case "Receipt Type" of "Receipt Type"::Customer: begin
                    CustLedger[1].Reset;
                    CustLedger[1].SetCurrentKey(CustLedger[1]."Customer No.", Open, "Document No.");
                    CustLedger[1].SetRange(CustLedger[1]."Customer No.", "Account No");
                    CustLedger[1].SetRange(Open, true);
                    CustLedger[1].SetRange("Document Type", CustLedger[1]."Document Type"::Invoice);
                    CustLedger[1].CalcFields(CustLedger[1].Amount);
                    if PAGE.RunModal(25, CustLedger[1]) = ACTION::LookupOK then begin
                        if CustLedger[1]."Applies-to ID" <> '' then begin
                            CustLedger[2].Reset;
                            CustLedger[2].SetCurrentKey(CustLedger[2]."Customer No.", Open, "Applies-to ID");
                            CustLedger[2].SetRange(CustLedger[2]."Customer No.", "Account No");
                            CustLedger[2].SetRange(Open, true);
                            CustLedger[2].SetRange("Applies-to ID", CustLedger[1]."Applies-to ID");
                            if CustLedger[2].Find('-')then begin
                                repeat CustLedger[2].CalcFields(CustLedger[2].Amount);
                                    Amt:=Amt + Abs(CustLedger[2].Amount);
                                until CustLedger[2].Next = 0;
                            end;
                            if Amt <> Amt then //ERROR('Amount is not equal to the amount applied on the application form');
 if Amount = 0 then Amount:=Amt;
                            Validate(Amount);
                            "Applies to Doc. No":=CustLedger[1]."Document No.";
                            Description:=CustLedger[1].Description;
                            Validate("Currency Code", CustLedger[1]."Currency Code");
                        end
                        else
                        begin
                            if Amount <> Abs(CustLedger[1].Amount)then CustLedger[1].CalcFields(CustLedger[1]."Remaining Amount");
                            if Amount = 0 then Amount:=Abs(CustLedger[1]."Remaining Amount");
                            Validate(Amount);
                            "Applies to Doc. No":=CustLedger[1]."Document No.";
                            Description:=CustLedger[1].Description;
                            Amount:=CustLedger[1].Amount;
                            "Currency Code":=CustLedger[1]."Currency Code";
                            DocumentAttachment[1].Reset();
                            DocumentAttachment[1].SetRange("Table ID", Database::"Sales Invoice Header");
                            DocumentAttachment[1].SetRange("No.", CustLedger[1]."Document No.");
                            if DocumentAttachment[1].FindSet()then begin
                                repeat DocumentAttachment[2].Reset();
                                    DocumentAttachment[2].SetRange("Table ID", Database::"Receipt Header");
                                    DocumentAttachment[2].SetRange("No.", Rec."No.");
                                    DocumentAttachment[2].SetRange("File Name", DocumentAttachment[1]."File Name");
                                    DocumentAttachment[2].SetRange("File Type", DocumentAttachment[1]."File Type");
                                    DocumentAttachment[2].SetRange("File Extension", DocumentAttachment[1]."File Extension");
                                    if not DocumentAttachment[2].FindFirst then begin
                                        DocumentAttachment[3].Init();
                                        DocumentAttachment[3].TransferFields(DocumentAttachment[1]);
                                        DocumentAttachment[3]."Table ID":=Database::"Receipt Header";
                                        DocumentAttachment[3]."No.":=Rec."No.";
                                        DocumentAttachment[3].Insert(true);
                                    end;
                                until DocumentAttachment[1].Next() = 0;
                            end;
                        end;
                    end;
                    Validate(Amount);
                end;
                "Receipt Type"::Vendor: begin
                    VendLedger[1].Reset;
                    VendLedger[1].SetCurrentKey(VendLedger[1]."Vendor No.", Open, "Document No.");
                    VendLedger[1].SetRange(VendLedger[1]."Vendor No.", "Account No");
                    VendLedger[1].SetRange(Open, true);
                    VendLedger[1].CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
                    if PAGE.RunModal(29, VendLedger[1]) = ACTION::LookupOK then begin
                        if VendLedger[1]."Applies-to ID" <> '' then begin
                            VendLedger[2].Reset;
                            VendLedger[2].SetCurrentKey(VendLedger[2]."Vendor No.", Open, "Applies-to ID");
                            VendLedger[2].SetRange(VendLedger[2]."Vendor No.", "Account No");
                            VendLedger[2].SetRange(Open, true);
                            VendLedger[2].SetRange(VendLedger[2]."Applies-to ID", VendLedger[1]."Applies-to ID");
                            if VendLedger[2].Find('-')then begin
                                repeat VendLedger[2].CalcFields(VendLedger[2]."Remaining Amount");
                                    Amt:=Amt + Abs(VendLedger[2]."Remaining Amount");
                                until VendLedger[2].Next = 0;
                                if Amount <> Amount then //ERROR('Amount is not equal to the amount applied on the application form');
 if Amount = 0 then Amount:=Amt;
                                Validate(Amount);
                                "Applies to Doc. No":=VendLedger[1]."Document No.";
                                Description:=VendLedger[1].Description;
                                Validate("Currency Code", VendLedger[1]."Currency Code");
                            end
                            else
                            begin
                                if Amount <> Abs(VendLedger[1]."Remaining Amount")then VendLedger[1].CalcFields(VendLedger[1]."Remaining Amount", VendLedger[1]."Remaining Amt. (LCY)");
                                if Amount = 0 then Amount:=Abs(VendLedger[1]."Remaining Amount");
                                Validate(Amount);
                                "Applies to Doc. No":=VendLedger[1]."Document No.";
                                Description:=VendLedger[1].Description;
                                Validate("Currency Code", VendLedger[1]."Currency Code");
                            end;
                        end;
                    end;
                    Amount:=Abs(VendLedger[1]."Remaining Amount");
                    Validate(Amount);
                    Description:=VendLedger[1].Description;
                    Validate("Currency Code", VendLedger[1]."Currency Code");
                end;
                end;
            end;
        }
        field(15; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
    }
    keys
    {
        key(PK; "No.", "Line No.")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    begin
        ReceiptHeader.Get("No.");
        ReceiptHeader.TestField(Status, ReceiptHeader.Status::Open);
    end;
    trigger OnRename()
    begin
        ReceiptHeader.Get("No.");
        ReceiptHeader.TestField(Status, ReceiptHeader.Status::Open);
    end;
    trigger OnInsert()
    begin
        ReceiptHeader.Get("No.");
        ReceiptHeader.TestField(Status, ReceiptHeader.Status::Open);
    end;
    var Vendor: Record Vendor;
    Customer: Record Customer;
    Bank: Record "Bank Account";
    GLAccount: Record "G/L Account";
    Employee: Record Employee;
    ReceiptHeader: Record "Receipt Header";
    Amt: Decimal;
    CustLedger: array[2]of Record "Cust. Ledger Entry";
    VendLedger: array[2]of Record "Vendor Ledger Entry";
    DocumentAttachment: array[3]of Record "Document Attachment";
}
