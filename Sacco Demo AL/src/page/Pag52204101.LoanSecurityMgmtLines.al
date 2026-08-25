page 52204101 "Loan Security Mgmt Lines"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Security Mgmt Lines";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No"; Rec."Security Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Security Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Description"; Rec."Product Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Principal"; Rec."Loan Principal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Balance"; Rec."Loan Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Intial Guaranteed"; Rec."Intial Guaranteed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Outstanding Guaranteed"; Rec."Outstanding Guaranteed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Substitution; Rec.Substitution)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Release; Rec.Release)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("No."; Rec."No.")
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
            group(Replacements)
            {
                action("Replace With")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Loan Security Mgmt Det. Lines";
                    RunPageLink = "No." = field("No."), "Line No" = field("Line No");
                }
            }
        }
    }
}
