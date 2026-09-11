table 52203501 "Customer Charges"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Customer Charges";
    DrillDownPageId = "Customer Charges";

    fields
    {
        field(1; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer where("Customer Posting Group"=const('TENANT'));

            trigger OnValidate()
            begin
                if Cust.Get("Customer No.")then begin
                    Cust.TestField("VAT Bus. Posting Group");
                    Cust.TestField("E-Mail");
                    "VAT Bus. Posting Group":=Cust."VAT Bus. Posting Group";
                end;
            end;
        }
        field(3; "Charge Code"; Code[20])
        {
            TableRelation = "Charges Setup";

            trigger OnValidate()
            begin
                if ChargesSetup.Get("Charge Code")then begin
                    "VAT Prod. Posting Group":=ChargesSetup."VAT Prod. Posting Group";
                    "GL Account":=ChargesSetup."GL Account";
                    Description:=ChargesSetup.Description;
                end;
            end;
        }
        field(4; Description; Text[50])
        {
            Editable = false;
        }
        field(5; Amount; Decimal)
        {
            trigger OnValidate()
            var
                VATAmount: Decimal;
            begin
                GLSetup.Get;
                GLSetup.TestField("Rounding Type");
                GLSetup.TestField("Amount Rounding Precision");
                if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Up then Direction:='>'
                else if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Nearest then Direction:='='
                    else if GLSetup."Rounding Type" = GLSetup."Rounding Type"::Down then Direction:='<';
                if not VATSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group")then Error('VAT Posting Setup for %1 and %2 do not exist', "VAT Bus. Posting Group", "VAT Prod. Posting Group")
                else
                begin
                    VATAmount:=Round((Amount / (1 + VATSetup."VAT %" / 100) * VATSetup."VAT %" / 100), GLSetup."Amount Rounding Precision", Direction);
                    "Amount Excl. Tax":=Amount - VATAmount;
                end;
            end;
        }
        field(6; "Amount Excl. Tax"; Decimal)
        {
            Editable = false;
        }
        field(7; "VAT Prod. Posting Group"; Code[20])
        {
            Editable = false;
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(8; "VAT Bus. Posting Group"; Code[20])
        {
            Editable = false;
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(9; "GL Account"; Code[20])
        {
            TableRelation = "G/L Account" where(Blocked=const(false), "Direct Posting"=const(true), "Account Type"=const(Posting));
        }
    }
    keys
    {
        key(Key1; "Line No", "Customer No.")
        {
            Clustered = true;
        }
        key(Key2; "Customer No.", "Line No")
        {
        }
    }
    var ChargesSetup: Record "Charges Setup";
    Cust: Record Customer;
    VATSetup: Record "VAT Posting Setup";
    GLSetup: Record "General Ledger Setup";
    Direction: Text;
}
