page 52204188 "Loan Documents"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Appraisal Documents";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document Description"; Rec."Document Description")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
