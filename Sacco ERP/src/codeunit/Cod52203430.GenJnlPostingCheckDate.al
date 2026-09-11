codeunit 52203430 "Gen. Jnl.-Posting Check Date"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeGenJnlPostBatchRun', '', True, True)]
    procedure OnBeforeGenJnlPostBatchRun(var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        CheckUserPostingDates;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', True, True)]
    procedure OnBeforeCode(var GenJournalLine: Record "Gen. Journal Line"; var HideDialog: Boolean)
    begin
        CheckUserPostingDates;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Ext", 'OnBeforeGenJnlPostBatchRun', '', True, True)]
    procedure OnBeforeGenJnlPostBatchRun_Ext(var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        CheckUserPostingDates;
    end;
    local procedure CheckUserPostingDates()
    begin
    // If UserSetup.Get(UserId) then begin
    //     UserSetup.TestField("Allow Posting From");
    //     UserSetup.TestField("Allow Posting To");
    // end
    // else
    //     Error(StrSubstNo('%1 have have a setup, Please Contact Admin', UserId));
    end;
    var UserSetup: Record "User Setup";
}
