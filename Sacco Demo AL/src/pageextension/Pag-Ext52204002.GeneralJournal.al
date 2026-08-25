pageextension 52204002 "General Journal" extends "General Journal"
{
    layout
    {
        // Add changes to page layout here
        modify("Account No.")
        {
            trigger OnAfterValidate()
            begin
                LoanEditability := false;
                MemberPostingTypeEditability := false;
                Rec."Product Posting Type" := Rec."Product Posting Type"::" ";
                if Rec."Account Type" = Rec."Account Type"::Vendor then begin
                    if Vendor.Get(Rec."Account No.") then begin
                        Rec."Member No." := Vendor."Member No.";
                        Rec."Product Posting Type" := Vendor."Product Posting Type";
                        if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Loan Account" then begin
                            LoanEditability := true;
                            Rec."Product Posting Type" := Rec."Product Posting Type"::"Loan Account";
                        end
                        else
                            MemberPostingTypeEditability := true;
                    end;
                end;
            end;
        }
        modify("Document Type")
        {
            Visible = false;
        }
        modify("VAT Reporting Date")
        {
            Visible = false;
        }
        modify("Currency Code")
        {
            Visible = false;
        }
        modify("EU 3-Party Trade")
        {
            Visible = false;
        }
        modify("Gen. Posting Type")
        {
            Visible = false;
        }
        modify("Gen. Bus. Posting Group")
        {
            Visible = false;
        }
        modify("Gen. Prod. Posting Group")
        {
            Visible = false;
        }
        modify("Bal. Gen. Posting Type")
        {
            Visible = false;
        }
        modify("Bal. Gen. Bus. Posting Group")
        {
            Visible = false;
        }
        modify("Bal. Gen. Prod. Posting Group")
        {
            Visible = false;
        }
        modify("Deferral Code")
        {
            Visible = false;
        }
        modify(Correction)
        {
            Visible = false;
        }
        modify(Comment)
        {
            Visible = false;
        }
        modify(Amount)
        {
            Visible = false;
        }
        modify("Amount (LCY)")
        {
            Visible = false;
        }
        addafter(Amount)
        {
            field("&Debit Amount"; Rec."Debit Amount")
            {
                ApplicationArea = Basic, Suite;
            }
            field("&Credit Amount"; Rec."Credit Amount")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter(Description)
        {

            field("Loan No."; Rec."Loan No.")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
                Editable = LoanEditability;
            }
            field("Transaction Type"; Rec."Transaction Type")
            {
                ApplicationArea = Basic, Suite;
                Editable = Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account";
            }
        }
        addafter("Shortcut Dimension 2 Code")
        {
            field("Member No."; Rec."Member No.")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        // Add changes to page actions here
        addafter(Post)
        {
            action("Post Custom")
            {
                trigger OnAction()
                var
                    JournalMgt: Codeunit "Journal Management";
                    JournalLine: Record "Gen. Journal Line";
                    JnlPost: Codeunit "Gen. Jnl.-Post Line";
                begin
                    JournalLine.Reset();
                    JournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    JournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    if JournalLine.FindSet() then begin
                        repeat
                            JnlPost.Run(JournalLine);
                            JournalLine.Delete();
                            Commit();
                        until JournalLine.Next() = 0;
                    end;
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        if ObjUseretup.Get(UserId) then begin
            if not ObjUseretup."Can Use General Journal" then Error(PermError);
        end;
    end;

    var
        ObjUseretup: Record "User Setup";
        PermError: TextConst ENU = 'You do not have the permission to open this page. Please contact the system administrator.';
        Vendor: Record Vendor;
        LoanEditability: Boolean;
        MemberPostingTypeEditability: Boolean;
}
