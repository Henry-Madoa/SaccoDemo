tableextension 52203454 "Bank Account" extends "Bank Account"
{
    fields
    {
        modify("Bank Branch No.")
        {
            TableRelation = "External Bank Branches"."Branch Code" where("Bank Code" = field(Bank_Code));
        }
        // Add changes to table fields here
        field(52204000; "Account Type"; Enum "Bank Account Types")
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Tag Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50002; "Tag Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            //TableRelation = Table0;
        }
        field(50003; "Custodial Payment Account"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "Minimum Float"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50005; "Maximum Float"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50006; "Petty Cash Holder"; Code[20])
        {
            TableRelation = Employee where(Status = const(Active));
        }
        field(50008; "Bank Sort Code"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50009; Bank_Code; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "External Banks";
            Caption = 'Bank Code';
        }
    }
}
