codeunit 52203467 "Investment Mgmt"
{
    PROCEDURE CreateSchedule(FinancialInvestmentHeader: Record "Fixed Deposit Header");
    VAR
        FINEntries: Record "Fixed Deposit Schedule";
        Lprinciple: Decimal;
        Linterest: Decimal;
        StartDate: Date;
        EndDate: Date;
        EntryNo: Integer;
        RepDate: Date;
        PayableAmount: Decimal;
    BEGIN
        FINEntries.RESET;
        FINEntries.SETRANGE("Investment No", FinancialInvestmentHeader."No.");
        IF FINEntries.FINDFIRST THEN FINEntries.DELETEALL;
        FINEntries.RESET;
        IF FINEntries.FINDLAST THEN EntryNo:=FINEntries."Entry No." + 1
        ELSE
            EntryNo:=1;
        StartDate:=FinancialInvestmentHeader."Investment Date";
        EndDate:=FinancialInvestmentHeader."Maturity Date";
        RepDate:=CALCDATE(FinancialInvestmentHeader."Investment Period", StartDate);
        RepDate:=CALCDATE('-1M', RepDate);
        Lprinciple:=FinancialInvestmentHeader."Face Value";
        REPEAT Linterest:=Lprinciple * FinancialInvestmentHeader."Negotiated Intrest" * (1 / 1200);
            IF FinancialInvestmentHeader."Interest Type" = FinancialInvestmentHeader."Interest Type"::"Reducing Balannce" THEN Lprinciple+=Linterest;
            PayableAmount+=Linterest;
            FINEntries.INIT;
            FINEntries."Investment No":=FinancialInvestmentHeader."No.";
            FINEntries."Entry No.":=EntryNo;
            EntryNo+=1;
            FINEntries."No.":=GetPrefix(StartDate);
            FINEntries."Entry Type":=FINEntries."Entry Type"::"Interest Due";
            FINEntries.Description:='Interest Receivable ' + FINEntries."No.";
            FINEntries.Amount:=Linterest;
            FINEntries."Posting Date":=StartDate;
            FINEntries.INSERT;
            IF StartDate = RepDate THEN BEGIN
                FINEntries.INIT;
                FINEntries."Investment No":=FinancialInvestmentHeader."No.";
                FINEntries."Entry No.":=EntryNo;
                EntryNo+=1;
                FINEntries."No.":=GetPrefix(StartDate);
                FINEntries."Entry Type":=FINEntries."Entry Type"::"Payment Due";
                FINEntries.Description:='Interest Receivable ' + FINEntries."No.";
                FINEntries.Amount:=PayableAmount;
                FINEntries."Posting Date":=StartDate;
                FINEntries.INSERT;
                RepDate:=CALCDATE(FinancialInvestmentHeader."Investment Period", RepDate);
                PayableAmount:=0;
            END;
            StartDate:=CALCDATE(FinancialInvestmentHeader."Investment Period", StartDate);
            IF StartDate >= EndDate THEN BEGIN
                FINEntries.INIT;
                FINEntries."Investment No":=FinancialInvestmentHeader."No.";
                FINEntries."Entry No.":=EntryNo;
                EntryNo+=1;
                FINEntries."No.":=GetPrefix(StartDate);
                FINEntries."Entry Type":=FINEntries."Entry Type"::"Principle Due";
                FINEntries.Description:='Principle Receivable ' + FINEntries."No.";
                FINEntries.Amount:=FinancialInvestmentHeader."Face Value";
                FINEntries."Posting Date":=StartDate;
                FINEntries.INSERT;
            END;
        UNTIL StartDate >= EndDate;
    END;
    LOCAL PROCEDURE GetPrefix(ParseDate: Date)DocNo: Code[20];
    BEGIN
        DocNo:='';
        CASE DATE2DMY(ParseDate, 2)OF 1: DocNo:='JAN-';
        2: DocNo:='FEB-';
        3: DocNo:='MAR-';
        4: DocNo:='APR-';
        5: DocNo:='MAY-';
        6: DocNo:='JUN-';
        7: DocNo:='JUL-';
        8: DocNo:='AUG-';
        9: DocNo:='SEP-';
        10: DocNo:='OCT-';
        11: DocNo:='NOV-';
        12: DocNo:='DEC-';
        END;
        DocNo+=FORMAT(DATE2DMY(ParseDate, 3));
    END;
    [IntegrationEvent(false, false)]
    PROCEDURE OnPostFD(VAR FDHeader: Record "Fixed Deposit Header");
    BEGIN
    END;
    LOCAL PROCEDURE "*****End of FD Posting*******"();
    BEGIN
    END;
    [IntegrationEvent(false, false)]
    PROCEDURE OnPostLiquidation(VAR FDHeader: Record "Fixed Deposit Header");
    BEGIN
    END;
}
