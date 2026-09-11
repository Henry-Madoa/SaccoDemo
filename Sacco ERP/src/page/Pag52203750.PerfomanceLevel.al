page 52203750 "Perfomance Level"
{
    PageType = List;
    SourceTable = "Appraisal Perfomance";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line Nos"; Rec."Line Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Perfomace Level"; Rec."Perfomace Level")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
