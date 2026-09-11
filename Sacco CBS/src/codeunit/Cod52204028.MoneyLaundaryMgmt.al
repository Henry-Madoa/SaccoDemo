codeunit 52204028 "Money Laundary Mgmt."
{
    var
        UnclearedEffect: Record "Uncleared Funds";
        SaccoSetup: Record "General Ledger Setup";

    procedure PostMoneyLaundary(MoneyLaundaryCheck: Record "Money Laundary Check")
    begin
        if Confirm(StrSubstNo('You are about to Cleared Laundary Check Doc No. %1, Do you wish to continue?', MoneyLaundaryCheck."No.")) then begin
            if UnclearedEffect.Get(MoneyLaundaryCheck."Uncleared Funds Entry No.") then begin
                UnclearedEffect.Cleared := true;
                UnclearedEffect."Cleared By" := UserId;
                UnclearedEffect."Cleared On" := CurrentDateTime;
                UnclearedEffect.Modify(true);
                MoneyLaundaryCheck."Cleared By" := UserId;
                MoneyLaundaryCheck."Cleared On" := CurrentDateTime;
                MoneyLaundaryCheck.Cleared := true;
                MoneyLaundaryCheck.Modify(true);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertDtldVendLedgEntry', '', True, True)]
    procedure OnAfterInsertDtldVendLedgEntry(GenJournalLine: Record "Gen. Journal Line"; var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry")
    begin
        SaccoSetup.Get;
        if SaccoSetup."Money Laundary Limit" <> 0 then begin
            if ((GenJournalLine."Product Posting Type" = GenJournalLine."Product Posting Type"::"Withdrawable Deposit") and ((SaccoSetup."Money Laundary Limit" - GenJournalLine."Credit Amount") <= 0)) then begin
                UnclearedEffect.Init();
                UnclearedEffect."Entry No" := UnclearedEffect.GetLastEntryNo + 1;
                UnclearedEffect.Validate("Member No", GenJournalLine."Member No.");
                UnclearedEffect."Document No" := GenJournalLine."Document No.";
                UnclearedEffect.Amount := -GenJournalLine.Amount;
                UnclearedEffect."Account No" := GenJournalLine."Account No.";
                UnclearedEffect."Money Laundary Check" := true;
                UnclearedEffect."Created By" := UserId;
                UnclearedEffect."Created On" := CurrentDateTime;
                UnclearedEffect.Insert(true);
            end;
        end;
    end;
}
