page 52203731 "Appraisal List Score Acceptanc"
{
    CardPageID = "Appraisal Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Appraisal Header";
    SourceTableView = WHERE("Employee User Id"=CONST('2'), Status=CONST("Agreement Level"));

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
                field("Function/Team"; Rec."Function/Team")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal Calendar"; Rec."Calendar Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        UserSetup.Get(UserId);
        if not UserSetup."HR Admin" then begin
            Rec.FilterGroup(2);
            Rec.SetRange("Employee No", UserSetup."Employee No.");
            Rec.FilterGroup(0);
        end;
    end;
    var UserSetup: Record "User Setup";
}
