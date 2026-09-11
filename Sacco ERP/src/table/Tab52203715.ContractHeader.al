table 52203715 "Contract Header"
{
    DrillDownPageID = "Contract List";
    LookupPageID = "Contract List";

    fields
    {
        field(1; "No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Requisition No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Vendor No."; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor where("Account Type"=const(Supplier));

            trigger OnValidate()
            begin
                if Vendor.Get("Vendor No.")then "Vendor Name":=Vendor.Name;
            end;
        }
        field(4; "Tender No."; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if ProcurementRequest.Get("Tender No.")then begin
                    "Tender Title":=ProcurementRequest.Description;
                    ProcurementRequest.CalcFields("Total Amount");
                    "Tender Amount":=ProcurementRequest."Total Amount" end;
            end;
        }
        field(5; "Tender Title"; Text[100])
        {
            Caption = 'Contract Title';
            DataClassification = ToBeClassified;
        }
        field(6; "Agreement Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Contract Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Contract period"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Format("Contract period") <> '' then "Contract End Date":=CalcDate("Contract period", "Contract Start Date");
            end;
        }
        field(9; "Contract End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Tender Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Contract Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Signed';
            OptionMembers = New, Signed;
        }
        field(12; "Contract Signing Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(13; Status;Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14; "Contract Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Extended By"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Format("Extended By") <> '' then begin
                    Rec.Status:=Rec.Status::Open;
                    "original expiry period":=Rec."New Expiry Date";
                    "Original extension period":=Rec."Extended By";
                    "Original Date of Extension":=Rec."Date of Extension";
                    "New Expiry Date":=CalcDate("Extended By", "Contract End Date");
                    "No. Of Extension"+=1;
                    "Date of Extension":=WorkDate;
                    "Contract Extended":=true;
                end;
            end;
        }
        field(16; "New Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Contract Extended"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Date of Extension"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "No. Of Extension"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Original extension period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "original expiry period"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Original Date of Extension"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Vendor Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(27; "Total Milestone Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Delivery Period (Days)"; DateFormula)
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
    fieldgroups
    {
    }
    trigger OnInsert()
    begin
        PurchPayablesSetup.Get;
        PurchPayablesSetup.TestField("Contract Nos");
        NoSeriesManagement.InitSeries(PurchPayablesSetup."Contract Nos", "No. Series", 0D, "No.", "No. Series");
    end;
    var ProcurementRequest: Record "Procurement Request";
    PurchPayablesSetup: Record "Purchases & Payables Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    Vendor: Record Vendor;
}
