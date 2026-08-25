page 52204046 "Collateral Linked Loans"
{
    PageType = Listpart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Collateral Linked Loans";
    ModifyAllowed = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Loan No."; Rec."Loan No.")
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
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Details"; Rec."Product Details")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Balance"; Rec."Current Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
