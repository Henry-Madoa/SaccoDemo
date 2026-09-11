page 52204255 "Storage Types"
{
    CardPageID = "Storage Type Header";
    PageType = List;
    SourceTable = "Storage Types";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
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
