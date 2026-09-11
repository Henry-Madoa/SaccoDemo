table 52203515 "Requisition Header"
{
    fields
    {
        field(1; "No."; Code[22])
        {
        }
        field(2; "Employee No."; Code[20])
        {
            TableRelation = Employee where(Status=const(Active));

            trigger OnValidate()
            begin
                if Employee.Get("Employee No.")then begin
                    "Employee Name":=Employee.FullName;
                    //  Employee.TestField("Global Dimension 1 Code");
                    "Global Dimension 1 Code":=Employee."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=Employee."Global Dimension 2 Code";
                    "Global Dimension 3 Code":=Employee."Global Dimension 3 Code";
                end;
            end;
        }
        field(3; "Employee Name"; Text[50])
        {
            Editable = false;
        }
        field(4; "Plan Name"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Description; Text[250])
        {
        }
        field(6; "Requisition Date"; Date)
        {
            Editable = false;
        }
        field(7; Status;Enum "Document Status")
        {
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                Lines.Reset;
                Lines.SetRange("Requisition No", "No.");
                if Lines.FindSet then begin
                    repeat Lines.Status:=Status;
                        Lines.Modify;
                    until Lines.Next = 0;
                end;
            end;
        }
        field(8; "Raised by"; Code[50])
        {
            Editable = false;
        }
        field(9; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(10; Rejected; Boolean)
        {
        }
        field(11; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=FILTER(1), Blocked=const(false));

            trigger OnValidate()
            begin
                Lines.Reset;
                Lines.SetRange("Requisition No", "No.");
                if Lines.Find('-')then Lines.ModifyAll("Global Dimension 1 Code", "Global Dimension 1 Code");
            end;
        }
        field(12; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));

            trigger OnValidate()
            begin
                Lines.Reset;
                Lines.SetRange("Requisition No", "No.");
                if Lines.Find('-')then Lines.ModifyAll("Global Dimension 2 Code", "Global Dimension 2 Code");
            end;
        }
        field(13; "Global Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(14; "Procurement Plan"; Code[20])
        {
            Editable = false;
        }
        field(15; "Document Type"; Option)
        {
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,None,Purchase Requisition,Store Requisition,Imprest,Claim-Accounting,Appointment,Payment Voucher';
            OptionMembers = Quote, "Order", Invoice, "Credit Memo", "Blanket Order", "Return Order", "None", "Purchase Requisition", "Store Requisition", Imprest, "Claim-Accounting", Appointment, "Payment Voucher";
        }
        field(16; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(17; "Requisition Type";Enum "Procurement Requisition Types")
        {
            trigger OnValidate()
            begin
                Lines.Reset;
                Lines.SetRange("Requisition No", "No.");
                if Lines.Find('-')then repeat Lines."Requisition Type":="Requisition Type";
                        Lines.Modify();
                    until Lines.Next() = 0;
            end;
        }
        field(18; Posted; Boolean)
        {
        }
        field(19; "No of Approvals"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(50200), "Document No."=FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; Select; Boolean)
        {
        }
        field(21; "Selected By"; Code[50])
        {
        }
        field(22; "Location Code"; Code[20])
        {
            TableRelation = Location where("Use As In-Transit"=const(false));

            trigger OnValidate()
            begin
                Lines.Reset();
                Lines.SetRange("Requisition No", "No.");
                if Lines.Find('-')then repeat Lines."Location Code":="Location Code";
                        Lines.Modify();
                    until Lines.Next() = 0;
            end;
        }
        field(23; Received; Boolean)
        {
        }
        field(24; "Received From"; Text[80])
        {
        }
        field(25; "Received Date"; DateTime)
        {
        }
        field(26; Issued; Boolean)
        {
        }
        field(27; "Issued By"; Code[50])
        {
        }
        field(28; "Issued Date"; Date)
        {
        }
        field(29; "PR Closed"; Boolean)
        {
        }
        field(30; "PR Closed By"; Option)
        {
            OptionCaption = ' ,Direct Receipt of Goods/Services,Purchase Order,Rejection';
            OptionMembers = " ", "Direct Receipt of Goods/Services", "Purchase Order", Rejection;
        }
        field(31; "Closed Date"; Date)
        {
        }
        field(32; "Closed By"; Code[50])
        {
        }
        field(33; "Quantity Requested"; Decimal)
        {
            CalcFormula = Sum("Requisition Lines".Quantity WHERE("Requisition No"=FIELD("No.")));
            FieldClass = FlowField;
        }
        field(34; Amount; Decimal)
        {
            CalcFormula = Sum("Requisition Lines".Amount WHERE("Requisition No"=FIELD("No.")));
            FieldClass = FlowField;
        }
        field(35; "Reason Code"; Code[50])
        {
            TableRelation = "Expense Codes" where("Account No"=filter(<>''));

            trigger OnValidate()
            begin
                if Expenses.Get("Reason Code")then begin
                    Description:=Expenses.Description;
                    "Account Type":=Expenses."Account Type";
                    "Account No":=Expenses."Account No";
                end;
            end;
        }
        field(36; "Account Type";Enum "Expense Types")
        {
        }
        field(37; "Account No"; Code[20])
        {
            TableRelation = IF("Account Type"=CONST("G/L Account"))"G/L Account" WHERE("Account Type"=CONST(Posting), Blocked=CONST(false))
            ELSE IF("Account Type"=CONST(Vendor))Vendor
            ELSE IF("Account Type"=CONST(Customer))Customer
            ELSE IF("Account Type"=CONST(Item))Item
            ELSE IF("Account Type"=CONST("Fixed Asset"))"Fixed Asset";
        }
        field(38; "Needed By Date"; Date)
        {
            trigger OnValidate()
            begin
                if "Needed By Date" < "Requisition Date" then Error('Needed by date can not be lesser than requisition date.');
            end;
        }
        field(39; "Expiration Date"; Date)
        {
        }
        field(40; "Supplier No"; Code[20])
        {
            TableRelation = Vendor where("Account Type"=const(Supplier));
        }
        field(41; "PO Generated Directly"; Boolean)
        {
        }
        field(42; "PO Generated By"; Code[50])
        {
        }
        field(43; "PO Generated Date"; Date)
        {
        }
        field(44; "PO Number"; Code[20])
        {
        }
        field(45; "Pending Approvals"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(50200), "Document No."=FIELD("No."), Status=FILTER(Open|Created)));
            Caption = 'Pending Approvals';
            FieldClass = FlowField;
        }
        field(46; "Current Budget"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Budget Name";
            Editable = false;
        }
        field(48; "Store Req. Qty. Approved"; Decimal)
        {
            CalcFormula = Sum("Requisition Lines"."Quantity Approved" WHERE("Requisition No"=FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(49; "Store Req. Qty. Issued"; Decimal)
        {
            CalcFormula = Sum("Requisition Lines"."Quantity Issued" WHERE("Requisition No"=FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Procurement Method";Enum "Procurement Methods")
        {
            DataClassification = ToBeClassified;
            InitValue = "Direct Procurement";
        }
        field(51; Approvers; Integer)
        {
            Editable = false;
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(50200), "Document No."=FIELD("No."), Status=FILTER(Approved)));
            FieldClass = FlowField;
            Caption = 'Approvers';
        }
        field(52; "Process Initiated"; Boolean)
        {
            Editable = false;
        }
        field(53; Title; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(54; Currency; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Currency;
        }
        field(55; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(56; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(57; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(58; "Approval Entries"; Integer)
        {
            Editable = false;
            fieldclass = flowfield;
            CalcFormula = Count("Approval Entry" WHERE("Document No."=FIELD("No.")));
        }
        field(59; "Store Location"; Code[20])
        {
            TableRelation = Location;
            DataClassification = ToBeClassified;
        }
        field(60; "Posted By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(61; "Requested Delivery Date"; Date)
        {
            DataClassification = ToBeClassified;
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
    end;
    trigger OnInsert()
    begin
        GLSetup.Get;
        GLSetup.TestField("Current Budget");
        PurchPayablesSetup.Get;
        if "No." = '' then begin
            if "Requisition Type" = "Requisition Type"::"Purchase Requisition" then begin
                PurchPayablesSetup.TestField("Purchase Req No");
                NoSeriesMgt.InitSeries(PurchPayablesSetup."Purchase Req No", xRec."No.", 0D, "No.", "No. Series");
            end;
            if "Requisition Type" = "Requisition Type"::"Store Requisition" then begin
                PurchPayablesSetup.TestField("Store Requisition Nos.");
                NoSeriesMgt.InitSeries(PurchPayablesSetup."Store Requisition Nos.", xRec."No.", 0D, "No.", "No. Series");
            end;
        end;
        "Raised by":=UserId;
        "Current Budget":=GLSetup."Current Budget";
        "Requisition Date":=WorkDate;
        if not LoginMgmt.IsWebServiceUser then begin
            if not UserSetup.Get(UserId)then Error('Contact Admin for your account to be setup')
            else if not UserSetup."Procurement Admin" then begin
                    Validate("Employee No.", UserSetup."Employee No.");
                end;
        end;
        "Requisition Date":=WorkDate;
        "Needed By Date":=WorkDate;
        "Expiration Date":=WorkDate;
        "Procurement Plan":=GLSetup."Current Budget";
    end;
    //Attachment check code
    procedure DocumentAttachmentsCheck(): Boolean begin
        DocumentAttachment.Reset();
        DocumentAttachment.SetRange("Table ID", 50200);
        DocumentAttachment.SetRange("No.", Rec."No.");
        DocumentAttachment.SetFilter("File Name", '<>%1', '');
        if DocumentAttachment.FindSet()then exit(true)
        else
            exit(false);
    end;
    procedure ValidatorResponse(): Text begin
        exit(Validator_Err);
    end;
    var PurchPayablesSetup: Record "Purchases & Payables Setup";
    GLSetup: Record "General Ledger Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    UserSetup: Record "User Setup";
    LoginMgmt: Codeunit "User Management Ext";
    Employee: Record Employee;
    Expenses: Record "Expense Codes";
    Lines: Record "Requisition Lines";
    DimVal: Record "Dimension Value";
    DocumentAttachment: Record "Document Attachment";
    Validator_Err: Label 'You have not attached any document. Please attach some documents';
    procedure AssitEdit(): Boolean begin
        PurchPayablesSetup.Get;
        PurchPayablesSetup.TestField("Store Requisition Nos.");
        if NoSeriesMgt.SelectSeries(PurchPayablesSetup."Store Requisition Nos.", xRec."No. Series", "No. Series")then begin
            NoSeriesMgt.SetSeries("No.");
            exit(true);
        end;
    end;
}
