page 52203938 "Job Shortlisting Criteria"
{
    PageType = ListPart;
    SourceTable = "Job Shortlisting Criteria";
    Caption = 'Shortlisting Criteria';

    layout
    {
        area(content)
        {
            repeater(Control5)
            {
                field("Qualification Type"; Rec."Qualification Type")
                {
                    ApplicationArea = All;
                }
                field(Qualification; Rec."Qualification Code")
                {
                    ApplicationArea = All;
                }
                field(Score; Rec.Score)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
