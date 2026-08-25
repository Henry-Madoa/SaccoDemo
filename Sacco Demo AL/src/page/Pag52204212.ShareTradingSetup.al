page 52204212 "Share Trading Setup"
{
    PageType = List;
    SourceTable = "Share Trading Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = Not IsPublished;

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Base Price"; Rec."Base Price")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Published; Rec.Published)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Charges; Rec.Charges)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Clearing Account"; Rec."Clearing Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Holding Account"; Rec."Holding Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Value On Market"; Rec."Total Value On Market")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Shares On Market"; Rec."Shares On Market")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Reserve Price"; Rec."Reserve Price")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Share Life"; Rec."Share Life")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Tolerance Period"; Rec."Tolerance Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("On No Bid"; Rec."On No Bid")
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
            action(Publish)
            {
                ApplicationArea = Basic, Suite;
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    ShareTrading.PublishShareTradingSetup(Rec);
                    CurrPage.Update;
                end;
            }
            action("Take Down")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ShareTrading.TakeDownShareTradingSetup(Rec);
                    CurrPage.Update;
                end;
            }
            action(Checklist)
            {
                ApplicationArea = Basic, Suite;
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Share Trading Checklist Setup";
                RunPageLink = "Source Code" = FIELD("Document No.");
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        IsPublished := false;
        IsPublished := Rec.Published;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IsPublished := false;
        IsPublished := Rec.Published;
    end;

    var
        IsPublished: Boolean;
        ShareTrading: Codeunit "Share Trading Mgmt";
}
