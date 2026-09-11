page 52203591 "Contract Commitments"
{
    Caption = 'Contractual Commitments';
    CardPageID = "Contract Commitment Header";
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Contract Commitment Header";
    SourceTableView = WHERE(Commited=CONST(false));

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Type of Commitment"; Rec."Type of Commitment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Commited; Rec.Commited)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Narration; Rec.Narration)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(Uncommit)
            {
                ApplicationArea = Basic, Suite;
                Image = Undo;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = Rec.Commited;

                trigger OnAction()
                begin
                    Rec.CalcFields("Total Amount");
                    if Rec."Total Amount" = 0 then Error('There is nothing to uncommit.');
                    if Confirm('Are you sure you want to uncommit the following funds?', false) = true then begin
                        Committments.Reset;
                        Committments.SetRange("Commitment No", Rec."No.");
                        Committments.DeleteAll;
                        Rec.Commited:=false;
                        Rec.Modify;
                        Message('Items uncommitted Successfully');
                    end;
                end;
            }
            action("Commit ")
            {
                ApplicationArea = Basic, Suite;
                Image = Apply;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = NOT Rec.Commited;

                trigger OnAction()
                begin
                    Rec.CalcFields("Total Amount");
                    if Rec."Total Amount" = 0 then Error('There is nothing to commit.');
                    if Confirm('Are you sure you want to commit the following funds?', false) = true then begin
                        Lines.Reset;
                        Lines.SetRange(Lines."No.", Rec."No.");
                        if Lines.FindFirst then begin
                            if Committments.FindLast then EntryNo:=Committments."Entry No";
                            repeat Committments.Init;
                                Committments."Commitment No":=Rec."No.";
                                Committments."Commitment Type":=Committments."Commitment Type"::Committed;
                                if Lines."Commitment Date" = 0D then Error('Please enter the commitment date');
                                Committments."Commitment Date":=Lines."Commitment Date";
                                Committments."Global Dimension 1":=Lines."Global Dimension 1 Code";
                                Committments."Global Dimension 2":=Lines."Global Dimension 2 Code";
                                Committments."Committed Amount":=Lines.Amount;
                                GenLedSetup.Get;
                                GLAccount.SetFilter(GLAccount."Budget Filter", GenLedSetup."Current Budget");
                                GLAccount.SetRange(GLAccount."No.", Lines."GL Account No.");
                                GLAccount.CalcFields(GLAccount."Budgeted Amount", GLAccount."Net Change");
                                //Get budget amount avaliable
                                GLAccount.SetRange(GLAccount."Date Filter", GenLedSetup."Current Budget Start Date", GenLedSetup."Current Budget End Date");
                                if GLAccount.Find('-')then begin
                                    GLAccount.CalcFields(GLAccount."Budgeted Amount", GLAccount."Net Change");
                                    BudgetAmount:=GLAccount."Budgeted Amount";
                                    Expenses:=GLAccount."Net Change";
                                    BudgetAvailable:=GLAccount."Budgeted Amount" - GLAccount."Net Change";
                                end;
                                //Get committed Amount
                                /*CommittedAmount:=0;
                                CommitmentEntries.RESET;
                                CommitmentEntries.SETCURRENTKEY(CommitmentEntries.Account);
                                CommitmentEntries.SETRANGE(CommitmentEntries.Account,Lines."GL Account No.");
                                CommitmentEntries.SETRANGE(CommitmentEntries."Commitment Date",GenLedSetup."Current Budget Start Date",Lines."Commitment Date");
                                CommitmentEntries.CALCSUMS(CommitmentEntries."Committed Amount");
                                CommittedAmount:=CommitmentEntries."Committed Amount";
                                IF LineCommitted("No.",Lines."No.",Lines."Line No.")THEN
                                   MESSAGE('Line No %1 has been commited',Lines."Line No.")
                                ELSE                            IF CommittedAmount+Lines."Line Amount">BudgetAvailable THEN
                                  IF (BudgetAvailable < 0) OR (BudgetAvailable = 0) THEN
                                    ERROR('There is no budget available for %1',Lines.Description)
                                   ELSE
                                   ERROR('You have Exceeded Budget for G/L Account No %1 By %2 Budget Available %3 CommittedAmount %4'
                                   ,Committments.Account,
                                   ABS(BudgetAvailable-(CommittedAmount+Lines."Line Amount")),BudgetAvailable,CommittedAmount);*/
                                Committments.User:=UserId;
                                Committments."Document No":=Rec."No.";
                                Committments."No.":=Lines."No.";
                                Committments."Line No.":=Lines."Line No.";
                                Committments.Account:=Lines."GL Account No.";
                                Committments."Account Type":=Committments."Account Type"::"G/L Account";
                                Committments.Validate("Account No.", Lines."GL Account No.");
                                Committments."Account Name":=Lines."Account Name";
                                Committments.Description:=Lines.Description;
                                EntryNo:=EntryNo + 1;
                                Committments."Entry No":=EntryNo;
                                Committments.Insert;
                            until Lines.Next = 0;
                        end;
                        Rec.Commited:=true;
                        Rec.Modify;
                        Message('Items Committed Successfully');
                    end;
                end;
            }
        }
    }
    var Committments: Record "Commitment Entries";
    Lines: Record "Contract Commitment Lines";
    EntryNo: Integer;
    GenLedSetup: Record "General Ledger Setup";
    GLAccount: Record "G/L Account";
    BudgetAmount: Decimal;
    Expenses: Decimal;
    BudgetAvailable: Decimal;
    CommittedAmount: Decimal;
}
