page 52204213 "Share Floating"
{
    PageType = Card;
    SourceTable = "Share Floating";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = NOT IsPublished;

                field("Document No."; Rec."Document No")
                {
                    Editable = false;
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
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Share Type"; Rec."Share Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No."; Rec."Account No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Reserve Price"; Rec."Reserve Price")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Par Value"; Rec."Par Value")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Total Shares"; Rec."Total Shares")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Acceptable Price"; Rec."Minimum Acceptable Price")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Shares to Float"; Rec."Shares to Float")
                {
                    Editable = NOT IsFul;
                }
                field("Floated Value"; Rec."Floated Value")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Current Balance"; Rec."Current Balance")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Bid Price"; Rec."Maximum Bid Price")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Share Life"; Rec."Share Life")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("On No Bid"; Rec."On No Bid")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Published On"; Rec."Published On")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field(Published; Rec.Published)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Exiry Date"; Rec."Exiry Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Archived; Rec.Archived)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Payment Receipt Information")
            {
                Editable = AcceptingPayment;

                field("Payment Due Date"; Rec."Payment Due Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Purchase Date"; Rec."Purchase Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Tolerance Period"; Rec."Tolerance Period")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
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
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Proceeds Account"; Rec."Proceeds Account")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control13; "Share Floating Lines")
            {
                Visible = false;
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
                    Rec.TestField("Shares to Float");
                    Rec.TestField("Minimum Acceptable Price");
                    if CONFIRM('Do you want to Publish Sale?') then begin
                        ShareTradingMgmt.PublishSale(Rec);
                        CurrPage.Close;
                    end;
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
        IsFul := (Rec."Float Type" = Rec."Float Type"::Full);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IsPublished := false;
        IsPublished := Rec.Published;
        AcceptingPayment := false;
        AcceptingPayment := Rec.Awarded;
        IsFul := (Rec."Float Type" = Rec."Float Type"::Full);
    end;

    var
        ShareTradingMgmt: Codeunit "Share Trading Mgmt";
        IsPublished: Boolean;
        AcceptingPayment: Boolean;
        IsFul: Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
}
