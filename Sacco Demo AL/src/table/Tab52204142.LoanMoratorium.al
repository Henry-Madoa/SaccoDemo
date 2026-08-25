table 52204142 "Loan Moratorium"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Loan Moratoriums";
    DrillDownPageId = "Loan Moratoriums";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No."; Code[20])
        {
            TableRelation = Members where(Status = filter(Active | "Not Paid Up"));
        }
        field(3; "Member Name"; Text[250])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Full Name" where("No." = field("Member No.")));
        }
        field(4; Type; Enum "Moratorium Types")
        {
        }
        field(5; "Loan No."; Code[20])
        {
            TableRelation = Loans where("Member No." = field("Member No."), "Loan Balance" = filter(> 0));

            trigger OnValidate()
            begin
                Loans.Reset();
                Loans.SetRange("No.", "Loan No.");
                Loans.SetFilter("Date Filter", '..%1', "Moratorium Start Date");
                if Loans.FindFirst then begin
                    Loans.CalcFields(Disbursements);
                    "Product Code" := Loans."Product Code";
                    "Product Name" := Loans."Product Description";
                    Loans.CalcFields("Loan Balance", "Monthly Installment", "Principal Repayment");
                    If Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::"FOSA (Partial)" then begin
                        GeneralLedgerSetup.Get;
                        If Loans."Posting Date" < GeneralLedgerSetup."Opening Balance Posting Date" then
                            "Current Principal Balance" := Loans."Openning Disbursed Balance" - Loans."Principal Repayment"
                        else
                            "Current Principal Balance" := Loans.Disbursements - Loans."Principal Repayment";
                    end else begin
                        LoanShedule.Reset();
                        LoanShedule.SetRange("Loan No.", "Loan No.");
                        LoanShedule.SetFilter("Expected Date", '..%1', "Moratorium Start Date");
                        if LoanShedule.FindSet then begin
                            if LoanShedule.Count <= 1 then
                                "Current Principal Balance" := Loans."Approved Amount"
                            else
                                "Current Principal Balance" := Loans."Approved Amount" - Loans."Principal Repayment";
                        end;
                    end;

                    "Monthly Installment" := Loans."Monthly Installment";
                    SaccoProducts.Get(Loans."Product Code");
                    "Repayment Period" := SaccoProducts."Maximum Installments";
                end;
            end;
        }
        field(6; "Product Code"; Code[20])
        {
            Editable = false;
            TableRelation = "Sacco Products" where("Product Posting Type" = const("Loan Account"));
        }
        field(7; "Product Name"; Text[100])
        {
            Editable = false;
        }
        field(8; "Current Principal Balance"; Decimal)
        {
            Editable = false;
        }
        field(9; "Moratorium Date"; Date)
        {
            trigger OnValidate()
            begin
                Validate("Moratorium Period");
            end;
        }
        field(10; "Moratorium Period"; Integer)
        {
            trigger OnValidate()
            var
                SameMonth: Boolean;
                CalculatedDate: Date;
            begin
                if "Moratorium Period" = 0 then
                    exit;
                if Loans.Get("Loan No.") then;

                "Moratorium Start Date" := CalcDate('CM', "Moratorium Date");
                "Moratorium End Date" := CalcDate(format("Moratorium Period" - 1) + 'M', "Moratorium Start Date");

                if "Moratorium Start Date" < Loans."Repayment Start Date" then
                    Error(StrSubstNo('Loan Repayment Start Date should be %1', Loans."Repayment Start Date"));

                if "Moratorium End Date" > Loans."Repayment End Date" then
                    Error(StrSubstNo('Loan Repayment End Date should be %1', Loans."Repayment End Date"));

                Loans.Get("Loan No.");
                "Remaining Installments Months" := LoansManagement.GetMonthsDifference("Moratorium End Date", Loans."Repayment End Date") - 1;
                "New Monthly Installment" := Round("Current Principal Balance" / "Remaining Installments Months");
                Validate("Loan No.");
            end;
        }
        field(11; "Moratorium Start Date"; Date)
        {
            Editable = false;
            trigger OnValidate()
            begin
                Validate("Loan No.");
            end;
        }
        field(12; "Moratorium End Date"; Date)
        {
            Editable = false;
        }
        field(13; "Remaining Installments Months"; Integer)
        {
            Editable = false;
        }
        field(14; "Restructure Date"; Date)
        {
            trigger OnValidate()
            var
                SameMonth: Boolean;
                CalculatedDate: Date;
                Day, Month, Year : integer;
            begin
                Day := Date2DMY("Restructure Date", 1);
                Month := Date2DMY("Restructure Date", 2);
                Year := Date2DMY("Restructure Date", 3);

                GeneralLedgerSetup.Get();
                SaccoProducts.Get("Product Code");
                if SaccoProducts."Repayment Cutoff Date" = 0 then
                    SameMonth := true
                else begin
                    if Date2DMY("Restructure Date", 1) > SaccoProducts."Repayment Cutoff Date" then
                        SameMonth := false
                    else
                        SameMonth := true;
                end;
                CalculatedDate := DMY2Date(1, Month, Year);
                if SameMonth then begin
                    if GeneralLedgerSetup."Loan Repayment Start" = GeneralLedgerSetup."Loan Repayment Start"::"Begining of the Month" then begin
                        "Repayment Start Date" := CalculatedDate;
                    end
                    else begin
                        "Repayment Start Date" := CalcDate('CM', CalculatedDate);
                    end;
                end
                else begin
                    if GeneralLedgerSetup."Loan Repayment Start" = GeneralLedgerSetup."Loan Repayment Start"::"Begining of the Month" then begin
                        "Repayment Start Date" := CalcDate('1M', CalculatedDate);
                    end
                    else begin
                        "Repayment Start Date" := CalcDate('CM+1M', CalculatedDate);
                    end;
                end;
            end;
        }
        field(15; "Repayment Start Date"; Date)
        {
            Editable = false;
        }
        field(16; "Monthly Installment"; Decimal)
        {
            BlankZero = true;
            Editable = false;
        }
        field(17; Installments; Integer)
        {
            BlankZero = true;

            trigger OnValidate()
            var
                Loans: Record Loans;
                LoanProducts: Record "Sacco Products";
                TotalMRepay, LInterest, LBalance, LPrincipal, PrincipalAmnt : Decimal;
            begin
                Loans.Get("Loan No.");
                if Installments > "Repayment Period" then
                    Error('You Cannot exceed %1 months', "Repayment Period");

                if "Restructure Date" = 0D then
                    "Restructure Date" := Today;

                Validate("Restructure Date");
                "Repayment End Date" := CalcDate(format(Installments) + 'M', "Repayment Start Date");

                PrincipalAmnt := "Current Principal Balance";
                LBalance := PrincipalAmnt;
               
                //Calculate New Installment
                IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::Amortised THEN BEGIN

                    IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                        TotalMRepay := ROUND((Loans."Interest Rate" / 12 / 100) / (1 - POWER((1 + (Loans."Interest Rate" / 12 / 100)), -(Rec."Installments"))) * (PrincipalAmnt), 0.0001, '>')
                    ELSE
                        TotalMRepay := ROUND((Loans."Interest Rate" / 100) / (1 - POWER((1 + (Loans."Interest Rate" / 100)), -(Rec."Installments"))) * (PrincipalAmnt), 0.0001, '>');
                    LInterest := LBalance / 100 / 12 * Loans."Interest Rate";
                    LPrincipal := TotalMRepay - LInterest;
                end;
                IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::"Straight Line" THEN BEGIN
                    LPrincipal := PrincipalAmnt / Rec."Installments";
                    IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                        LInterest := (Loans."Interest Rate" / 12 / 100) * PrincipalAmnt
                    ELSE
                        LInterest := (Loans."Interest Rate" / 100) * PrincipalAmnt;
                    LInterest := LInterest;
                end;
                IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::"Reducing Balance" THEN BEGIN
                    LPrincipal := PrincipalAmnt / Rec."Installments";
                    IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                        LInterest := (Loans."Interest Rate" / 12 / 100) * LBalance
                    ELSE
                        LInterest := (Loans."Interest Rate" / 100) * LBalance;
                    LInterest := LInterest;
                end;
                LInterest := Round(LInterest, 1, '>');
                LPrincipal := Round(LPrincipal, 1, '>');
                "New Monthly Installment" := LInterest + LPrincipal;
            end;
        }
        field(18; "New Monthly Installment"; Decimal)
        {
        }
        field(19; "Created By"; Code[100])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(20; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(21; "Repayment Period"; Integer)
        {
            Editable = false;
        }
        field(22; "Repayment End Date"; Date)
        {
            Editable = false;
        }
        field(23; Posted; Boolean)
        {
            Editable = false;
        }
        field(24; "Posted On"; Date)
        {
            Editable = false;
        }
        field(25; Status; Enum "Document Status")
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(key2; "Member No.", "Loan No.")
        {
        }
    }
    var
        NoSeries: Codeunit NoSeriesManagement;
        LoansManagement: Codeunit "Loans Management";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Loans: Record Loans;
        SaccoProducts: Record "Sacco Products";
        LoanShedule: Record "Loan Schedule";


    trigger OnInsert()
    begin
        GeneralLedgerSetup.Get();
        "No." := NoSeries.GetNextNo(GeneralLedgerSetup."Loan Restructure Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;
}
