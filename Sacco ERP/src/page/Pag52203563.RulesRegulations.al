page 52203563 "Rules & Regulations"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Rules & Regulations";

    layout
    {
        area(content)
        {
            repeater(Control8)
            {
                ShowCaption = false;

                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Rules & Regulations"; Rec."Rules & Regulations")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Link"; Rec."Document Link")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Language Code (Default)"; Rec."Language Code (Default)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Attachement; Rec.Attachement)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
