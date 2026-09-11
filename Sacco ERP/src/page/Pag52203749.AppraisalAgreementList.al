page 52203749 "Appraisal Agreement List"
{
    CardPageID = "Appraisal Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Appraisal Header";
    SourceTableView = WHERE(Status=CONST("Agreement Level"), Sequence=filter(<>0));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Appraisal No"; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Level/Grade"; Rec."Level/Grade")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal Calendar"; Rec."Calendar Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal Start Date"; Rec."Appraisal Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal End Date"; Rec."Appraisal End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Supervisor No"; Rec."Supervisor No")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    var UserSetup: Record "User Setup";
}
