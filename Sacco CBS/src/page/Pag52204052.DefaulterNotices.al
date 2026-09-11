page 52204052 "Defaulter Notices"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Defaulter Notice";
    CardPageId = "Defaulter Notice";
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Notice Date"; Rec."Notice Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("First Notice Sent On"; Rec."First Notice Sent On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Second Notice Sent On"; Rec."Second Notice Sent On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Third Notice Sent On"; Rec."Third Notice Sent On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
