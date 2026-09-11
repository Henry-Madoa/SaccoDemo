codeunit 52203468 "HR Appraisal Jnl.-Check Line"
{
    TableNo = "Appraisal Journal Line";

    trigger OnRun()
    var
        TempJnlLineDim: Record "Journal Line Dimension" temporary;
    begin
        GLSetup.Get;
        if Rec."Shortcut Dimension 1 Code" <> '' then begin
            TempJnlLineDim."Table ID":=DATABASE::"Appraisal Journal Line";
            TempJnlLineDim."Journal Template Name":=Rec."Journal Template Name";
            TempJnlLineDim."Journal Batch Name":=Rec."Journal Batch Name";
            TempJnlLineDim."Journal Line No.":=Rec."Line No.";
            TempJnlLineDim."Dimension Code":=GLSetup."Global Dimension 1 Code";
            TempJnlLineDim."Dimension Value Code":=Rec."Shortcut Dimension 1 Code";
            TempJnlLineDim.Insert;
        end;
        if Rec."Shortcut Dimension 2 Code" <> '' then begin
            TempJnlLineDim."Table ID":=DATABASE::"Appraisal Journal Line";
            TempJnlLineDim."Journal Template Name":=Rec."Journal Template Name";
            TempJnlLineDim."Journal Batch Name":=Rec."Journal Batch Name";
            TempJnlLineDim."Journal Line No.":=Rec."Line No.";
            TempJnlLineDim."Dimension Code":=GLSetup."Global Dimension 2 Code";
            TempJnlLineDim."Dimension Value Code":=Rec."Shortcut Dimension 2 Code";
            TempJnlLineDim.Insert;
        end;
        RunCheck(Rec, TempJnlLineDim);
    end;
    var Text000: Label 'The combination of dimensions used in %1 %2, %3, %4 is blocked. %5';
    Text001: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5';
    GLSetup: Record "General Ledger Setup";
    FASetup: Record "Human Resource Setup";
    DimMgt: Codeunit DimensionManagement;
    CallNo: Integer;
    Text002: Label 'The Posting Date Must be within the open leave periods';
    Text003: Label 'The Posting Date Must be within the allowed Setup date';
    Text004: Label 'The Allocation of Leave days has been done for the period';
    procedure ValidatePostingDate(var InsuranceJnlLine: Record "Appraisal Journal Line")
    begin
        with InsuranceJnlLine do begin
            TestField("Appraisal Period");
            TestField("Document No.");
            TestField("Posting Date");
            TestField("Staff No.");
            if("Posting Date" < "Appraisal Period Start Date") or ("Posting Date" > "Appraisal Period End Date")then FASetup.Get();
        end;
    end;
    procedure RunCheck(var InsuranceJnlLine: Record "Appraisal Journal Line"; var JnlLineDim: Record "Journal Line Dimension")
    var
        TableID: array[10]of Integer;
        No: array[10]of Code[20];
    begin
        with InsuranceJnlLine do begin
            TestField("Appraisal No.");
            TestField("Document No.");
            TestField("Posting Date");
            TestField("Staff No.");
            CallNo:=1;
            TableID[1]:=DATABASE::"Appraisal Journal Line";
            if "Line No." <> 0 then Error(Text001, TableCaption, "Journal Template Name", "Journal Batch Name", "Line No.", DimMgt.GetDimValuePostingErr)
            else
                Error(DimMgt.GetDimValuePostingErr);
        end;
        ValidatePostingDate(InsuranceJnlLine);
    end;
}
