table 52203444 "Petty Cash Header"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; "Employee No."; Code[20])
        {
            TableRelation = Employee where(Status=const(Active));

            trigger OnValidate()
            begin
                if EmpRec.Get("Employee No.")then begin
                    EmpRec.TestField("Global Dimension 2 Code");
                    "Job Title":=EmpRec."Job Title";
                    "Employee Name":=EmpRec.FullName;
                    "Payment To":=EmpRec.FullName;
                    "On Behalf of":=EmpRec.FullName;
                    "Global Dimension 1 Code":=EmpRec."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=EmpRec."Global Dimension 2 Code";
                    PaymentMethod.Reset();
                    PaymentMethod.SetRange(Type, PaymentMethod.Type::Cash);
                    if not PaymentMethod.FindFirst then Error('Payment Method of type Cash must be set up, Kindly contact Admin')
                    else
                    begin
                        "Pay Mode":=PaymentMethod.Code;
                        "Payment Tx No.(Cheque No.)":="No.";
                    end;
                end;
            end;
        }
        field(3; "Employee Name"; Text[100])
        {
            Editable = false;
        }
        field(4; "Global Dimension 1 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,1,1';
            Caption = 'Department';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(5; "Global Dimension 2 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(6; "Global Dimension 3 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(7; Date; Date)
        {
            Editable = false;
        }
        field(8; "Created By"; Code[50])
        {
            Editable = false;
        }
        field(9; Status;Enum "Document Status")
        {
            Editable = false;

            trigger OnValidate()
            begin
                Lines.Reset();
                Lines.SetRange(No, "No.");
                if Lines.FindSet()then begin
                    repeat Lines.Validate(Status, Status);
                        Lines.Modify(true);
                    until Lines.Next() = 0;
                end;
            end;
        }
        field(10; "No. Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(11; "Paying Account Code"; Code[20])
        {
            TableRelation = "Bank Account" where("Account Type"=const("Petty Cash"));

            trigger OnValidate()
            begin
                if BankAccount.Get("Paying Account Code")then "Account Name":=BankAccount.Name;
            end;
        }
        field(12; "Account Name"; Text[30])
        {
            Editable = false;
        }
        field(13; "Payment To"; Text[30])
        {
            Editable = false;
        }
        field(14; "On Behalf of"; Text[30])
        {
        }
        field(15; "Payment Narration"; Text[50])
        {
            trigger OnValidate()
            begin
            // AdvancedFinanceSetup.TextRegExChecker("Payment Narration");
            end;
        }
        field(16; "Payment Date"; Date)
        {
        }
        field(17; "Total Amount"; Decimal)
        {
            CalcFormula = Sum("Petty Cash Details".Amount WHERE(No=FIELD("No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(18; Posted; Boolean)
        {
            Editable = false;
        }
        field(19; "Posted By"; Code[50])
        {
            Editable = false;
            Caption = 'Cashier';
        }
        field(20; "Posted Date"; Date)
        {
            Editable = false;
        }
        field(21; "Job Title"; Text[50])
        {
            Editable = false;
        }
        field(22; "Pay Mode"; Code[10])
        {
            TableRelation = "Payment Method";
            Editable = false;
        }
        field(23; "Payment Tx No.(Cheque No.)"; Code[10])
        {
            Editable = false;

            trigger OnValidate()
            begin
            //AdvancedFinanceSetup.CodeRegExChecker("Payment Tx No.(Cheque No.)");
            end;
        }
        field(24; "Cheque Date"; Date)
        {
        }
        field(25; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(27; "SharePoint Link"; Text[250])
        {
        }
        field(28; Approvers; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(Database::"Petty Cash Header"), "Document No."=FIELD("No."), Status=FILTER(Approved)));
            FieldClass = FlowField;
            Caption = 'Approvers';
            Editable = false;
        }
        field(29; "Pending Approvals Ext"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(Database::"Petty Cash Header"), "Document No."=FIELD("No."), Status=FILTER(Open|Created)));
            Caption = 'Pending Approvals';
            FieldClass = FlowField;
            Editable = false;
        }
        field(30; Paid; Boolean)
        {
        }
        field(31; "Paid Date"; Date)
        {
        }
        field(32; "Paid By"; Code[50])
        {
        }
        field(33; "Posting Date"; Date)
        {
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnDelete()
    begin
        Rec.TestField(Status, Rec.Status::Open);
        Rec.Testfield(Posted, false);
    end;
    trigger OnModify()
    begin
        Rec.Testfield(Posted, false);
    end;
    trigger OnInsert()
    begin
        if "No." = '' then begin
            AdvancedFinanceSetup.Get;
            AdvancedFinanceSetup.TestField("Petty Cash Nos");
            NoSeriesMgt.InitSeries(AdvancedFinanceSetup."Petty Cash Nos", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        Date:=WorkDate;
        if not LoginMgmt.IsWebServiceUser then begin
            "Created By":=UserId;
            if UserSetup.Get(UserId)then begin
                if not UserSetup."Finance Admin" then begin
                    "Employee No.":=UserSetup."Employee No.";
                    Validate("Employee No.");
                end;
            end;
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
    procedure RequestedAmountValidator()
    begin
        CalcFields("Total Amount");
        if "Total Amount" = 0 then Error(Text001);
    end;
    procedure AttachmentValidator(): Boolean begin
        DocumentAttachment.Reset();
        DocumentAttachment.SetRange("Table ID", Database::"Petty Cash Header");
        DocumentAttachment.SetRange("No.", Rec."No.");
        DocumentAttachment.SetFilter("File Name", '<>%1', '');
        if DocumentAttachment.FindSet()then exit(true)
        else
            exit(true);
    end;
    procedure AttachmentValidatorResponse(): Text begin
        exit(Validator_Err);
    end;
    var DocumentAttachment: Record "Document Attachment";
    Validator_Err: Label 'You have not attached any document. Please attach document/s and continue.';
    EmpRec: Record Employee;
    AdvancedFinanceSetup: Record "General Ledger Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    UserSetup: Record "User Setup";
    BankAccount: Record "Bank Account";
    PaymentMethod: Record "Payment Method";
    Text000: Label 'There is no Petty Cash for %1, Kindly contact Admin for the setup';
    Text001: Label 'Requested can not be equal to zero.';
    Lines: Record "Petty Cash Details";
    LoginMgmt: Codeunit "User Management Ext";
}
