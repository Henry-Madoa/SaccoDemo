table 52203439 "Payment Voucher"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            NotBlank = false;
            Editable = false;

            trigger OnValidate()
            begin
                GLSetup.Get;
                if "No." <> xRec."No." then NoSeriesMgt.TestManual(GLSetup."PV Nos");
                "No. Series" := '';
            end;
        }
        field(2; Date; Date)
        {
            Editable = false;
        }
        field(3; Type; Code[20])
        {
        }
        field(4; "Pay Mode"; Code[20])
        {
            TableRelation = "Payment Method";

            trigger OnValidate()
            begin
                if PaymentMethod.Get(Rec."Pay Mode") then begin
                    if PaymentMethod.Type = PaymentMethod.Type::Cheque then begin
                        if "Cheque Date" = 0D then "Cheque Date" := WorkDate;
                    end;
                    if PaymentMethod.Type = PaymentMethod.Type::FOSA then Error('FOSA Payment For Vendor Payment is still under review');
                end;
            end;
        }
        field(5; "Cheque Number"; Code[20])
        {
            trigger OnValidate()
            begin
                if "Cheque Number" <> '' then begin
                    PV.Reset;
                    PV.SetRange(PV."Cheque Number", "Cheque Number");
                    if PV.Find('-') then begin
                        if PV."No." <> "No." then Error('Cheque No. already exists');
                    end;
                end;
            end;
        }
        field(6; "Cheque Date"; Date)
        {
        }
        field(7; "Clearing Date"; Date)
        {
        }
        field(8; "Payroll Period"; Date)
        {
            TableRelation = "Accounting Period";
        }
        field(9; "Prepared By"; Code[50])
        {
            Editable = false;
        }
        field(10; Posted; Boolean)
        {
            Editable = false;

            trigger OnValidate()
            begin
                if (Posted = true) and (xRec.Posted <> Posted) then begin
                    PVLines.Reset;
                    PVLines.SetRange("No.", Rec."No.");
                    if PVLines.FindSet then begin
                        repeat
                            PVLines.Posted := true;
                            PVLines."Posted Date" := WorkDate;
                            PVLines.Modify;
                        until PVLines.Next = 0;
                    end;
                end;
            end;
        }
        field(11; "Posted By"; Code[50])
        {
            Editable = false;
        }
        field(12; "Posted Date"; Date)
        {
            Editable = false;
        }
        field(13; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));

            trigger OnValidate()
            begin
                UpdatePaymentLines;
            end;
        }
        field(14; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = const(false));

            trigger OnValidate()
            begin
                UpdatePaymentLines;
            end;
        }
        field(15; "Time Posted"; Time)
        {
            Editable = false;
        }
        field(16; "Total Amount"; Decimal)
        {
            Caption = 'Net Amount';
            CalcFormula = Sum("Payment Voucher Lines"."Net Amount" WHERE("No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Paying Bank Account"; Code[20])
        {
            TableRelation = "Bank Account";
        }
        field(18; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(19; "Payment Type"; Enum "Payment Types")
        {
            trigger OnValidate()
            begin
                if "Payment Type" in ["Payment Type"::"Staff Bulk Payment"] then begin
                    PaymentMethod.Reset();
                    PaymentMethod.SetRange(Type, PaymentMethod.Type::FOSA);
                    if PaymentMethod.FindFirst then "Pay Mode" := PaymentMethod.Code;
                end;
                PVLines.Reset;
                PVLines.SetRange("No.", Rec."No.");
                if PVLines.FindSet then begin
                    repeat
                        PVLines.Validate("Payment Type", "Payment Type");
                        PVLines.Modify(true);
                    until PVLines.Next = 0;
                end;
            end;
        }
        field(20; Currency; Code[20])
        {
            TableRelation = Currency.Code;

            trigger OnValidate()
            begin
                UpdatePaymentLines;
            end;
        }
        field(21; "No. Series"; Code[20])
        {
        }
        field(22; "Account Type"; Option)
        {
            Editable = false;
            OptionCaption = 'G/L Account,Customer,Vendor,Bank Account,Fixed Asset';
            OptionMembers = "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset";
        }
        field(23; "From Self Service"; Boolean)
        {
        }
        field(24; "Cheque Received By"; Text[250])
        {
        }
        field(25; "Applies- To Doc No."; Code[20])
        {
            trigger OnLookup()
            begin
                case "Account Type" of
                    "Account Type"::Customer:
                        begin
                            CustLedger.Reset;
                            CustLedger.SetCurrentKey(CustLedger."Customer No.", Open, "Document No.");
                            CustLedger.SetRange(Open, true);
                            CustLedger.CalcFields(CustLedger.Amount);
                            if PAGE.RunModal(25, CustLedger) = ACTION::LookupOK then begin
                                "Applies- To Doc No." := CustLedger."Document No.";
                            end;
                        end;
                end;
            end;
        }
        field(26; "Pending Approvals"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Table ID" = CONST(Database::"Payment Voucher"), "Document No." = FIELD("No."), Status = FILTER(Open | Created)));
            Caption = 'Pending Approvals';
            FieldClass = FlowField;
            Editable = false;
        }
        field(27; "Approvals Trail"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Table ID" = CONST(Database::"Payment Voucher"), "Document No." = FIELD("No."), Status = FILTER(Approved)));
            FieldClass = FlowField;
            Caption = 'Approvers';
            Editable = false;
        }
        field(28; Uncommited; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Total Withholding Tax"; Decimal)
        {
            CalcFormula = Sum("Payment Voucher Lines"."WHT Amount One" WHERE("No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; Description; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Narration';

            trigger OnValidate()
            begin
                UpdatePaymentLines;
            end;
        }
        field(31; EFT_No; Text[30])
        {
        }
        field(32; "EFT Posted"; Boolean)
        {
        }
        field(33; "Purchase Invoice Amount"; Decimal)
        {
            CalcFormula = Sum("Payment Voucher Lines"."Purchase Invoice Amount" WHERE("No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(34; "Gross Amount"; Decimal)
        {
            Caption = 'Amount To Be Paid';
            CalcFormula = Sum("Payment Voucher Lines".Amount WHERE("No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(35; "Outstanding Amount"; Decimal)
        {
            CalcFormula = Sum("Payment Voucher Lines"."Outstanding Amount" WHERE("No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(36; "VAT Already Charged"; Decimal)
        {
            CalcFormula = Sum("Payment Voucher Lines"."VAT Already Charged" WHERE("No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(37; "W\Tax Already Charged"; Decimal)
        {
            CalcFormula = Sum("Payment Voucher Lines"."W\Tax Already Charged" WHERE("No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(38; "Vendor No"; Code[20])
        {
            Editable = false;
        }
        field(39; "Beneficiary Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Vendor.Name WHERE("No." = FIELD("Vendor No")));
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
        fieldgroup(DropDown; "No.", Description, "Payment Type", "Posted Date", "Global Dimension 1 Code", "Gross Amount", Status)
        {
        }
        fieldgroup(Brick; "No.", Description, "Payment Type", "Posted Date", "Global Dimension 1 Code", "Gross Amount", Status)
        {
        }
    }
    trigger OnDelete()
    begin
        Rec.TestField(Status, Rec.Status::Open);
        Rec.Testfield(Posted, false);
    end;

    trigger OnInsert()
    begin
        Date := WorkDate;
        Rec."Prepared By" := UserId;
        GLSetup.Get();
        GLSetup.TestField("PV Nos");
        if "No." = '' then NoSeriesMgt.InitSeries(GLSetup."PV Nos", xRec."No. Series", 0D, "No.", "No. Series");
    end;

    procedure AmountToBePaidValidator()
    begin
        CalcFields("Total Amount");
        if "Total Amount" = 0 then Error(Text004);
    end;

    procedure AttachmentValidator(): Boolean
    begin
        DocumentAttachment.Reset();
        DocumentAttachment.SetRange("Table ID", Database::"Payment Voucher");
        DocumentAttachment.SetRange("No.", Rec."No.");
        DocumentAttachment.SetFilter("File Name", '<>%1', '');
        if DocumentAttachment.FindSet() then
            exit(true)
        else
            exit(true);
    end;

    procedure AttachmentValidatorResponse(): Text
    begin
        exit(Validator_Err);
    end;

    [Scope('Cloud')]
    procedure AssistEdit(): Boolean
    begin
        GLSetup.Get();
        GLSetup.TestField(GLSetup."PV Nos");
        if NoSeriesMgt.SelectSeries(GLSetup."PV Nos", xRec."No. Series", "No. Series") then begin
            NoSeriesMgt.SetSeries("No.");
            exit(true);
        end;
    end;

    procedure CreateDepartmentalRequest()
    begin
        if UserSetup.Get(UserId) then begin
            if Employee.Get(UserSetup."Employee No.") then begin
                Rec."Prepared By" := UserId;
                Rec.Status := Rec.Status::Open;
                Rec."From Self Service" := true;
                "Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
                "Global Dimension 2 Code" := Employee."Global Dimension 2 Code";
            end;
        end
        else
            Error(Text003);
    end;

    local procedure UpdatePaymentLines()
    var
        Lines: Record "Payment Voucher Lines";
    begin
        Lines.Reset();
        Lines.SetRange("No.", Rec."No.");
        Lines.SetFilter(Amount, '<>%1', 0);
        if Lines.FindSet() then begin
            repeat
                Lines."Global Dimension 1 Code" := "Global Dimension 1 Code";
                Lines."Global Dimension 2 Code" := "Global Dimension 2 Code";
                Lines.Description := Description;
                Lines."Currency Code" := Currency;
                Lines.Modify(true);
            until Lines.Next() = 0;
        end;
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posted Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;

    procedure OnBeforeApproval()
    begin
        Rec.TestField(Status, Rec.Status::Open);
        Rec.Testfield(Date);
        Rec.Testfield(Description);
        //Check Lines
        PVLines.Reset;
        PVLines.SetRange("No.", Rec."No.");
        if not PVLines.FindLast then Error('Payment voucher Lines cannot be empty');
        AmountToBePaidValidator;
        if not AttachmentValidator then Error(Rec.AttachmentValidatorResponse);
    end;

    var
        DocumentAttachment: Record "Document Attachment";
        Validator_Err: Label 'You have not attached any document. Please attach document/s and continue.';
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CustLedger: Record "Cust. Ledger Entry";
        PV: Record "Payment Voucher";
        PVLines: Record "Payment Voucher Lines";
        GLSetup: Record "General Ledger Setup";
        Employee: Record Employee;
        UserSetup: Record "User Setup";
        PaymentMethod: Record "Payment Method";
        Text003: Label 'You do not have a setup. Please Contact the Administrator.';
        Text004: Label 'Amount To be paid can not be equal to zero.';
}
