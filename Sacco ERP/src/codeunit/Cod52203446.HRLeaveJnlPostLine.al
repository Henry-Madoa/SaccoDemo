codeunit 52203446 "HR Leave Jnl.- Post Line"
{
    Permissions = TableData "Ins. Coverage Ledger Entry"=rimd,
        TableData "Insurance Register"=rimd;
    TableNo = "Leave Journal Line";

    trigger OnRun()
    var
        TempJnlLineDim2: Record "Journal Line Dimension" temporary;
    begin
        GLSetup.Get;
        TempJnlLineDim2.Reset;
        TempJnlLineDim2.DeleteAll;
        if Rec."Global Dimension 1 Code" <> '' then begin
            TempJnlLineDim2."Table ID":=DATABASE::"Insurance Journal Line";
            TempJnlLineDim2."Journal Template Name":=Rec."Journal Template Name";
            TempJnlLineDim2."Journal Batch Name":=Rec."Journal Batch Name";
            TempJnlLineDim2."Journal Line No.":=Rec."Line No.";
            TempJnlLineDim2."Dimension Code":=GLSetup."Global Dimension 1 Code";
            TempJnlLineDim2."Dimension Value Code":=Rec."Global Dimension 1 Code";
            TempJnlLineDim2.Insert;
        end;
        if Rec."Global Dimension 2 Code" <> '' then begin
            TempJnlLineDim2."Journal Template Name":=Rec."Journal Template Name";
            TempJnlLineDim2."Journal Batch Name":=Rec."Journal Batch Name";
            TempJnlLineDim2."Journal Line No.":=Rec."Line No.";
            TempJnlLineDim2."Dimension Code":=GLSetup."Global Dimension 2 Code";
            TempJnlLineDim2."Dimension Value Code":=Rec."Global Dimension 2 Code";
            TempJnlLineDim2.Insert;
        end;
        RunWithCheck(Rec, TempJnlLineDim2);
    end;
    var GLSetup: Record "General Ledger Setup";
    FA: Record Employee;
    Insurance: Record "Leave Applications";
    InsuranceJnlLine: Record "Leave Journal Line";
    InsCoverageLedgEntry: Record "Leave Ledger Entries";
    InsCoverageLedgEntry2: Record "Leave Ledger Entries";
    InsuranceReg: Record "Insurance Register";
    TempJnlLineDim: Record "Journal Line Dimension" temporary;
    InsuranceJnlCheckLine: Codeunit "HR Leave Jnl.- Check Line";
    MakeInsCoverageLedgEntry: Codeunit "HR Make Leave Ledg. Entry";
    DimMgt: Codeunit DimensionManagement;
    NextEntryNo: Integer;
    procedure RunWithCheck(var InsuranceJnlLine2: Record "Leave Journal Line"; var TempJnlLineDim2: Record "Journal Line Dimension")
    begin
        InsuranceJnlLine.Copy(InsuranceJnlLine2);
        TempJnlLineDim.Reset;
        TempJnlLineDim.DeleteAll;
        Code(true);
        InsuranceJnlLine2:=InsuranceJnlLine;
    end;
    procedure RunWithOutCheck(var InsuranceJnlLine2: Record "Leave Journal Line"; var TempJnlLineDim2: Record "Journal Line Dimension")
    begin
        InsuranceJnlLine.Copy(InsuranceJnlLine2);
        TempJnlLineDim.Reset;
        TempJnlLineDim.DeleteAll;
        Code(false);
        InsuranceJnlLine2:=InsuranceJnlLine;
    end;
    local procedure "Code"(CheckLine: Boolean)
    begin
        with InsuranceJnlLine do begin
            if "Document No." = '' then exit;
            if CheckLine then InsuranceJnlCheckLine.RunCheck(InsuranceJnlLine, TempJnlLineDim);
            Insurance.Reset;
            FA.Reset;
            FA.SetRange("No.", "Staff No.");
            if FA.FindFirst then MakeInsCoverageLedgEntry.CopyFromJnlLine(InsCoverageLedgEntry, InsuranceJnlLine);
        end;
        if NextEntryNo = 0 then begin
            InsCoverageLedgEntry.LockTable;
            if InsCoverageLedgEntry2.Find('+')then NextEntryNo:=InsCoverageLedgEntry2."Entry No.";
            InsuranceReg.LockTable;
            if InsuranceReg.Find('+')then InsuranceReg."No.":=InsuranceReg."No." + 1
            else
                InsuranceReg."No.":=1;
            InsuranceReg.Init;
            InsuranceReg."From Entry No.":=NextEntryNo + 1;
            InsuranceReg."Creation Date":=WorkDate;
            InsuranceReg."Source Code":=InsuranceJnlLine."Source Code";
            InsuranceReg."Journal Batch Name":=InsuranceJnlLine."Journal Batch Name";
            InsuranceReg."User ID":=UserId;
        end;
        NextEntryNo:=NextEntryNo + 1;
        InsCoverageLedgEntry."Entry No.":=NextEntryNo;
        InsCoverageLedgEntry.Insert;
        if InsuranceReg."To Entry No." = 0 then begin
            InsuranceReg."To Entry No.":=NextEntryNo;
            InsuranceReg.Insert;
        end
        else
        begin
            InsuranceReg."To Entry No.":=NextEntryNo;
            InsuranceReg.Modify;
        end;
    end;
}
