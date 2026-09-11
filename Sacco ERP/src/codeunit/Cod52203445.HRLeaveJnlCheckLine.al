codeunit 52203445 "HR Leave Jnl.- Check Line"
{
    TableNo = "Leave Journal Line";

    trigger OnRun()
    var
        TempJnlLineDim: Record "Journal Line Dimension" temporary;
    begin
        GLSetup.Get;
        if Rec."Global Dimension 1 Code" <> '' then begin
            TempJnlLineDim."Table ID":=DATABASE::"Leave Journal Line";
            TempJnlLineDim."Journal Template Name":=Rec."Journal Template Name";
            TempJnlLineDim."Journal Batch Name":=Rec."Journal Batch Name";
            TempJnlLineDim."Journal Line No.":=Rec."Line No.";
            TempJnlLineDim."Dimension Code":=GLSetup."Global Dimension 1 Code";
            TempJnlLineDim."Dimension Value Code":=Rec."Global Dimension 1 Code";
            TempJnlLineDim.Insert;
        end;
        if Rec."Global Dimension 2 Code" <> '' then begin
            TempJnlLineDim."Table ID":=DATABASE::"Leave Journal Line";
            TempJnlLineDim."Journal Template Name":=Rec."Journal Template Name";
            TempJnlLineDim."Journal Batch Name":=Rec."Journal Batch Name";
            TempJnlLineDim."Journal Line No.":=Rec."Line No.";
            TempJnlLineDim."Dimension Code":=GLSetup."Global Dimension 2 Code";
            TempJnlLineDim."Dimension Value Code":=Rec."Global Dimension 2 Code";
            TempJnlLineDim.Insert;
        end;
        RunCheck(Rec, TempJnlLineDim);
    end;
    var Text000: Label 'The combination of dimensions used in %1 %2, %3, %4 is blocked. %5';
    Text001: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5';
    GLSetup: Record "General Ledger Setup";
    DimMgt: Codeunit DimensionManagement;
    CallNo: Integer;
    Text002: Label 'The Posting Date Must be within the open leave periods';
    Text003: Label 'The Posting Date Must be within the allowed Setup date';
    Text004: Label 'The Allocation of Leave days has been done for the period';
    procedure RunCheck(var InsuranceJnlLine: Record "Leave Journal Line"; var JnlLineDim: Record "Journal Line Dimension")
    var
        TableID: array[10]of Integer;
        No: array[10]of Code[20];
    begin
        with InsuranceJnlLine do begin
            if "Leave Entry Type" = "Leave Entry Type"::Negative then begin
                TestField("Leave Calendar Code");
            end;
            TestField("Document No.");
            TestField("Posting Date");
            TestField("Staff No.");
            CallNo:=1;
            No[1]:="Leave Calendar Code";
        end; //ValidatePostingDate(InsuranceJnlLine);
    end;
}
