codeunit 52203452 "HR Leave Jnl.- Post Batch"
{
    TableNo = "Leave Journal Line";

    trigger OnRun()
    begin
        LeaveJnlLine.Copy(Rec);
        Code;
    //Rec:= InsuranceJnlLine;
    end;
    var Text000: Label 'cannot exceed %1 characters';
    Text001: Label 'Journal Batch Name    #1##########\\';
    Text002: Label 'Checking lines        #2######\';
    Text003: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@';
    Text004: Label 'A maximum of %1 posting number series can be used in each journal.';
    LeaveJnlLine: Record "Leave Journal Line";
    LeaveJnlTempl: Record "Leave Journal Template";
    LeaveJnlBatch: Record "Leave Journal Batch";
    LeaveReg: Record "Leave Register";
    LvCoverageLedgEntry: Record "Leave Ledger Entries";
    LeaveJnlLine2: Record "Leave Journal Line";
    LeaveJnlLine3: Record "Leave Journal Line";
    NoSeries: Record "No. Series" temporary;
    LeaveJnlPostLine: Codeunit "HR Leave Jnl.- Post Line";
    LeaveJnlCheckLine: Codeunit "HR Leave Jnl.- Check Line";
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
        with LeaveJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            if RecordLevelLocking then LockTable;
            LeaveJnlTempl.Get("Journal Template Name");
            LeaveJnlBatch.Get("Journal Template Name", "Journal Batch Name");
            if StrLen(IncStr(LeaveJnlBatch.Name)) > MaxStrLen(LeaveJnlBatch.Name)then LeaveJnlBatch.FieldError(Name, StrSubstNo(Text000, MaxStrLen(LeaveJnlBatch.Name)));
            if not Find('=><')then begin
                Commit;
                "Line No.":=0;
                exit;
            end;
            Window.Open(Text001 + Text002 + Text003);
            Window.Update(1, "Journal Batch Name");
            LineCount:=0;
            StartLineNo:="Line No.";
            repeat LineCount:=LineCount + 1;
                Window.Update(2, LineCount);
                JnlLineDim.SetRange("Table ID", DATABASE::"Insurance Journal Line");
                JnlLineDim.SetRange("Journal Template Name", "Journal Template Name");
                JnlLineDim.SetRange("Journal Batch Name", "Journal Batch Name");
                JnlLineDim.SetRange("Journal Line No.", "Line No.");
                JnlLineDim.SetRange("Allocation Line No.", 0);
                TempJnlLineDim.DeleteAll;
                LeaveJnlCheckLine.RunCheck(LeaveJnlLine, TempJnlLineDim);
                if Next = 0 then Find('-');
            until "Line No." = StartLineNo;
            NoOfRecords:=LineCount; //LedgEntryDim.LOCKTABLE;
            LvCoverageLedgEntry.LockTable;
            if RecordLevelLocking then if LvCoverageLedgEntry.Find('+')then;
            LeaveReg.LockTable;
            if LeaveReg.Find('+')then InsuranceRegNo:=LeaveReg."No." + 1
            else
                InsuranceRegNo:=1; // Post lines
            LineCount:=0;
            LastDocNo:='';
            LastDocNo2:='';
            LastPostedDocNo:='';
            Find('-');
            repeat LineCount:=LineCount + 1;
                Window.Update(3, LineCount);
                Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
                if not("Leave Calendar Code" = '') and (LeaveJnlBatch."No. Series" <> '') and ("Document No." <> LastDocNo2)then TestField("Document No.", NoSeriesMgt.GetNextNo(LeaveJnlBatch."No. Series", "Posting Date", false));
                LastDocNo2:="Document No.";
                if "Posting No. Series" = '' then "Posting No. Series":=LeaveJnlBatch."No. Series"
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
                LeaveJnlPostLine.RunWithOutCheck(LeaveJnlLine, TempJnlLineDim);
            until Next = 0;
            if LeaveReg.Find('+')then;
            if LeaveReg."No." <> InsuranceRegNo then InsuranceRegNo:=0;
            Init;
            // Update/delete lines
            if InsuranceRegNo <> 0 then begin
                if not RecordLevelLocking then begin
                    JnlLineDim.LockTable(true, true);
                    LockTable(true, true);
                end;
                LeaveJnlLine2.CopyFilters(LeaveJnlLine);
                LeaveJnlLine2.SetFilter("Leave Calendar Code", '<>%1', '');
                if LeaveJnlLine2.Find('+')then; // Remember the last line
                JnlLineDim.SetRange("Table ID", DATABASE::"Insurance Journal Line");
                JnlLineDim.CopyFilter("Journal Template Name", "Journal Template Name");
                JnlLineDim.CopyFilter("Journal Batch Name", "Journal Batch Name");
                JnlLineDim.SetRange("Allocation Line No.", 0);
                LeaveJnlLine3.Copy(LeaveJnlLine);
                if LeaveJnlLine3.Find('-')then repeat JnlLineDim.SetRange("Journal Line No.", LeaveJnlLine3."Line No.");
                        JnlLineDim.DeleteAll;
                        LeaveJnlLine3.Delete;
                    until LeaveJnlLine3.Next = 0;
                LeaveJnlLine3.Reset;
                LeaveJnlLine3.SetRange("Journal Template Name", "Journal Template Name");
                LeaveJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
                if not LeaveJnlLine3.Find('+')then if IncStr("Journal Batch Name") <> '' then begin
                        LeaveJnlBatch.Get("Journal Template Name", "Journal Batch Name");
                        LeaveJnlBatch.Delete;
                        LeaveJnlBatch.Name:=IncStr("Journal Batch Name");
                        if LeaveJnlBatch.Insert then;
                        "Journal Batch Name":=LeaveJnlBatch.Name;
                    end;
                LeaveJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
                if(LeaveJnlBatch."No. Series" = '') and not LeaveJnlLine3.Find('+')then begin
                    LeaveJnlLine3.Init;
                    LeaveJnlLine3."Journal Template Name":="Journal Template Name";
                    LeaveJnlLine3."Journal Batch Name":="Journal Batch Name";
                    LeaveJnlLine3."Line No.":=10000;
                    LeaveJnlLine3.Insert;
                    LeaveJnlLine3.SetUpNewLine(LeaveJnlLine2);
                    LeaveJnlLine3.Modify;
                end;
            end;
            if LeaveJnlBatch."No. Series" <> '' then NoSeriesMgt.SaveNoSeries;
            if NoSeries.Find('-')then repeat Evaluate(PostingNoSeriesNo, NoSeries.Description);
                    NoSeriesMgt2[PostingNoSeriesNo].SaveNoSeries;
                until NoSeries.Next = 0;
            Commit;
            Clear(LeaveJnlCheckLine);
            Clear(LeaveJnlPostLine);
        end;
        UpdateAnalysisView.UpdateAll(0, true);
        Commit;
    end;
}
