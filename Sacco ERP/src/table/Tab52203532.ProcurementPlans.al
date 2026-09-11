table 52203532 "Procurement Plans"
{
    DataClassification = CustomerContent;
    Caption = 'Procurement Plan';

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Employee Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Employee where(Status=const(Active));

            trigger OnValidate()
            begin
                UsersRec.Reset;
                UsersRec.SetRange("Employee No.", "Employee Code");
                if UsersRec.FindFirst then begin
                    if EmpRec.Get(UsersRec."Employee No.")then begin
                        "Global Dimension 1 Code":=EmpRec."Global Dimension 1 Code";
                        "Global Dimension 2 Code":=EmpRec."Global Dimension 2 Code";
                        "Global Dimension 3 Code":=EmpRec."Global Dimension 3 Code";
                    end;
                end;
                if NAVemp.Get("Employee Code")then "Employee Name":=NAVemp.FullName();
            end;
        }
        field(3; "Employee Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; Status;Enum "Document Status")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Lines.Reset;
                Lines.SetRange("Document No", Rec."No.");
                if Lines.Find('-')then begin
                    repeat Lines.Status:=Status;
                        Lines.Modify;
                    until Lines.Next = 0;
                end;
                if Rec.Status = Rec.Status::Approved then begin
                //ProcurementMgmt.UpdateItemBudgetEntries(Rec);
                end;
            end;
        }
        field(5; "Location Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(6; Date; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Item Budget Name"; Code[10])
        {
            TableRelation = "Item Budget Name".Name where("Analysis Area"=const(Purchase));
        }
        field(8; "Raised By"; code[50])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(9; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(10; "Global Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,1,1';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=FILTER(1), Blocked=const(false));

            trigger OnValidate()
            begin
            //Lines.Reset;
            //Lines.SetRange("Repair No", "No.");
            //if Lines.Find('-') then
            //Lines.ModifyAll("Global Dimension 1 Code", "Global Dimension 1 Code");
            end;
        }
        field(11; "Global Dimension 2 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));

            trigger OnValidate()
            begin
            //Lines.Reset;
            //Lines.SetRange("Repair No", "No.");
            //if Lines.Find('-') then
            //Lines.ModifyAll("Global Dimension 2 Code", "Global Dimension 2 Code");
            end;
        }
        field(12; "Global Dimension 3 Code"; code[20])
        {
            Editable = false;
            DataClassification = CustomerContent;
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(13; "No of Approvals"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(50931), "Document No."=FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Pending Approvals"; Integer)
        {
            //DataClassification = ToBeClassified;
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(50931), "Document No."=FIELD("No."), Status=FILTER(Open|Created)));
            Caption = 'Pending Approvals';
            FieldClass = FlowField;
        }
        field(15; Approvers; Integer)
        {
            //DataClassification = ToBeClassified;
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(50931), "Document No."=FIELD("No."), Status=FILTER(Approved)));
            Caption = 'Approvers';
            FieldClass = FlowField;
        }
        field(16; Posted; Boolean)
        {
        }
        field(17; "Plan Name"; Text[150])
        {
        }
        field(18; "Financial Year"; Code[100])
        {
        }
        field(19; "Current Budget"; Code[70])
        {
        }
        field(20; "Created By"; Code[100])
        {
        }
        field(21; "Date Created"; Date)
        {
        }
        field(22; "Start Date"; Date)
        {
        }
        field(23; "End Date"; Date)
        {
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    var PurchPayablesSetup: Record "Purchases & Payables Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    UsersRec: Record "User Setup";
    NAVemp: Record Employee;
    EmpRec: Record Employee;
    Expenses: Record "Expense Codes";
    Lines: Record "Procurement Plan Lines";
    DocumentAttachment: Record "Document Attachment";
    Validator_Err: Label 'You have not attached any document. Please attach some documents';
    ProcurementMgmt: Codeunit "Procurement Management";
    trigger OnInsert()
    begin
        if "No." = '' then begin
            PurchPayablesSetup.Get;
            PurchPayablesSetup.TestField("Procurement Plan No.");
            NoSeriesMgt.InitSeries(PurchPayablesSetup."Procurement Plan No.", xRec."No.", 0D, "No.", "No. Series");
        end;
        "Raised by":=UserId;
        if UsersRec.Get(UserId)then begin
            UsersRec.TestField("Employee No.");
            "Employee Code":=UsersRec."Employee No.";
            Validate("Employee Code");
        end;
        PurchPayablesSetup.Get();
        PurchPayablesSetup.TestField("Item Budget Name");
        Validate("Item Budget Name", PurchPayablesSetup."Item Budget Name");
        Date:=Today;
    end;
    trigger OnDelete()
    begin
        if Rec.Status = Rec.Status::Open then Rec.Testfield("Raised by", UserId)
        else
            Error('You cannot delete header at this stage.');
    end;
    procedure DocumentAttachmentsCheck(): Boolean begin
        DocumentAttachment.Reset();
        DocumentAttachment.SetRange("Table ID", Database::"Procurement Plans");
        DocumentAttachment.SetRange("No.", Rec."No.");
        DocumentAttachment.SetFilter("File Name", '<>%1', '');
        if DocumentAttachment.FindSet()then exit(true)
        else
            exit(false);
    end;
    procedure ValidatorResponse(): Text begin
        exit(Validator_Err);
    end;
}
