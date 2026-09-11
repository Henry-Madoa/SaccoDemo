codeunit 52203448 "HR Make Leave Ledg. Entry"
{
    procedure CopyFromJnlLine(var InsCoverageLedgEntry: Record "Leave Ledger Entries"; var InsuranceJnlLine: Record "Leave Journal Line")
    begin
        with InsCoverageLedgEntry do begin
            "Entered By":=UserId;
            "Leave Year Code":=InsuranceJnlLine."Leave Calendar Code";
            "Employee No.":=InsuranceJnlLine."Staff No.";
            "Employee Name":=InsuranceJnlLine."Staff Name";
            "Application No.":=InsuranceJnlLine."Leave Application No.";
            "Leave Application No.":=InsuranceJnlLine."Leave Application No.";
            "Posting Date":=InsuranceJnlLine."Posting Date";
            "Leave Entry Type":=InsuranceJnlLine."Leave Entry Type";
            "Leave Type":=InsuranceJnlLine."Leave Type";
            "Leave Approval Date":=InsuranceJnlLine."Leave Approval Date";
            if "Leave Approval Date" = 0D then "Leave Approval Date":="Posting Date";
            "Document No.":=InsuranceJnlLine."Document No.";
            if InsuranceJnlLine."Leave Entry Type" = InsuranceJnlLine."Leave Entry Type"::Negative then Quantity:=-InsuranceJnlLine."No. of Days"
            else
            begin
                Quantity:=InsuranceJnlLine."No. of Days";
            end;
            Description:=InsuranceJnlLine.Description;
            "Global Dimension 1 Code":=InsuranceJnlLine."Global Dimension 1 Code";
            "Global Dimension 2 Code":=InsuranceJnlLine."Global Dimension 2 Code";
            "Journal Batch Name":=InsuranceJnlLine."Journal Batch Name";
            "Start Date":=InsuranceJnlLine."Start Date";
            "End Date":=InsuranceJnlLine."End Date";
        end;
    end;
    procedure CopyFromInsuranceCard()
    begin
    /*WITH InsCoverageLedgEntry DO BEGIN
              "FA Class Code" := Insurance."FA Class Code";
              "FA Subclass Code" := Insurance."FA Subclass Code";
              "FA Location Code" := Insurance."FA Location Code";
              "Location Code" := Insurance."Location Code";
            end;*/
    end;
    procedure SetDisposedFA(FANo: Code[20]): Boolean begin
    /*FASetup.GET;
            FASetup.TESTFIELD("Insurance Depr. Book");
            IF FADeprBook.GET(FANo,FASetup."Insurance Depr. Book") THEN
              EXIT(FADeprBook."Disposal Date" > 0D)
            ELSE
              EXIT(FALSE);
             */
    end;
    procedure UpdateLeaveApp(LeaveCode: Code[20]; Status: Option)
    var
        LeaveApplication: Record "Leave Applications";
    begin
    end;
}
