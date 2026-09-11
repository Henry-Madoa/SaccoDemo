page 52203916 "Qualification Criteria"
{
    PageType = ListPart;
    SourceTable = "Qualification Criteria";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Criteria; rec.Criteria)
                {
                    Applicationarea = all;
                }
                field("Start Date"; Rec."Start Date")
                {
                    Applicationarea = all;
                }
                field("End Date"; Rec."End Date")
                {
                    Applicationarea = all;
                }
                field(Gender; rec.Gender)
                {
                    Applicationarea = all;
                }
                field("Period in years"; Rec."Period in years")
                {
                    Applicationarea = all;
                }
                field("Prefered Sector"; Rec."Prefered Sector")
                {
                    Applicationarea = all;
                }
            }
        }
    }
    actions
    {
    }
}
