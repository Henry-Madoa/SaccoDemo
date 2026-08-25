page 52204225 "Sacco Lookup Values"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Sacco Lookup Values";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
