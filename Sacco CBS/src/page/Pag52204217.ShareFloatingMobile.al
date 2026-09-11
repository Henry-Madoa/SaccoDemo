page 52204217 "Share Floating Mobile"
{
    PageType = Card;
    SourceTable = "Share Floating";
    SourceTableView = WHERE(Archived = CONST(false), Published = CONST(true));

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = NOT IsPublished;

                field("Document No."; Rec."Document No")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Float Type"; Rec."Float Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Share Type"; Rec."Share Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No."; Rec."Account No.")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Reserve Price"; Rec."Reserve Price")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Par Value"; Rec."Par Value")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Total Shares"; Rec."Total Shares")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Acceptable Price"; Rec."Minimum Acceptable Price")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Shares to Float"; Rec."Shares to Float")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Balance"; Rec."Current Balance")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Bid Price"; Rec."Maximum Bid Price")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Share Life"; Rec."Share Life")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("On No Bid"; Rec."On No Bid")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Published On"; Rec."Published On")
                {
                    Editable = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Exiry Date"; Rec."Exiry Date")
                {
                    Editable = true;
                }
            }
            group("Payment Receipt Information")
            {
                Editable = AcceptingPayment;

                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Account No."; Rec."Payment Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("External Refrence No."; Rec."External Refrence No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Date"; Rec."Payment Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Amount"; Rec."Payment Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Proceeds Account"; Rec."Proceeds Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control13; "Share Floating Lines")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document No." = FIELD("Document No");
            }
        }
        area(factboxes)
        {
            part(Control21; "Vendor Statistics FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("Account No.");
            }
            part(Control23; "Member Profile Picture")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("Member No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Publish Sale")
            {
                ApplicationArea = Basic, Suite;
                Image = ViewPostedOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if CONFIRM('Do you want to Publish Sale?') then ShareTradingMgmt.PublishSale(Rec);
                    CurrPage.UPDATE;
                end;
            }
            action("Analyze Bids")
            {
                ApplicationArea = Basic, Suite;
                Image = Aging;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ShareTradingMgmt.AnalyseShareTrade(Rec);
                    CurrPage.UPDATE;
                end;
            }
            action("Notify Award")
            {
                ApplicationArea = Basic, Suite;
                Image = SendEmailPDF;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if CONFIRM('Do you want to Notify Winning Bid Member?') then ShareTradingMgmt.NotifyAward(Rec);
                end;
            }
            action("Post Purchase")
            {
                ApplicationArea = Basic, Suite;
                Image = PostInventoryToGL;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if CONFIRM('Do you want to Post Purchase?') then ShareTradingMgmt.PostPurchase(Rec);
                    CurrPage.UPDATE;
                end;
            }
            action("Transfer Shares")
            {
                trigger OnAction()
                begin
                    ShareTradingMgmt.TransferShares(Rec);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        IsPublished := false;
        IsPublished := Rec.Published;
        AcceptingPayment := false;
        AcceptingPayment := Rec.Awarded;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IsPublished := false;
        IsPublished := Rec.Published;
        AcceptingPayment := false;
        AcceptingPayment := Rec.Awarded;
    end;

    var
        ShareTradingMgmt: Codeunit "Share Trading Mgmt";
        IsPublished: Boolean;
        AcceptingPayment: Boolean;
}
