page 52204193 "BCRQ Setup"
{
    PageType = List;
    SourceTable = "BCRQ Setup";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Global Editor"; Rec."Global Editor")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Partial Member Update"; Rec."Partial Member Update")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Can Rejoin Member"; Rec."Can Rejoin Member")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("MPOA Update"; Rec."MPOA Update")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Can Release Uncleared Funds"; Rec."Can Release Uncleared Funds")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
