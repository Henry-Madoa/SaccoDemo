tableextension 52204006 "Det. Cust. Ledg. CBS Ext." extends "Detailed Cust. Ledg. Entry"
{
    fields
    {
        field(52204000; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members;
            Editable = false;
        }
        field(52204001; "Sacco Transaction Type"; Enum "Sacco Transaction Type")
        {
            Editable = false;
        }
        field(52204002; "Product Posting Type"; Enum "Product Posting Type")
        {
            Editable = false;
        }
        field(52204003; "Loan No."; Code[20])
        {
            Editable = false;
        }
        field(52204004; "Transaction Time"; Time)
        {
            Editable = false;
        }
    }
}
