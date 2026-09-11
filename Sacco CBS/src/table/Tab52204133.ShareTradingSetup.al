table 52204133 "Share Trading Setup"
{
    DataCaptionFields = "Document No.", "Start Date", "End Date";
    DrillDownPageID = "Share Trading Setup";
    LookupPageID = "Share Trading Setup";

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Base Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Published; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            var
                ShareTradingSetup: Record "Share Trading Setup";
            begin
                ShareTradingSetup.Reset;
                ShareTradingSetup.SetRange(Published, true);
                if ShareTradingSetup.FindFirst then begin
                    ShareTradingSetup.Published := false;
                    ShareTradingSetup.Modify;
                end;
            end;
        }
        field(6; Status; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = 'New,Published,Retired';
            OptionMembers = New,Published,Retired;
        }
        field(7; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(9; Charges; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Transaction Charges";
        }
        field(10; "Clearing Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer;
        }
        field(11; "Holding Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." WHERE("Direct Posting" = CONST(true));
        }
        field(12; "Total Value On Market"; Decimal)
        {
            CalcFormula = Sum("Share Floating"."Floated Value" WHERE("Share Type" = FIELD("Document No."), Published = CONST(true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Shares On Market"; Decimal)
        {
            CalcFormula = Sum("Share Floating"."Shares to Float" WHERE("Share Type" = FIELD("Document No."), Published = CONST(true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Reserve Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Share Life"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "On No Bid"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Extend,Reverse;
        }
        field(17; "Tolerance Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Minimum Share to Float"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Document No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        GeneralSetup.Get;
        GeneralSetup.TestField("Share Trading Nos.");
        "Document No." := NoSeriesManagement.GetNextNo(GeneralSetup."Share Trading Nos.", Today, true);
    end;

    var
        GeneralSetup: Record "General Ledger Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
}
