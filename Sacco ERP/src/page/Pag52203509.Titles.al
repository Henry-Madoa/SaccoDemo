page 52203509 "Titles"
{
    PageType = List;
    SourceTable = Title;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = All;
                }
                field(Visible; Rec.Visible)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
