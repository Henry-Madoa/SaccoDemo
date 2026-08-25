table 52204205 "ICS Mobile Transactions"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No."; Code[30])
        {
        }
        field(2; "Transaction Date"; Date)
        {
        }
        field(3; "Account No."; Code[50])
        {
            TableRelation = Vendor."No.";
            ValidateTableRelation = false;
        }
        field(4; "Description"; Text[200])
        {
        }
        field(5; "Amount"; Decimal)
        {
        }
        field(6; "Posted"; Boolean)
        {
        }
        field(7; "Transaction Type"; enum "Mobile Transaction Type")
        {
            // {trigger OnValidate()
            //     var
            //     begin
            //         if "Transaction Type" = "Transaction Type"::" " then
            //             Error(Format("Transaction Type"));
            //       end;
        }
        field(8; "Transaction Time"; Time)
        {
        }
        field(9; "Account No 2"; Code[50])
        {
        }
        field(10; "Date Posted"; Date)
        {
        }
        field(11; "Time Posted"; Time)
        {
        }
        field(12; "Comments"; Text[250])
        {
        }
        field(13; "Charge"; Decimal)
        {
        }
        field(14; "Name"; Text[100])
        {
            ObsoleteState = Removed;
            //FieldClass = FlowField;
            //CalcFormula = lookup(Vendor.Name where("No." = field("Account No.")));
        }
        field(27; "Names"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor."Search Name" where("No." = field("Account No.")));
        }
        field(15; "Keyword"; Code[20])
        {
        }
        field(16; "ID No"; Code[30])
        {
        }
        field(17; "Mobile No"; Code[30])
        {
        }
        field(18; "Status"; Option)
        {
            OptionMembers = "Pending Posting","Completed","Failed","Sending Money";
            OptionCaption = 'Pending Posting,Completed,Failed,Sending Money';
        }
        field(19; "Source"; Option)
        {
            OptionMembers = Fosa,Mpesa;
            OptionCaption = 'Fosa,Mpesa';
        }
        field(20; "Type"; Code[20])
        {
        }
        field(21; "Reference"; Code[50])
        {
        }
        field(22; "Loan No"; Code[30])
        {
        }
        field(23; "Tranfer To"; Option)
        {
            OptionMembers = " ",Self,Other,Loan;
            OptionCaption = ' ,Self,Other,Loan';
        }
        field(24; "Channel"; Option)
        {
            OptionMembers = " ",App,Ussd;
            OptionCaption = ' ,App,Ussd';
        }
        field(25; "Document No. Initial"; Code[30])
        {
        }
        field(26; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            autoIncrement = true;
        }
        field(28; "Member No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Call Back updated"; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; "Line No")
        {
            Clustered = true;
        }
    }
}
