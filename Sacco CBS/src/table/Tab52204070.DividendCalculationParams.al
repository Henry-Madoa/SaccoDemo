table 52204070 "Dividend Calculation Params"
{
    fields
    {
        field(1; "Dividend Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Type; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false), "Product Posting Type" = filter(<> "Loan Account"));
            trigger OnValidate()
            begin
                if AccountTypesSetup.Get(Type) then begin
                    Description := AccountTypesSetup.Description;
                    "Share Capital" := AccountTypesSetup."Product Posting Type" = AccountTypesSetup."Product Posting Type"::"Share Capital Account";
                    "Minimum Balance" := AccountTypesSetup."Minimum Balance";
                    "Qualified Minimum Balance" := AccountTypesSetup."Minimum Balance";
                end;
            end;
        }
        field(3; Description; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Posting Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Rate; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Rate Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Pro Rated,Straight Line';
            OptionMembers = "Pro Rated","Straight Line";
        }
        field(7; "Post To"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Savings,Same Account,Accrue';
            OptionMembers = Savings,"Same Account",Accrue;
        }
        field(8; "Share Capital"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "Minimum Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Maximum Boost Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Qualified Minimum Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Calculated Amount"; Decimal)
        {
            CalcFormula = Sum("Dividend Det. Entries".Amount WHERE("Dividend Code" = FIELD("Dividend Code"), "Account Type" = FIELD(Type)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Account Balances"; Decimal)
        {
            CalcFormula = Sum("Dividend Det. Entries"."Account Balance" WHERE("Dividend Code" = FIELD("Dividend Code"), "Account Type" = FIELD(Type), "Month No." = CONST(12)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Boosting %"; Decimal)
        {
            DataClassification = ToBeClassified;
            Description = 'Members Without Dividend Advance';
        }
        field(15; "Boosting % 2"; Decimal)
        {
            DataClassification = ToBeClassified;
            Description = 'Members With Dividend Advance';
        }
    }
    keys
    {
        key(Key1; "Dividend Code", Type)
        {
            Clustered = true;
        }
    }
    var
        AccountTypesSetup: Record "Sacco Products";
        DividendHeader: Record "Dividend Header";
}
