page 52203445 "HR Non Working Days & Dates"
{
    Caption = 'HR Non Working Dates';
    PageType = ListPart;
    SourceTable = "Non Working Days & Dates";

    layout
    {
        area(content)
        {
            repeater(Control1102755000)
            {
                ShowCaption = false;

                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Reason; Rec.Reason)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Recurring; Rec.Recurring)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
