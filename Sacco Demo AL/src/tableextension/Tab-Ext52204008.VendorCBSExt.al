tableextension 52204008 "Vendor CBS Ext." extends Vendor
{
    fields
    {
        field(52204000; "Member No."; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members;
        }
        field(52204001; Status; Enum "Member Status")
        {
        }
        field(52204002; "Product Posting Type"; Enum "Product Posting Type")
        {
        }
        field(52204003; "Product Code"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1));
            Editable = false;
        }
        field(52204004; "Business Account"; Boolean)
        {
        }
        field(52204005; "ATM Use Allowed"; Boolean)
        {
        }
        field(52204006; "Cash Withdraw Allowed"; Boolean)
        {
        }
        field(52204007; "Cash Deposit Allowed"; Boolean)
        {
        }
        field(52204008; "Cash Transfer Allowed"; Boolean)
        {
        }
        field(52204009; "Card No"; Code[50])
        {
            Editable = false;
        }
        field(52204010; "Cheque Book Allowed"; Boolean)
        {
        }
        field(52204011; "Uncleared Funds"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Uncleared Funds".Amount where("Account No" = field("No."), Cleared = const(false)));
        }
        field(52204012; "Cheques On Hand"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Cheque Deposits".Amount where("Account No." = field("No."), Status = const(Approved)));
        }
        field(52204013; "Member Name"; Text[100])
        {
            Caption = 'Search Name';
            Editable = false;
        }
        field(52204014; "Business Location"; Text[100])
        {
            Editable = false;
        }
        field(52204015; "Paybill Business Account No."; Code[20])
        {
        }
        field(52204016; "Loan Recovery Priority"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52204017; "Print Sequence"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52204018; "Date Of Birth"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52204019; "Notification Sent"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52204020; "Salary Based"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52204021; "Divinded Based"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52204022; "Mobile Loan"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(52204023; "Can Prompt STK Push"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(Key22; "Print Sequence")
        {
        }
    }
}
