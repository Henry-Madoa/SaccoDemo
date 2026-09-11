page 52203764 "User Posting Batches"
{
    PageType = List;
    SourceTable = "User Posting Batches";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(User; Rec.User)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("General Jounral"; Rec."General Jounral")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("General Journal Batch"; Rec."General Journal Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Jurnal"; Rec."Payment Jurnal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Journal Batch"; Rec."Payment Journal Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Receipt Journal"; Rec."Receipt Journal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Receipt Journal Batch"; Rec."Receipt Journal Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Item Journal"; Rec."Item Journal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Item Journal Batch"; Rec."Item Journal Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transfer Journal"; Rec."Transfer Journal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transfer Journal Batch"; Rec."Transfer Journal Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
