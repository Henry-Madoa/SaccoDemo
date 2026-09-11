pageextension 52204011 Receipt extends Receipt
{
    layout
    {
        modify(ReceiptDetails)
        {
            Visible = ((Rec."Receipt Type" <> Rec."Receipt Type"::Member));
        }
        addafter("Receipt Type")
        {
            field("&Posting Date"; Rec."Posting Date")
            {
                ShowMandatory = true;
                ApplicationArea = Basic, Suite;
            }
            group(MemberDetails)
            {
                ShowCaption = false;
                Visible = Rec."Receipt Type" = Rec."Receipt Type"::Member;

                field("Member No."; Rec."Member No.")
                {
                    ShowMandatory = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        addbefore(Amount)
        {
            field("Received Amount"; Rec."Received Amount")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
        }
        addafter(ReceiptDetails)
        {
            part("MemberReceiptDetails"; "Member Receipt Lines")
            {
                Caption = 'Receipt Lines';
                Visible = Rec."Receipt Type" = Rec."Receipt Type"::Member;
                Editable = Rec.Status = Rec.Status::Open;
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("No.");
            }
        }
    }
    actions
    {
        modify(Print)
        {
            Visible = false;
        }
        modify(Post)
        {
            Visible = false;
        }
        modify("Send Approval Request")
        {
            trigger OnBeforeAction()
            begin
                Rec.OnBeforeSendForApproval;
            end;
        }
        addafter("Print")
        {
            action("&Print")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Visible = Rec.Posted;
                Image = Print;

                trigger OnAction()
                var
                    Receipt: Record "Receipt Header";
                begin
                    Receipt.Reset();
                    Receipt.SetRange("No.", Rec."No.");
                    if Receipt.FindFirst() then begin
                        if Receipt."Receipt Type" = Receipt."Receipt Type"::Member then
                            Report.Run(Report::"Member Cash Receipt", true, false, Receipt)
                        else
                            Report.Run(Report::"Cash Receipt", true, false, Receipt);
                    end;
                end;
            }
        }
        addafter(Post)
        {
            action("&Post")
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Visible = ((not Rec.Posted) and ((Rec.Status = Rec.Status::Approved) or PostingVisibility));
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Receipt: Record "Receipt Header";
                begin
                    if Confirm('Do you want to Post?') then begin
                        ReceiptManagement.PostReceipt(Rec);
                        Commit();
                        Rec.Reset();
                        Rec.SetRange("No.", Rec."No.");
                        if Rec.FindFirst() then begin
                            if Rec."Receipt Type" = Rec."Receipt Type"::Member then
                                Report.Run(Report::"Member Cash Receipt", true, false, Rec)
                            else
                                Report.Run(Report::"Cash Receipt", true, false, Rec);
                            CurrPage.Close();
                        end;
                    end
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        SetControlAppearance;
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance;
    end;

    local procedure SetControlAppearance()
    begin
        if Rec.Amount >= Rec."Approval Limit" then
            PostingVisibility := false
        else
            PostingVisibility := true;
    end;

    var
        PostingVisibility: Boolean;
        ReceiptManagement: Codeunit "CBS Cash Management";
}
