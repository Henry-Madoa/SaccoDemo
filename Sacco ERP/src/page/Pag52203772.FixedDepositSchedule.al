page 52203772 "Fixed Deposit Schedule"
{
    PageType = ListPart;
    SourceTable = "Fixed Deposit Schedule";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Investment No"; Rec."Investment No")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Actual Amount"; Rec."Actual Amount")
                {
                    Editable = Editx;
                    ApplicationArea = Basic, Suite;
                }
                field("Witholding Tax"; Rec."Witholding Tax")
                {
                    Editable = Editx;
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Actual Posting Date"; Rec."Actual Posting Date")
                {
                    Editable = Editx;
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("Line Functions")
            {
                action("Accrue Interest")
                {
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    begin
                        if FDHeader.Get(Rec."Investment No") then
                            if FDHeader."Marked for Liquidation" or FDHeader.Liquidated or (FDHeader.Status <> FDHeader.Status::Running) then //ERROR('You can not Post Accrual of this Document');
                                if not Confirm(StrSubstNo('Are you sure you want to Accrue Interest for %1 on %2', Rec."Investment No", Rec."No."), true) then exit;
                        Rec.Testfield("Actual Amount");
                        with Rec do begin
                            if (Rec."Entry Type" <> Rec."Entry Type"::"Payment Due") or Rec.Posted then // ERROR('You can not Accrue this Entry');
                                if UserPostingBatches.Get(UserId) then begin
                                    UserPostingBatches.TestField("Payment Jurnal");
                                    UserPostingBatches.TestField("Payment Journal Batch");
                                    JTemplate := UserPostingBatches."Payment Jurnal";
                                    JBatch := UserPostingBatches."Payment Journal Batch";
                                end;
                            HumanResourceMgmt.CreateGeneralJournalBatch(JTemplate, JBatch, false);
                            HumanResourceMgmt.DeleteGeneralJournalLines(JTemplate, JBatch);
                            if FDHeader.Get(Rec."Investment No") then begin
                                FDHeader.TestField("FD Certificate No.");
                                LineN := 1;
                                HumanResourceMgmt.CreateGnlJournalLineInv(JTemplate, JBatch, FDHeader."FD Certificate No.", LineN, GenJournalLine."Account Type"::"G/L Account", FDHeader."Interest Receivable Account", Rec."Actual Posting Date", Rec."Actual Amount", FDHeader."Global Dimension 1 Code", FDHeader."Global Dimension 2 Code", '', Rec."No." + ' ' + Rec.Description, 'EFT', '', GenJournalLine."Applies-to Doc. Type"::" ", '', 1, '', FDHeader."No.");
                                LineN := LineN + 1;
                                HumanResourceMgmt.CreateGnlJournalLineInv(JTemplate, JBatch, FDHeader."FD Certificate No.", LineN, GenJournalLine."Account Type"::"G/L Account", FDHeader."Interest Received Account", Rec."Actual Posting Date", -(Rec."Actual Amount" + Rec."Witholding Tax"), FDHeader."Global Dimension 1 Code", FDHeader."Global Dimension 2 Code", '', Rec."No." + ' ' + Rec.Description, 'EFT', '', GenJournalLine."Applies-to Doc. Type"::" ", '', 1, '', FDHeader."No.");
                                if Rec."Witholding Tax" <> 0.0 then begin
                                    LineN := LineN + 1;
                                    HumanResourceMgmt.CreateGnlJournalLineInv(JTemplate, JBatch, FDHeader."FD Certificate No.", LineN, GenJournalLine."Account Type"::"G/L Account", FDHeader."W/Tax Account", Rec."Actual Posting Date", Rec."Witholding Tax", FDHeader."Global Dimension 1 Code", FDHeader."Global Dimension 2 Code", '', Rec."No." + ' ' + Rec.Description, 'EFT', '', GenJournalLine."Applies-to Doc. Type"::" ", '', 1, '', FDHeader."No.");
                                end;
                            end;
                        end;
                        HumanResourceMgmt.PostGeneralJournalLines(JTemplate, JBatch);
                        GLEntry.Reset;
                        GLEntry.SetRange("Document No.", Rec."No.");
                        GLEntry.SetRange(Reversed, false);
                        if GLEntry.FindFirst then begin
                            Rec.Posted := true;
                            Rec."Posted By" := UserId;
                            Rec."Posted At" := Time;
                            Rec."Posted On" := WorkDate;
                            Rec.Modify(true);
                        end;
                        CurrPage.Close;
                    end;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        SetPosted;
    end;

    trigger OnOpenPage()
    begin
        SetPosted;
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        HumanResourceMgmt: Codeunit "Human Resource Management";
        UserPostingBatches: Record "User Posting Batches";
        JTemplate: Code[20];
        JBatch: Code[20];
        LineN: Integer;
        GenJournalLine: Record "Gen. Journal Line";
        FDHeader: Record "Fixed Deposit Header";
        GLEntry: Record "G/L Entry";
        Editx: Boolean;

    local procedure SetPosted()
    begin
        Editx := true;
        if Rec.Posted or (Rec."Entry Type" <> Rec."Entry Type"::"Interest Due") then Editx := false;
    end;
}
