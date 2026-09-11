page 52203738 "Appraisal Approved List"
{
    CardPageID = "Appraisal Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Appraisal Header";
    SourceTableView = WHERE(Status=CONST("Overview Manager Level"), Sequence=filter(<>0));

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
            }
        }
    }
    trigger OnOpenPage()
    begin
    // UserSetup.GET(USERID);
    // IF NOT UserSetup."Is HR Admin" THEN BEGIN
    //  FILTERGROUP(2);
    //  SETRANGE("Employee No",UserSetup."Employee No.");
    //  FILTERGROUP(0);
    // end;
    end;
    var UserSetup: Record "User Setup";
}
