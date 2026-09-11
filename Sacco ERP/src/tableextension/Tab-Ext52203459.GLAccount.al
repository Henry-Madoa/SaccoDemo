tableextension 52203459 "G/L Account" extends "G/L Account"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Commitment Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Commitment Entries"."Committed Amount" WHERE("Account No." = FIELD("No.")));
        }
        field(50002; "Requisition Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "Show on Claim"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "Asset Code Mandatory"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50005; "Asset Filter"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Fixed Asset";
        }
        field(50006; "Imprest/Loan Code Mandatory"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50007; "Income/Expense"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Income,Expense;
        }
        field(50008; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,Bank,"Accumulated Profit","Accounts Payable",Capital,"Current Asset","Current Liability",Expense,"Fixed Asset",Income,"Long Term Liability",TradignExpense,"Trading Income";
        }
        field(50009; "Acc  Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,"Commission Due",Tax;
        }
        field(50010; "Fund Filter"; Code[20])
        {
            //FieldClass = FlowFilter;
        }
        field(50011; "Global Dimension 3 Filter"; Code[20])
        {
            FieldClass = FlowFilter;
            CaptionClass = '1,3,3';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3));
        }
    }
}
