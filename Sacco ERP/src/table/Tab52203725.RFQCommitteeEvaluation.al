table 52203725 "RFQ Committee Evaluation"
{
    fields
    {
        field(1; "RFQ No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Vendor No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; "Vendor Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Quoted Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Committee Member ID"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "Committee Member No"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Committee Member Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; Award; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Award = true then begin
                    RFQCommitteeEvaluation.Reset;
                    RFQCommitteeEvaluation.SetRange("RFQ No.", "RFQ No.");
                    RFQCommitteeEvaluation.SetRange(No, No);
                    RFQCommitteeEvaluation.SetRange("Committee Member ID", "Committee Member ID");
                    RFQCommitteeEvaluation.SetRange(Award, true);
                    if RFQCommitteeEvaluation.FindFirst then begin
                        Error('You have already picked a vendor for this item, un-select the vendor to pick a different one');
                    end;
                end;
            end;
        }
        field(9; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; Remarks; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(11; No; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(12; Description; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(13; "Unit Price"; Decimal)
        {
            CalcFormula = Lookup("Quotation Vendors Bids"."Unit Price" WHERE("Quote No"=FIELD("RFQ No."), "Vendor No"=FIELD("Vendor No.")));
            FieldClass = FlowField;
        }
        field(14; "Proc. Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(15; Specification; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Revised Quote"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "RFQ No.", "Line No.")
        {
        }
    }
    var RFQCommitteeEvaluation: Record "RFQ Committee Evaluation";
}
