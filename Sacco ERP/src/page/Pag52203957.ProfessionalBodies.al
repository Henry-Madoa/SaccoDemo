page 52203957 "Professional Bodies"
{
    PageType = List;
    SourceTable = "Professional Bodies";

    layout
    {
        area(content)
        {
            repeater(Control6)
            {
                ShowCaption = false;

                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
