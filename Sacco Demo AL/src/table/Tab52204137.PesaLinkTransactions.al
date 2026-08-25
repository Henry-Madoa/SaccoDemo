table 52204137 "PesaLink Transactions"
{
    DrillDownPageId = "Pesalink Transactions";
    LookupPageId = "Pesalink Transactions";
    fields
    {
        field(1; "Reference Number"; Code[20]) { }

        field(2; "Transaction Direction"; Enum "Channel Transactions Direction") { }

        field(3; "Channel Code"; Code[20]) { }

        field(4; "Source Account Number"; Code[20]) { }

        field(5; "Source Bank Code"; Code[20]) { }

        field(6; Amount; Decimal) { }

        field(7; Currency; Code[20]) { }

        field(8; "Member No."; Code[20]) { }

        field(9; "FOSA Account Number"; Code[20]) { }

        field(10; "Destination Account Number"; Code[20]) { }

        field(11; "Destination Bank Code"; Code[20]) { }

        field(12; Narration; Text[250]) { }

        field(13; Status; Enum "Channel Transactions Status") { }

        field(14; Comments; Text[250]) { }

        field(15; "Transaction Time"; DateTime) { }

        field(16; "Posting Time"; DateTime) { }

        field(17; Skip; Boolean) { }

        field(18; "Payment Refrence Code"; Code[35]) { }
    }

    keys
    {
        key(PK; "Reference Number")
        {
            Clustered = true;
        }
    }
}