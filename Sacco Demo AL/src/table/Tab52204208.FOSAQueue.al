table 52204208 "FOSA Queue"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; PrimaryKey; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Gross Disbursals"; decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum(Loans."Approved Amount" where(Status = const(Approved), Posted = const(true)));
        }
        field(3; "Placements Portfolio"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Member Fixed Deposits".Amount where(Terminated = const(false)));
        }
        field(4; "Collateral in Store"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Collateral Register"."Collateral Value" where(Status = filter(<> Collected)));
        }
        field(5; "User ID"; code[100])
        {
        }
        field(6; "Requests to Approve"; Integer)
        {
            FieldClass = flowfield;
            CalcFormula = count("Approval Entry" where(Status = const(Created), "Approver ID" = field("User ID")));
            Editable = false;
        }
        field(7; "Running Standing Orders"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Standing Order" where(Running = const(true)));
        }
        field(8; "Total Members"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Members);
        }
        field(9; "Pending Member Applications"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Member Application" where(Processed = const(false)));
        }
        field(10; "Mobile Transactions"; Decimal)
        {
            Caption = 'Pending Mobile Transactions';
            FieldClass = FlowField;
            CalcFormula = sum("Channel Transactions".Amount where(Posted = const(false)));
        }
        field(11; "ATM Transactions"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("ATM Transactions".Amount where(Posted = const(false)));
            Caption = 'Pending ATM Transactions';
        }
        field(12; "ATM Applications"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("ATM Application");
        }
        field(13; "Treasury Transactions"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("FOSA Transactions" where(Posted = const(false)));
        }
        field(14; "Mobile Loans"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("E-Loan Application"."Applied Amount");
        }
        field(15; "Mobile Credits"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Channel Transaction Dump".Amount where("Posting Type" = const(Credit)));
        }
        field(16; "Mobile Debits"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Channel Transaction Dump".Amount where("Posting Type" = const(Debit)));
        }
        field(17; "Total ATM Transactions"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("ATM Transactions".Amount);
        }
    }
    keys
    {
        key(PK; PrimaryKey, "User ID")
        {
            Clustered = true;
        }
    }
}
