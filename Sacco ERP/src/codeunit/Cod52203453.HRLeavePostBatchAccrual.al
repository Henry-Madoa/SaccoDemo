codeunit 52203453 "HR Leave Post Batch Accrual"
{
    TableNo = "Leave Journal Line";

    trigger OnRun()
    begin
        InsuranceJnlLine.Copy(Rec);
        Code;
    //Rec:= InsuranceJnlLine;
    end;
    var Text000: Label 'cannot exceed %1 characters';
    Text001: Label 'Journal Batch Name    #1##########\\';
    Text002: Label 'Checking lines        #2######\';
    Text003: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@';
    Text004: Label 'A maximum of %1 posting number series can be used in each journal.';
    InsuranceJnlLine: Record "Leave Journal Line";
    InsuranceJnlTempl: Record "Leave Journal Template";
    InsuranceJnlBatch: Record "Leave Journal Batch";
    InsuranceReg: Record "Leave Register";
    InsCoverageLedgEntry: Record "Leave Ledger Entries";
    InsuranceJnlLine2: Record "Leave Journal Line";
    InsuranceJnlLine3: Record "Leave Journal Line";
    NoSeries: Record "No. Series" temporary;
    InsuranceJnlPostLine: Codeunit "HR Leave Jnl.- Post Line";
    InsuranceJnlCheckLine: Codeunit "HR Leave Jnl.- Check Line";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    NoSeriesMgt2: array[10]of Codeunit NoSeriesManagement;
    DimMgt: Codeunit DimensionManagement;
    Window: Dialog;
    LineCount: Integer;
    StartLineNo: Integer;
    NoOfRecords: Integer;
    InsuranceRegNo: Integer;
    LastDocNo: Code[20];
    LastDocNo2: Code[20];
    LastPostedDocNo: Code[20];
    NoOfPostingNoSeries: Integer;
    PostingNoSeriesNo: Integer;
    procedure "Code"()
    var
        JnlLineDim: Record "Journal Line Dimension";
        TempJnlLineDim: Record "Journal Line Dimension" temporary;
        UpdateAnalysisView: Codeunit "Update Analysis View";
    begin
        with InsuranceJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            if RecordLevelLocking then LockTable;
            InsuranceJnlTempl.Get("Journal Template Name");
            InsuranceJnlBatch.Get("Journal Template Name", "Journal Batch Name");
            if StrLen(IncStr(InsuranceJnlBatch.Name)) > MaxStrLen(InsuranceJnlBatch.Name)then InsuranceJnlBatch.FieldError(Name, StrSubstNo(Text000, MaxStrLen(InsuranceJnlBatch.Name)));
            if not Find('=><')then begin
                Commit;
                "Line No.":=0;
                exit;
            end;
            LineCount:=0;
            StartLineNo:="Line No.";
            repeat LineCount:=LineCount + 1;
                JnlLineDim.SetRange("Table ID", DATABASE::"Insurance Journal Line");
                JnlLineDim.SetRange("Journal Template Name", "Journal Template Name");
                JnlLineDim.SetRange("Journal Batch Name", "Journal Batch Name");
                JnlLineDim.SetRange("Journal Line No.", "Line No.");
                JnlLineDim.SetRange("Allocation Line No.", 0);
                TempJnlLineDim.DeleteAll;
                InsuranceJnlCheckLine.RunCheck(InsuranceJnlLine, TempJnlLineDim);
                if Next = 0 then Find('-');
            until "Line No." = StartLineNo;
            NoOfRecords:=LineCount; //LedgEntryDim.LOCKTABLE;
            InsCoverageLedgEntry.LockTable;
            if RecordLevelLocking then if InsCoverageLedgEntry.Find('+')then;
            InsuranceReg.LockTable;
            if InsuranceReg.Find('+')then InsuranceRegNo:=InsuranceReg."No." + 1
            else
                InsuranceRegNo:=1; // Post lines
            LineCount:=0;
            LastDocNo:='';
            LastDocNo2:='';
            LastPostedDocNo:='';
            Find('-');
            repeat LineCount:=LineCount + 1;
                if not("Leave Calendar Code" = '') and (InsuranceJnlBatch."No. Series" <> '') and ("Document No." <> LastDocNo2)then TestField("Document No.", NoSeriesMgt.GetNextNo(InsuranceJnlBatch."No. Series", "Posting Date", false));
                LastDocNo2:="Document No.";
                if "Posting No. Series" = '' then "Posting No. Series":=InsuranceJnlBatch."No. Series"
                else if not("Leave Calendar Code" = '')then if "Document No." = LastDocNo then "Document No.":=LastPostedDocNo
                        else
                        begin
                            if not NoSeries.Get("Posting No. Series")then begin
                                NoOfPostingNoSeries:=NoOfPostingNoSeries + 1;
                                if NoOfPostingNoSeries > ArrayLen(NoSeriesMgt2)then Error(Text004, ArrayLen(NoSeriesMgt2));
                                NoSeries.Code:="Posting No. Series";
                                NoSeries.Description:=Format(NoOfPostingNoSeries);
                                NoSeries.Insert;
                            end;
                            LastDocNo:="Document No.";
                            Evaluate(PostingNoSeriesNo, NoSeries.Description);
                            "Document No.":=NoSeriesMgt2[PostingNoSeriesNo].GetNextNo("Posting No. Series", "Posting Date", false);
                            LastPostedDocNo:="Document No.";
                        end;
                JnlLineDim.SetRange("Table ID", DATABASE::"Insurance Journal Line");
                JnlLineDim.SetRange("Journal Template Name", "Journal Template Name");
                JnlLineDim.SetRange("Journal Batch Name", "Journal Batch Name");
                JnlLineDim.SetRange("Journal Line No.", "Line No.");
                JnlLineDim.SetRange("Allocation Line No.", 0);
                TempJnlLineDim.DeleteAll;
                InsuranceJnlPostLine.RunWithOutCheck(InsuranceJnlLine, TempJnlLineDim);
            until Next = 0;
            if InsuranceReg.Find('+')then;
            if InsuranceReg."No." <> InsuranceRegNo then InsuranceRegNo:=0;
            Init;
            // Update/delete lines
            if InsuranceRegNo <> 0 then begin
                if not RecordLevelLocking then begin
                    JnlLineDim.LockTable(true, true);
                    LockTable(true, true);
                end;
                InsuranceJnlLine2.CopyFilters(InsuranceJnlLine);
                InsuranceJnlLine2.SetFilter("Leave Calendar Code", '<>%1', '');
                if InsuranceJnlLine2.Find('+')then; // Remember the last line
                JnlLineDim.SetRange("Table ID", DATABASE::"Insurance Journal Line");
                JnlLineDim.CopyFilter("Journal Template Name", "Journal Template Name");
                JnlLineDim.CopyFilter("Journal Batch Name", "Journal Batch Name");
                JnlLineDim.SetRange("Allocation Line No.", 0);
                InsuranceJnlLine3.Copy(InsuranceJnlLine);
                if InsuranceJnlLine3.Find('-')then repeat JnlLineDim.SetRange("Journal Line No.", InsuranceJnlLine3."Line No.");
                        JnlLineDim.DeleteAll;
                        InsuranceJnlLine3.Delete;
                    until InsuranceJnlLine3.Next = 0;
                InsuranceJnlLine3.Reset;
                InsuranceJnlLine3.SetRange("Journal Template Name", "Journal Template Name");
                InsuranceJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
                if not InsuranceJnlLine3.Find('+')then if IncStr("Journal Batch Name") <> '' then begin
                        InsuranceJnlBatch.Get("Journal Template Name", "Journal Batch Name");
                        InsuranceJnlBatch.Delete;
                        InsuranceJnlBatch.Name:=IncStr("Journal Batch Name");
                        if InsuranceJnlBatch.Insert then;
                        "Journal Batch Name":=InsuranceJnlBatch.Name;
                    end;
                InsuranceJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
                if(InsuranceJnlBatch."No. Series" = '') and not InsuranceJnlLine3.Find('+')then begin
                    InsuranceJnlLine3.Init;
                    InsuranceJnlLine3."Journal Template Name":="Journal Template Name";
                    InsuranceJnlLine3."Journal Batch Name":="Journal Batch Name";
                    InsuranceJnlLine3."Line No.":=10000;
                    InsuranceJnlLine3.Insert;
                    InsuranceJnlLine3.SetUpNewLine(InsuranceJnlLine2);
                    InsuranceJnlLine3.Modify;
                end;
            end;
            if InsuranceJnlBatch."No. Series" <> '' then NoSeriesMgt.SaveNoSeries;
            if NoSeries.Find('-')then repeat Evaluate(PostingNoSeriesNo, NoSeries.Description);
                    NoSeriesMgt2[PostingNoSeriesNo].SaveNoSeries;
                until NoSeries.Next = 0;
            Commit;
            Clear(InsuranceJnlCheckLine);
            Clear(InsuranceJnlPostLine);
        end;
        UpdateAnalysisView.UpdateAll(0, true);
        Commit;
    end;
}
