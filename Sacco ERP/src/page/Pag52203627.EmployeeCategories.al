page 52203627 "Employee Categories"
{
    PageType = List;
    SourceTable = "Hr Job Competencies";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Job ID"; Rec."Job ID")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
