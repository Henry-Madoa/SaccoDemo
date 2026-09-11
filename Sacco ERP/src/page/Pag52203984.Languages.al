page 52203984 "&Languages"
{
    PageType = List;
    SourceTable = "&Languages";
    Caption = 'Languages';

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
