codeunit 52203457 "HR Medical Jnl.-Post"
{
    TableNo = "Leave Journal Line";

    trigger OnRun()
    begin
        HRJournalLine.Copy(Rec);
        Code;
        Rec.Copy(HRJournalLine);
    end;
    var Text000: Label 'Do you want to post the journal lines?';
    Text001: Label 'There is nothing to post.';
    Text002: Label 'The journal lines were successfully posted.';
    Text003: Label 'The journal lines were successfully posted. You are now in the %1 journal.';
    HRJournalLineTemplate: Record "Leave Journal Template";
    HRJournalLine: Record "Leave Journal Line";
    HRJournalPostBatch: Codeunit "HR Leave Jnl.- Post Batch";
    TempJnlBatchName: Code[10];
    Text004: Label 'Since you are making a Negative Adjustment, "Number of Days" Should be Less Than Zero and not %1';
    local procedure "Code"()
    begin
        with HRJournalLine do begin
            HRJournalLineTemplate.Get("Journal Template Name");
            HRJournalLineTemplate.TestField("Force Posting Report", false);
            TempJnlBatchName:="Journal Batch Name";
            HRJournalPostBatch.Run(HRJournalLine);
            if "Line No." = 0 then Message(Text001)
            else if TempJnlBatchName = "Journal Batch Name" then begin
                    Message(Text002);
                    HRJournalLine.DeleteAll end
                else
                begin
                    Message(Text003, "Journal Batch Name");
                end;
            if not Find('=><') or (TempJnlBatchName <> "Journal Batch Name")then begin
                Reset;
                FilterGroup:=2;
                SetRange("Journal Template Name", "Journal Template Name");
                SetRange("Journal Batch Name", "Journal Batch Name");
                FilterGroup:=0;
                "Line No.":=1;
            end;
        end;
    end;
}
