page 52203678 "Proffesional Examiners"
{
    PageType = List;
    SourceTable = "Professional Examiners";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Professional Examiner"; Rec."Professional Examiner")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
