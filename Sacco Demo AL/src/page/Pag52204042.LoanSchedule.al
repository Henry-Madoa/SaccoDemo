page 52204042 "Loan Schedule"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Schedule";
    InsertAllowed = false;
    Editable = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Monthly Repayment"; Rec."Monthly Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principal Repayment"; Rec."Principal Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Repayment"; Rec."Interest Repayment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Date"; Rec."Expected Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
