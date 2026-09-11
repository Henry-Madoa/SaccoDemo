page 52203584 "Service Category"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Service Category";
    DataCaptionFields = Code, Description;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Category Code"; Rec.Code)
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
