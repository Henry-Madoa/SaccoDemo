page 52204200 "Paybill Keywords"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Paybill Keywords";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Kewyword Code"; Rec."Kewyword Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Posting Type"; Rec."Product Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
