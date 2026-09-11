page 52203488 "Leave Recalls"
{
    CardPageID = "Leave Recall";
    Editable = true;
    PageType = List;
    SourceTable = "Leave Recall";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
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
                field("Days Applied"; Rec."Days Applied")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave No.To Recall"; Rec."Leave No.To Recall")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Days To Recall"; Rec."Days To Recall")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
    /*UserSetup.GET(USERID);
            IF NOT UserSetup."Is Global Admin" THEN BEGIN
              FILTERGROUP(2);
              SETRANGE("Employee No",UserSetup."Employee No.");
              FILTERGROUP(0);
            end;*/
    end;
    var Employee: Record Employee;
    UserSetup: Record "User Setup";
    "--Philip": Integer;
}
