pageextension 52204009 "Payment Journal CBS Ext." extends "Payment Journal"
{
    layout
    {
        // Add changes to page layout here
        addafter("Account No.")
        {
            field("Member Posting Type"; Rec."Product Posting Type")
            {
                ApplicationArea = Basic, Suite;
            }
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
            action("Update Lines")
            {
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                var
                    JournalLine: Record "Gen. Journal Line";
                    Vendor: Record Vendor;
                    ProductFactory: Record "Sacco Products";
                begin
                    JournalLine.Reset();
                    JournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    JournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    JournalLine.SetRange("Account Type", JournalLine."Account Type"::Vendor);
                    if JournalLine.FindSet() then begin
                        repeat
                            if Vendor.Get(JournalLine."Account No.") then begin
                                if ProductFactory.Get(Vendor."Product Code") then begin
                                    JournalLine."Product Posting Type" := ProductFactory."Product Posting Type";
                                    JournalLine.Modify();
                                end
                                else begin
                                    if ProductFactory.Get(Vendor."Vendor Posting Group") then begin
                                        JournalLine."Product Posting Type" := ProductFactory."Product Posting Type";
                                        JournalLine.Modify();
                                    end;
                                end;
                                if Vendor."Member No." <> '' then Vendor."Account Type" := Vendor."Account Type"::Sacco;
                                Vendor.Modify();
                            end;
                        until JournalLine.Next() = 0;
                        Message('Done');
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
}
