page 52204120 "Checkoff Variation"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Checkoff Variation Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = Rec.Status = Rec.Status::New;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Lines; "Checkoff Variation Lines")
            {
                Editable = (Rec.Status = Rec.Status::New);
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("No.");
            }
            group("Audit Trail")
            {
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Post Variation")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Post;
                Visible = ((Rec.Status = Rec.Status::Submitted) and not Rec.Processed);

                trigger OnAction()
                begin
                    if Confirm('Do you want to Post') then begin
                        LoansMGT.PostVariation(Rec."No.");
                        CurrPage.Close();
                    end;
                end;
            }
            action(Submit)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = PostedReceipt;
                Visible = Rec.Status = Rec.Status::New;

                trigger OnAction()
                begin
                    if Confirm('Do you want to Submit') then begin
                        Rec.Status := Rec.Status::Submitted;
                        Rec.Modify(true);
                        CurrPage.Close();
                    end;
                end;
            }
        }
    }
    var
        LoansMGT: Codeunit "Loans Management";
        isCoreBankingSource: Boolean;

    trigger OnOpenPage()
    begin
        isCoreBankingSource := (Rec."Source Type" = Rec."Source Type"::"Core Banking");
    end;
}
