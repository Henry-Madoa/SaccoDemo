table 52204117 "Loan Repayment Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Entry No"; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Loan No"; Code[20])
        {
            trigger OnLookup()
            var
                LoanApp: Record Loans;
                LoanRepayment: Record "Loan Repayment Header";
                LoansMgt: Codeunit "Loans Management";
            begin
                LoanRepayment.Get("No.");
                LoanApp.Reset();
                LoanApp.SetFilter("Loan Balance", '>0');
                LoanApp.SetRange("Member No.", LoanRepayment."Member No");
                if Page.RunModal(0, LoanApp) = Action::LookupOK then begin
                    LoanApp.CalcFields("Loan Balance", "Penalty Balance", "Interest Balance", "Principal Balance");
                    "Loan No" := LoanApp."No.";
                    "Loan Name" := LoanApp."Product Description";
                    "Loan Account" := LoanApp."Loan Account";
                    "Penalty Balance" := LoanApp."Penalty Balance";
                    "Accrued Interest" := LoansMgt.GetProratedInterest(LoanApp."No.", LoanRepayment."Posting Date");
                    "Interest Balance" := LoanApp."Interest Balance";
                    "Principal Balance" := LoanApp."Principal Balance";
                    "Loan Balance" := LoanApp."Loan Balance";
                end;
            end;
        }
        field(4; "Loan Name"; Text[100])
        {
            Editable = false;
        }
        field(5; "Penalty Balance"; Decimal)
        {
            Editable = false;
        }
        field(6; "Accrued Interest"; Decimal)
        {
            Editable = false;
        }
        field(7; "Interest Balance"; Decimal)
        {
            Editable = false;
        }
        field(8; "Principal Balance"; Decimal)
        {
            Editable = false;
        }
        field(9; "Payment Amount"; Decimal)
        {
            trigger OnValidate()
            var
                LoanRepayment: Record "Loan Repayment Header";
                JournalMgmt: Codeunit "Journal Management";
                GeneralLedgerSetup: Record "General Ledger Setup";
            begin
                if LoanRepayment.Get("No.") then begin
                    if LoanRepayment."Available Balance" < "Payment Amount" then
                        Error(StrSubstNo('You cannot pay more than the available balance, The available balance is %1,', LoanRepayment."Available Balance"));

                    GeneralLedgerSetup.Get;
                    GeneralLedgerSetup.TestField("Loan Repayment Charge");
                    "Charge Code" := GeneralLedgerSetup."Loan Repayment Charge";
                    "Charge Amount" := JournalMgmt.GetChargesAmount("Charge Code", "Payment Amount");
                end;
            end;
        }
        field(10; "Loan Account"; Code[20])
        {
            Editable = false;
        }
        field(11; "Loan Balance"; Decimal)
        {
            Editable = false;
        }
        field(12; "Charge Code"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(13; "Charge Amount"; Decimal)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.", "Entry No")
        {
            Clustered = true;
        }
    }
}
