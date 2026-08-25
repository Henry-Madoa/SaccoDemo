page 52204090 "Transaction Charges Setup"
{
    PageType = ListPart;
    SourceTable = "Transaction Charges Setup";
    SourceTableView = sorting(Priority) order(ascending);
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Post to Account Type"; Rec."Post to Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Post-to Account No."; Rec."Post-to Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Calculation Type"; Rec."Calculation Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Vendor One Charge"; Rec."Coop Charge")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("Calculation Scheme")
            {
                action("Rates Scheme")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = StepInto;
                    Ellipsis = true;
                    Scope = Repeater;
                    RunObject = page "Transaction Calc. Scheme";
                    RunPageLink = "Charge Code" = field(Code), "Source Code" = field("Transaction Code");
                }
            }
        }
    }
}
