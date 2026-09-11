table 52203718 "Tender Bid Bonds"
{
    fields
    {
        field(1; "Document No."; Code[30])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                ProcSetup.Get;
                if "Document No." <> '' then begin
                    ProcSetup.TestField("Bid Bond No.");
                    Nmgt.TestManual(ProcSetup."Bid Bond No.");
                    "No. series":='';
                end;
            end;
        }
        field(2; "Tender No."; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Procurement Request"."No.";

            trigger OnValidate()
            begin
                if ProcRequest.Get("Tender No.")then if(ProcRequest."Procurement Method" = ProcRequest."Procurement Method"::"Open Tendering") or (ProcRequest."Procurement Method" = ProcRequest."Procurement Method"::"Restricted Tendering")then begin
                        if(ProcRequest."Tender Status" <> ProcRequest."Tender Status"::"Order Created") or (ProcRequest."Tender Status" <> ProcRequest."Tender Status"::"Contract Created")then "Tender Status":="Tender Status"::Ongoing;
                    end;
            end;
        }
        field(3; "Supplier No."; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Tender Suppliers" WHERE("Reference No"=FIELD("Tender No."));
        }
        field(4; "Supplier Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Bid Bond Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Bid Bond Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Active,Inactive';
            OptionMembers = " ", Active, Inactive;
        }
        field(7; "Tender Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Ongoing,Awarded,Dropped';
            OptionMembers = " ", Ongoing, Awarded, Dropped;
        }
        field(8; "No. series"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
    }
    keys
    {
        key(Key1; "Document No.")
        {
        }
        key(Key2; "Tender No.")
        {
        }
    }
    trigger OnInsert()
    begin
        ProcSetup.Get;
        if "Document No." = '' then begin
            ProcSetup.TestField("Bid Bond No.");
            Nmgt.InitSeries(ProcSetup."Bid Bond No.", xRec."No. series", 0D, "Document No.", "No. series");
            "No. series":=ProcSetup."Bid Bond No.";
        end;
    end;
    var ProcSetup: Record "Purchases & Payables Setup";
    Nmgt: Codeunit NoSeriesManagement;
    ProcRequest: Record "Procurement Request";
}
