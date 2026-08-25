page 52204133 "Employer Stations"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Employer Stations";

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
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
