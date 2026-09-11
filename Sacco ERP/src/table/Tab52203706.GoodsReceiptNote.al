table 52203706 "Goods Receipt Note"
{
    DrillDownPageID = "Goods Receipt List";
    LookupPageID = "Goods Receipt List";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                ProcurementSetup.Get;
                if "No." <> '' then begin
                    NoSeriesManagement.TestManual(ProcurementSetup."Goods Receipt Nos");
                    "No. Series":='';
                end;
            end;
        }
        field(2; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No.")then "Employee Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
            end;
        }
        field(3; "Employee Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Created Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Created Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Created By"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Purchase Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Purchase Header"."No." WHERE(Status=CONST(Released), "Document Type"=CONST(Order));

            trigger OnValidate()
            begin
                if xRec."Purchase Order No." <> Rec."Purchase Order No." then GoodsReceiptNoteLines.Reset;
                GoodsReceiptNoteLines.SetRange("Document No", "No.");
                if GoodsReceiptNoteLines.FindFirst then GoodsReceiptNoteLines.DeleteAll;
                FnPopulateLines("Purchase Order No.");
                if PurchaseHeader.Get(DocType::Order, "Purchase Order No.")then begin
                    "Vendor No.":=PurchaseHeader."Buy-from Vendor No.";
                    "Vendor Name":=PurchaseHeader."Buy-from Vendor Name";
                end;
            end;
        }
        field(8; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Pending Approval,Approved,Rejected';
            OptionMembers = New, "Pending Approval", Approved, Rejected;
        }
        field(9; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Posted By"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Posted On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Posted At"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(14; "Delivery Note No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Vendor No."; Code[30])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(16; "Vendor Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(17; Approvals; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Document No."=FIELD("No."), Status=FILTER(Open|Created|Approved)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(18; "Delivery Date"; Date)
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
        if Status <> Status::New then Error('You can only Delete a New Document');
        GoodsReceiptNoteLines.Reset;
        GoodsReceiptNoteLines.SetRange("Document No", "No.");
        if GoodsReceiptNoteLines.FindFirst then GoodsReceiptNoteLines.DeleteAll;
    end;
    trigger OnInsert()
    begin
        if UserSetup.Get(UserId)then begin
            UserSetup.TestField("Store Admin");
            "Employee No.":=UserSetup."Employee No.";
            Validate("Employee No.");
        end;
        if "No." = '' then begin
            ProcurementSetup.Get;
            ProcurementSetup.TestField("Goods Receipt Nos");
            NoSeriesManagement.InitSeries(ProcurementSetup."Goods Receipt Nos", xRec."No. Series", 0D, "No.", "No. Series");
            "No. Series":=ProcurementSetup."Goods Receipt Nos";
        end;
    end;
    trigger OnModify()
    begin
    // IF Status<>Status::New THEN
    //  ERROR('You can only Modify a New Document');
    end;
    var ProcurementSetup: Record "Purchases & Payables Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    UserSetup: Record "User Setup";
    GoodsReceiptNoteLines: Record "Goods Receipt Note Lines";
    PurchaseHeader: Record "Purchase Header";
    PurchaseLine: Record "Purchase Line";
    LineN: Integer;
    Employee: Record Employee;
    GoodsReceiptNote: Record "Goods Receipt Note";
    DocType: Option Quote, "Order", Invoice;
    local procedure FnPopulateLines(DocN: Code[10])
    begin
        PurchaseHeader.Reset;
        PurchaseHeader.SetRange("No.", DocN);
        if PurchaseHeader.FindSet then begin
            PurchaseLine.Reset;
            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
            PurchaseLine.SetRange("Document No.", "Purchase Order No.");
            PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
            PurchaseLine.SetFilter("Qty. to Receive", '<>%1', 0);
            if PurchaseLine.FindSet then begin
                repeat LineN:=10;
                    GoodsReceiptNoteLines.Init;
                    GoodsReceiptNoteLines."Document No":="No.";
                    GoodsReceiptNoteLines."Line No."+=LineN + 10;
                    GoodsReceiptNoteLines."Item No.":=PurchaseLine."No.";
                    GoodsReceiptNoteLines.Validate("Item No.");
                    GoodsReceiptNoteLines."Item Description":=PurchaseLine.Description;
                    GoodsReceiptNoteLines.Location:=PurchaseLine."Location Code";
                    GoodsReceiptNoteLines."Quantity Ordered":=PurchaseLine."Qty. to Receive";
                    GoodsReceiptNoteLines."Unit of Measure":=PurchaseLine."Unit of Measure Code";
                    GoodsReceiptNoteLines.Validate("Unit of Measure", PurchaseLine."Unit of Measure Code");
                    GoodsReceiptNoteLines."Unit Price":=PurchaseLine."Unit Price (LCY)";
                    GoodsReceiptNoteLines."Total Amount":=PurchaseLine."Line Amount";
                    GoodsReceiptNoteLines.Insert;
                until PurchaseLine.Next = 0;
            end
            else
            begin
                Message('There is nothing to receive in the LPO');
            end;
        end;
    end;
    procedure FnModifyLPO(DocN: Code[20]; DocN1: Code[20])
    var
        Plines: Record "Purchase Line";
        Glines: Record "Goods Receipt Note Lines";
    begin
        Glines.Reset;
        Glines.SetRange("Document No", DocN);
        Glines.SetRange("Item No.", Glines."Item No.");
        if Glines.FindSet then repeat Message('%1', Glines."Item No.");
                Plines.Reset;
                Plines.SetRange("Document Type", Plines."Document Type"::Order);
                Plines.SetRange("Document No.", DocN1);
                Plines.SetRange(Type, Plines.Type::Item);
                Plines.SetRange("No.", Glines."Item No.");
                if Plines.FindSet then repeat Message('%1', Plines."No.");
                        Plines."Qty. to Receive":=Glines."Quantity to Receive";
                        Plines.Validate("Qty. to Receive");
                        Plines.Modify;
                    until Plines.Next = 0;
            until Glines.Next = 0;
    end;
}
