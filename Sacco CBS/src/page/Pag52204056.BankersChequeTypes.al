page 52204056 "Bankers Cheque Types"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Cheque Types";
    SourceTableView = where(Type=const("Bankers Cheque"));

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
                field("Transaction Nos."; Rec."Transaction Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Amount"; Rec."Maximum Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Clearing Account Type"; Rec."Clearing Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Clearing Account"; Rec."Clearing Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Clearing Charge"; Rec."Clearing Charge")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
