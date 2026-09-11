page 52203537 "Job Competencies"
{
    PageType = ListPart;
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
                field("Competence Description"; Rec."Competence Description")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
