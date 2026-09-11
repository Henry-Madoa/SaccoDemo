page 52203438 "HR Leave Calendar Lines"
{
    PageType = ListPart;
    SourceTable = "Leave Calendar Lines";

    layout
    {
        area(content)
        {
            repeater(Control1102755000)
            {
                Editable = true;
                ShowCaption = false;

                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Day; Rec.Day)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Non Working"; Rec."Non Working")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Reason; Rec.Reason)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
