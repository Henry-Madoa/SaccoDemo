table 52204141 "Channel Transactions"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Transaction Type"; Code[20])
        {
        }
        field(3; "Document No"; Code[20])
        {
        }
        field(4; "Cr_Member No"; Code[20])
        {
        }
        field(5; "Dr_Member No"; Code[20])
        {
        }
        field(6; "Cr_Account No"; Code[20])
        {
        }
        field(7; "Dr_Account No"; Code[20])
        {
        }
        field(8; Amount; Decimal)
        {
        }
        field(9; "Created On"; DateTime)
        {
        }
        field(10; "Created By"; Code[100])
        {
        }
        field(11; Posted; Boolean)
        {
        }
        field(12; Narration; Text[100])
        {
        }
        field(13; "Utility Code"; Code[20])
        {
        }
        field(14; "Posted On"; DateTime)
        {
        }
        field(15; "Credit Member Name"; Text[200])
        {
            fieldclass = flowfield;
            CalcFormula = lookup(Members."Full Name" where("No." = field("Cr_Member No")));
        }
        field(16; "Debit Member Name"; Text[200])
        {
            fieldclass = flowfield;
            CalcFormula = lookup(Members."Full Name" where("No." = field("Dr_Member No")));
        }
        field(17; "Transaction Name"; Text[100])
        {
        }
        field(18; Skip; Boolean)
        {
        }
        field(19; "Payment Refrence Code"; Code[20])
        {
        }
        field(20; Confirmed; Boolean)
        {
        }
        field(21; "Confirmation Time"; DateTime)
        {
        }
        field(22; Reversed; Boolean)
        {
        }
        field(23; Phone; Code[50])
        {
        }
        field(24; Name; Text[100])
        {
        }
        field(25; "Account Reference"; Code[20])
        {
        }
        field(26; "Loan No."; Code[20])
        {
            trigger OnValidate()
            var
                Loans: Record Loans;
            begin
                If Loans.Get("Loan No.") then "Cr_Account No" := Loans."Loan Account";
            end;
        }
        field(27; "Posting Date"; Date)
        {
        }
        field(28; "Paybill Transaction Type"; Enum "Paybill Transaction Types")
        {
        }
    }
    keys
    {
        key(Key1; "Entry No", "Document No")
        {
            Clustered = true;
        }
    }
    procedure GetLastEntryNo() EntryNo: Integer
    var
        ArchivedChannelTransactions: Record "Archived Channel Transactions";
    begin
        ArchivedChannelTransactions.Reset;
        IF ArchivedChannelTransactions.FindLast THEN
            EntryNo := ArchivedChannelTransactions."Entry No" + 1
        ELSE
            EntryNo := 1;
    end;
}
