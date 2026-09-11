pageextension 52204013 "Payment Voucher" extends "Payment Voucher"
{
    layout
    {
        addafter("Payment Type")
        {
            group(EFTVisibility)
            {
                ShowCaption = false;
                Visible = Rec."Payment Type" = Rec."Payment Type"::"EFT Loan Payment";

                field("Clearing Date"; Rec."Clearing Date")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("EFT Charges"; Rec."EFT Charges")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
            }
            group("RTGS/SWIFT")
            {
                ShowCaption = false;
                Visible = Rec."Payment Type" = Rec."Payment Type"::"RTGS/SWIFT";

                field("Charge Code"; Rec."Charge Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
            }
        }
        addbefore(Description)
        {
            group(MemberDetails)
            {
                Visible = ((Rec."Payment Type" = Rec."Payment Type"::"Member Payment") or (Rec."Payment Type" = Rec."Payment Type"::"RTGS/SWIFT") or (Rec."Payment Type" = Rec."Payment Type"::"Loan Payment") or (Rec."Payment Type" = Rec."Payment Type"::"Member Exit"));
                ShowCaption = false;

                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("&Charge Code"; Rec."Charge Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        addbefore("Total Amount")
        {
            group("AvailableBalance")
            {
                ShowCaption = false;
                Visible = ((Rec."Payment Type" = Rec."Payment Type"::"Member Payment") or (Rec."Payment Type" = Rec."Payment Type"::"RTGS/SWIFT") or (Rec."Payment Type" = Rec."Payment Type"::"Loan Payment") or (Rec."Payment Type" = Rec."Payment Type"::"Member Exit"));
                field("Available Balance"; Rec."Available Balance")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
            }
        }
        addbefore("Paying Details")
        {
            part(Control1; "Payment EFT Charges")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("No.");
                Editable = Rec.Status = Rec.Status::Open;
                Visible = Rec."Payment Type" = Rec."Payment Type"::"EFT Loan Payment";
            }
        }
        addafter(Control4)
        {
            part(Control5; "Loans Voucher Lines")
            {
                Visible = Rec."Payment Type" = Rec."Payment Type"::"Loan Payment";
                Editable = ((Rec.Posted = false) and ((Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::Approved)));
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("No.");
                UpdatePropagation = Both;
            }
        }
        modify(Control4)
        {
            Visible = Rec."Payment Type" <> Rec."Payment Type"::"Loan Payment";
        }
    }
    actions
    {
        modify(Post)
        {
            Visible = false;
        }
        addafter(Post)
        {
            action("&Post")
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Approved) and (Rec.Posted = false));

                trigger OnAction()
                var
                    CashMgmt: Codeunit "CBS Cash Management";
                    CommunicationMgmt: Codeunit "Communications Mgmt";
                begin
                    CashMgmt.PostPaymentVoucher(Rec);
                end;
            }
        }
    }
}
