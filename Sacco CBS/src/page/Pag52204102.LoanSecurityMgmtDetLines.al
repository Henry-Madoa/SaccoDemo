page 52204102 "Loan Security Mgmt Det. Lines"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Security Mgmt Det. Lines";

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
                field(Line_no; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(Entry_no; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Security Type"; Rec."Security Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Security Code"; Rec."Security Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Security Name"; Rec."Security Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Qualified Guarantee"; Rec."Qualified Guarantee")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Self Guarantee"; Rec."Self Guarantee")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Original Amount"; Rec."Original Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Propoation Remaining"; Rec."Propoation Remaining")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Guarantee Amount"; Rec."Guarantee Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
